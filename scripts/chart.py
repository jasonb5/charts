import argparse
import logging
import os
import re
import requests
import json
import yaml
import subprocess
from semver.version import Version

logger = logging.getLogger("chart")


def str_presenter(dumper, data):
    if data.count("\n") > 0:  # check for multiline string
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


yaml.add_representer(str, str_presenter)

BASEVERSION = r"""
                  ^
                  (?:(?P<prefix>[a-zA-Z-]*)-?)?
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
                  (?P<postfix>.*)?
                  $
               """


BASEPATTERN = re.compile(BASEVERSION, re.VERBOSE)


def main():
    args = get_args()

    if args["log"]:
        logging.basicConfig(filename=args["log_file"], level=args["log_level"])

    if args["action"] == "update":
        update_chart(**args)
    elif args["action"] == "coerce":
        coerce_tag(**args)
    elif args["action"] == "os-check":
        os_check(**args)
    elif args["action"] == "version":
        version(**args)
    elif args["action"] == "list":
        list_versions(**args)


def get_args():
    parser = argparse.ArgumentParser(prog="chart")

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
    update_parser.add_argument(
        "--match-prerelease", action="store_true", help="Pre-release must match"
    )

    coerce_parser = subparsers.add_parser("coerce", help="coerce tag")
    coerce_parser.add_argument("tag", help="tag to coerce")

    os_check_parser = subparsers.add_parser(
        "os-check", help="Prints content of /etc/os-release"
    )
    os_check_parser.add_argument("chart_dir", help="path to chart directory")

    version_parser = subparsers.add_parser("version", help="Prints chart/app version")
    version_parser.add_argument(
        "--chart", help="Prints chart version", action="store_true"
    )
    version_parser.add_argument("chart_dir", help="path to chart directory")

    list_parser = subparsers.add_parser("list", help="list candidates")
    list_parser.add_argument("chart_dir", help="path to chart directory")
    list_parser.add_argument("--token", help="GitHub token", required=True)
    list_parser.add_argument("--raw", action="store_true", help="Print raw tags")
    list_parser.add_argument(
        "--newer", action="store_true", help="Filters only newer versions"
    )
    list_parser.add_argument(
        "--match-prerelease",
        action="store_true",
        help="List versions that match prerelease",
    )

    args = vars(parser.parse_args())

    if args["log_file"]:
        args["log"] = True

    return args


def update_chart(**args):
    chart_repo, _, tag = parse_helm_chart(**args)

    try:
        prefix, parsed_tag, postfix = coerce_version(tag, BASEPATTERN)
    except ValueError:
        print(f"Could not parse tag {tag}")

        return

    candidates = get_candidate_versions(chart_repo, **args)

    new_tag = search_new_tag(
        parsed_tag, candidates, BASEPATTERN, prefix, postfix, **args
    )

    if new_tag is None:
        print("Found no updated tag")
    else:
        update_chart_tag(tag=new_tag, **args)


def search_ghcr(chart_repo, token, **_):
    org, package_name = chart_repo.split("/")[1:]

    url = (
        f"https://api.github.com/orgs/{org}/packages/container/{package_name}/versions"
    )

    user_url = (
        f"https://api.github.com/users/{org}/packages/container/{package_name}/versions"
    )

    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    response = requests.get(url, headers=headers)

    if response.status_code == 404:
        response = requests.get(user_url, headers=headers)

    response.raise_for_status()

    data = response.json()

    # logger.debug(f"Raw response\n{data}")

    candidates = [y for x in data for y in x["metadata"]["container"]["tags"]]

    logger.info(f"Found {len(candidates)} candidates")

    return candidates


def search_docker_hub(chart_repo, **_):
    namespace, repository = chart_repo.split("/")

    url = f"https://hub.docker.com/v2/namespaces/{namespace}/repositories/{repository}/tags"

    response = requests.get(url)

    response.raise_for_status()

    data = response.json()

    candidates = [x["name"] for x in data["results"]]

    logger.info(f"Found {len(candidates)} candidates")

    return candidates


