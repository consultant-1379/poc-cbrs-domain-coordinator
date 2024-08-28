{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-enm-common-helmchart-library.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image registry url
*/}}
{{- define "eric-enm-common-helmchart-library.registryUrl" -}}
{{- if .Values.global.registry.url -}}
{{- print .Values.global.registry.url -}}
{{- else -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- end -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-enm-common-helmchart-library.pullSecrets" -}}
{{- if .Values.global.registry.pullSecret -}}
{{- print .Values.global.registry.pullSecret -}}
{{- else if .Values.imageCredentials.registry.pullSecret -}}
{{- print .Values.imageCredentials.registry.pullSecret -}}
{{- end -}}
{{- end -}}

{{/*
Create ingress hosts
*/}}
{{- define "eric-enm-common-helmchart-library.enmHost" -}}
{{- if .Values.global.ingress.enmHost -}}
{{- print .Values.global.ingress.enmHost -}}
{{- else if .Values.ingress.enmHost -}}
{{- print .Values.ingress.enmHost -}}
{{- end -}}
{{- end -}}

{{/*
Create replicas
*/}}
{{- define "eric-enm-common-helmchart-library.replicas" -}}
{{- $replica_SG_name := printf "%s-%s" "replicas" .Chart.Name -}}
{{- if index .Values "global" $replica_SG_name -}}
{{- print (index .Values "global" $replica_SG_name) -}}
{{- else if index .Values $replica_SG_name -}}
{{- print (index .Values $replica_SG_name) -}}
{{- end -}}
{{- end -}}


{{/*
Create Storage Class
*/}}
{{- define "eric-enm-common-helmchart-library.storageClass" -}}
{{- if .Values.global.persistentVolumeClaim.storageClass -}}
{{- print .Values.global.persistentVolumeClaim.storageClass -}}
{{- else if .Values.persistentVolumeClaim.storageClass -}}
{{- print .Values.persistentVolumeClaim.storageClass -}}
{{- end -}}
{{- end -}}

{{/*
Generate chart secret name
*/}}
{{- define "eric-enm-common-helmchart-library.secretName" -}}
{{ default (include "eric-enm-common-helmchart-library.fullname" .) .Values.existingSecret }}
{{- end -}}

{{/*
Generate product name
*/}}
{{- define "eric-enm-common-helmchart-library.productName" -}}
{{- $product_name := printf "%s-%s" "helm" .Chart.Name -}}
{{- print $product_name -}}
{{- end -}}


{{/*
Generate Product info
*/}}
#product-info for configmap is resides inside _configmap.yaml
#If any change in the below product-info. Its Mandatory to change in the _configmap.yaml
{{- define "eric-enm-common-helmchart-library.product-info" }}
ericsson.com/product-name: {{ default (include "eric-enm-common-helmchart-library.productName" .) }}
ericsson.com/product-number: "{{ .Values.productInfo.number }}"
ericsson.com/product-revision: "{{ .Values.productInfo.rstate }}"
{{- end}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-enm-common-helmchart-library.chartname" -}}
{{- printf "%s" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eric-enm-common-helmchart-library.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eric-enm-common-helmchart-library.fullname" -}}
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
Generate config map  name
*/}}
{{- define "eric-enm-common-helmchart-library.configmapName" -}}
{{- $top := first . -}}
{{- $configmap_name := printf " %s\n" $top  | replace ".yaml" "" -}}
{{ printf $configmap_name }}
{{- end -}}

{{/*
Parameterisation of volume PVSize
*/}}
{{- define "eric-enm-common-helmchart-library.PVSize" -}}
{{- $pvSize := printf "%s%s" .Values.service.name "PVSize" -}}
{{- if index .Values "global" "persistentVolumeClaim" $pvSize -}}
{{- print (index .Values "global" "persistentVolumeClaim" $pvSize) -}}
{{- else if index .Values "persistentVolumeClaim" $pvSize -}}
{{- print (index .Values "persistentVolumeClaim" $pvSize) }}
{{- end -}}
{{- end -}}

{{- /*
eric-enm-common-helmchart-library.util.merge will merge two YAML templates and output the result.

This takes an array of three values:
- the top context
- the template name of the overrides (destination)
- the template name of the base (source)

*/ -}}
{{- define "eric-enm-common-helmchart-library.util.merge" -}}
{{- $top := first . -}}
{{- $overrides := fromYaml (include (index . 1) $top) | default (dict ) -}}
{{- $tpl := fromYaml (include (index . 2) $top) | default (dict ) -}}
{{- toYaml (merge $overrides $tpl) -}}
{{- end -}}