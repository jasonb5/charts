# searxng

![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2024.7.15-9a4fa7cc4](https://img.shields.io/badge/AppVersion-2024.7.15--9a4fa7cc4-informational?style=flat-square)

SearXNG is a free internet metasearch engine which aggregates results from more than 70 search services. Users are neither tracked nor profiled. Additionally, SearXNG can be used over Tor for online anonymity.

**Homepage:** <https://docs.searxng.org/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| jasonb5 |  |  |

## Source Code

* <https://github.com/jasonb5/charts/tree/main/charts/searxng>
* <https://github.com/searxng/searxng>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://jasonb5.github.io/charts | common | 0.1.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| workload | string | `"deployment"` | The default [workload](https://jasonb5.github.io/charts/site/guide/common-library/#workload) type |
| dnsConfig.options[0].name | string | `"ndots"` |  |
| dnsConfig.options[0].value | string | `"1"` |  |
| image.repository | string | `"searxng/searxng"` | Container image repository |
| image.tag | string | Chart.AppVersion | Image tag |
| env.TZ | string | `"UTC"` | Set the timezone |
| service | object | `{"ports":{"default":{"port":8080}}}` | [Service](https://jasonb5.github.io/charts/site/guide/common-library/#service) |
| service.ports.default.port | int | `8080` | Default port |
| ingress | object | `{"enabled":false,"hosts":[{"host":null,"name":"default"}],"tls":{"enabled":false}}` | [Ingress](https://jasonb5.github.io/charts/site/guide/common-library/#ingress) |
| ingress.enabled | bool | `false` | Enable/disable ingress |
| ingress.hosts[0] | object | `{"host":null,"name":"default"}` | Reference default service |
| ingress.hosts[0].host | string | `nil` | Ingress hostname |
| ingress.tls | object | `{"enabled":false}` | [TLS](https://jasonb5.github.io/charts/site/guide/common-library/#tls) |
| ingress.tls.enabled | bool | `false` | Enable/disable tls |
| persistence | object | `{"config":{"enabled":false,"mountPath":"/etc/searxng","size":"1Gi","type":"pvc"}}` | [Persistence](https://jasonb5.github.io/charts/site/guide/common-library/#persistence) |
| persistence.config.enabled | bool | `false` | Enable/disable persistence |
| persistence.config.type | string | `"pvc"` | Type of volume mount |
| persistence.config.size | string | `"1Gi"` | Size of volume |
| persistence.config.mountPath | string | `"/etc/searxng"` | Mount path |

{%
include-markdown "../../charts/searxng/CUSTOM.md"
%}

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)