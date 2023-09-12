{{- define "common.statefulset" }}
apiVersion: apps/v1
kind: StatefulSet
metadata:
{{- include "common.metadata" . | nindent 2 }}
spec:
  {{- with .Values.minReadySeconds }}
  minReadySeconds: {{ . }}
  {{- end }}
  {{- with .Values.ordinals }}
  ordinals: {{ . }}
  {{- end }}
  {{- with .Values.persistentVolumeClaimRetentionPolicy }}
  persistentVolumeClaimRetentionPolicy: {{ . }}
  {{- end }}
  {{- with .Values.podManagementPolicy }}
  podManagementPolicy: {{ . }}
  {{- end }}
  replicas: {{ .Values.replicas }}
  {{- with .Values.revisionHistoryLimit }}
  revisionHistoryLimit: {{ . }}
  {{- end }}
  selector:
    matchlabels:
    {{- include "common.selectorLabels" . | nindent 6 }}
  {{- with .Values.serviceName }}
  serviceName: {{ . }}
  {{- end }}
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
  {{- with .Values.volumeClaimTemplates }}
  volumeClaimTemplates: {{ . }}
  {{- end }}
{{- end }}
