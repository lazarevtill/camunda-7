# templates/_monitoring-helpers.tpl

{{/*
Monitoring Enabled Check
Returns true if monitoring is enabled
*/}}
{{- define "camunda-bpm-platform.monitoring.enabled" -}}
{{- if .Values.monitoring.enabled }}
{{- true }}
{{- end }}
{{- end }}

{{/*
ServiceMonitor Configuration
Returns ServiceMonitor configuration if enabled
*/}}
{{- define "camunda-bpm-platform.monitoring.serviceMonitor" -}}
{{- if and .Values.monitoring.enabled .Values.monitoring.serviceMonitor.enabled }}
labels:
  {{- include "camunda-bpm-platform.labels" . | nindent 2 }}
  {{- with .Values.monitoring.serviceMonitor.additionalLabels }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
jobLabel: {{ include "camunda-bpm-platform.fullname" . }}
namespaceSelector:
  matchNames:
    - {{ .Release.Namespace }}
selector:
  matchLabels:
    {{- include "camunda-bpm-platform.selectorLabels" . | nindent 4 }}
endpoints:
  - port: metrics
    interval: {{ .Values.monitoring.serviceMonitor.interval | default "30s" }}
    scrapeTimeout: {{ .Values.monitoring.serviceMonitor.scrapeTimeout | default "10s" }}
    path: {{ .Values.monitoring.path | default "/actuator/prometheus" }}
    {{- with .Values.monitoring.serviceMonitor.relabelings }}
    relabelings:
      {{- toYaml . | nindent 6 }}
    {{- end }}
{{- end }}
{{- end }}

{{/*
Prometheus Rules Configuration
Returns PrometheusRules if enabled
*/}}
{{- define "camunda-bpm-platform.monitoring.prometheusRules" -}}
{{- if and .Values.monitoring.enabled .Values.monitoring.prometheusRules.enabled }}
labels:
  {{- include "camunda-bpm-platform.labels" . | nindent 2 }}
  {{- with .Values.monitoring.prometheusRules.additionalLabels }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
groups:
  - name: {{ include "camunda-bpm-platform.fullname" . }}
    rules:
      # Process Engine Metrics
      - alert: CamundaHighProcessInstanceCount
        expr: camunda_process_instances_total > {{ .Values.monitoring.alertRules.processCountThreshold }}
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High number of process instances
          description: Total process instances exceeds threshold of {{ .Values.monitoring.alertRules.processCountThreshold }}

      # Job Execution Metrics
      - alert: CamundaHighJobFailureRate
        expr: rate(camunda_job_execution_failed_total[5m]) > {{ .Values.monitoring.alertRules.failureRateThreshold }}
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High job failure rate
          description: Job failure rate exceeds threshold of {{ .Values.monitoring.alertRules.failureRateThreshold }}

      # System Health Metrics
      - alert: CamundaHighSystemLoad
        expr: system_cpu_usage > {{ .Values.monitoring.alertRules.systemLoadThreshold }}
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High system load
          description: System CPU usage exceeds threshold

      # Database Connection Metrics
      - alert: CamundaDatabaseConnectionPoolSaturation
        expr: hikaricp_connections_active / hikaricp_connections_max > {{ .Values.monitoring.alertRules.connectionPoolThreshold }}
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: Database connection pool near capacity
          description: Database connection pool utilization is high

      {{- with .Values.monitoring.alertRules.custom }}
      {{- toYaml . | nindent 6 }}
      {{- end }}
{{- end }}
{{- end }}

{{/*
Grafana Dashboard Configuration
Returns Grafana dashboard configuration if enabled
*/}}
{{- define "camunda-bpm-platform.monitoring.grafanaDashboards" -}}
{{- if and .Values.monitoring.enabled .Values.monitoring.grafana.dashboards.enabled }}
{{- range $name, $dashboard := .Values.monitoring.grafana.dashboards.files }}
{{ $name }}: |-
  {{- tpl $dashboard $ | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}