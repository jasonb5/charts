{{- define "common.addons" }}
{{- if .Values.addons.codeserver.enabled }}
{{- include "common.addons.codeserver" . }}
{{- end }}
{{- end }}

{{- define "common.addons.codeserver" }}
{{- $extraContainers := default dict .Values.extraContainers }}
{{- with .Values.addons.codeserver }}
{{- $extraContainers := mustMerge $extraContainers (dict "codeserver" .) }}
{{- end }}
{{- $_ := set .Values "extraContainers" $extraContainers }}
{{- end }}
