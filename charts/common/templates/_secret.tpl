{{- define "common.secret" }}
apiVersion: v1
{{- with .Values.data }}
data:
  {{- range $key, $value := . }}
  {{ $key }}: {{ toJson (tpl $value $.TemplateValues) | b64enc }}
  {{- end }}
{{- end }}
kind: Secret
metadata:
{{- include "common.metadata" . | nindent 2 }}
{{- with .Values.stringData }}
stringData:
  {{- range $key, $value := . }}
  {{ $key }}: {{ toJson (tpl $value $.TemplateValues) }}
  {{- end }}
{{- end }}
type: {{ default "Opaque" .Values.type }}
{{- end }}
