{{- define "common.pod" }}
{{- $volumes := default dict .Values.persistence }}
{{- with .Values.activeDeadlineSeconds }}
activeDeadlineSeconds: {{ . }}
{{- end }}
{{- with .Values.affinity }}
affinity:
{{- toYaml . | nindent 2 }}
{{- end }}
containers:
{{- include "common.container" . | nindent 2 }}
{{- with .Values.extraContainers }}
{{- range $key, $value := . }}
{{- range $name, $volume := default dict $value.persistence }}
{{- if not (hasKey $volumes $name) }}
{{- $volumes := mustMerge $volumes (dict $name $volume) }}
{{- end }}
{{- end }}
{{- $values := mustMerge $value (dict "workloadName" $.Values.workloadName "name" $key) }}
{{- $dot := dict "Values" $values "TemplateValues" $.TemplateValues "Release" $.Release "Chart" $.Chart }}
{{- include "common.container" $dot | nindent 2 }}
{{- end }}
{{- end }}
{{- with .Values.dnsConfig }}
dnsConfig:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.dnsPolicy }}
dnsPolicy: {{ . }}
{{- end }}
{{- with .Values.hostAliases }}
hostAliases:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.hostIPC }}
hostIPC: {{ . }}
{{- end }}
{{- with .Values.hostNetwork }}
hostNetwork: {{ . }}
{{- end }}
{{- with .Values.hostPID }}
hostPID: {{ . }}
{{- end }}
{{- with .Values.hostUsers }}
hostUsers: {{ . }}
{{- end }}
{{- with .Values.hostname }}
hostname: {{ . }}
{{- end }}
{{- with .Values.image.pullSecrets }}
{{- $dot := dict "Values" (dict "workloadName" "default" "name" "regcreds") "Release" $.Release "Chart" $.Chart }}
imagePullSecrets:
- name: {{ include "common.fullname.postfix" $dot }}
{{- end }}
{{- with .Values.initContainers }}
initContainers:
{{- range $key, $value := . }}
{{- range $name, $volume := default dict $value.persistence }}
{{- if not (hasKey $volumes $name) }}
{{- $volumes := mustMerge $volumes (dict $name $volume) }}
{{- end }}
{{- end }}
{{- $values := mustMerge $value (dict "workloadName" $.Values.workloadName "name" $key) }}
{{- $dot := dict "Values" $values "TemplateValues" $.TemplateValues "Release" $.Release "Chart" $.Chart }}
{{- include "common.container" $dot | nindent 2 }}
{{- end }}
{{- end }}
{{- with .Values.nodeName }}
nodeName: {{ . }}
{{- end }}
{{- with .Values.nodeSelector }}
nodeSelector:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.preemptionPolicy }}
preemptionPolicy: {{ . }}
{{- end }}
{{- with .Values.priority }}
priority: {{ . }}
{{- end }}
{{- with .Values.priorityClassName }}
priorityClassName: {{ . }}
{{- end }}
{{- with .Values.podRestartPolicy }}
restartPolicy: {{ . }}
{{- end }}
{{- with .Values.runtimeClassName }}
runtimeClassName: {{ . }}
{{- end }}
{{- with .Values.podSecurityContext }}
securityContext:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.serviceAccount }}
serviceAccountName: {{ .name }}
{{- end }}
{{- with .Values.terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ . }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- if gt (len $volumes) 0 }}
volumes:
{{- range $key, $value := $volumes }}
{{- if $value.enabled }}
{{- $values := dict "Values" (dict "workloadName" $.Values.workloadName "name" $key) "Release" $.Release "Chart" $.Chart }}
- name: {{ ternary (include "common.name" $) $key (eq $key "default") }}
  {{- $type := default "pvc" $value.type }}
  {{- if eq $type "configmap" }}
  configMap:
    {{- if $value.configMapName }}
    name: {{ $value.configMapName }}
    {{- else }}
    name: {{ include "common.fullname.postfix" $values }}
    {{- end }}
  {{- else if eq $type "emptydir" }}
  emptyDir: {}
  {{- else if eq $type "hostpath" }}
  hostPath:
    path: {{ $value.path }}
    {{- with $value.mountType }}
    type: {{ . }}
    {{- end }}
  {{- else if eq $type "nfs" }}
  nfs:
    path: {{ $value.path }}
    {{- with $value.readOnly }}
    readOnly: {{ . }}
    {{- end }}
    server: {{ $value.server }}
  {{- else if eq $type "pvc" }}
  persistentVolumeClaim:
    claimName: {{ ternary $value.existingClaim (include "common.fullname.postfix" $values) (hasKey $value "existingClaim") }}
    {{- with $value.readOnly }}
    readOnly: {{ . }}
    {{- end }}
  {{- else if eq $type "secret" }}
  secret:
    {{- if $value.secretName }}
    secretName: {{ $value.secretName }}
    {{- else }}
    secretName: {{ include "common.fullname.postfix" $values }}
    {{- end }}
  {{- else }}
  {{- printf "Unknown volume type %v" $type | fail }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
