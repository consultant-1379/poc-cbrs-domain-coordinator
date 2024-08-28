{{/* vim: set filetype=mustache: */}}

{{/*
Create a map from ".Values.global" with defaults if missing in values file.
This hides defaults from values file.
*/}}
{{ define "eric-pm-server.global" }}
  {{- $globalDefaults := dict "security" (dict "tls" (dict "enabled" true)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "url" "armdocker.rnd.ericsson.se")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "timezone" "UTC") -}}
  {{- $globalDefaults := merge $globalDefaults (dict "nodeSelector" (dict)) -}}
  {{ if .Values.global }}
    {{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
  {{ else }}
    {{- $globalDefaults | toJson -}}
  {{ end }}
{{ end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "eric-pm-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create version
*/}}
{{- define "eric-pm-server.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-pm-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image registry url
*/}}
{{- define "eric-pm-server.registry" -}}
{{- if .Values.imageCredentials.registry.url -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- else -}}
{{- $g := fromJson (include "eric-pm-server.global" .) -}}
{{- print $g.registry.url -}}
{{- end -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-pm-server.pullSecrets" -}}
  {{- if .Values.imageCredentials.pullSecret }}
    {{- print .Values.imageCredentials.pullSecret }}
  {{- else -}}
    {{- $g := fromJson (include "eric-pm-server.global" .) -}}
    {{- if $g.pullSecret }}
      {{- print $g.pullSecret }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
[ADPPRG-23796] Create image credentials repopath and remove the double //
*/}}
{{- define "eric-pm-server.repoPath" -}}
{{- if .Values.imageCredentials.repoPath -}}
{{- print "/" .Values.imageCredentials.repoPath "/" -}}
{{- else -}}
{{- print "/" -}}
{{- end -}}
{{- end -}}

{{/*
Create configuration reload url
*/}}
{{- define "eric-pm-server.configmap-reload.webhook" -}}
{{- if .Values.server.prefixURL -}}
{{- printf "http://127.0.0.1:9090/%s/-/reload" .Values.server.prefixURL -}}
{{- else -}}
{{- print "http://127.0.0.1:9090/-/reload" -}}
{{- end -}}
{{- end -}}

{{/*
Create a merged set of nodeSelectors from global and service level.
*/}}
{{ define "eric-pm-server.nodeSelector" }}
  {{- $g := fromJson (include "eric-pm-server.global" .) -}}
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

{{- define "eric-pm-server.fsGroup.coordinated" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.fsGroup -}}
            {{- if .Values.global.fsGroup.manual -}}
                {{ .Values.global.fsGroup.manual }}
            {{- else -}}
                {{- if eq .Values.global.fsGroup.namespace true -}}
                     # The 'default' defined in the Security Policy will be used.
                {{- else -}}
                    10000
                {{- end -}}
            {{- end -}}
        {{- else -}}
            10000
        {{- end -}}
    {{- else -}}
        10000
    {{- end -}}
{{- end -}}
