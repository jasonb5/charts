{{- define "common.jobSpec" }}
{{- with .Values.activeDeadlineSeconds }}
activeDeadlineSeconds: {{ . }}
{{- end }}
{{- with .Values.backoffLimit }}
backoffLimit: {{ . }}
{{- end }}
{{- with .Values.backoffLimitPerIndex }}
backoffLimitPerIndex: {{ . }}
{{- end }}
{{- with .Values.completionMode }}
completionMode: {{ . }}
{{- end }}
{{- with .Values.completions }}
completions: {{ . }}
{{- end }}
{{- with .Values.maxFailedIndexes }}
maxFailedIndexes: {{ . }}
{{- end }}
{{- with .Values.parallelism }}
parallelism: {{ . }}
{{- end }}
{{- with .Values.podFailurePolicy }}
podFailurePolicy:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.podReplacementPolicy }}
podReplacementPolicy: {{ . }}
{{- end }}
template:
  spec:
  {{- include "common.pod" . | nindent 4 }}
{{- with .Values.ttlSecondsAfterFinished }}
ttlSecondsAfterFinished: {{ . }}
{{- end }}
{{- end }}

{{- define "common.job" }}
apiVersion: batch/v1
kind: Job
metadata:
{{- include "common.metadata" . | nindent 2 }}
spec:
{{- include "common.jobSpec" . | nindent 2 }}
{{- end }}
