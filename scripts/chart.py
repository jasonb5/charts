import argparse
import logging
import os
import re
import requests
import json
import yaml
import functools
import subprocess
import pytest
from pathlib import Path
from semver.version import Version

logger = logging.getLogger("chart")


def str_presenter(dumper, data):
    if data.count("\n") > 0:  # check for multiline string
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


yaml.add_representer(str, str_presenter)

yaml_load = functools.partial(yaml.load, Loader=yaml.SafeLoader)

LETTER = "[a-zA-Z]"
POSITIVE_DIGIT = "[1-9]"
DIGIT = f"(?:0|{POSITIVE_DIGIT})"
DIGITS = f"{DIGIT}+"
NON_DIGIT = f"(?:{LETTER}|-)"
IDENTIFIER_CHARACTER = f"(?:{DIGIT}|{NON_DIGIT})"
IDENTIFIER_CHARACTERS = f"{IDENTIFIER_CHARACTER}+"
NUMERIC_IDENTIFIER = f"(?:0|(?:{POSITIVE_DIGIT}(?:{DIGITS})?))"
ALPHANUMBERIC_IDENTIFIER = f"(?:(?:{NON_DIGIT}(?:{IDENTIFIER_CHARACTERS})?)|(?:{IDENTIFIER_CHARACTERS}{NON_DIGIT}(?:{IDENTIFIER_CHARACTERS})?))"
BUILD_IDENTIFIER = f"(?:{ALPHANUMBERIC_IDENTIFIER}|{DIGITS})"
PRERELEASE_IDENTIFIER = f"(?:{ALPHANUMBERIC_IDENTIFIER}|{NUMERIC_IDENTIFIER})"
BUILD = f"(?:\\+(?P<build>{BUILD_IDENTIFIER}(?:\\.(?:{BUILD_IDENTIFIER}))*))?"
PRERELEASE = (
    f"(?:-(?P<prerelease>{PRERELEASE_IDENTIFIER}(?:\\.(?:{PRERELEASE_IDENTIFIER}))*))?"
)
VERSION_CORE = f"(?:(?P<major>{NUMERIC_IDENTIFIER})(?:\\.(?P<minor>{NUMERIC_IDENTIFIER})(?:\\.(?P<patch>{NUMERIC_IDENTIFIER}))?)?)"
SEMVER = f"{VERSION_CORE}{PRERELEASE}{BUILD}"
SEMVER_EXTENDED = f"(?P<prefix>(?:.*-)*v?)?{SEMVER}(?P<postfix>.*)?"


@pytest.mark.parametrize(
    "value,test,expected",
    (
        (SEMVER, "0.1.12", ("0", "1", "12", None, None)),
        (SEMVER, "1.0.0-alpha", ("1", "0", "0", "alpha", None)),
        (SEMVER, "1.0.0-alpha.1", ("1", "0", "0", "alpha.1", None)),
        (SEMVER, "1.0.0-0.3.7", ("1", "0", "0", "0.3.7", None)),
        (SEMVER, "1.0.0-x.7.z.92", ("1", "0", "0", "x.7.z.92", None)),
        (SEMVER, "1.0.0-x-y-z.--", ("1", "0", "0", "x-y-z.--", None)),
        (SEMVER, "1.0.0-alpha+001", ("1", "0", "0", "alpha", "001")),
        (
            SEMVER,
            "1.0.0-beta+exp.sha.5114f85",
            ("1", "0", "0", "beta", "exp.sha.5114f85"),
        ),
        (
            SEMVER,
            "1.0.0+21AF26D3----117B344092BD",
            ("1", "0", "0", None, "21AF26D3----117B344092BD"),
        ),
        (SEMVER, "1.0.0+20130313144700", ("1", "0", "0", None, "20130313144700")),
        (BUILD, "+001", ("001",)),
        (BUILD, "+20130313144700", ("20130313144700",)),
        (BUILD, "+exp.sha.5114f85", ("exp.sha.5114f85",)),
        (BUILD, "+21AF26D3----117B344092BD", ("21AF26D3----117B344092BD",)),
        (PRERELEASE, "--", ("-",)),
        (PRERELEASE, "-alpha", ("alpha",)),
        (PRERELEASE, "-alpha.1", ("alpha.1",)),
        (PRERELEASE, "-0.3.7", ("0.3.7",)),
        (PRERELEASE, "-x.7.z.92", ("x.7.z.92",)),
        (PRERELEASE, "-x-y-z.--", ("x-y-z.--",)),
        (VERSION_CORE, "0", ("0", None, None)),
        (VERSION_CORE, "1", ("1", None, None)),
        (VERSION_CORE, "10", ("10", None, None)),
        (VERSION_CORE, "0.0", ("0", "0", None)),
        (VERSION_CORE, "0.1", ("0", "1", None)),
        (VERSION_CORE, "0.10", ("0", "10", None)),
        (VERSION_CORE, "0.0.0", ("0", "0", "0")),
        (VERSION_CORE, "0.0.1", ("0", "0", "1")),
        (VERSION_CORE, "0.0.10", ("0", "0", "10")),
        (VERSION_CORE, "00", None),
        (VERSION_CORE, "0.00", None),
        (VERSION_CORE, "0.0.00", None),
        (VERSION_CORE, "0.0.0.0", None),
        (VERSION_CORE, "a", None),
        (VERSION_CORE, "0.a", None),
        (VERSION_CORE, "0.0.a", None),
    ),
)
def test_pattern(value, test, expected):
    pattern = re.compile(value)

    match = pattern.fullmatch(test)

    if expected is None:
        assert match is None
    else:
        assert match is not None
        assert match.groups() == expected


