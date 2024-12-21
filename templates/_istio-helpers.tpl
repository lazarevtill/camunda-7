# templates/_istio-helpers.tpl

{{/*
Istio Enabled Check
Returns true if Istio integration is enabled
*/}}
{{- define "camunda-bpm-platform.istio.enabled" -}}
{{- if .Values.istio.enabled }}
{{- true }}
{{- end }}
{{- end }}

{{/*
Istio Gateway Name
Returns the appropriate gateway name
*/}}
{{- define "camunda-bpm-platform.istio.gatewayName" -}}
{{- if .Values.istio.gateway.useExisting }}
{{- required "A valid .Values.istio.gateway.name is required when useExisting is true" .Values.istio.gateway.name }}
{{- else }}
{{- printf "%s-gateway" (include "camunda-bpm-platform.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Istio Pod Annotations
Returns the required Istio pod annotations
*/}}
{{- define "camunda-bpm-platform.istio.podAnnotations" -}}
{{- if (include "camunda-bpm-platform.istio.enabled" .) }}
sidecar.istio.io/inject: "true"
proxy.istio.io/config: |
  holdApplicationUntilProxyStarts: true
  concurrency: {{ .Values.istio.proxy.concurrency | default 2 }}
  terminationDrainDuration: {{ .Values.istio.proxy.terminationDrainDuration | default "5s" }}
{{- if .Values.istio.proxy.resources }}
  resources:
    {{- toYaml .Values.istio.proxy.resources | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Istio mTLS Settings
Returns mTLS configuration
*/}}
{{- define "camunda-bpm-platform.istio.mtls" -}}
{{- if and (include "camunda-bpm-platform.istio.enabled" .) .Values.istio.mtls.enabled }}
security.istio.io/tlsMode: istio
{{- end }}
{{- end }}

{{/*
Istio Virtual Service Configuration
Returns common virtual service settings
*/}}
{{- define "camunda-bpm-platform.istio.virtualService.config" -}}
{{- if .Values.istio.virtualService.enabled }}
hosts:
{{- range .Values.istio.virtualService.hosts }}
  - {{ . | quote }}
{{- end }}
gateways:
{{- if not .Values.istio.virtualService.gateways }}
  - {{ include "camunda-bpm-platform.istio.gatewayName" . }}
{{- else }}
{{- toYaml .Values.istio.virtualService.gateways | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Istio Destination Rule Timeouts
Returns timeout configuration
*/}}
{{- define "camunda-bpm-platform.istio.timeouts" -}}
connectionPool:
  tcp:
    maxConnections: {{ .Values.istio.destinationRule.connectionPool.tcp.maxConnections }}
    connectTimeout: {{ .Values.istio.destinationRule.connectionPool.tcp.connectTimeout }}
  http:
    http2MaxRequests: {{ .Values.istio.destinationRule.connectionPool.http.http2MaxRequests }}
    maxRequestsPerConnection: {{ .Values.istio.destinationRule.connectionPool.http.maxRequestsPerConnection }}
    maxRetries: {{ .Values.istio.destinationRule.connectionPool.http.maxRetries }}
{{- end }}

{{/*
Istio Authorization Policy Rules
Returns authorization rules
*/}}
{{- define "camunda-bpm-platform.istio.authorizationRules" -}}
{{- if .Values.istio.authorizationPolicy.enabled }}
rules:
  # Allow health check endpoints
  - to:
      - operation:
          paths: ["/actuator/health/*", "/actuator/prometheus"]
          methods: ["GET"]
  
  # Allow authenticated API access
  - to:
      - operation:
          paths: ["/engine-rest/*", "/camunda/*"]
          methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
    {{- if .Values.istio.authorizationPolicy.jwt.enabled }}
    from:
      - source:
          requestPrincipals: ["*"]
    when:
      - key: request.auth.claims[iss]
        values:
        {{- range .Values.istio.authorizationPolicy.jwt.issuers }}
          - {{ . | quote }}
        {{- end }}
    {{- end }}
  
  {{- with .Values.istio.authorizationPolicy.customRules }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
{{- end }}