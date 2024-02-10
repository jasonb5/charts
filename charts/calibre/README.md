# calibre

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 7.4.0](https://img.shields.io/badge/AppVersion-7.4.0-informational?style=flat-square)

Calibre is a powerful and easy to use e-book manager. Users say it's outstanding and a must-have. It'll allow you to do nearly everything and it takes things a step beyond normal e-book software. It's also completely free and open source and great for both casual users and computer experts.

**Homepage:** <https://calibre-ebook.com/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| jasonb5 |  |  |

## Source Code

* <https://github.com/jasonb5/charts/tree/main/charts/calibre>
* <https://github.com/kovidgoyal/calibre>
* <https://github.com/linuxserver/docker-calibre>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://jasonb5.github.io/charts | common | 0.1.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| workload | string | `"deployment"` | The default [workload](https://jasonb5.github.io/charts/site/guide/common-library/#workload) type |
| image.repository | string | `"ghcr.io/linuxserver/calibre"` | Container image repository |
| image.tag | string | Chart.AppVersion | Image tag |
| env.TZ | string | `"UTC"` | Set the timezone |
| service | object | `{"ports":{"default":{"port":8080},"web":{"port":8081}}}` | [Service](https://jasonb5.github.io/charts/site/guide/common-library/#service) |
| service.ports.default.port | int | `8080` | Default port |
| service.ports.web | object | `{"port":8081}` | Calibre web server gui |
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