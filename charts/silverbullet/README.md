# silverbullet

![Version: 0.1.13](https://img.shields.io/badge/Version-0.1.13-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.8.1](https://img.shields.io/badge/AppVersion-0.8.1-informational?style=flat-square)

SilverBullet aims to be a **workshop for the mind**: a creative space where you collect, create and expand your personal knowledge, while simultaneously letting you evolve the tools you use to do so.

**Homepage:** <https://silverbullet.md/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| jasonb5 |  |  |

## Source Code

* <https://github.com/jasonb5/charts/tree/main/charts/silverbullet>
* <https://github.com/silverbulletmd/silverbullet>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://jasonb5.github.io/charts | common | 0.1.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| workload | string | `"deployment"` | The default [workload](https://jasonb5.github.io/charts/site/guide/common-library/#workload) type |
| image.repository | string | `"zefhemel/silverbullet"` | Container image repository |
| image.tag | string | Chart.AppVersion | Image tag |
| env.TZ | string | `"UTC"` | Set the timezone |
| service | object | `{"ports":{"default":{"port":3000}}}` | [Service](https://jasonb5.github.io/charts/site/guide/common-library/#service) |
| service.ports.default.port | int | `3000` | Default port |
| ingress | object | `{"enabled":false,"hosts":[{"host":null,"name":"default"}],"tls":{"enabled":false}}` | [Ingress](https://jasonb5.github.io/charts/site/guide/common-library/#ingress) |
| ingress.enabled | bool | `false` | Enable/disable ingress |
| ingress.hosts[0] | object | `{"host":null,"name":"default"}` | Reference default service |
| ingress.hosts[0].host | string | `nil` | Ingress hostname |
| ingress.tls | object | `{"enabled":false}` | [TLS](https://jasonb5.github.io/charts/site/guide/common-library/#tls) |
| ingress.tls.enabled | bool | `false` | Enable/disable tls |
| persistence | object | `{"config":{"enabled":false,"mountPath":"/space","size":"1Gi","type":"pvc"}}` | [Persistence](https://jasonb5.github.io/charts/site/guide/common-library/#persistence) |
| persistence.config.enabled | bool | `false` | Enable/disable persistence |
| persistence.config.type | string | `"pvc"` | Type of volume mount |
| persistence.config.size | string | `"1Gi"` | Size of volume |
| persistence.config.mountPath | string | `"/space"` | Volume mount path |

{%
include-markdown "../../charts/silverbullet/CUSTOM.md"
%}

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)
