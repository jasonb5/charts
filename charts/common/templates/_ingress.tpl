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
  {{- range $serviceName, $host := .Values.hosts }}
  - http:
      paths:
      {{- $service := get $.Values.service $serviceName }}
      {{- range $path := $host.paths }}
      {{- $values := dict "Values" (dict "workloadName" "default" "name" "default") "Release" $.Release "Chart" $.Chart }}
      - backend:
          service:
            name: {{ include "common.fullname.postfix" $values }}
            port:
              number: {{ $service.port }}
        path: {{ default "/" $path.path }}
        pathType: {{ default "Prefix" $path.pathType }}
      {{- end }}
    {{- with $host.host }}
    host: {{ . }}
    {{- end }}
  {{- end }}
  {{- with .Values.tls }}
  {{- $hosts := without (keys $.Values.hosts) "default" }}
  {{- $values := dict "Values" (dict "workloadName" "default" "name" .) "Release" $.Release "Chart" $.Chart }}
  tls:
  - hosts:
    {{- range $host := values $.Values.hosts }}
    {{- with $host.host }}
    - {{ . }}
    {{- end }}
    {{- end }}
    secretName: {{ include "common.fullname.postfix" $values }}
  {{- end }}
{{- end }}
