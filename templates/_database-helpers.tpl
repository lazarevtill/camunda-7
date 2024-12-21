# templates/_database-helpers.tpl

{{/*
Database Host
Returns the appropriate database host based on configuration
*/}}
{{- define "camunda-bpm-platform.database.host" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" (include "camunda-bpm-platform.fullname" .) }}
{{- else }}
{{- required "A valid .Values.externalDatabase.host is required when postgresql.enabled is false" .Values.externalDatabase.host }}
{{- end }}
{{- end }}

{{/*
Database Port
Returns the appropriate database port
*/}}
{{- define "camunda-bpm-platform.database.port" -}}
{{- if .Values.postgresql.enabled }}
{{- print "5432" }}
{{- else }}
{{- required "A valid .Values.externalDatabase.port is required when postgresql.enabled is false" .Values.externalDatabase.port }}
{{- end }}
{{- end }}

{{/*
Database Name
Returns the database name
*/}}
{{- define "camunda-bpm-platform.database.name" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database }}
{{- else }}
{{- required "A valid .Values.externalDatabase.database is required when postgresql.enabled is false" .Values.externalDatabase.database }}
{{- end }}
{{- end }}

{{/*
Database Connection URL
Constructs the full database URL
*/}}
{{- define "camunda-bpm-platform.database.url" -}}
{{- $host := include "camunda-bpm-platform.database.host" . }}
{{- $port := include "camunda-bpm-platform.database.port" . }}
{{- $database := include "camunda-bpm-platform.database.name" . }}
jdbc:postgresql://{{ $host }}:{{ $port }}/{{ $database }}
{{- end }}

{{/*
Database Secret Name
Returns the name of the secret containing database credentials
*/}}
{{- define "camunda-bpm-platform.database.secretName" -}}
{{- if .Values.postgresql.enabled }}
{{- if .Values.postgresql.auth.existingSecret }}
{{- .Values.postgresql.auth.existingSecret }}
{{- else }}
{{- printf "%s-postgresql" (include "camunda-bpm-platform.fullname" .) }}
{{- end }}
{{- else }}
{{- default (printf "%s-external-db" (include "camunda-bpm-platform.fullname" .)) .Values.externalDatabase.existingSecret }}
{{- end }}
{{- end }}

{{/*
Database Secret Key for Username
*/}}
{{- define "camunda-bpm-platform.database.secretUsernameKey" -}}
{{- if .Values.postgresql.enabled }}
{{- print "username" }}
{{- else }}
{{- default "username" .Values.externalDatabase.existingSecretUsernameKey }}
{{- end }}
{{- end }}

{{/*
Database Secret Key for Password
*/}}
{{- define "camunda-bpm-platform.database.secretPasswordKey" -}}
{{- if .Values.postgresql.enabled }}
{{- print "password" }}
{{- else }}
{{- default "password" .Values.externalDatabase.existingSecretPasswordKey }}
{{- end }}
{{- end }}

{{/*
Database Connection Pool Configuration
Returns the database connection pool settings
*/}}
{{- define "camunda-bpm-platform.database.pool" -}}
spring.datasource.hikari.maximum-pool-size={{ .Values.database.pool.maxPoolSize | default 10 }}
spring.datasource.hikari.minimum-idle={{ .Values.database.pool.minIdle | default 5 }}
spring.datasource.hikari.idle-timeout={{ .Values.database.pool.idleTimeout | default 300000 }}
spring.datasource.hikari.connection-timeout={{ .Values.database.pool.connectionTimeout | default 20000 }}
spring.datasource.hikari.max-lifetime={{ .Values.database.pool.maxLifetime | default 1200000 }}
spring.datasource.hikari.auto-commit={{ .Values.database.pool.autoCommit | default true }}
{{- end }}