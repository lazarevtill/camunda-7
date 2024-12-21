# templates/_database-validation.tpl

{{/*
Database Configuration Validation
*/}}
{{- define "camunda-bpm-platform.validateDatabaseConfig" -}}
{{- if .Values.postgresql.enabled }}
  {{- if and (not .Values.postgresql.auth.existingSecret) (not .Values.postgresql.auth.password) }}
    {{- fail "PostgreSQL password must be provided either through auth.password or auth.existingSecret" -}}
  {{- end }}
{{- else if not .Values.externalDatabase.existingSecret }}
  {{- required "External database configuration is required when postgresql.enabled is false" .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
Generate Random Password
*/}}
{{- define "camunda-bpm-platform.generatePassword" -}}
{{- $length := 16 }}
{{- $strings := list "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z" "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" }}
{{- $password := "" }}
{{- range $i := until $length }}
  {{- $password = print $password (index $strings (randInt (len $strings))) }}
{{- end }}
{{- $password -}}
{{- end -}}