# templates/_security-helpers.tpl

{{/*
Pod Security Context
Returns the pod security context configuration
*/}}
{{- define "camunda-bpm-platform.security.podSecurityContext" -}}
{{- if .Values.security.podSecurityContext }}
{{- toYaml .Values.security.podSecurityContext }}
{{- else }}
fsGroup: 1000
runAsUser: 1000
runAsNonRoot: true
seccompProfile:
  type: RuntimeDefault
{{- end }}
{{- end }}

{{/*
Container Security Context
Returns the container security context configuration
*/}}
{{- define "camunda-bpm-platform.security.containerSecurityContext" -}}
{{- if .Values.security.containerSecurityContext }}
{{- toYaml .Values.security.containerSecurityContext }}
{{- else }}
allowPrivilegeEscalation: false
capabilities:
  drop:
    - ALL
readOnlyRootFilesystem: true
runAsNonRoot: true
runAsUser: 1000
seccompProfile:
  type: RuntimeDefault
{{- end }}
{{- end }}

{{/*
Network Policy Configuration
Returns the network policy configuration if enabled
*/}}
{{- define "camunda-bpm-platform.security.networkPolicy" -}}
{{- if .Values.security.networkPolicies.enabled }}
podSelector:
  matchLabels:
    {{- include "camunda-bpm-platform.selectorLabels" . | nindent 4 }}
policyTypes:
  - Ingress
  - Egress
ingress:
  # Allow ingress from Istio ingress gateway
  {{- if .Values.istio.enabled }}
  - from:
      - namespaceSelector:
          matchLabels:
            istio-injection: enabled
      - podSelector:
          matchLabels:
            app: istio-ingressgateway
    ports:
      - port: {{ .Values.service.port }}
        protocol: TCP
  {{- end }}
  
  # Allow ingress for metrics scraping
  {{- if .Values.monitoring.enabled }}
  - from:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: monitoring
      - podSelector:
          matchLabels:
            app: prometheus
    ports:
      - port: {{ .Values.metrics.port }}
        protocol: TCP
  {{- end }}
  
  # Custom ingress rules
  {{- with .Values.security.networkPolicies.additionalIngressRules }}
  {{- toYaml . | nindent 2 }}
  {{- end }}

egress:
  # Allow egress to PostgreSQL
  - to:
      - podSelector:
          matchLabels:
            app.kubernetes.io/name: postgresql
    ports:
      - port: 5432
        protocol: TCP
  
  # Allow DNS resolution
  - to:
      - namespaceSelector: {}
        podSelector:
          matchLabels:
            k8s-app: kube-dns
    ports:
      - port: 53
        protocol: UDP
      - port: 53
        protocol: TCP
  
  # Custom egress rules
  {{- with .Values.security.networkPolicies.additionalEgressRules }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
TLS Configuration
Returns the TLS configuration if enabled
*/}}
{{- define "camunda-bpm-platform.security.tls" -}}
{{- if .Values.security.tls.enabled }}
tls:
  enabled: true
  {{- if .Values.security.tls.secretName }}
  secretName: {{ .Values.security.tls.secretName }}
  {{- else }}
  secretName: {{ include "camunda-bpm-platform.fullname" . }}-tls
  {{- end }}
  {{- with .Values.security.tls.configuration }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
RBAC Configuration
Returns the RBAC configuration if enabled
*/}}
{{- define "camunda-bpm-platform.security.rbac" -}}
{{- if .Values.security.rbac.enabled }}
rules:
  # Default rules for Camunda
  - apiGroups: [""]
    resources: ["configmaps", "secrets"]
    verbs: ["get", "list", "watch"]
  # Additional custom rules
  {{- with .Values.security.rbac.additionalRules }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
{{- end }}