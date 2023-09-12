{{- define "common.configmap" }}
apiVersion: v1
data:
  {{- range $key, $value := .Values.data }}
  {{ $key }}: {{ toJson (tpl $value $.TemplateValues) }}
  {{- end }}
kind: ConfigMap
metadata:
{{- include "common.metadata" . | nindent 2 }}
{{- end }}
