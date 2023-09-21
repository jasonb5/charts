{{- define "common.addons" }}
{{- if .Values.addons.codeserver.enabled }}
{{- include "common.addons.codeserver" . }}
{{- end }}
{{- end }}
