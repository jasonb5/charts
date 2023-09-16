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
Each workload has a single ingress, which is disabled by default. Each key under `hosts` is a domain referenced by the ingress. Each domain can have multiple paths. The `default` domain is the equivalent of setting `host` to `*`.
```yaml
ingress:
  enabled: true
  hosts:
    default:
      - path: /home
        pathType: Prefix
        name: https
    domain.io:
      - name: default
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
