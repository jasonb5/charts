{{- define "common.deployment" }}
apiVersion: apps/v1
kind: Deployment
metadata:
{{- include "common.metadata" . | nindent 2 }}
spec:
  {{- with .Values.minReadySeconds }}
  minReadySeconds: {{ . }}
  {{- end }}
  {{- with .Values.progressDeadlineSeconds }}
  progressDeadlineSeconds: {{ . }}
  {{- end }}
  replicas: {{ .Values.replicas }}
  {{- with .Values.revisionHistoryLimit }}
  revisionHistoryLimit: {{ . }}
  {{- end }}
  selector:
    matchLabels:
    {{- include "common.selectorLabels" . | nindent 6 }}
  {{- with .Values.strategy }}
  strategy:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  template:
    metadata:
      labels:
      {{- include "common.selectorLabels" . | nindent 8 }}
    spec:
    {{- include "common.pod" . | nindent 6 }}
{{- end }}
