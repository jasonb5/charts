import argparse
import logging
import os
import re
import requests
import yaml
from semver.version import Version

logger = logging.getLogger("update-chart")


def str_presenter(dumper, data):
    if data.count("\n") > 0:  # check for multiline string
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


yaml.add_representer(str, str_presenter)

BASEVERSION = r"(?P<major>0|[1-9]\d*)(\.(?P<minor>0|[1-9]\d*)(\.(?P<patch>0|[1-9]\d*))?)?(?:-(?P<prerelease>.*))?"


def update_chart():
    kwargs = get_args()

    if kwargs["log"]:
        level = logging.getLevelName(kwargs["log_level"])

        logging.basicConfig(level=level)

    repository, app_version = parse_chart(**kwargs)

    if "ghcr.io" in repository:
        new_version = check_ghcr(repository, app_version, **kwargs)
    else:
        new_version = check_docker_hub(repository, app_version, **kwargs)

    if new_version is None:
        print("Found no new version")
    else:
        update_app_version(new_version, **kwargs)


def get_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("chart_dir")

    parser.add_argument("--in-place", action="store_true")
    parser.add_argument("--token")

    level_choices = list(logging._nameToLevel.keys())[:-1]
    parser.add_argument("--log", action="store_true")
    parser.add_argument("--log-level", default="INFO", choices=level_choices)

    return vars(parser.parse_args())


def parse_chart(chart_dir, **_):
    values_file = os.path.join(chart_dir, "values.yaml")

    with open(values_file) as fd:
        values_data = yaml.load(fd, Loader=yaml.SafeLoader)

    repository = values_data["image"]["repository"]

    logger.info(f"Found image repository {repository!r}")

    chart_file = os.path.join(chart_dir, "Chart.yaml")

    with open(chart_file) as fd:
        chart_data = yaml.load(fd, Loader=yaml.SafeLoader)

    app_version = chart_data["appVersion"]

    logger.info(f"Found appVersion {app_version!r}")

    return repository, app_version


def check_ghcr(repository, app_version, token, **_):
    org, package_name = repository.split("/")[1:]

    logger.info(f"Searching GitHub {org!r} org for {package_name!r} package")

    url = (
        f"https://api.github.com/orgs/{org}/packages/container/{package_name}/versions"
    )

    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    logger.debug(f"Searching url {url!r}")

    response = requests.get(url, headers=headers)

    response.raise_for_status()

    data = response.json()

    pattern = re.compile(BASEVERSION, re.VERBOSE)

    prefix, version, _, orig = parse_version(app_version, pattern)

    if prefix == "":
        pattern = re.compile(r"^" + BASEVERSION, re.VERBOSE)
    else:
        pattern = re.compile(r"^" + prefix + BASEVERSION, re.VERBOSE)

    candidates = [
        y
        for x in data
        for y in x["metadata"]["container"]["tags"]
        if y.startswith(prefix)
    ]

    return find_new_version(version, orig, candidates, pattern)


def check_docker_hub(repository, app_version, **_):
    namespace, repository = repository.split("/")

    url = f"https://hub.docker.com/v2/namespaces/{namespace}/repositories/{repository}/tags"

    logger.debug(f"Searching url {url!r}")

    response = requests.get(url)

    response.raise_for_status()

    data = response.json()

    pattern = re.compile(BASEVERSION, re.VERBOSE)

    _, version, _, orig = parse_version(app_version, pattern)

    candidates = [x["name"] for x in data["results"]]

    return find_new_version(version, orig, candidates, pattern)


def parse_version(version, pattern):
    prefix = ""
    postfix = ""

    try:
        ver = Version.parse(version)
    except ValueError:
        prefix, ver, postfix, _ = coerce(version, pattern)

    if ver is None:
        raise Exception(f"Failed to parse {version!r}")

    logger.info(f"Parsed version {str(ver)}")

    return prefix, ver, postfix, version


def coerce(version, pattern):
    match = pattern.search(version)

    if not match:
        return ("", None, "", version)

    try:
        ver = Version.parse(version[match.start() :])
    except ValueError:
        ver = {
            key: 0 if value is None else value
            for key, value in match.groupdict().items()
        }

        ver = Version(**ver)

    prefix = version[: match.start()]

    postfix = version[match.end() :]

    logger.debug(
        f"Coerced {version} to {str(ver)}, prefix {prefix!r}, postfix {postfix!r}"
    )

    return prefix, ver, postfix, version


def find_new_version(version, version_orig, candidates, pattern):
    new_version = None

    logger.info(f"Looking at {len(candidates)} update candidates")

    for x in candidates:
        try:
            _, ver, _, orig = parse_version(x, pattern)
        except Exception as e:
            logger.debug(str(e))

            continue

        if ver > version:
            new_version = orig

            logger.info(f"Found new version {new_version}")

            break

        logger.info(
            f"Version {str(ver)} ({orig}) is not newer than {str(version)} ({version_orig})"
        )

    return new_version


def update_app_version(version, chart_dir, in_place, **_):
    chart_file = os.path.join(chart_dir, "Chart.yaml")

    with open(chart_file) as fd:
        data = yaml.load(fd, Loader=yaml.SafeLoader)

    data["appVersion"] = version

    updated_chart = yaml.dump(data, sort_keys=False)

    if in_place:
        with open(chart_file, "wb") as fd:
            fd.write(updated_chart.encode("utf-8"))
        print(version)
    else:
        print(updated_chart)


if __name__ == "__main__":
    update_chart()
