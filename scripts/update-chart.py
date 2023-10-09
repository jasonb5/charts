import argparse
import json
import logging
import os
import re
import requests
import semver
import yaml
from datetime import datetime
from semver.version import Version

logger = logging.getLogger("update-chart")


def str_presenter(dumper, data):
    if data.count("\n") > 0:  # check for multiline string
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


yaml.add_representer(str, str_presenter)

BASEVERSION = re.compile(
    r"""(?P<major>0|[1-9]\d*)
        (\.
        (?P<minor>0|[1-9]\d*)
        (\.
        (?P<patch>0|[1-9]\d*)
        )?
        )?
    """,
    re.VERBOSE,
)


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
        print(f"Found no update from {app_version}")
    else:
        print(f"Update version {app_version} -> {new_version}")

        if kwargs["in_place"]:
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


def parse_chart(chart_dir, **kwargs):
    values_file = os.path.join(chart_dir, "values.yaml")

    with open(values_file) as fd:
        values_data = yaml.load(fd, Loader=yaml.SafeLoader)

    repository = values_data["image"]["repository"]

    chart_file = os.path.join(chart_dir, "Chart.yaml")

    with open(chart_file) as fd:
        chart_data = yaml.load(fd, Loader=yaml.SafeLoader)

    app_version = chart_data["appVersion"]

    return repository, app_version


def check_ghcr(repository, app_version, token, **kwargs):
    org, package_name = repository.split("/")[1:]

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

    prefix, app_version, _, orig = parse_version(app_version)

    if app_version is None:
        logger.info(f"Could not parse appVersion {orig}")

        return None

    # filter tags with matching prefix
    versions = [
        parse_version(y)
        for x in data
        for y in x["metadata"]["container"]["tags"]
        if y.startswith(prefix)
    ]

    new_version = None

    for _, version, _, orig in versions:
        if version is None:
            logger.debug(f"Could not parse {orig}")

            continue

        if version > app_version:
            new_version = orig

            break

        logger.debug(f"Version {version!s} is not newer than {app_version!s}")

    return new_version


def check_docker_hub(repository, app_version, **kwargs):
    namespace, repository = repository.split("/")

    url = f"https://hub.docker.com/v2/namespaces/{namespace}/repositories/{repository}/tags"

    response = requests.get(url)

    response.raise_for_status()

    data = response.json()

    _, app_version, _, orig = parse_version(app_version)

    if app_version is None:
        logger.info(f"Could not parse appVersion {orig}")

        return None

    versions = [parse_version(x["name"]) for x in data["results"]]

    new_version = None

    for _, version, _, orig in versions:
        if version is None:
            logger.debug(f"Could not parse {orig}")

            continue

        if version > app_version:
            new_version = orig

            break

        logger.debug(f"Version {version!s} is not newer than {app_version!s}")

    return new_version


def parse_version(version):
    try:
        ver = Version.parse(version)
    except ValueError:
        ver = coerce(version)
    else:
        ver = ["", ver, "", version]

    return ver


def coerce(version):
    match = BASEVERSION.search(version)

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

    return prefix, ver, postfix, version


def update_app_version(version, chart_dir, **kwargs):
    chart_file = os.path.join(chart_dir, "Chart.yaml")

    with open(chart_file) as fd:
        data = yaml.load(fd, Loader=yaml.SafeLoader)

    data["appVersion"] = version

    with open(chart_file, "wb") as fd:
        yaml.dump(data, fd, encoding="utf-8", sort_keys=False)


if __name__ == "__main__":
    update_chart()
