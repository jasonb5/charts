{{- define "common.addons.codeserver" }}
{{- $tag := default "latest" .Values.addons.codeserver.tag }}
{{- $pullPolicy := default "Always" .Values.addons.codeserver.pullPolicy }}
{{- $image := dict "repository" "ghcr.io/linuxserver/code-server" "tag" $tag "pullPolicy" $pullPolicy }}
{{- $service := dict "ports" (dict "codeserver" (dict "port" 8443)) }}
{{- $persistence := dict "config" (dict "enabled" true "type" "emptydir") }} 
{{- with .Values.addons.codeserver.persistence }}
{{- $persistence = mustMergeOverwrite $persistence . }}
{{- end }}
{{- $container := dict "image" $image "service" $service "persistence" $persistence }}
{{- $extraContainers := default dict .Values.extraContainers }}
{{- $ingress := default (dict "enabled" true "hosts" list) .Values.ingress }}
{{- $path := default "/" .Values.addons.codeserver.ingress.path }}
{{- $pathType := default "ImplementationSpecific" .Values.addons.codeserver.ingress.pathType }}
{{- $host := dict "name" "codeserver" "paths" (list (dict "path" $path "pathType" $pathType)) }}
{{- with .Values.addons.codeserver.ingress.host }}
{{- $_ := set $host "host" . }}
{{- end }}
{{- $_ := set $ingress "hosts" (mustAppend $ingress.hosts $host) }}
{{- $_ := set .Values "ingress" $ingress }}
{{- $_ := set .Values "extraContainers" (mustMerge $extraContainers (dict "codeserver" $container)) }}
{{- end }}