class ParsedVersion:
    def __init__(self, version, prefix, postfix):
        self.version = version
        self.prefix = prefix
        self.postfix = postfix

    @classmethod
    def parse(cls, tag, pattern):
        try:
            version = Version.parse(tag)
        except ValueError:
            prefix, version, postfix = cls.coerce_version(tag, pattern)
        else:
            prefix, postfix = "", ""

        return cls(version, prefix, postfix)

    @staticmethod
    def coerce_version(tag, pattern):
        match = pattern.fullmatch(tag)

        try:
            groups = match.groupdict()
        except AttributeError:
            raise ParseError(f"Could not parse {tag}")

        prefix = groups.pop("prefix")

        postfix = groups.pop("postfix")

        groups = {x: "" if y is None else y for x, y in groups.items()}

        for key in groups.keys():
            if key in ("major", "minor", "patch"):
                if groups[key] == "":
                    groups[key] = 0
                else:
                    groups[key] = int(groups[key])
            else:
                if groups[key] is None:
                    groups[key] = ""

        version = Version(**groups)

        return prefix, version, postfix

    def newer(self, version):
        if self.prefix != version.prefix:
            raise ValueError(
                f"Missmatched prefixes {self.prefix!r} and {version.prefix!r}"
            )

        if self.version <= version.version:
            logger.debug("{} is not newer than {}".format(version, self.version))

            return False

        if (
            self.postfix != ""
            and version.postfix != ""
            and self.postfix <= version.postfix
        ):
            return False

        return True

    def __repr__(self):
        return f"Prefix: {self.prefix} Version: {self.version} Postfix: {self.postfix}"

    def __str__(self):
        return f"{self.prefix}{self.version!s}{self.postfix}"


class ParseError(Exception):
    pass


def main():
    args = get_args()

    action = args.pop("action")

    if args["log"]:
        logging.basicConfig(level=args["log_level"])

    if action == "list":
        list_image_tags(**args)
    elif action == "current":
        pattern = re.compile(SEMVER_EXTENDED)

        try:
            _, version, chart_version = parse_chart(args["chart"], pattern)
        except ParseError:
            logger.info("Could not parse chart")
        else:
            if args["chart_version"]:
                print(f"{chart_version}")
            else:
                print(f"{version!s}")
    elif action == "update":
        update_chart(**args)


