{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-enmsg-dpmediation.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate Product info
*/}}
#product-info for configmap is resides inside _configmap.yaml
#If any change in the below product-info. Its Mandatory to change in the _configmap.yaml
{{- define "eric-enmsg-dpmediation.product-info" }}
ericsson.com/product-name: {{ default (include "eric-enmsg-dpmediation.productName" .) }}
ericsson.com/product-number: "{{ .Values.productInfo.number }}"
ericsson.com/product-revision: "{{ .Values.productInfo.rstate }}"
{{- end}}

{{/*
Generate product name
*/}}
{{- define "eric-enmsg-dpmediation.productName" -}}
{{- $product_name := printf "%s-%s" "helm" .Chart.Name -}}
{{- print $product_name -}}
{{- end -}}

{{/*
Create replicas
*/}}
{{- define "eric-enmsg-dpmediation.replicas" -}}
{{- $replica_SG_name := printf "%s-%s" "replicas" .Chart.Name -}}
{{- if index .Values "global" $replica_SG_name -}}
{{- print (index .Values "global" $replica_SG_name) -}}
{{- else if index .Values $replica_SG_name -}}
{{- print (index .Values $replica_SG_name) -}}
{{- end -}}
{{- end -}}

{{/*
Create image registry url
*/}}
{{- define "eric-enmsg-dpmediation.registryUrl" -}}
{{- if .Values.global.registry.url -}}
{{- print .Values.global.registry.url -}}
{{- else -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- end -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eric-enmsg-dpmediation.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-enmsg-dpmediation.pullSecrets" -}}
{{- if .Values.global.registry.pullSecret -}}
{{- print .Values.global.registry.pullSecret -}}
{{- else if .Values.imageCredentials.registry.pullSecret -}}
{{- print .Values.imageCredentials.registry.pullSecret -}}
{{- end -}}
{{- end -}}

{{/*
Generate config map  name
*/}}
{{- define "eric-enmsg-dpmediation.configmapName" -}}
{{- $top := first . -}}
{{- $configmap_name := printf "%s\n" $top  | replace ".yaml" "" -}}
{{ printf "%s" $configmap_name }}
{{- end -}}

{{/*
Create ingress hosts
*/}}
{{- define "eric-enmsg-dpmediation.enmHost" -}}
{{- if .Values.global.ingress.enmHost -}}
{{- print .Values.global.ingress.enmHost -}}
{{- else if .Values.ingress.enmHost -}}
{{- print .Values.ingress.enmHost -}}
{{- end -}}
{{- end -}}