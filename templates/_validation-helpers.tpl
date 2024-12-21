# templates/_validation-helpers.tpl

{{/*
Validate Configuration
Performs comprehensive validation of chart configuration
*/}}
{{- define "camunda-bpm-platform.validateConfig" -}}
{{- if and .Values.postgresql.enabled .Values.externalDatabase.host -}}
{{- fail "Both postgresql.enabled and externalDatabase.host are set. Please choose either built-in PostgreSQL or external database." -}}
{{- end -}}

{{- if and .Values.istio.enabled .Values.ingress.enabled -}}
{{- fail "Both Istio and Ingress are enabled. Please choose one ingress method." -}}
{{- end -}}

{{- if and (eq .Values.service.type "LoadBalancer") .Values.istio.enabled -}}
{{- fail "Service type LoadBalancer conflicts with Istio integration. Please use ClusterIP with Istio." -}}
{{- end -}}

{{- $replicaCount := int .Values.replicaCount -}}
{{- if and .Values.postgresql.enabled (gt $replicaCount 1) -}}
{{- if not .Values.postgresql.primary.replication.enabled -}}
{{- fail "Multiple replicas require PostgreSQL replication to be enabled." -}}
{{- end -}}
{{- end -}}

{{- if and .Values.monitoring.enabled (not .Values.metrics.enabled) -}}
{{- fail "Monitoring requires metrics to be enabled. Please enable metrics or disable monitoring." -}}
{{- end -}}
{{- end }}

{{- define "camunda-bpm-platform.validateConfig" -}}
{{- if and .Values.postgresql.enabled .Values.externalDatabase.host -}}
{{- fail "Both postgresql.enabled and externalDatabase.host are set" -}}
{{- end -}}
{{- end -}}

{{/*
Validate Resource Requirements
Ensures resource requests and limits are properly set
*/}}
{{- define "camunda-bpm-platform.validateResources" -}}
{{- if not .Values.resources -}}
{{- fail "Resource requests and limits must be specified for production deployments." -}}
{{- end -}}
{{- if not (and .Values.resources.requests .Values.resources.limits) -}}
{{- fail "Both resource requests and limits should be specified." -}}
{{- end -}}
{{- end }}

{{/*
Validate Security Settings
Ensures security best practices are followed
*/}}
{{- define "camunda-bpm-platform.validateSecurity" -}}
{{- if not .Values.security.podSecurityContext -}}
{{- fail "Pod security context must be specified for secure deployment." -}}
{{- end -}}
{{- if and .Values.istio.enabled (not .Values.istio.mtls.enabled) -}}
{{- fail "mTLS should be enabled when using Istio for security." -}}
{{- end -}}
{{- if and .Values.security.tls.enabled (not .Values.security.tls.secretName) -}}
{{- fail "TLS secret name must be provided when TLS is enabled." -}}
{{- end -}}
{{- end }}

