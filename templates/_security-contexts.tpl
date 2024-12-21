# templates/_security-contexts.tpl

{{/*
Default Pod Security Context
*/}}
{{- define "camunda-bpm-platform.defaultPodSecurityContext" -}}
runAsUser: 1000
runAsGroup: 1000
fsGroup: 1000
runAsNonRoot: true
seccompProfile:
  type: RuntimeDefault
{{- end }}

{{/*
Default Container Security Context
*/}}
{{- define "camunda-bpm-platform.defaultContainerSecurityContext" -}}
allowPrivilegeEscalation: false
capabilities:
  drop:
    - ALL
readOnlyRootFilesystem: true
runAsNonRoot: true
runAsUser: 1000
runAsGroup: 1000
seccompProfile:
  type: RuntimeDefault
privileged: false
{{- end }}