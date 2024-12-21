# templates/_observability-helpers.tpl

{{/*
Tracing Configuration
Returns OpenTelemetry/Jaeger configuration
*/}}
{{- define "camunda-bpm-platform.observability.tracing" -}}
{{- if .Values.observability.tracing.enabled }}
OTEL_EXPORTER_OTLP_ENDPOINT: {{ .Values.observability.tracing.endpoint | quote }}
OTEL_SERVICE_NAME: {{ include "camunda-bpm-platform.fullname" . }}
OTEL_RESOURCE_ATTRIBUTES: "service.namespace={{ .Release.Namespace }},service.instance.id=$(POD_NAME)"
{{- with .Values.observability.tracing.samplingRate }}
OTEL_TRACES_SAMPLER_ARG: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Logging Configuration
Returns structured logging configuration
*/}}
{{- define "camunda-bpm-platform.observability.logging" -}}
{{- if .Values.observability.logging.structured }}
logging.pattern.console: '{"timestamp":"%d{ISO8601}", "level":"%p", "thread":"%t", "class":"%c{1}", "message":"%m", "stacktrace":"%ex"}%n'
{{- else }}
logging.pattern.console: "%d{ISO8601} %p [%t] %c{1} - %m%n"
{{- end }}
{{- end }}

{{/*
Metrics Configuration
Returns enhanced metrics configuration
*/}}
{{- define "camunda-bpm-platform.observability.metrics" -}}
{{- if .Values.observability.metrics.enabled }}
management:
  endpoints:
    web:
      exposure:
        include: health,prometheus,metrics
  metrics:
    tags:
      application: {{ include "camunda-bpm-platform.fullname" . }}
      namespace: {{ .Release.Namespace }}
    distribution:
      sla:
        # Define SLA buckets for histogram metrics
        - 10ms
        - 50ms
        - 100ms
        - 200ms
        - 500ms
        - 1s
    enable:
      process: true
      jvm: true
      tomcat: true
      system: true
{{- end }}
{{- end }}