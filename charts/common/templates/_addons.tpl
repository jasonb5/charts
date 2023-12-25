{{- define "common.addons" }}
{{- include "common.addon" (list "codeserver" .Values) }}
{{- end }}

{{- define "common.addon" }}
{{- $name := first . }}
{{- $values := last . }}
{{- if hasKey $values "addons" }}
{{- $addon := get $values.addons $name }}
{{- if $addon.enabled }}
{{- $extraContainers := default dict $values.extraContainers }}
{{- $extraContainers = mustMerge $extraContainers (dict $name $addon) }}
{{- $_ := set $values "extraContainers" $extraContainers }}
{{- end }}
{{- end }}
{{- end }}
