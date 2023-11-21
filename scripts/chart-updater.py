import argparse
import logging
import os
import re
import requests
import json
import yaml
from semver.version import Version

logger = logging.getLogger("chart-updater")


def str_presenter(dumper, data):
    if data.count("\n") > 0:  # check for multiline string
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


yaml.add_representer(str, str_presenter)

BASEVERSION = r"""
                  ^
                  (?:(?P<prefix>[a-zA-Z-]*)-)?
                  (?P<major>0|[1-9]\d*)
                  (?:
                    \.
                    (?P<minor>0|[1-9]\d*)
                    (?:
                        \.
                        (?P<patch>0|[1-9]\d*)
                    )?
                  )?
                  (?:-(?P<prerelease>
                      (?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)
                      (?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*
                  ))?
                  (?:\+(?P<build>
                    [0-9a-zA-Z-]+
                    (?:\.[0-9a-zA-Z-]+)*
                  ))?
                  $
               """


def main():
    args = get_args()

    if args["log"]:
        logging.basicConfig(filename=args["log_file"], level=args["log_level"])

    if args["action"] == "update":
        update_chart(**args)
    elif args["action"] == "coerce":
        coerce_tag(**args)


def get_args():
    parser = argparse.ArgumentParser(prog="chart-updater")

    parser.add_argument("--log", action="store_true", help="enable logging")
    levels = ("DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL")
    parser.add_argument(
        "--log-level", choices=levels, default="INFO", help="logging level"
    )
    parser.add_argument("--log-file", help="file to write logs")

    subparsers = parser.add_subparsers(dest="action")

    update_parser = subparsers.add_parser("update", help="update Helm chart")
    update_parser.add_argument("chart_dir", help="path to chart directory")
    update_parser.add_argument(
        "--in-place", action="store_true", help="update chart yaml in place"
    )
    update_parser.add_argument("--token", help="GitHub token")

    coerce_parser = subparsers.add_parser("coerce", help="coerce tag")
    coerce_parser.add_argument("tag", help="tag to coerce")

    args = vars(parser.parse_args())

    if args["log_file"]:
        args["log"] = True

    return args


def update_chart(**args):
    chart_repo, tag = parse_helm_chart(**args)

    pattern = re.compile(BASEVERSION, re.VERBOSE)

    try:
        prefix, parsed_tag = coerce(tag, pattern)
    except ValueError:
        print(f"Could not parse tag {tag}")

        return

    if "ghcr.io" in chart_repo:
        candidates = search_ghcr(chart_repo, **args)
    else:
        candidates = search_docker_hub(chart_repo, **args)

    new_tag = search_new_tag(parsed_tag, candidates, pattern, prefix)

    if new_tag is None:
        print("Found no updated tag")
    else:
        update_chart_tag(tag=new_tag, **args)


def parse_helm_chart(chart_dir, **_):
    values_file = os.path.join(chart_dir, "values.yaml")

    with open(values_file) as fd:
        data = yaml.load(fd, Loader=yaml.SafeLoader)

    chart_repo = data["image"]["repository"]

    logger.info(f"Using chart repo {chart_repo!r}")

    chart_file = os.path.join(chart_dir, "Chart.yaml")

    with open(chart_file) as fd:
        data = yaml.load(fd, Loader=yaml.SafeLoader)

    app_version = data["appVersion"]

    logger.info(f"Using appVersion {app_version!r}")

    return chart_repo, app_version


def search_ghcr(chart_repo, token, **_):
    org, package_name = chart_repo.split("/")[1:]

    url = (
        f"https://api.github.com/orgs/{org}/packages/container/{package_name}/versions"
    )

    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    response = requests.get(url, headers=headers)

    response.raise_for_status()

    data = response.json()

    candidates = [y for x in data for y in x["metadata"]["container"]["tags"]]

    logger.info(f"Found {len(candidates)} candidates")

    return candidates


def search_docker_hub(chart_repo, **_):
    namespace, repository = chart_repo.split("/")

    url = f"https://hub.docker.com/v2/namespaces/{namespace}/repositories/{repository}/tags"

    response = requests.get(url)

    response.raise_for_status()

    data = response.json()

    logger.info(f"Found {data['count']} candidates")

    return [x["name"] for x in data["results"]]


def search_new_tag(tag, candidates, pattern, prefix):
    new_tag = None

    for x in candidates:
        try:
            candidate_prefix, candidate_tag = coerce(x, pattern)
        except ValueError as e:
            logger.info(e)

            continue

        if prefix != candidate_prefix:
            logger.debug(
                f"Skipping {x} mismatch prefixes {prefix!r} and {candidate_prefix!r}"
            )

            continue

        if candidate_tag > tag:
            new_tag = x

            logger.info(f"Found new tag {new_tag}")

            break

        logger.info(f"Tag {x} is not newer than {tag}")

    return new_tag


def coerce_tag(tag, **args):
    pattern = re.compile(BASEVERSION, re.VERBOSE)

    try:
        prefix, coerced_tag = coerce(tag, pattern)
    except ValueError as e:
        print(e)
    else:
        print(f"Coerced tag {tag} to {str(coerced_tag)}, prefix {prefix!r}")


def coerce(version, pattern):
    ver = None

    try:
        ver = Version.parse(version)
    except ValueError as e:
        pass
    else:
        prefix = ""

        ver = ver.replace(prerelease=None, build=None)

    if ver is None:
        match = pattern.match(version)

        if match is None:
            raise ValueError(f"Could not parse {version!r}")

        groups = match.groupdict()

        prefix = groups.pop("prefix", "")

        if prefix is None:
            prefix = ""

        # set defaults so 2 and 2.0 can be parsed
        for x in ["major", "minor", "patch"]:
            if groups[x] is None:
                groups[x] = 0

        groups.pop("prerelease")
        groups.pop("build")

        try:
            ver = Version(**groups)
        except ValueError:
            raise ValueError(f"Could not parse {version!r}") from None

    logger.info(f"Coerced version {version} to {str(ver)} with prefix {prefix!r}")

    return prefix, ver


def update_chart_tag(chart_dir, tag, in_place, **args):
    chart_file = os.path.join(chart_dir, "Chart.yaml")

    with open(chart_file) as fd:
        data = yaml.load(fd, Loader=yaml.SafeLoader)

    data["appVersion"] = tag

    if in_place:
        with open(chart_file, "wb") as fd:
            yaml.dump(data, fd, encoding="utf-8", sort_keys=False)

        print(tag)
    else:
        print(yaml.dump(data, sort_keys=False))


if __name__ == "__main__":
    main()
