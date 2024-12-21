# templates/_performance-helpers.tpl

{{/*
Cache Configuration
Returns cache settings
*/}}
{{- define "camunda-bpm-platform.performance.cache" -}}
{{- if .Values.performance.cache.enabled }}
camunda.bpm.process-engine:
  process-definition-cache-limit: {{ .Values.performance.cache.processDefinitionLimit }}
  default-number-of-retries: {{ .Values.performance.cache.defaultRetries }}
spring.cache:
  type: caffeine
  caffeine.spec: |
    maximumSize={{ .Values.performance.cache.maximumSize }}
    expireAfterWrite={{ .Values.performance.cache.expireAfterWrite }}
{{- end }}
{{- end }}

{{/*
Connection Pool Optimization
Returns optimized connection pool settings
*/}}
{{- define "camunda-bpm-platform.performance.connectionPool" -}}
spring.datasource.hikari:
  maximum-pool-size: {{ .Values.performance.connectionPool.maxPoolSize }}
  minimum-idle: {{ .Values.performance.connectionPool.minIdle }}
  idle-timeout: {{ .Values.performance.connectionPool.idleTimeout }}
  connection-timeout: {{ .Values.performance.connectionPool.connectionTimeout }}
  max-lifetime: {{ .Values.performance.connectionPool.maxLifetime }}
  validation-timeout: {{ .Values.performance.connectionPool.validationTimeout }}
  keepalive-time: {{ .Values.performance.connectionPool.keepaliveTime }}
{{- end }}

{{/*
JVM Optimization
Returns JVM optimization settings
*/}}
{{- define "camunda-bpm-platform.performance.jvm" -}}
{{- if .Values.performance.jvm.optimization }}
env:
  - name: JAVA_TOOL_OPTIONS
    value: >-
      -XX:+UseG1GC
      -XX:MaxGCPauseMillis={{ .Values.performance.jvm.maxGCPauseMillis }}
      -XX:InitialRAMPercentage={{ .Values.performance.jvm.initialRAMPercentage }}
      -XX:MaxRAMPercentage={{ .Values.performance.jvm.maxRAMPercentage }}
      -XX:+HeapDumpOnOutOfMemoryError
      -XX:HeapDumpPath=/tmp/heapdump.hprof
      {{- if .Values.performance.jvm.debug }}
      -XX:+PrintGCDetails
      -XX:+PrintGCDateStamps
      -Xlog:gc*:file=/tmp/gc.log
      {{- end }}
{{- end }}
{{- end }}

{{/*
Thread Pool Configuration
Returns thread pool optimization settings
*/}}
{{- define "camunda-bpm-platform.performance.threadPool" -}}
{{- if .Values.performance.threadPool.enabled }}
server:
  tomcat:
    threads:
      max: {{ .Values.performance.threadPool.maxThreads }}
      min-spare: {{ .Values.performance.threadPool.minSpare }}
    accept-count: {{ .Values.performance.threadPool.acceptCount }}
    max-connections: {{ .Values.performance.threadPool.maxConnections }}
{{- end }}
{{- end }}