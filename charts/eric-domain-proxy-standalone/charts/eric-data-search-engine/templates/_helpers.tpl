{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "eric-data-search-engine.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "eric-data-search-engine.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eric-data-search-engine.fullname" -}}
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
{{- define "eric-data-search-engine.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image url
*/}}
{{- define "eric-data-search-engine.image-registry-url" -}}
{{- $g := fromJson (include "eric-data-search-engine.global" .) }}
{{- $registryurl := or .Values.imageCredentials.registry.url $g.registry.url -}}
{{- printf "%s/%s/%s:%s" $registryurl .Values.imageCredentials.repoPath .Values.images.searchengine.name .Values.images.searchengine.tag -}}
{{- end -}}

{{/*
Create agent name
*/}}
{{- define "eric-data-search-engine.agentname" -}}
{{ template "eric-data-search-engine.name" . }}-agent
{{- end -}}

{{/*
Create a map from testInternals with defaults if missing in values file.
This hides defaults from values file.
Version: 1.0
*/}}
{{ define "eric-data-search-engine.testInternal" }}
  {{- $tiDefaults := (dict ) -}}
  {{ if .Values.testInternal }}
    {{- mergeOverwrite $tiDefaults .Values.testInternal | toJson -}}
  {{ else }}
    {{- $tiDefaults | toJson -}}
  {{ end }}
{{ end }}

{{/*
Create a map from .Values.global with defaults if missing in values file.
This hides defaults from values file.
*/}}
{{ define "eric-data-search-engine.global" }}
  {{- $globalDefaults := dict "security" (dict "tls" (dict "enabled" true)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "imagePullPolicy" "IfNotPresent")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "url" "armdocker.rnd.ericsson.se")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "pullSecret") -}}
  {{- $globalDefaults := merge $globalDefaults (dict "timezone" "UTC") -}}
  {{- $globalDefaults := merge $globalDefaults (dict "nodeSelector" (dict)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "internalIPFamily" "") -}}
  {{- $globalDefaults := merge $globalDefaults (dict "fsGroup" (dict)) -}}
  {{ if .Values.global }}
    {{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
  {{ else }}
    {{- $globalDefaults | toJson -}}
  {{ end }}
{{ end }}

{{- define "eric-data-search-engine.deprecation-notices" -}}
{{- $g := fromJson (include "eric-data-search-engine.global" .) }}
{{- end }}

{{- define "eric-data-search-engine.pod-anti-affinity" }}
affinity:
  podAntiAffinity:
  {{- if eq .root.Values.affinity.podAntiAffinity "hard" }}
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: "app"
              operator: "In"
              values:
                - {{ include "eric-data-search-engine.fullname" .root | quote }}
            - key: "role"
              operator: "In"
              values:
                - {{ .context | quote }}
        topologyKey: "kubernetes.io/hostname"
  {{- else if eq .root.Values.affinity.podAntiAffinity "soft" }}
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: "app"
                operator: "In"
                values:
                  - {{ include "eric-data-search-engine.fullname" .root | quote }}
              - key: "role"
                operator: "In"
                values:
                  - {{ .context | quote }}
          topologyKey: "kubernetes.io/hostname"
  {{- end -}}
{{- end -}}

{{/*
Create a merged set of nodeSelectors from global and service level.
*/}}
{{- define "eric-data-search-engine.nodeSelector" }}
{{- $g := fromJson (include "eric-data-search-engine.global" .root) -}}
  {{- $localNodeSelectorForContext := index .root.Values.nodeSelector .context -}}
  {{- if $localNodeSelectorForContext -}}
    {{- range $key, $localValue := $localNodeSelectorForContext -}}
        {{- if hasKey $g.nodeSelector $key -}}
          {{- $globalValue := index $g.nodeSelector $key -}}
          {{- if ne $globalValue $localValue -}}
            {{- printf "nodeSelector \"%s\" is specified in both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $key $key $globalValue $key $localValue | fail -}}
          {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- toYaml (merge $g.nodeSelector $localNodeSelectorForContext) | trim -}}
  {{- else -}}
    {{- toYaml $g.nodeSelector | trim -}}
  {{- end -}}
{{- end -}}

{{- define "eric-data-search-engine.fsGroup.coordinated" -}}
{{- $g := fromJson (include "eric-data-search-engine.global" .) -}}
    {{- if $g.fsGroup.manual -}}
        {{ $g.fsGroup.manual }}
    {{- else if $g.fsGroup.namespace -}}
        {{- print "# The 'default' defined in the Security Policy will be used." -}}
    {{- else -}}
        10000
    {{- end -}}
{{- end -}}

{{- define "eric-data-search-engine.log-redirect" -}}
  {{- if has "stream" .Values.log.outputs -}}
    {{- if has "stdout" .Values.log.outputs -}}
      {{- "all" -}}
    {{- else -}}
      {{- "file" -}}
    {{- end -}}
  {{- else -}}
    {{- "stdout" -}}
  {{- end -}}
{{- end -}}
