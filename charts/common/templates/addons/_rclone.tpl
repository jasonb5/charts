{{- define "common.addonRclone" }}
	{{- $addon := get (default dict .addons) "rclone" }}
	{{- if and $addon $addon.enabled }}
		{{- $config := get .persistence "config" }}
		{{- $env := dict "RCLONE_CROND_SCHEDULE" $addon.cronSchedule "RCLONE_CROND_ARGS" $addon.cronArgs }}
		{{- if $addon.globalArgs }}
			{{- $_ := set $env "RCLONE_ARGS" $addon.globalArgs }}
		{{- end }}
		{{- if $addon.backupArgs }}
			{{- $_ := set $env "RCLONE_BACKUP_ARGS" $addon.backupArgs }}
		{{- end }}
		{{- if $addon.restoreArgs }}
			{{- $_ := set $env "RCLONE_RESTORE_ARGS" $addon.restoreArgs }}
		{{- end }}
		{{- if $addon.restore }}
			{{- $_ := set $env "RCLONE_RESTORE" "yes" }}
		{{- end }}
		{{- if $addon.restic.enabled }}
			{{- $_ := set $env "RCLONE_USE_RESTIC" "yes" }}
			{{- if $addon.restic.snapshot }}
				{{- $_ := set $env "RCLONE_SNAPSHOT" $addon.restic.snapshot }}
			{{- end }}
		{{- end }}
		{{- $_ := set $env "RCLONE_SOURCE" (default "/config" $config.mountPath) }}
		{{- $_ := set $env "RCLONE_DESTINATION" (required "Must set destination" $addon.destination) }}

		{{- $_ := set $addon "env" $env }}
		{{- $persistence := mustMerge (default dict $addon.persistence) (dict "config" $config) }}
		{{- $_ := set $addon "persistence" $persistence }}
		{{- $extraContainers := default dict .extraContainers }}
		{{- $extraContainers = mustMerge $extraContainers (dict "rclone" $addon) }}
		{{- $_ := set . "extraContainers" $extraContainers }}
	{{- end }}
{{- end }}
