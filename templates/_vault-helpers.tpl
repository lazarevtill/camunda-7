# templates/_vault-helpers.tpl

{{/*
Vault Configuration Validation
Validates required Vault settings
*/}}
{{- define "camunda-bpm-platform.vault.validateConfig" -}}
{{- if .Values.vault.enabled -}}
  {{- if not .Values.vault.config.address -}}
    {{- fail "Vault address must be provided when Vault is enabled" -}}
  {{- end -}}
  {{- if not .Values.vault.auth.role -}}
    {{- fail "Vault authentication role must be provided when Vault is enabled" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Vault Authentication Settings
Returns the authentication configuration for Vault
*/}}
{{- define "camunda-bpm-platform.vault.authSettings" -}}
{{- if .Values.vault.enabled }}
auth:
  kubernetes:
    enabled: true
    role: {{ .Values.vault.auth.role }}
    serviceAccountName: {{ include "camunda-bpm-platform.serviceAccountName" . }}
    mountPath: {{ .Values.vault.auth.mount | default "kubernetes" }}
  {{- if .Values.vault.auth.tokenReviewerJwt }}
    tokenReviewerJwt: {{ .Values.vault.auth.tokenReviewerJwt }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Vault Agent Configuration
Returns the Vault agent configuration settings
*/}}
{{- define "camunda-bpm-platform.vault.agentConfig" -}}
{{- if .Values.vault.enabled }}
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/agent-init-first: "true"
vault.hashicorp.com/agent-pre-populate-only: "true"
vault.hashicorp.com/agent-revoke-on-shutdown: "true"
vault.hashicorp.com/agent-revoke-grace: "5m"
vault.hashicorp.com/role: {{ .Values.vault.auth.role }}
vault.hashicorp.com/agent-cache-enable: "true"
vault.hashicorp.com/agent-run-as-user: "1000"
vault.hashicorp.com/agent-run-as-group: "1000"
vault.hashicorp.com/agent-set-security-context: "true"
vault.hashicorp.com/preserve-secret-case: "true"
vault.hashicorp.com/agent-limits-cpu: {{ .Values.vault.agent.resources.limits.cpu | default "100m" | quote }}
vault.hashicorp.com/agent-limits-mem: {{ .Values.vault.agent.resources.limits.memory | default "128Mi" | quote }}
vault.hashicorp.com/agent-requests-cpu: {{ .Values.vault.agent.resources.requests.cpu | default "50m" | quote }}
vault.hashicorp.com/agent-requests-mem: {{ .Values.vault.agent.resources.requests.memory | default "64Mi" | quote }}
{{- if .Values.vault.config.namespace }}
vault.hashicorp.com/namespace: {{ .Values.vault.config.namespace }}
{{- end }}
{{- if .Values.vault.tls.enabled }}
vault.hashicorp.com/tls-secret: {{ .Values.vault.tls.secretName }}
vault.hashicorp.com/tls-server-name: {{ .Values.vault.tls.serverName | default "vault.vault.svc.cluster.local" }}
vault.hashicorp.com/ca-cert: "/vault/tls/ca.crt"
{{- end }}
{{- end }}
{{- end }}

{{/*
Vault Secret Template Generator
Generates templates for secret injection
*/}}
{{- define "camunda-bpm-platform.vault.secretTemplate" -}}
{{- $path := .path -}}
{{- $keys := .keys -}}
{{- $kvVersion := .kvVersion | default "v2" -}}
{{- $template := printf `
{{- with secret "%s" -}}
{{- range $key, $value := .Data.data -}}
{{ $key }}={{ $value }}
{{- end -}}
{{- end -}}
` ($kvVersion | ternary (printf "secret/data/%s" $path) (printf "secret/%s" $path)) -}}
{{- $template | nindent 0 }}
{{- end }}

{{/*
Vault Secret Path Constructor
Constructs the full path for a secret in Vault
*/}}
{{- define "camunda-bpm-platform.vault.secretPath" -}}
{{- $path := .path -}}
{{- $kvVersion := .kvVersion | default "v2" -}}
{{- if eq $kvVersion "v2" -}}
{{- printf "secret/data/%s" $path -}}
{{- else -}}
{{- printf "secret/%s" $path -}}
{{- end -}}
{{- end }}

{{/*
Vault Annotations Generator
Returns all required annotations for Vault integration
*/}}
{{- define "camunda-bpm-platform.vault.annotations" -}}
{{- if .Values.vault.enabled }}
# Basic Vault Agent Configuration
{{- include "camunda-bpm-platform.vault.agentConfig" . | nindent 0 }}

# Secret Injection Configuration
{{- range $key, $value := .Values.vault.secrets }}
vault.hashicorp.com/agent-inject-secret-{{ $key }}: {{ include "camunda-bpm-platform.vault.secretPath" (dict "path" $value.path "kvVersion" $.Values.vault.config.kvVersion) }}
vault.hashicorp.com/agent-inject-template-{{ $key }}: |
  {{- if $value.template }}
  {{- $value.template | nindent 2 }}
  {{- else }}
  {{- include "camunda-bpm-platform.vault.secretTemplate" (dict "path" $value.path "keys" $value.keys "kvVersion" $.Values.vault.config.kvVersion) | nindent 2 }}
  {{- end }}
{{- end }}

# Command Injection for Secret Processing
{{- if .Values.vault.agent.command }}
vault.hashicorp.com/agent-inject-command: |
  {{- .Values.vault.agent.command | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Vault Environment Variables
Returns environment variables for Vault configuration
*/}}
{{- define "camunda-bpm-platform.vault.environment" -}}
{{- if .Values.vault.enabled }}
- name: VAULT_ADDR
  value: {{ .Values.vault.config.address }}
{{- if .Values.vault.config.namespace }}
- name: VAULT_NAMESPACE
  value: {{ .Values.vault.config.namespace }}
{{- end }}
- name: VAULT_SKIP_VERIFY
  value: {{ .Values.vault.tls.skipVerify | default "false" | quote }}
{{- range $key, $value := .Values.vault.environment }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Vault Pod Security Context
Returns security context settings for Vault integration
*/}}
{{- define "camunda-bpm-platform.vault.securityContext" -}}
{{- if .Values.vault.enabled }}
runAsUser: 1000
runAsGroup: 1000
runAsNonRoot: true
fsGroup: 1000
seccompProfile:
  type: RuntimeDefault
{{- end }}
{{- end }}

{{/*
Vault Container Security Context
Returns container security context for Vault agent
*/}}
{{- define "camunda-bpm-platform.vault.containerSecurityContext" -}}
{{- if .Values.vault.enabled }}
allowPrivilegeEscalation: false
capabilities:
  drop:
    - ALL
readOnlyRootFilesystem: true
runAsUser: 1000
runAsGroup: 1000
runAsNonRoot: true
seccompProfile:
  type: RuntimeDefault
{{- end }}
{{- end }}