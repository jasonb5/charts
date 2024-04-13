# wallabag

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.6.9](https://img.shields.io/badge/AppVersion-2.6.9-informational?style=flat-square)

wallabag is a self hostable application for saving web pages. Unlike other services, wallabag is free (as in freedom) and open source.

With this application you will not miss content anymore. Click, save, read it when you want. It saves the content you select so that you can read it when you have time.

**Homepage:** <https://wallabag.org/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| jasonb5 |  |  |

## Source Code

* <https://github.com/jasonb5/charts/tree/main/charts/wallabag>
* <https://github.com/wallabag/wallabag>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://jasonb5.github.io/charts | common | 0.1.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| workload | string | `"deployment"` | The default [workload](https://jasonb5.github.io/charts/site/guide/common-library/#workload) type |
| image.repository | string | `"wallabag/wallabag"` | Container image repository |
| image.tag | string | Chart.AppVersion | Image tag |
| env.TZ | string | `"UTC"` | Set the timezone |
| env.SYMFONY__ENV__SECRET | string | `nil` | Secret key used to generate security-related tokens |
| env.SYMFONY__ENV__DOMAIN_NAME | string | `nil` | Full url of install e.g. http://127.0.0.1:80 |
| service | object | `{"ports":{"default":{"port":80}}}` | [Service](https://jasonb5.github.io/charts/site/guide/common-library/#service) |
| service.ports.default.port | int | `80` | Default port |
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