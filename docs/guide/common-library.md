# Common library

This Helm library chart is used to build application charts.

## Workload

The `workload` key defines the workload type. The value can be `deployment`, `statefulset`, `daemonset`, `job`, or `cronjob`. The default is `null` which can be useful to create only top-level objects e.g. `configmap`, `secret`, `extraObjects`.

```yaml
workload: deployment
```

## ConfigMap

The `configmap` key defines a map, each key/value pair is a unique ConfigMap. The key can be used to reference the specific ConfigMap. The ConfigMap data is stored unied the `data` key. The values can be static values or templates.

```yaml
configmap:
  default:
    data:
      CONFIG_PATH: /config
      PORT: "{{ .Values.service.ports.default.port }}"
```

Examples using a ConfigMap.

```yaml
envFrom:
  default:
    type: configmap
```

```yaml
persistence:
  config:
    enabled: true
    type: configmap
```

## Secret

The `secret` key defines a map, each key/value pair is a unique Secret. The key can be used to reference the specific Secret. The Secret data is stored unied the `data` key. The values can be static values or templates.

```yaml
secret:
  default:
    data:
      PASSWORD: abcd1234
```

Examples using a Secret.

```yaml
envFrom:
  default:
    type: secret
```

```yaml
persistence:
  config:
    enabled: true
    type: secret
```

## Persistence

The `persistence` key is a map, the keys are unique identifiers for the volume. Each volume is disabled by default. The `type` can be `configmap`, `emptydir`, `hostpath`, `nfs`, `pvc`, or `secret`.

```yaml
persistence:
  config:
    enabled: true
    type: emptydir
```

## Service

The `service` key defines the service for the workflow. Each workflow has a single service. Each key/value under `ports` defines a single backend. The key can be used to reference the service port.

```yaml
service:
  ports:
    default:
      port: 80
```

## Ingress

The `ingress` key defines the ingress for the workflow. Each workload has a single ingress, which is disabled by default. Each value under `hosts` is a unique path.

```yaml
ingress:
  enabled: true
  hosts:
  - name: default
```

### TLS

TLS is enabled by setting `ingress.tls.enabled` to true. The `secretName` should reference a secret containing a key/cert pair.

```yaml
ingress:
  enabled: true
  hosts:
  - name: default
  tls:
    enabled: true
    secretName: tls-certs
```

## Network Policy

The `networkPolicy` key defines the network policy for the workflow. Each workflow has a single network policy, which is disabled by default. The default network policy adds a single rule for ingress and blocks egress. Additional ingress/egress rules can be added under the `ingress` and `egress` keys. To default ingress/egress rules can be disabled with `disableDefaultEgress` and `disableDefaultIngress` keys.

```yaml
networkPolicy:
  enabled: true
```

## Addons

The common library provides addons that are attached as `extraContainers`.

### Visual Studio Code

This addon will attach a sidecar running `Visual Code Studio`. The addons uses the [`ghcr.io/linuxserver/code-server`](https://github.com/linuxserver/docker-code-server/pkgs/container/code-server) container. The minimal configuration requires an ingress and persistence be defined.

```yaml
addons:
  codeserver:
    enabled: true
    ingress:
      enabled: false
      hosts:
      - name: codeserver
        host:
    persistence:
      config:
        type: pvc
```
