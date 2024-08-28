{{/*
Expand the name of the chart.
*/}}
{{- define "eric-cnom-document-database-mg.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart version as used by the chart label.
*/}}
{{- define "eric-cnom-document-database-mg.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-cnom-document-database-mg.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a map from ".Values.global" with defaults if missing in values file.
This hides defaults from values file.
*/}}
{{ define "eric-cnom-document-database-mg.global" }}
  {{- $globalDefaults := dict "timezone" "UTC" -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "url" "selndocker.mo.sw.ericsson.se")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "pullSecret" "")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "nodeSelector" (dict)) -}}
  {{ if .Values.global }}
    {{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
  {{ else }}
    {{- $globalDefaults | toJson -}}
  {{ end }}
{{ end }}

{{/*
Create image registry url
*/}}
{{- define "eric-cnom-document-database-mg.registryUrl" -}}
{{- $global := fromJson (include "eric-cnom-document-database-mg.global" .) -}}
{{- if .Values.imageCredentials.registry.url -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- else -}}
{{- print $global.registry.url -}}
{{- end -}}
{{- end -}}

{{/*
Create image repoPath
*/}}
{{- define "eric-cnom-document-database-mg.repoPath" -}}
{{- if .Values.imageCredentials.repoPath -}}
{{- print "/" .Values.imageCredentials.repoPath "/" -}}
{{- else -}}
{{- print "/" -}}
{{- end -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-cnom-document-database-mg.pullSecrets" -}}
{{- $global := fromJson (include "eric-cnom-document-database-mg.global" .) -}}
{{- if .Values.imageCredentials.registry.pullSecret -}}
{{- print .Values.imageCredentials.registry.pullSecret -}}
{{- else if $global.registry.pullSecret -}}
{{- print $global.registry.pullSecret -}}
{{- end -}}
{{- end -}}

{{/*
Create a merged set of nodeSelectors from global and service level.
*/}}
{{ define "eric-cnom-document-database-mg.nodeSelector" }}
{{- $global := fromJson (include "eric-cnom-document-database-mg.global" .) -}}
{{- if .Values.nodeSelector -}}
  {{- range $key, $localValue := .Values.nodeSelector -}}
    {{- if hasKey $global.nodeSelector $key -}}
        {{- $globalValue := index $global.nodeSelector $key -}}
        {{- if ne $globalValue $localValue -}}
          {{- printf "nodeSelector \"%s\" is specified in both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $key $key $globalValue $key $localValue | fail -}}
        {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml (merge $global.nodeSelector .Values.nodeSelector) | trim -}}
{{- else -}}
  {{- toYaml $global.nodeSelector | trim -}}
{{- end -}}
{{ end }}

{{/*
Create the name for the admin secret.
*/}}
{{- define "eric-cnom-document-database-mg.adminSecret" -}}
    {{- if .Values.auth.existingAdminSecret -}}
        {{- .Values.auth.existingAdminSecret -}}
    {{- else -}}
        {{- template "eric-cnom-document-database-mg.name" . -}}-admin
    {{- end -}}
{{- end -}}

{{/*
Create the name for the key secret.
*/}}
{{- define "eric-cnom-document-database-mg.keySecret" -}}
    {{- if .Values.auth.existingKeySecret -}}
        {{- .Values.auth.existingKeySecret -}}
    {{- else -}}
        {{- template "eric-cnom-document-database-mg.name" . -}}-keyfile
    {{- end -}}
{{- end -}}

{{/*
Return the proper Storage Class
*/}}
{{- define "eric-cnom-document-database-mg.storageClass" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
*/}}
{{- $global := fromJson (include "eric-cnom-document-database-mg.global" .) -}}
{{- if $global -}}
    {{- if $global.storageClass -}}
        {{- if (eq "-" $global.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" $global.storageClass -}}
        {{- end -}}
    {{- else -}}
        {{- if .Values.persistence.storageClass -}}
              {{- if (eq "-" .Values.persistence.storageClass) -}}
                  {{- printf "storageClassName: \"\"" -}}
              {{- else }}
                  {{- printf "storageClassName: %s" .Values.persistence.storageClass -}}
              {{- end -}}
        {{- end -}}
    {{- end -}}
{{- else -}}
    {{- if .Values.persistence.storageClass -}}
        {{- if (eq "-" .Values.persistence.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" .Values.persistence.storageClass -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Returns the proper Service name depending if an explicit service name is set
in the values file. If the name is not explicitly set it will take the "eric-cnom-document-database-mg.name"
*/}}
{{- define "eric-cnom-document-database-mg.serviceName" -}}
  {{- if .Values.service.name -}}
    {{ .Values.service.name }}
  {{- else -}}
    {{ template "eric-cnom-document-database-mg.name" .}}
  {{- end -}}
{{- end -}}

{{/*
Return Ericsson product information which should be appended in all resource annotations.
*/}}
{{- define "eric-cnom-document-database-mg.product-info" -}}
{{- if .Values.productInfo -}}
{{- with .Values.productInfo -}}
{{- if .name }}
{{ printf "ericsson.com/product-name: %s" .name }}
{{- end -}}
{{- if .productNumber }}
{{ printf "ericsson.com/product-number: %s" .productNumber }}
{{- end -}}
{{- if .revision }}
{{ printf "ericsson.com/product-revision: %s" .revision }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}