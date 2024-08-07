# invidious

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2024.03.31-08390ac](https://img.shields.io/badge/AppVersion-2024.03.31--08390ac-informational?style=flat-square)

An open source alternative front-end to YouTube.

**Homepage:** <https://invidious.io/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| jasonb5 |  |  |

## Source Code

* <https://github.com/jasonb5/charts/tree/main/charts/invidious>
* <https://github.com/iv-org>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://jasonb5.github.io/charts | common | 0.1.x |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 0.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| workload | string | `"deployment"` | The default [workload](https://jasonb5.github.io/charts/site/guide/common-library/#workload) type |
| image.repository | string | `"quay.io/invidious/invidious"` | Container image repository |
| image.tag | string | Chart.AppVersion | Image tag |
| hmacKey | string | `nil` | Required HMAC Key |
| env.TZ | string | `"UTC"` | Set the timezone |
| env.INVIDIOUS_CONFIG | string | `"db:\n  dbname: {{ .Values.postgresql.auth.database }}\n  user: {{ .Values.postgresql.auth.username }}\n  password: {{ .Values.postgresql.auth.password }}\n  host: {{ printf \"%s-postgresql\" .Release.Name }}\n  port: 5432\ncheck_tables: true\nexternal_port: 443\ndomain: {{ get (first .Values.ingress.hosts) \"host\" }}\nhttps_only: true\nstatistics_enabled: true\nhmac_key: {{ .Values.hmacKey }}\n"` |  |
| service | object | `{"ports":{"default":{"port":3000}}}` | [Service](https://jasonb5.github.io/charts/site/guide/common-library/#service) |
| service.ports.default.port | int | `3000` | Default port |
| ingress | object | `{"enabled":false,"hosts":[{"host":null,"name":"default"}],"tls":{"enabled":false}}` | [Ingress](https://jasonb5.github.io/charts/site/guide/common-library/#ingress) |
| ingress.enabled | bool | `false` | Enable/disable ingress |
| ingress.hosts[0] | object | `{"host":null,"name":"default"}` | Reference default service |
| ingress.hosts[0].host | string | `nil` | Ingress hostname |
| ingress.tls | object | `{"enabled":false}` | [TLS](https://jasonb5.github.io/charts/site/guide/common-library/#tls) |
| ingress.tls.enabled | bool | `false` | Enable/disable tls |
| postgresql | object | `{"architecture":"standalone","auth":{"database":"invidious","password":null,"postgresPassword":null,"username":"invidious"},"enabled":true,"metrics":{"enabled":false},"primary":{"persistence":{"enabled":false}},"readReplicas":{"persistence":{"enabled":false}}}` | PostgreSQL server, see Bitnami chart for [values](https://github.com/bitnami/charts/tree/main/bitnami/postgresql#parameters) |
| postgresql.auth.postgresPassword | string | `nil` | Root database password |
| postgresql.auth.password | string | `nil` | Database password |

{%
include-markdown "../../charts/invidious/CUSTOM.md"
%}

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.13.1](https://github.com/norwoodj/helm-docs/releases/v1.13.1)
