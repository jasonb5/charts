{{- define "common.name.postfix" }}
{{- $workload := ternary "" (printf "-%s" .Values.workloadName) (or (not (hasKey .Values "workloadName")) (eq .Values.workloadName "default")) }}
{{- $name := ternary "" (printf "-%s" .Values.name) (or (not (hasKey .Values "name")) (eq .Values.name "default")) }}
{{- $postfix := printf "%s%s" $workload $name }}
{{- $base := include "common.name" . }}
{{- $baseLen := sub 63 (len $postfix) | int }}
{{- printf "%s%s" ($base | trunc $baseLen | trimSuffix "-") $postfix }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "common.fullname.postfix" -}}
{{- $workload := ternary "" (printf "-%s" .Values.workloadName) (or (not (hasKey .Values "workloadName")) (eq .Values.workloadName "default")) }}
{{- $name := ternary "" (printf "-%s" .Values.name) (or (not (hasKey .Values "name")) (eq .Values.name "default")) }}
{{- $postfix := printf "%s%s" $workload $name }}
{{- $base := include "common.fullname" . }}
{{- $baseLen := sub 63 (len $postfix) | int }}
{{- printf "%s%s" ($base | trunc $baseLen | trimSuffix "-") $postfix }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "common.labels" -}}
helm.sh/chart: {{ include "common.chart" . }}
{{ include "common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Print debug variable
*/}}
{{- define "common.debug" -}}
{{- printf "%s" (toPrettyJson .) | fail }}
{{- end }}

{{/*
Merge values from common with app values
*/}}
{{- define "common.merge" -}}
{{- $common := get .Values "common" }}
{{- $values := mustMergeOverwrite (deepCopy $common) (omit .Values "common") }}
{{- $_ := set $values "workloadName" "default" }}
{{- $_ := set $values "name" "default" }}
{{- $_ := set . "Values" $values }}
{{- $_ := set . "Defaults" $common }}
{{- $_ := set . "TemplateValues" . }}
{{- end }}

{{/*
Common metadata for objects
*/}}
{{- define "common.metadata" -}}
{{- with .Values.annotations }}
annotations:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- $labels := include "common.labels" . }}
{{- with .Values.labels }}
{{- $labels = mustMerge $labels . }}
{{- end }}
labels:
{{- $labels | nindent 2 }}
name: {{ include "common.fullname.postfix" . }}
namespace: {{ .Release.Namespace }}
{{- end }}

{{- define "common.collectImagePullSecrets" -}}
{{- $pullSecrets := dict }}
{{- with .image.pullSecrets }}
{{- $pullSecrets = mustMerge $pullSecrets (fromYaml (include "common.formatImagePullSecret" .)) }}
{{- end }}
{{- with .initContainers }}
{{- range $c := . }}
{{- with $c.image.pullSecrets }}
{{- $pullSecrets = mustMerge $pullSecrets (fromYaml (include "common.formatImagePullSecret" .)) }}
{{- end }}
{{- end }}
{{- end }}
{{- with .extraContainers }}
{{- range $c := . }}
{{- with $c.image.pullSecrets }}
{{- $pullSecrets = mustMerge $pullSecrets (fromYaml (include "common.formatImagePullSecret" .)) }}
{{- end }}
{{- end }}
{{- end }}
{{- if eq (len $pullSecrets) 0 }}
{{- printf "{}" }}
{{- else }}
{{- $stringData := dict ".dockerconfigjson" (toJson (dict "auths" $pullSecrets)) }}
{{- $base := dict "regcreds" (dict "type" "kubernetes.io/dockerconfigjson" "stringData" $stringData) }}
{{- printf "%s" (toYaml $base) }}
{{- end }}
{{- end }}

{{- define "common.formatImagePullSecret" -}}
{{- $auths := dict }}
{{- range $key, $value := . }}
{{- $username := required (printf "%r is missing username" $key) $value.username }}
{{- $password := required (printf "%r is missing password" $key) $value.password }}
{{- $email := required (printf "%r is missing email" $key) $value.email }}
{{- $auths = mustMerge $auths (dict $key (dict "email" $email "auth" (printf "%s:%s" $username $password | b64enc))) }}
{{- end }}
{{- printf "%s" (toYaml $auths) }}
{{- end }}
