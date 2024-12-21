# templates/_helpers.tpl

{{/*
Main Application Name
Returns the name of the chart or overridden value
*/}}
{{- define "camunda-bpm-platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Full Application Name
Creates a fully qualified app name, truncated at 63 chars
If release name contains chart name, it will be used as full name
*/}}
{{- define "camunda-bpm-platform.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart Name and Version
Used for labels
*/}}
{{- define "camunda-bpm-platform.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common Labels
Standard Kubernetes labels
*/}}
{{- define "camunda-bpm-platform.labels" -}}
helm.sh/chart: {{ include "camunda-bpm-platform.chart" . }}
{{ include "camunda-bpm-platform.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.global.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector Labels
Labels used for selecting pods
*/}}
{{- define "camunda-bpm-platform.selectorLabels" -}}
app.kubernetes.io/name: {{ include "camunda-bpm-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service Account Name
Create the service account name
*/}}
{{- define "camunda-bpm-platform.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "camunda-bpm-platform.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Pod Annotations
Combines global and local pod annotations
*/}}
{{- define "camunda-bpm-platform.podAnnotations" -}}
{{- $podAnnotations := dict -}}
{{- with .Values.global.annotations }}
{{- $podAnnotations = merge $podAnnotations . -}}
{{- end }}
{{- with .Values.podAnnotations }}
{{- $podAnnotations = merge $podAnnotations . -}}
{{- end }}
{{- toYaml $podAnnotations }}
{{- end }}

{{/*
API Version Helpers
Determine correct API versions based on cluster capabilities
*/}}
{{- define "camunda-bpm-platform.capabilities.apiVersion.ingress" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1" }}
{{- print "networking.k8s.io/v1" }}
{{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" }}
{{- print "networking.k8s.io/v1beta1" }}
{{- else }}
{{- print "extensions/v1beta1" }}
{{- end }}
{{- end }}

{{- define "camunda-bpm-platform.capabilities.apiVersion.hpa" -}}
{{- if .Capabilities.APIVersions.Has "autoscaling/v2" }}
{{- print "autoscaling/v2" }}
{{- else }}
{{- print "autoscaling/v2beta1" }}
{{- end }}
{{- end }}

{{/*
Environment Check
Validates minimum required Kubernetes version
*/}}
{{- define "camunda-bpm-platform.validateEnvironment" -}}
{{- if semverCompare "< 1.19-0" .Capabilities.KubeVersion.Version }}
{{- fail "Kubernetes cluster version 1.19 or higher is required" }}
{{- end }}
{{- end }}

{{/*
Image Pull Secret Creation Helper
*/}}
{{- define "camunda-bpm-platform.imagePullSecrets" -}}
{{- with .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.imagePullSecrets }}
imagePullSecrets:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Resource Request/Limit Helper
Combines global and local resource settings
*/}}
{{- define "camunda-bpm-platform.resources" -}}
{{- $resources := dict -}}
{{- with .Values.global.resources }}
{{- $resources = merge $resources . -}}
{{- end }}
{{- with .Values.resources }}
{{- $resources = merge $resources . -}}
{{- end }}
{{- toYaml $resources }}
{{- end }}