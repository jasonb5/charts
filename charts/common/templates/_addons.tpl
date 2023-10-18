{{- define "common.addons" }}
{{- include "common.addon" (list "codeserver" .Values) }}
{{- include "common.addon" (list "rclone" .Values) }}
{{- end }}

{{- define "common.addon" }}
{{- $name := first . }}
{{- $values := last . }}
{{- $addon := get $values.addons $name }}
{{- if $addon.enabled }}
{{- $extraContainers := default dict $values.extraContainers }}
{{- $extraContainers = mustMerge $extraContainers (dict $name $addon) }}
{{- $_ := set $values "extraContainers" $extraContainers }}
{{- end }}
{{- end }}
