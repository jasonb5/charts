{{- define "common.service" }}
apiVersion: v1
kind: Service
metadata:
{{- include "common.metadata" . | nindent 2 }}
spec:
  {{- with .Values.loadBalancerIP }}
  loadBalancerIP: {{ . }}
  {{- end }}
  ports:
  {{- range $key, $value := .Values.ports }}
  - name: {{ ternary (include "common.name" $) $key (eq $key "default") }}
    {{- with $value.nodePort }}
    nodePort: {{ . }}
    {{- end }}
    port: {{ default $value.port $value.exposedPort }}
    protocol: {{ default "TCP" $value.protocol }}
    targetPort: {{ $value.port }}
  {{- end }}
  selector:
  {{- include "common.selectorLabels" . | nindent 4 }}
  {{- with .Values.type }}
  type: {{ . }}
  {{- end }}
{{- end }}
