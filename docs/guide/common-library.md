# Common library
This Helm library chart is used to build application charts.

Everything in the `values.yaml` is defined as a map, where the key is the name of the Kubernetes resource. There can only be a single `default` key, any other key will be appended to the default resource name, e.g. `config` would be appended as `-config` to the default name.

## Workload
Workload can be set to `deployment`, `statefulset`, `daemonset`, `job`, or `cronjob`.
```yaml
workload: deployment
```
### No Workload
If workload is not defined then no default workload is generated. This can be useful to create any top-level objects e.g. `configmap`, `secret`, or `extraObjects`.

## ConfigMap
ConfigMaps are defined in a map, where each key is a separate ConfigMap. The following example would create two ConfigMap objects. The values of the ConfigMap keys can be templates to reference other resource definitions.
```yaml
configmap:
  default:
    CONFIG_PATH: /config
  app:
    PORT: "{{ .Values.service.ports.default.port }}"
```
### Reference ConfigMap
To reference a ConfigMap in the default container using `envFrom` you simply use the key of the ConfigMap.
```yaml 
envFrom:
  default:
    type: configmap
```

This works for containers defined in `extraContainers` as well.
```yaml
extraContainers:
  sidecar:
    envFrom:
      default:
        type: configmap
```

## Secret
Secrets like ConfigMaps are defined in a map, where each key is a separate Secret. The following example would create two Secret objects. The values of the Secret keys can be templates to reference other resource definitions.
```yaml
secret:
  default:
    PASSWORD: abcd1234
  app:
    DB_PASSWORD: 1234
```
### Reference Secret
To reference a Secret in the default container using `envFrom` you simply use the key of the Secret.
```yaml 
envFrom:
  default:
    type: secret
```

This works for containers defined in `extraContainers` as well.
```yaml
extraContainers:
  sidecar:
    envFrom:
      default:
        type: secret
```

## Persistence
Persistence is defined as a map, the key can be used to reference the storage. The `type` can be `configmap`, `emptydir`, `hostpath`, `nfs`, `pvc`, or `secret`.
```yaml
persistence:
  config:
    type: emptydir
  data:
    type: nfs
    server: 192.168.0.1
    path: /mnt/user/appdata
```

## Service
Each workload has a single service. Each key under `ports` references a single port of the default container.
```yaml
service:
  ports:
    default:
      port: 80
    https:
      port: 443
```

## Ingress
Each workload has a single ingress, which is disabled by default. Each item under `hosts` is an ingress path, at a minimum `name` needs to be defined to reference the target service. If `host` is not defined on the ingress path then the host will default to "*". If the `paths` key is not defined on the ingress path, then a default path will be added for "/".
```yaml
ingress:
  enabled: true
  hosts:
  # A basic ingress path that will have a single path `/` to the default service
  - name: default
  - name: https
    host: domain.io
    paths:
    - path: /home
      pathType: Prefix
```
### TLS
If the `tls` key under `ingress` is present then it's value will be the secret name containing the certs. The `hosts` key under `tls` will be auto populated with any hosts that are defined.
```yaml
ingress:
  enabled: true
  hosts:
  - name: https
    host: domain.io
    paths:
    - path: /home
  tls: tls-certs
```

## Network Policy
The network policy is disabled by default. Once enabled the default policy will add ingress rules for each service port and allows all egress traffic. Custom egress and ingress rules can be added to `egress` and `ingress` keys, these will be merged with the default rules. The default rules can be disabled with `disableDefaultEgress` and `disableDefaultIngress`.
```yaml
networkPolicy:
  enabled: true
  disableDefaultEgress: false
  disableDefaultIngress: false
  egress:
  ingress:
```

## Addons
The common library provides addons that are attached as `extraContainers`.

### Visual Studio Code
This addon will attach an instance of `Visual Code Studio` to the workload. The addons uses the [`ghcr.io/linuxserver/code-server`](https://github.com/linuxserver/docker-code-server/pkgs/container/code-server) container. The tag, persistence and ingress can be customized.
```yaml
addons:
  codeserver:
    enabled: true
    tag: 4.16.1
    pullPolicy: IfNotPresent
    ingress:
      host: code.domain.io
      path: /code
      pathType: Prefix
    persistence:
      config:
        type: pvc
```
