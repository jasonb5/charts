{{- define "common.container" }}
- name: {{ ternary (include "common.name" .) .Values.name (or (not (hasKey .Values "name")) (eq .Values.name "default")) }}
  {{- with .Values.args }}
  args:
  {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.command }}
  command:
  {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.env }}
  env:
    {{- range $key, $value := . }}
    - name: {{ $key }}
      value: {{ tpl (toString $value) $.TemplateValues }}
    {{- end }}
  {{- end }}
  {{- with .Values.envFrom }}
  envFrom:
    {{- range $key, $value := . }}
    {{- $dot := dict "Values" (dict "workloadName" $.Values.workloadName "name" $key) "Release" $.Release "Chart" $.Chart }}
    {{- if eq $value.type "configmap" }}
    - configMapRef:
        name: {{ include "common.fullname.postfix" $dot }}
    {{- else if eq $value.type "secret" }}
    - secretRef:
        name: {{ include "common.fullname.postfix" $dot }}
    {{- end }}
    {{- end }}
  {{- end }}
  image: {{ .Values.image.repository }}:{{ default .Chart.AppVersion .Values.image.tag }}
  {{- with .Values.image.pullPolicy }}
  imagePullPolicy: {{ . }}
  {{- end }}
  {{- with .Values.lifecycle }}
  lifecycle:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.livenessProbe }}
  livenessProbe:
  {{- tpl (toYaml .) $.TemplateValues | nindent 4 }}
  {{- end }}
  {{- with .Values.service }}
  ports:
  {{- range $key, $value := .ports }}
  - containerPort: {{ $value.port }}
    {{- with $value.hostPort }}
    hostPort: {{ . }}
    {{- end }}
    name: {{ ternary (include "common.name" $) $key (eq $key "default") }}
    protocol: {{ default "TCP" $value.protocol }}
  {{- end }}
  {{- end }}
  {{- with .Values.readinessProbe }}
  readinessProbe:
  {{- tpl (toYaml .) $.TemplateValues | nindent 4 }}
  {{- end }}
  {{- with .Values.resources }}
  resources:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.restartPolicy }}
  restartPolicy: {{ . }}
  {{- end }}
  {{- with .Values.securityContext }}
  securityContext:
  {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.startupProbe }}
  startupProbe:
  {{- tpl (toYaml .) $.TemplateValues | nindent 4 }}
  {{- end }}
  {{- with .Values.persistence }}
  volumeMounts:
  {{- range $key, $value := . }}
  {{- if $value.enabled }}
  - name: {{ ternary (include "common.name" $) $key (eq $key "default") }}
    mountPath: {{ default (printf "/%s" $key) $value.mountPath }}
    {{- with $value.mountPropagation }}
    mountPropagation: {{ . }}
    {{- end }}
    {{- with $value.readOnly }}
    readOnly: {{ . }}
    {{- end }}
    {{- with $value.subPath }}
    subPath: {{ . }}
    {{- end }}
  {{- end }}
  {{- end }}
  {{- end }}
  {{- with .Values.workingDir }}
  workingDir: {{ . }}
  {{- end }}
{{- end }}
