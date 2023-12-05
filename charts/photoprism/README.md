# photoprism

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 231021-ce](https://img.shields.io/badge/AppVersion-231021--ce-informational?style=flat-square)

AI-Powered Photos App for the Decentralized Web 🌈💎✨

**Homepage:** <https://www.photoprism.app/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| jasonb5 |  |  |

## Source Code

* <https://github.com/jasonb5/charts/tree/main/charts/photoprism>
* <https://github.com/photoprism/photoprism>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| workload | string | `"deployment"` | The default [workload](https://jasonb5.github.io/charts/site/guide/common-library/#workload) type |
| image.repository | string | `"photoprism/photoprism"` | Container image repository |
| image.tag | string | Chart.AppVersion | Image tag |
| env | object | `{"PHOTOPRISM_ADMIN_PASSWORD":null,"PHOTOPRISM_EXPERIMENTAL":false,"TZ":"UTC"}` | Photoprism config [options](https://docs.photoprism.app/getting-started/config-options/) |
| env.TZ | string | `"UTC"` | Set the timezone |
| env.PHOTOPRISM_ADMIN_PASSWORD | string | `nil` | Set password for `admin` user |
| env.PHOTOPRISM_EXPERIMENTAL | bool | `false` | Enable/disable experimental features |
| service | object | `{"ports":{"default":{"port":2342}}}` | [Service](https://jasonb5.github.io/charts/site/guide/common-library/#service) |
| service.ports.default.port | int | `2342` | Default port |
| ingress | object | `{"enabled":false,"hosts":[{"host":null,"name":"default"}],"tls":{"enabled":false}}` | [Ingress](https://jasonb5.github.io/charts/site/guide/common-library/#ingress) |
| ingress.enabled | bool | `false` | Enable/disable ingress |
| ingress.hosts[0] | object | `{"host":null,"name":"default"}` | Reference default service |
| ingress.hosts[0].host | string | `nil` | Ingress hostname |
| ingress.tls | object | `{"enabled":false}` | [TLS](https://jasonb5.github.io/charts/site/guide/common-library/#tls) |
| ingress.tls.enabled | bool | `false` | Enable/disable tls |
| persistence | object | `{"import":{"enabled":false,"mountPath":"/photoprism/import","type":null},"originals":{"enabled":false,"mountPath":"/photoprism/originals","type":null},"storage":{"enabled":false,"mountPath":"/photoprism/storage","type":null}}` | [Persistence](https://jasonb5.github.io/charts/site/guide/common-library/#persistence) |
| persistence.storage.enabled | bool | `false` | Enable/disable storage mount (sidecar, cache, and database) |
| persistence.storage.type | string | `nil` | Type of volume mount |
| persistence.originals.enabled | bool | `false` | Enable/disable originals mount |
| persistence.originals.type | string | `nil` | Type of volume mount |
| persistence.import.enabled | bool | `false` | Enable/disable import mount |
| persistence.import.type | string | `nil` | Type of volume mount |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)