def list_versions(chart_dir, raw, newer, match_prerelease, **args):
    chart_repo, _, app_version = parse_helm_chart(chart_dir)

    current_prefix, current_version, current_postfix = coerce_version(
        app_version, BASEPATTERN
    )

    candidates = get_candidate_versions(chart_repo, **args)

    skip_prerelease = current_version.prerelease is None

    for version in candidates:
        if raw:
            print(version)
        else:
            try:
                prefix, new_version, postfix = coerce_version(version, BASEPATTERN)
            except ValueError:
                logger.debug(f"Could not parse {version}")

                continue

            if (
                match_prerelease
                and new_version.prerelease != current_version.prerelease
            ):
                logger.info(f"Skipping, missmatched prerelease")

                continue

            if skip_prerelease and new_version.prerelease is not None:
                logger.debug(f"Skipping verion {new_version!s} with pre-release")

                continue

            if current_prefix != prefix:
                logger.debug(f"Missmatched prefixes {current_prefix} != {prefix}")

                continue

            if not newer or (newer and new_version > current_version):
                if prefix == "":
                    print(f"{version}")
                else:
                    print(f"{prefix}-{version}")
            else:
                logger.debug(f"Skipping old version {version}")

                continue


def search_new_tag(tag, candidates, pattern, prefix, postfix, match_prerelease, **args):
    new_tag = None
    new_version = None

    skip_prerelease = tag.prerelease is None

    for x in candidates:
        if x == "1.17.2.4511-ls70":
            breakpoint()
        try:
            candidate_prefix, candidate_tag, candidate_postfix = coerce_version(
                x, pattern
            )
        except ValueError as e:
            logger.info(e)

            continue

        if match_prerelease and tag.prerelease != candidate_tag.prerelease:
            logger.info(f"Skipping, missmatched prerelease")

            continue

        if skip_prerelease and candidate_tag.prerelease is not None:
            logger.debug(f"Skipping {x}, current version doesn't allow prerelease")

            continue

        if prefix != candidate_prefix:
            logger.debug(
                f"Skipping {x} mismatch prefixes {prefix!r} and {candidate_prefix!r}"
            )

            continue

        if new_tag is None:
            if candidate_tag > tag:
                new_tag = candidate_tag
                new_version = x

                logger.info(f"Found new tag {new_tag}")
            elif candidate_tag == tag and candidate_postfix > postfix:
                new_tag = candidate_tag
                new_version = x

                logger.info(f"Found new tag {new_tag}")
            else:
                logger.info(f"Tag {x} is not newer than {tag}")
        else:
            if candidate_tag > new_tag:
                new_tag = candidate_tag
                new_version = x

                logger.info(f"Found new tag {new_tag}")
            elif candidate_tag == new_tag and candidate_postfix > postfix:
                new_tag = candidate_tag
                new_version = x

                logger.info(f"Found new tag {new_tag}")
            else:
                logger.info(f"Tag {x} is not newer than {tag}")

    return new_version


def coerce_tag(tag, **args):
    pattern = re.compile(BASEVERSION, re.VERBOSE)

    try:
        prefix, coerced_tag, postfix = coerce_version(tag, pattern)
    except ValueError as e:
        print(e)
    else:
        print(f"Coerced tag {tag} to {str(coerced_tag)}, prefix {prefix!r}")


def coerce_version(version, pattern):
    ver = None

    try:
        ver = Version.parse(version)
    except ValueError as e:
        pass
    else:
        prefix = ""
        postfix = ""

    if ver is None:
        match = pattern.match(version)

        if match is None:
            raise ValueError(f"Could not parse {version!r}")

        groups = match.groupdict()

        prefix = groups.pop("prefix", "")

        postfix = groups.pop("postfix", "")

        # set defaults so 2 and 2.0 can be parsed
        for x in ["major", "minor", "patch"]:
            if groups[x] is None:
                groups[x] = 0

        try:
            ver = Version(**groups)
        except ValueError:
            raise ValueError(f"Could not parse {version!r}") from None

    logger.info(f"Coerced version {version} to {str(ver)} with prefix {prefix!r}")

    return prefix, ver, postfix


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


def os_check(chart_dir, **args):
    chart_repo, _, app_version = parse_helm_chart(chart_dir)

    cmd = f"docker run -it --rm --entrypoint=cat {chart_repo}:{app_version} /etc/os-release"

    result = subprocess.run(cmd.split(" "), capture_output=True)

    output = result.stdout.decode("utf-8")

    logger.debug(f"Output\n{output}")

    data = dict([x.split("=") for x in output.split("\r\n") if x != ""])

    print(f"{data['ID']}")


def version(chart_dir, chart, **args):
    _, version, app_version = parse_helm_chart(chart_dir)

    if chart:
        print(f"{version}")
    else:
        print(f"{app_version}")


def get_candidate_versions(chart_repo, **args):
    if "ghcr.io" in chart_repo:
        candidates = search_ghcr(chart_repo, **args)
    else:
        candidates = search_docker_hub(chart_repo, **args)

    return candidates


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

    version = data["version"]

    return chart_repo, version, app_version


if __name__ == "__main__":
    main()
