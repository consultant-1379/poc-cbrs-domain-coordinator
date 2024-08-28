{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eric-enm-monitoring-master.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eric-enm-monitoring-master.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-enm-monitoring-master.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image registry url
*/}}
{{- define "eric-enm-monitoring-master.registryUrl" -}}
{{- if .Values.global.registry.url -}}
{{- print .Values.global.registry.url -}}
{{- else -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- end -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-enm-monitoring-master.pullSecrets" -}}
{{- if .Values.global.registry.pullSecret -}}
{{- print .Values.global.registry.pullSecret -}}
{{- else if .Values.imageCredentials.registry.pullSecret -}}
{{- print .Values.imageCredentials.registry.pullSecret -}}
{{- end -}}
{{- end -}}

{{/*
Generate chart secret name
*/}}
{{- define "eric-enm-monitoring-master.secretName" -}}
{{ default (include "eric-enm-monitoring-master.fullname" .) .Values.existingSecret }}
{{- end -}}

{{/*
Generate Product info
*/}}
{{- define "eric-enm-monitoring-master.product-info" }}
ericsson.com/product-name: {{ include "eric-enm-monitoring-master.name" . | quote }}
ericsson.com/product-number: "{{ .Values.productInfo.number }}"
ericsson.com/product-revision: "{{ .Values.productInfo.rstate }}"
{{- end}}

{{/*
Create Labels
*/}}
{{- define "eric-enm-monitoring-master.labels" }}
app.kubernetes.io/name: {{ include "eric-enm-monitoring-master.name" . | quote }}
app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}