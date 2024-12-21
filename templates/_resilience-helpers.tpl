# templates/_resilience-helpers.tpl

{{/*
Circuit Breaker Configuration
Returns circuit breaker settings for both Istio and application level
*/}}
{{- define "camunda-bpm-platform.resilience.circuitBreaker" -}}
{{- if .Values.resilience.circuitBreaker.enabled }}
resilience4j.circuitbreaker:
  instances:
    database:
      slidingWindowSize: {{ .Values.resilience.circuitBreaker.slidingWindowSize }}
      minimumNumberOfCalls: {{ .Values.resilience.circuitBreaker.minimumCalls }}
      failureRateThreshold: {{ .Values.resilience.circuitBreaker.failureRateThreshold }}
      waitDurationInOpenState: {{ .Values.resilience.circuitBreaker.waitDuration }}
    external-services:
      slidingWindowSize: {{ .Values.resilience.circuitBreaker.externalServices.slidingWindowSize }}
      failureRateThreshold: {{ .Values.resilience.circuitBreaker.externalServices.failureRateThreshold }}
{{- end }}
{{- end }}

{{/*
Retry Configuration
Returns retry policy configuration
*/}}
{{- define "camunda-bpm-platform.resilience.retry" -}}
{{- if .Values.resilience.retry.enabled }}
resilience4j.retry:
  instances:
    database:
      maxAttempts: {{ .Values.resilience.retry.maxAttempts }}
      waitDuration: {{ .Values.resilience.retry.waitDuration }}
      retryExceptions:
        - java.sql.SQLException
        - org.springframework.dao.DataAccessException
    external-services:
      maxAttempts: {{ .Values.resilience.retry.externalServices.maxAttempts }}
      waitDuration: {{ .Values.resilience.retry.externalServices.waitDuration }}
{{- end }}
{{- end }}

{{/*
Rate Limiting Configuration
Returns rate limiting settings
*/}}
{{- define "camunda-bpm-platform.resilience.rateLimit" -}}
{{- if .Values.resilience.rateLimit.enabled }}
resilience4j.ratelimiter:
  instances:
    api:
      limitForPeriod: {{ .Values.resilience.rateLimit.limitForPeriod }}
      limitRefreshPeriod: {{ .Values.resilience.rateLimit.limitRefreshPeriod }}
      timeoutDuration: {{ .Values.resilience.rateLimit.timeoutDuration }}
    backoffice:
      limitForPeriod: {{ .Values.resilience.rateLimit.backoffice.limitForPeriod }}
      limitRefreshPeriod: {{ .Values.resilience.rateLimit.backoffice.limitRefreshPeriod }}
{{- end }}
{{- end }}

{{/*
Bulkhead Configuration
Returns bulkhead configuration for thread isolation
*/}}
{{- define "camunda-bpm-platform.resilience.bulkhead" -}}
{{- if .Values.resilience.bulkhead.enabled }}
resilience4j.bulkhead:
  instances:
    database:
      maxConcurrentCalls: {{ .Values.resilience.bulkhead.maxConcurrentCalls }}
      maxWaitDuration: {{ .Values.resilience.bulkhead.maxWaitDuration }}
    external-services:
      maxConcurrentCalls: {{ .Values.resilience.bulkhead.externalServices.maxConcurrentCalls }}
{{- end }}
{{- end }}