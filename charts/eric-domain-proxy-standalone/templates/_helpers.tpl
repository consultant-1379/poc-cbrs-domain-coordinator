{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eric-domain-proxy-standalone.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-domain-proxy-standalone.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart version as used by the chart label.
*/}}
{{- define "eric-domain-proxy-standalone.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the resource name for the log-shipper.
*/}}
{{- define "eric-domain-proxy-standalone.log-shipper.name" -}}
{{- default (printf "%s-log-shipper" (include "eric-domain-proxy-standalone.name" .)) (index .Values "eric-log-shipper" "logshipper" "serviceAccountName") | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the resource name for the pm-server.
*/}}
{{- define "eric-domain-proxy-standalone.pm-server.serviceaccount.name" -}}
{{- default (printf "%s-pm-server" (include "eric-domain-proxy-standalone.name" .)) (index .Values "eric-pm-server" "server" "serviceAccountName") | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the resource name for the pm-server.
*/}}
{{- define "eric-domain-proxy-standalone.pm-server.clusterrole.name" -}}
{{- default (printf "%s-pm-server" (include "eric-domain-proxy-standalone.name" .)) (index .Values "eric-pm-server" "server" "serviceAccountName") | trunc 63 | trimSuffix "-" -}}-{{ .Release.Namespace }}
{{- end -}}
