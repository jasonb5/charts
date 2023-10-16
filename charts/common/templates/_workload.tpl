{{- define "common.workload" }}
{{- include "common.addons" . }}
{{- with .Values.workload }}
{{- $name := lower . }}
{{- if eq $name "cronjob" }}
{{- include "common.cronjob" $ }}
{{- else if eq $name "daemonset" }}
{{- include "common.daemonset" $ }}
{{- else if eq $name "deployment" }}
{{- include "common.deployment" $ }}
{{- else if eq $name "job" }}
{{- include "common.job" $ }}
{{- else if eq $name "statefulset" }}
{{- include "common.statefulset" $ }}
{{- end }}
---
{{- end }}
{{- include "common.mergeServices" (list .Values .Values.extraContainers .Values.initContainers) }}
{{- with .Values.service }}
{{- $values := mustMerge . (dict "workloadName" $.Values.workloadName "name" "default") }}
{{- $dot := dict "Values" $values "Release" $.Release "Chart" $.Chart }}
{{- include "common.service" $dot }}
---
{{- end }}
{{- include "common.mergeIngress" (list .Values .Values.extraContainers .Values.initContainers) }}
{{- with .Values.ingress }}
{{- if .enabled }}
{{- $values := mustMerge . (dict "workloadName" $.Values.workloadName "name" "default" "service" $.Values.service.ports) }}
{{- $dot := dict "Values" $values "Release" $.Release "Chart" $.Chart }}
{{- include "common.ingress" $dot }}
---
{{- end }}
{{- end }}
{{- include "common.mergePersistence" (list .Values .Values.extraContainers .Values.initContainers) }}
{{- range $key, $value := .Values.persistence }}
{{- if and (eq $value.type "pvc") $value.enabled (not $value.existingClaim) }}
{{- $values := mustMerge $value (dict "workloadName" $.Values.workloadName "name" $key) }}
{{- $dot := dict "Values" $values "Release" $.Release "Chart" $.Chart }}
{{- include "common.pvc" $dot }}
---
{{- end }}
{{- end }}
{{- with .Values.networkPolicy }}
{{- if .enabled }}
{{- $values := mustMerge . (dict "workloadName" $.Values.workloadName "name" "default" "service" $.Values.service) }}
{{- $dot := dict "Values" $values "Release" $.Release "Chart" $.Chart }}
{{- include "common.networkPolicy" $dot }}
---
{{- end }}
{{- end }}
{{- end }}