def get_args():
    parser = argparse.ArgumentParser(prog="chart")

    subparsers = parser.add_subparsers(dest="action")

    logging_parser = subparsers.add_parser("logging", add_help=False)
    logging_parser.add_argument("--log", action="store_true", help="Enable logging")
    levels = ("DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL")
    logging_parser.add_argument(
        "--log-level", choices=levels, default="INFO", help="Logging level"
    )

    list_parser = subparsers.add_parser(
        "list", parents=[logging_parser], help="List versions for a chart"
    )
    list_parser.add_argument("chart", type=Path, help="Path to chart")
    list_parser.add_argument("--token", help="GitHub token")
    list_parser.add_argument(
        "--newer", action="store_true", help="Only print newer versions"
    )

    current_parser = subparsers.add_parser(
        "current", parents=[logging_parser], help="List current chart appVersion"
    )
    current_parser.add_argument("chart", type=Path, help="Path to chart")
    current_parser.add_argument(
        "--chart-version", action="store_true", help="Print chart version"
    )

    update_parser = subparsers.add_parser(
        "update", parents=[logging_parser], help="Updates charts Chart.yaml"
    )
    update_parser.add_argument("chart", type=Path, help="Path to chart")
    update_parser.add_argument("--token", help="GitHub token")
    update_parser.add_argument(
        "--inplace", "-i", action="store_true", help="Updates chart in-place"
    )

    args = vars(parser.parse_args())

    logger.debug(f"{args}")

    return args


def list_image_tags(chart, newer, **kwargs):
    pattern = re.compile(SEMVER_EXTENDED)

    repository, current, _ = parse_chart(chart, pattern)

    tags = get_tags(repository, pattern, **kwargs)

    for version in tags:
        try:
            if newer and version.newer(current):
                print(f"{version!s} is newer than {current!s}")
            elif not newer:
                print(f"{version!s}")
        except ValueError as e:
            logger.debug(str(e))


def update_chart(chart, inplace, **kwargs):
    pattern = re.compile(SEMVER_EXTENDED)

    try:
        repository, current, _ = parse_chart(chart, pattern)
    except ParseError as e:
        logger.info(f"{e}")

        return

    tags = get_tags(repository, pattern, **kwargs)

    newest = None

    for version in tags:
        try:
            newer = version.newer(newest or current)
        except ValueError:
            continue

        if newer:
            newest = version

    if newest is not None:
        with (chart / "Chart.yaml").open() as fd:
            data = yaml_load(fd.read())

        data["appVersion"] = str(newest)

        if inplace:
            with (chart / "Chart.yaml").open("wb") as fd:
                yaml.dump(data, fd, encoding="utf-8", sort_keys=False)

            print(newest)
        else:
            print(yaml.dump(data, sort_keys=False))


def parse_chart(chart, pattern):
    chart_yaml_path = chart / "Chart.yaml"

    with chart_yaml_path.open() as fd:
        data = yaml_load(fd)

    app_version = data["appVersion"]

    version = data["version"]

    values_yaml_path = chart / "values.yaml"

    with values_yaml_path.open() as fd:
        data = yaml_load(fd)

    repository = data["image"]["repository"]

    logger.info(f"Parsed repository {repository!r} with tag {app_version!r}")

    return repository, ParsedVersion.parse(app_version, pattern), version


def get_tags(repository, pattern, **kwargs):
    if "ghcr.io" in repository:
        tags = search_ghcr(repository, **kwargs)
    elif repository.count("/") == 1:
        tags = search_docker_hub(repository, **kwargs)
    else:
        logger.info(f"The {repository!r} is not supported")

        return []

    data = []

    for x in tags:
        try:
            version = ParsedVersion.parse(x, pattern)
        except ParseError as e:
            logger.debug(f"Parsing error: {e}")

            continue

        data.append(version)

    return data


def search_ghcr(repository, token, **_):
    org, package_name = repository.split("/")[1:]

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

    tags = [y for x in data for y in x["metadata"]["container"]["tags"]]

    logger.info(f"Found {len(tags)} candidates")

    return tags


def search_docker_hub(repository, **_):
    namespace, repository = repository.split("/")

    url = f"https://hub.docker.com/v2/namespaces/{namespace}/repositories/{repository}/tags"

    response = requests.get(url)

    response.raise_for_status()

    data = response.json()

    tags = [x["name"] for x in data["results"]]

    logger.info(f"Found {len(tags)} candidates")

    return tags


if __name__ == "__main__":
    main()
