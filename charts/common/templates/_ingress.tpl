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
    {{- range $domain, $paths := .Values.hosts }}
    - http:
        paths:
        {{- range $path := $paths }}
        {{- $service := get $.Values.service $path.name }}
        - backend:
            name: {{ $path.name }}
            port:
              number: {{ $service.port }}
          path: {{ default "/" $path.path }}
          {{- with $path.pathType }}
          pathType: {{ . }}
          {{- end }}
        {{- end }}
      {{- if ne $domain "default" }}
      host: {{ $domain }}
      {{- end }}
    {{- end }}
  {{- with .Values.tls }}
  {{- $hosts := without (keys $.Values.hosts) "default" }}
  {{- $values := dict "Values" (dict "workloadName" "default" "name" .) "Release" $.Release "Chart" $.Chart }}
  tls:
  - hosts:
    {{- toYaml $hosts | nindent 4 }}
    secretName: {{ include "common.fullname.postfix" $values }}
  {{- end }}
{{- end }}
