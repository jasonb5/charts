{{- define "common.app" }}
{{- include "common.merge" . }}
{{- include "common.addons" . }}
{{- include "common.workload" . }}
{{- with .Values.configmap }}
{{- range $key, $value := . }}
{{- $values := mustMerge $value (dict "workloadName" "default" "name" $key) }}
{{- $dot := dict "Values" $values "TemplateValues" $.TemplateValues "Release" $.Release "Chart" $.Chart }}
{{- include "common.configmap" $dot }}
---
{{- end }}
{{- end }}
{{- $secrets := fromYaml (include "common.collectImagePullSecrets" .Values) }}
{{- with .Values.secret }}
{{- $secrets = mustMerge $secrets . }}
{{- end }}
{{- if gt (len $secrets) 0 }}
{{- range $key, $value := $secrets }}
{{- $values := mustMerge $value (dict "workloadName" "default" "name" $key) }}
{{- $dot := dict "Values" $values "TemplateValues" $.TemplateValues "Release" $.Release "Chart" $.Chart }}
{{- include "common.secret" $dot }}
---
{{- end }}
{{- end }}
{{- with .Values.extraWorkloads }}
{{- range $key, $value := . }}
{{- $values := mustMergeOverwrite $.Defaults $value (dict "workloadName" $key "name" "default") }}
{{- $dot := dict "Values" $values "TemplateValues" $.TemplateValues "Release" $.Release "Chart" $.Chart }}
{{- include "common.workload" $dot }}
{{- end }}
{{- end }}
{{- with .Values.extraObjects }}
{{- range . }}
{{- if eq (kindOf .) "string" }}
{{ tpl . $.TemplateValues }}
{{- else }}
{{ toYaml . }}
{{- end }}
---
{{- end }}
{{- end }}
{{- end }}
