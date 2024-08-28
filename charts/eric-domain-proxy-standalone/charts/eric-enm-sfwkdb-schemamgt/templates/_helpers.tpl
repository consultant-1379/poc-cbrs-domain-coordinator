{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eric-enm-sfwkdb-schemamgt.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eric-enm-sfwkdb-schemamgt.fullname" -}}
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
{{- define "eric-enm-sfwkdb-schemamgt.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image registry url
*/}}
{{- define "eric-enm-sfwkdb-schemamgt.registryUrl" -}}
{{- if .Values.global.registry.url -}}
{{- print .Values.global.registry.url -}}
{{- else -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- end -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-enm-sfwkdb-schemamgt.pullSecrets" -}}
{{- if .Values.global.registry.pullSecret -}}
{{- print .Values.global.registry.pullSecret -}}
{{- else if .Values.imageCredentials.registry.pullSecret -}}
{{- print .Values.imageCredentials.registry.pullSecret -}}
{{- end -}}
{{- end -}}

{{/*
Create replicas
*/}}
{{- define "eric-enm-sfwkdb-schemamgt.replicas" -}}
{{- if index .Values "global" "replicas-eric-enm-sfwkdb-schemamgt" -}}
{{- print (index .Values "global" "replicas-eric-enm-sfwkdb-schemamgt") -}}
{{- else if index .Values "replicas-eric-enm-sfwkdb-schemamgt" -}}
{{- print (index .Values "replicas-eric-enm-sfwkdb-schemamgt") -}}
{{- end -}}
{{- end -}}

{{/*
Create Storage Class
*/}}
{{- define "eric-enm-sfwkdb-schemamgt.storageClass" -}}
{{- if .Values.global.persistentVolumeClaim.storageClass -}}
{{- print .Values.global.persistentVolumeClaim.storageClass -}}
{{- else if .Values.persistentVolumeClaim.storageClass -}}
{{- print .Values.persistentVolumeClaim.storageClass -}}
{{- end -}}
{{- end -}}

{{/*
Generate chart secret name
*/}}
{{- define "eric-enm-sfwkdb-schemamgt.secretName" -}}
{{ default (include "eric-enm-sfwkdb-schemamgt.fullname" .) .Values.existingSecret }}
{{- end -}}

Generate Product info
*/}}
{{- define "eric-enm-sfwkdb-schemamgt.product-info" }}
ericsson.com/product-name: "helm-eric-enm-sfwkdb-schemamgt"
ericsson.com/product-number: "CXC 174 2999"
ericsson.com/product-revision: "{{.Values.productInfo.rstate}}"
{{- end}}

{{/*
Set IANA Timezone
DR-HC-146 requires setting a default TZ of UTC if the optional
global .Values.global.timezone and local .Values.timezone values are not set.
Unlike many other DRs, the global timezone value must override a local value.
*/}}
{{- define "eric-enm-sfwkdb-schemamgt.timezone" -}}
{{- if .Values.global.enmProperties.timezone -}}
{{- print .Values.global.enmProperties.timezone -}}
{{- else if .Values.timezone -}}
{{- print .Values.timezone -}}
{{- else -}}
UTC
{{- end -}}
{{- end -}}
