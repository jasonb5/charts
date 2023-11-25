{{- define "common.ingress" }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
{{- include "common.metadata" . | nindent 2 }}
spec:
  {{- with .Values.className }}
  ingressClassName: {{ . }}
  {{- end }}
  rules:
  {{- range $host := .Values.hosts }}
  - http:
      paths:
      {{- $service := get $.Values.service $host.name }}
      {{- $paths := ternary $host.paths (list (dict "path" "/" "pathType" "ImplementationSpecific")) (hasKey $host "paths") }}
      {{- range $paths }}
      {{- $values := dict "Values" (dict "workloadName" "default" "name" "default") "Release" $.Release "Chart" $.Chart }}
      - backend:
          service:
            name: {{ include "common.fullname.postfix" $values }}
            port:
              number: {{ $service.port }}
        path: {{ .path }}
        pathType: {{ default "ImplementationSpecific" .pathType }}
      {{- end }}
    {{- with $host.host }}
    host: {{ . }}
    {{- end }}
  {{- end }}
  {{- if .Values.tls.enabled }}
  {{- $hosts := list }}
  {{- range .Values.hosts }}
  {{- if hasKey . "host" }}
  {{- $hosts = append $hosts .host }}
  {{- end }}
  {{- end }}
  tls:
  - hosts:
    {{- range $hosts }}
    - {{ . }}
    {{- end }}
    secretName: {{ .Values.tls.secretName }}
  {{- end }}
{{- end }}
