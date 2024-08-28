{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eric-enmsg-gossiprouter-eap7.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eric-enmsg-gossiprouter-eap7.fullname" -}}
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
{{- define "eric-enmsg-gossiprouter-eap7.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image registry url
*/}}
{{- define "eric-enmsg-gossiprouter-eap7.registryUrl" -}}
{{- if .Values.global.registry.url -}}
{{- print .Values.global.registry.url -}}
{{- else -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- end -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-enmsg-gossiprouter-eap7.pullSecrets" -}}
{{- if .Values.global.registry.pullSecret -}}
{{- print .Values.global.registry.pullSecret -}}
{{- else if .Values.imageCredentials.registry.pullSecret -}}
{{- print .Values.imageCredentials.registry.pullSecret -}}
{{- end -}}
{{- end -}}

{{/*
Create ingress hosts
*/}}
{{- define "eric-enmsg-gossiprouter-eap7.enmHost" -}}
{{- if .Values.global.ingress.enmHost -}}
{{- print .Values.global.ingress.enmHost -}}
{{- else if .Values.ingress_jboss_web_context.enmHost -}}
{{- print .Values.ingress_jboss_web_context.enmHost -}}
{{- end -}}
{{- end -}}

{{/*
Create replicas
*/}}
{{- define "eric-enmsg-gossiprouter-eap7.replicas" -}}
{{- if index .Values "global" "replicas-eric-enmsg-gossiprouter-eap7" -}}
{{- print (index .Values "global" "replicas-eric-enmsg-gossiprouter-eap7") -}}
{{- else if index .Values "replicas-eric-enmsg-gossiprouter-eap7" -}}
{{- print (index .Values "replicas-eric-enmsg-gossiprouter-eap7") -}}
{{- end -}}
{{- end -}}

{{/*
Create Storage Class
*/}}
{{- define "eric-enmsg-gossiprouter-eap7.storageClass" -}}
{{- if .Values.global.persistentVolumeClaim.storageClass -}}
{{- print .Values.global.persistentVolumeClaim.storageClass -}}
{{- else if .Values.persistentVolumeClaim.storageClass -}}
{{- print .Values.persistentVolumeClaim.storageClass -}}
{{- end -}}
{{- end -}}

{{/*
Generate chart secret name
*/}}
{{- define "eric-enmsg-gossiprouter-eap7.secretName" -}}
{{ default (include "eric-enmsg-gossiprouter-eap7.fullname" .) .Values.existingSecret }}
{{- end -}}

{{/*
Generate Product info
*/}}
{{- define "eric-enmsg-gossiprouter-eap7.product-info" }}
ericsson.com/product-name: "helm-eric-enmsg-gossiprouter"
ericsson.com/product-number: "CXC 174 2983"
ericsson.com/product-revision: "{{.Values.productInfo.rstate}}"
{{- end}}
