# jellyfin

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 10.8.13](https://img.shields.io/badge/AppVersion-10.8.13-informational?style=flat-square)

Jellyfin is the volunteer-built media solution that puts you in control of your media. Stream to any device from your own server, with no strings attached. Your media, your server, your way.

**Homepage:** <https://jellyfin.org/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| jasonb5 |  |  |

## Source Code

* <https://github.com/jasonb5/charts/tree/main/charts/jellyfin>
* <https://github.com/jellyfin/jellyfin>
* <https://github.com/linuxserver/docker-jellyfin>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://jasonb5.github.io/charts | common | 0.1.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| workload | string | `"deployment"` | The default [workload](https://jasonb5.github.io/charts/site/guide/common-library/#workload) type |
| image.repository | string | `"ghcr.io/linuxserver/jellyfin"` | Container image repository |
| image.tag | string | Chart.AppVersion | Image tag |
| env.TZ | string | `"UTC"` | Set the timezone |
| env.JELLYFIN_PublishedServerUrl | string | `nil` | Server Url based on primary IP address |
| service | object | `{"ports":{"default":{"port":8096}}}` | [Service](https://jasonb5.github.io/charts/site/guide/common-library/#service) |
| service.ports.default.port | int | `8096` | Default port |
| ingress | object | `{"enabled":false,"hosts":[{"host":null,"name":"default"}],"tls":{"enabled":false}}` | [Ingress](https://jasonb5.github.io/charts/site/guide/common-library/#ingress) |
| ingress.enabled | bool | `false` | Enable/disable ingress |
| ingress.hosts[0] | object | `{"host":null,"name":"default"}` | Reference default service |
| ingress.hosts[0].host | string | `nil` | Ingress hostname |
| ingress.tls | object | `{"enabled":false}` | [TLS](https://jasonb5.github.io/charts/site/guide/common-library/#tls) |
| ingress.tls.enabled | bool | `false` | Enable/disable tls |
| persistence | object | `{"config":{"enabled":false,"size":"1Gi","type":"pvc"}}` | [Persistence](https://jasonb5.github.io/charts/site/guide/common-library/#persistence) |
| persistence.config.enabled | bool | `false` | Enable/disable persistence |
| persistence.config.type | string | `"pvc"` | Type of volume mount |
| persistence.config.size | string | `"1Gi"` | Size of volume |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)