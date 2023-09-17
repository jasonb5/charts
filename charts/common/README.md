# common

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: library](https://img.shields.io/badge/Type-library-informational?style=flat-square)

A Helm chart for Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| workload | string | `nil` | Workload can be cronjob, daemonset, deployment, job, pod, or statefulset. |
| configmap | object | `nil` | Map of ConfigMaps, these are not unique to the workload. |
| secret | object | `nil` | Map of Secrets, these are not unique to the workload. |
| ingress | object | `nil` | Map of ingress, these are specific to the workload. |
| persistence | object | `nil` | Map of persistence, these are specifi to the workload. |
| annotations | object | `nil` | Annotations for default workload. |
| labels | object | `nil` | Labels for default workload. |
| extraWorkloads | object | `nil` | Extra workloads to create. |
| extraObjects | object | `nil` | Extra objects to create. |
| networkPolicy.enabled | bool | `false` | Enable/disable NetworkPolicy. |
| networkPolicy.disableDefaultEgress | bool | `false` | Disable default egress rules. |
| networkPolicy.disableDefaultIngress | bool | `false` | Disable default ingress rules. |
| networkPolicy.egress | list | `nil` | Egress rules that will be merged with default rules. |
| networkPolicy.ingress | list | `nil` | Ingress rules that will be merged with default rules. |
| concurrencyPolicy | string | `nil` | CronJob [concurrency policy](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#concurrency-policy) |
| failedJobHistoryLimit | string | `nil` | CronJob [job history](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#jobs-history-limits) |
| schedule | string | `nil` | CronJob [schedule](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#schedule-syntax) |
| startingDeadlineSeconds | string | `nil` | CronJob [starting deadline](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#starting-deadline) |
| successfulJobHistoryLimit | string | `nil` | CronJob [job history](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#jobs-history-limits) |
| timeZone | string | `nil` | CronJob [time zone](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#time-zones) |
| jobActiveDeadlineSeconds | string | `nil` | Job [active deadline](https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup) |
| backoffLimit | string | `nil` | Job [backoff limit](https://kubernetes.io/docs/concepts/workloads/controllers/job/#pod-backoff-failure-policy) |
| backoffLimitPerIndex | string | `nil` | Job [backoff limit per index](https://kubernetes.io/docs/concepts/workloads/controllers/job/#backoff-limit-per-index) |
| completionMode | string | `nil` | Job [completion mode](https://kubernetes.io/docs/concepts/workloads/controllers/job/#completion-mode) |
| completions | string | `nil` | Job [completions](https://kubernetes.io/docs/concepts/workloads/controllers/job/#completion-mode) |
| maxFailedIndexes | string | `nil` | Job [max failed indexes](https://kubernetes.io/docs/concepts/workloads/controllers/job/#backoff-limit-per-index) |
| parallelism | string | `nil` | Job [parallelism](https://kubernetes.io/docs/concepts/workloads/controllers/job/#parallel-jobs) |
| podFailurePolicy | string | `nil` | Job [pod failure policy](https://kubernetes.io/docs/concepts/workloads/controllers/job/#pod-failure-policy) |
| podReplacementPolicy | string | `nil` | Job [pod replacement policy](https://kubernetes.io/docs/concepts/workloads/controllers/job/#pod-replacement-policy) |
| ttlSecondsAfterFinished | string | `nil` | Job [ttl seconds after finished](https://kubernetes.io/docs/concepts/workloads/controllers/job/#ttl-mechanism-for-finished-jobs) |
| minReadySeconds | string | `nil` | Deployment, DaemonSet, StatefulSet [min ready seconds](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#min-ready-seconds) |
| progressDeadlineSeconds | string | `nil` | Deployment, DaemonSet, StatefulSet [progress deadline seconds](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#progress-deadline-seconds) |
| replicas | int | `1` | Deployment, DaemonSet, StatefulSet number of pod replicas |
| revisionHistoryLimit | string | `nil` | Deployment, DaemonSet, StatefulSet [revision history limit](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#revision-history-limit) |
| strategy | object | `{"type":"Recreate"}` | Deployment, DaemonSet, StatefulSet [strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) |
| updateStrategy | object | `{"type":"OnDelete"}` | StatefulSets, DaemonSet [update strategy](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies) |
| ordinals | string | `nil` | StatefulSets [ordinals](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#start-ordinal) |
| persistentVolumeClaimRetentionPolicy | string | `nil` | StatefulSets [persistent volume claim retention policy](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#persistentvolumeclaim-retention) |
| podManagementPolicy | string | `nil` | StatefulSets [pod management policy](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#persistentvolumeclaim-retention) |
| serviceName | string | `nil` | StatefulSets [service name](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#stable-network-id) |
| volumeClaimTemplates | string | `nil` | StatefulSets [volume claim templates](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#volume-claim-templates) |
| activeDeadlineSeconds | string | `nil` | Pod [active deadline seconds](https://kubernetes.io/docs/concepts/workloads/pods/#pod-update-and-replacement) |
| affinity | string | `nil` | Pod [affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) |
| dnsConfig | string | `nil` | Pod [dns config](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config) |
| dnsPolicy | string | `nil` | Pod [dns policy](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy) |
| hostAliases | string | `nil` | Pod [host aliases](https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/) |
| hostIPC | string | `nil` | Pod pass through host IPC |
| hostNetwork | string | `nil` | Pod pass through host network |
| hostPID | string | `nil` | Pod pass through host PID |
| hostUsers | string | `nil` | Pod pass through host users |
| hostname | string | `nil` | Pod hostname |
| initContainers | string | `nil` | Pod [init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#using-init-containers) |
| extraContainers | string | `nil` | Pod extra containers to include with the default container |
| nodeName | string | `nil` | Pod [nodeName](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodename) |
| nodeSelector | string | `nil` | Pod [node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) |
| preemptionPolicy | string | `nil` | Pod [preemption policy](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#preemption) |
| priority | string | `nil` | Pod [priority](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#pod-priority) |
| priorityClassName | string | `nil` | Pod [priority class name](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#priorityclass) |
| podRestartPolicy | string | `nil` | Pod [restart poliyc](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy) |
| runtimeClassName | string | `nil` | Pod [runtime class name](https://kubernetes.io/docs/concepts/containers/runtime-class/) |
| podSecurityContext | string | `nil` | Pod [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| serviceAccount | string | `nil` | Pod [service account](https://kubernetes.io/docs/concepts/security/service-accounts/) |
| terminationGracePeriodSeconds | string | `nil` | Pod [termination grace period seconds](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#deployment-and-scaling-guarantees) |
| tolerations | string | `nil` | Pod [tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) |
| args | string | `nil` | Container [args](https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/) |
| command | string | `nil` | Container [command](https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/) |
| env | string | `nil` | Container [env](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/) |
| envFrom | string | `nil` | Container [envFrom](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/) |
| image.repository | string | `nil` | Container [repository](https://kubernetes.io/docs/concepts/containers/images/#image-names) |
| image.tag | string | `nil` | Container [tag](https://kubernetes.io/docs/concepts/containers/images/#image-names) |
| image.pullSecrets | string | `nil` | Container [pullSecrets](https://kubernetes.io/docs/concepts/containers/images/#using-a-private-registry) |
| image.pullPolicy | string | `nil` | Cotnainer [pullPolicy](https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy) |
| lifecycle | string | `nil` | Container [lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/) |
| livenessProbe | string | `nil` | Container [livenessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| readinessProbe | string | `nil` | Container [readinessProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| resources | string | `nil` | Container [resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| restartPolicy | string | `nil` | Container [restartPolicy](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy) |
| securityContext | string | `nil` | Container [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| startupProbe | string | `nil` | Container [startupProbe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| workingDir | string | `nil` | Container working directory |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
