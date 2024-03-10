{{- define "common.addons" }}
{{- include "common.addon" (list "codeserver" .Values) }}
{{- include "common.addonRclone" .Values }}
{{- end }}

{{- define "common.addonRclone" }}
{{- $addon := get (default dict .addons) "rclone" }}
{{- if and $addon $addon.enabled }}
{{- $config := get .persistence "config" }}
{{- $backupApp := ternary "restic" "rclone" $addon.restic.enabled }}
{{- $env := dict "BACKUP_APP" $backupApp "RESTORE" $addon.restore "CRON" $addon.cronSchedule }}
{{- if eq $backupApp "rclone" }}
{{- with $addon.globalFlags }}
{{- $_ := set $env "RCLONE_GLOBAL_FLAGS" . }}
{{- end }}
{{- with $addon.flags }}
{{- $_ := set $env "RCLONE_FLAGS" . }}
{{- end }}
{{- if $addon.restore }}
{{- $_ := set $env "RCLONE_DESTINATION" (default "/config" $config.mountPath) }}
{{- $_ := set $env "RCLONE_SOURCE" $addon.rclone.destination }}
{{- else }}
{{- $_ := set $env "RCLONE_SOURCE" (default "/config" $config.mountPath) }}
{{- $_ := set $env "RCLONE_DESTINATION" $addon.rclone.destination }}
{{- end }}
{{- else }}
{{- with $addon.globalFlags }}
{{- $_ := set $env "RESTIC_GLOBAL_FLAGS" . }}
{{- end }}
{{- with $addon.flags }}
{{- $_ := set $env "RESTIC_FLAGS" . }}
{{- end }}
{{- $_ := set $env "RESTIC_REPO" $addon.restic.repo }}
{{- $_ := set $env "RESTIC_PATH" (default "/config" $config.mountPath) }}
{{- if $addon.restore }}
{{- $_ := set $env "RESTIC_SNAPSHOT" $addon.restic.snapshot }}
{{- end }}
{{- end }}
{{- if $addon.preScript }}
{{- $_ := set $env "PRE_SCRIPT" $addon.preScript }}
{{- end }}
{{- if $addon.postScript }}
{{- $_ := set $env "POST_SCRIPT" $addon.postScript }}
{{- end }}
{{- $_ := set $addon "env" $env }}
{{- $_ := set $addon "persistence" (dict "config" $config) }}
{{- $extraContainers := default dict .extraContainers }}
{{- $extraContainers = mustMerge $extraContainers (dict "rclone" $addon) }}
{{- $_ := set . "extraContainers" $extraContainers }}
{{- end }}
{{- end }}

{{- define "common.addon" }}
{{- $name := first . }}
{{- $values := last . }}
{{- if hasKey $values "addons" }}
{{- $addon := get $values.addons $name }}
{{- if $addon.enabled }}
{{- $extraContainers := default dict $values.extraContainers }}
{{- $extraContainers = mustMerge $extraContainers (dict $name $addon) }}
{{- $_ := set $values "extraContainers" $extraContainers }}
{{- end }}
{{- end }}
{{- end }}
