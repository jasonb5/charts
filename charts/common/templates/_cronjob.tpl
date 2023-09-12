{{- define "common.cronjob" }}
apiVersion: batch/v1
kind: CronJob
metadata:
{{- include "common.metadata" . | nindent 2 }}
spec:
  {{- with .Values.concurrencyPolicy }}
  concurrencyPolicy: {{ . }}
  {{- end }}
  {{- with .Values.failedJobHistoryLimit }}
  failedJobHistoryLimit: {{ . }}
  {{- end }}
  jobTemplate:
    spec:
    {{- include "common.jobSpec" . | nindent 6 }}
  schedule: {{ .Values.schedule | quote }}
  {{- with .Values.startingDeadlineSeconds }}
  startingDeadlineSeconds: {{ . }}
  {{- end }}
  {{- with .Values.successfulJobHistoryLimit }}
  successfulJobHistoryLimit: {{ . }}
  {{- end }}
  {{- with .Values.timeZone }}
  timeZone: {{ . }}
  {{- end }}
{{- end }}
