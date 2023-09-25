{{- define "common.pvc" }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
{{- include "common.metadata" . | nindent 2 }}
spec:
  accessModes:
  - {{ default "ReadWriteOnce" .Values.accessMode }}
  {{- with .Values.dataSource }}
  dataSource:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.dataSourceRef }}
  dataSourceRef:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  resources:
    requests:
      storage: {{ .Values.size }}
  {{- with .Values.selector }}
  selector:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.storageClassName }}
  storageClassName: {{ . }}
  {{- end }}
  volumeMode: Filesystem
  {{- with .Values.volumeName }}
  volumeName: {{ . }}
  {{- end }}
{{- end }}
