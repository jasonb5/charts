{{- define "common.workload" }}
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
{{- $services := default (dict "ports" dict) .Values.service }}
{{- with .Values.extraContainers }}
{{- range $value := values . }}
{{- with $value.service }}
{{- $_ := mustMerge $services.ports .ports }}
{{- end }}
{{- end }}
{{- end }}
{{- if gt (len $services.ports) 0 }}
{{- $values := mustMerge $services (dict "workloadName" $.Values.workloadName "name" "default") }}
{{- $dot := dict "Values" $values "Release" $.Release "Chart" $.Chart }}
{{- include "common.service" $dot }}
---
{{- end }}
{{- with .Values.ingress }}
{{- if .enabled }}
{{- $values := mustMerge . (dict "workloadName" $.Values.workloadName "name" "default" "service" $.Values.service.ports) }}
{{- $dot := dict "Values" $values "Release" $.Release "Chart" $.Chart }}
{{- include "common.ingress" $dot }}
---
{{- end }}
{{- end }}
{{- $persistence := default dict .Values.persistence }}
{{- with .Values.extraContainers }}
{{- $persistence = mustMerge $persistence . }}
{{- end }}
{{- with .Values.initContainers }}
{{- $persistence = mustMerge $persistence . }}
{{- end }}
{{- range $key, $value := $persistence }}
{{- if and (eq $value.type "pvc") $value.enabled }}
{{- $values := mustMerge $value (dict "workloadName" $.Values.workloadName "name" $key) }}
{{- $dot := dict "Values" $values "Release" $.Release "Chart" $.Chart }}
{{- include "common.pvc" $dot }}
---
{{- end }}
{{- end }}
{{- with .Values.networkPolicy }}
{{- if .enabled }}
{{- $values := mustMerge . (dict "workloadName" $.Values.workloadName "name" "default" "service" $services) }}
{{- $dot := dict "Values" $values "Release" $.Release "Chart" $.Chart }}
{{- include "common.networkPolicy" $dot }}
---
{{- end }}
{{- end }}
{{- end }}
