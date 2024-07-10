{{- define "common.postgresql.url" }}
{{- $serviceName := printf "%s-postgresql" (include "common.name" .) }}
{{- $auth := printf "%s:%s" .Values.postgresql.auth.username .Values.postgresql.auth.password }}
{{- $port := .Values.postgresql.primary.service.ports.postgresql }}
{{- $databaseName := .Values.postgresql.auth.database }}
{{- printf "postgresql://%s@%s:%v/%s" $auth $serviceName $port $databaseName }}
{{- end }}

{{- define "common.mariadb.url" }}
{{- printf "" }}
{{- end }}

{{- define "common.redis.url" }}
{{- printf "" }}
{{- end }}
