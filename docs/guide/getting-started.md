# Getting Started

This repository provides many homelab related Helm charts. There is a common library designed to simplify creating new Helm charts.

## Adding chart repository
To install the Helm charts provided by this repository you'll need to install Helm and add this repository.

```shell
helm repo add homelab https://jasonb5.github.io/charts
```

## List charts
List the charts available in the repository.

```shell
helm search repo homelab
```

## Install a chart
A Helm chart can be install with the following command.

```shell
helm install homelab/<chart name> --generate-name
```

## Creating a new chart
A [copier](https://copier.readthedocs.io/en/stable/) template is provided to create new Helm charts. The template uses the common library to build the chart. It also provides scaffolding for common dependencies e.g. Redis, MariaDB, and PostgreSQL.

```shell
pip install copier

make new-chart
```
