# homeassistant

![Version: 0.1.37](https://img.shields.io/badge/Version-0.1.37-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2024.7.2](https://img.shields.io/badge/AppVersion-2024.7.2-informational?style=flat-square)

🏡 Open source home automation that puts local control and privacy first.

**Homepage:** <https://www.home-assistant.io/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| jasonb5 |  |  |

## Source Code

* <https://github.com/jasonb5/charts/tree/main/charts/homeassistant>
* <https://github.com/home-assistant/core>
* <https://github.com/linuxserver/docker-homeassistant>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://jasonb5.github.io/charts | common | 0.1.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| workload | string | `"deployment"` | The default [workload](https://jasonb5.github.io/charts/site/guide/common-library/#workload) type |
| image.repository | string | `"ghcr.io/linuxserver/homeassistant"` | Container image repository |
| image.tag | string | Chart.AppVersion | Image tag |
| env.TZ | string | `"UTC"` | Set the timezone |
| hostNetwork | bool | `false` | Set to true for Home Assistant to desicover and automatically configure zeroconf/mDNS and UPnP devices |
| dnsConfig.options[0].name | string | `"ndots"` |  |
| dnsConfig.options[0].value | string | `"1"` |  |
| service | object | `{"ports":{"default":{"port":8123}}}` | [Service](https://jasonb5.github.io/charts/site/guide/common-library/#service) |
| service.ports.default.port | int | `8123` | Default port |
| ingress | object | `{"enabled":false,"hosts":[{"host":null,"name":"default"}],"tls":{"enabled":false}}` | [Ingress](https://jasonb5.github.io/charts/site/guide/common-library/#ingress) |
| ingress.enabled | bool | `false` | Enable/disable ingress |
| ingress.hosts[0] | object | `{"host":null,"name":"default"}` | Reference default service |
| ingress.hosts[0].host | string | `nil` | Ingress hostname |
| ingress.tls | object | `{"enabled":false}` | [TLS](https://jasonb5.github.io/charts/site/guide/common-library/#tls) |
| ingress.tls.enabled | bool | `false` | Enable/disable tls |
| persistence | object | `{"config":{"enabled":false,"size":"1Gi","type":"pvc"},"usb":{"enabled":false,"mountType":"CharDevice","path":null,"type":"hostpath"}}` | [Persistence](https://jasonb5.github.io/charts/site/guide/common-library/#persistence) |
| persistence.config.enabled | bool | `false` | Enable/disable persistence |
| persistence.config.type | string | `"pvc"` | Type of volume mount |
| persistence.config.size | string | `"1Gi"` | Size of volume |
| persistence.usb | object | `{"enabled":false,"mountType":"CharDevice","path":null,"type":"hostpath"}` | Example for USB device |

{%
include-markdown "../../charts/homeassistant/CUSTOM.md"
%}

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)
