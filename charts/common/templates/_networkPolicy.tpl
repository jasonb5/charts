{{- define "common.defaultIngress" -}}
value:
  - from:
      - podSelector: {}
    ports:
      {{- range $value := values .ports }}
      {{- $type := default "TCP" $value.protocol }}
      {{- if eq $type "TCP" }}
      - protocol: TCP
        port: {{ .port }}
      {{- else }}
      - protocol: UDP
        port: {{ .port }}
      {{- end }}
      {{- end }}
{{- end }}

{{- define "common.networkPolicy" }}
apiVersion: v1
kind: NetworkPolicy
metadata:
{{- include "common.metadata" . | nindent 2 }}
spec:
  {{- if not .Values.disableDefaultEgress  }}
  {{- $_ := set .Values "egress" (concat (default list .Values.egress) (list dict)) }}
  {{- end }}
  {{- with .Values.egress }}
  egress:
    {{- range $value := . }}
    - {{ toYaml $value | nindent 6 }}
    {{- end }}
  {{- end }}
  {{- if not .Values.disableDefaultIngress }}
  {{- $defaultIngress := include "common.defaultIngress" .Values.service }}
  {{- $_ := set .Values "ingress" (concat (default list .Values.ingress) (fromYaml $defaultIngress).value) }}
  {{- end }}
  {{- with .Values.ingress }}
  ingress:
    {{- range $value := . }}
    - {{ toYaml $value | nindent 6 }}
    {{- end }}
  {{- end }}
  {{- $podSelector := default (include "common.selectorLabels" .) .Values.podSelector }}
  podSelector:
  {{- $podSelector | nindent 4 }}
  policyTypes:
  {{- with .Values.egress }}
  - Egress
  {{- end }}
  {{- with .Values.ingress }}
  - Ingress
  {{- end }}
{{- end }}
