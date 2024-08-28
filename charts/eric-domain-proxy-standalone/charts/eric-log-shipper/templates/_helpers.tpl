{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "eric-log-shipper.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eric-log-shipper.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-log-shipper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image url
*/}}
{{- define "eric-log-shipper.image-registry-url" -}}
{{- $g := fromJson (include "eric-log-shipper.global" .) }}
{{- $registryurl := or .Values.imageCredentials.registry.url $g.registry.url -}}
{{- printf "%s/%s/%s:%s" $registryurl .Values.imageCredentials.repoPath .Values.images.logshipper.name .Values.images.logshipper.tag -}}
{{- end -}}

{{- define "eric-log-shipper.annotations" }}
ericsson.com/product-name: "Log Shipper"
ericsson.com/product-number: "CXC 201 1464"
ericsson.com/product-revision: {{ (split "-" (.Chart.Version | replace "+" "-" ))._0 | quote }}
{{- if .Values.annotations }}
{{ toYaml .Values.annotations }}
{{- end }}
{{- end }}

{{/*
Create kubernetes.io name and version
*/}}
{{- define "eric-log-shipper.labels" }}
app.kubernetes.io/name: {{ include "eric-log-shipper.name" . | quote }}
app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Values.labels }}
{{ toYaml .Values.labels }}
{{- end }}
{{- end }}

{{- define "eric-log-shipper.hooks"}}
postStart:
  exec:
    command:
      - /opt/filebeat/lifecycle-events.sh
      - POSTSTART
preStop:
  exec:
    command:
      - /opt/filebeat/lifecycle-events.sh
      - PRESTOP
{{- end }}

{{/*
Create a map from testInternals with defaults if missing in values file.
This hides defaults from values file.
Version: 1.0
*/}}
{{ define "eric-log-shipper.testInternal" }}
  {{- $tiDefaults := (dict ) -}}
  {{ if .Values.testInternal }}
    {{- mergeOverwrite $tiDefaults .Values.testInternal | toJson -}}
  {{ else }}
    {{- $tiDefaults | toJson -}}
  {{ end }}
{{ end }}

{{/*
Create a map from ".Values.global" with defaults if missing in values file.
This hides defaults from values file.
*/}}
{{ define "eric-log-shipper.global" }}
  {{- $globalDefaults := dict "security" (dict "tls" (dict "enabled" true)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "nodeSelector" (dict)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "imagePullPolicy" "IfNotPresent")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "url" "armdocker.rnd.ericsson.se")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "pullSecret") -}}
  {{- $globalDefaults := merge $globalDefaults (dict "timezone" "UTC") -}}
  {{- $globalDefaults := merge $globalDefaults (dict "security" (dict "policyBinding" (dict "create" false))) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "security" (dict "policyReferenceMap" (dict "plc-d25a2e10e7bd762518298d62fb4c47" "plc-d25a2e10e7bd762518298d62fb4c47"))) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "security" (dict "policyReferenceMap" (dict "plc-eebfaeadbede5d397d46df59cd48e0" "plc-eebfaeadbede5d397d46df59cd48e0"))) -}}
  {{ if .Values.global }}
    {{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
  {{ else }}
    {{- $globalDefaults | toJson -}}
  {{ end }}
{{ end }}

{{/*
Create a merged set of nodeSelectors from global and service level.
*/}}
{{ define "eric-log-shipper.nodeSelector" }}
  {{- $g := fromJson (include "eric-log-shipper.global" .) -}}
  {{- if .Values.nodeSelector -}}
    {{- range $key, $localValue := .Values.nodeSelector -}}
      {{- if hasKey $g.nodeSelector $key -}}
          {{- $globalValue := index $g.nodeSelector $key -}}
          {{- if ne $globalValue $localValue -}}
            {{- printf "nodeSelector \"%s\" is specified in both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $key $key $globalValue $key $localValue | fail -}}
          {{- end -}}
      {{- end -}}
    {{- end -}}
    {{- toYaml (merge $g.nodeSelector .Values.nodeSelector) | trim -}}
  {{- else -}}
    {{- toYaml $g.nodeSelector | trim -}}
  {{- end -}}
{{ end }}

{{/*
Deprecated settings
*/}}
{{ define "eric-log-shipper.deprecated" }}
  {{- $deprecated := dict -}}
  {{- mergeOverwrite $deprecated .Values | toJson -}}
{{ end }}

{{/*
Deprecation notices
*/}}
{{- define "eric-log-shipper.deprecation-notices" }}
  {{- $d := fromJson (include "eric-log-shipper.deprecated" .) -}}
  {{- if quote .Values.rbac.createServiceAccount }}
    {{ printf "'rbac.createServiceAccount' is deprecated as of release 5.2.0" }}
  {{- end }}
{{- end }}
