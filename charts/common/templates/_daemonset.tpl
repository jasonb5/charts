{{- define "common.daemonset" }}
apiVersion: v1
kind: DaemonSet
metadata:
{{- include "common.metadata" . | nindent 2 }}
spec:
  {{- with .Values.minReadySeconds }}
  minReadySeconds: {{ . }}
  {{- end }}
  {{- with .Values.revisionHistoryLimit }}
  revisionHistoryLimit: {{ . }}
  {{- end }}
  selector:
    matchlabels:
    {{- include "common.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
      {{- include "common.selectorLabels" . | nindent 8 }}
    spec:
    {{- include "common.pod" . | nindent 6 }}
  {{- with .Values.updateStrategy }}
  updateStrategy:
  {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
