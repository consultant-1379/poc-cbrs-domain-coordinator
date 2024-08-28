{{/*
Expand the name of the chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "eric-cnom-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
Note: Currently we directly reference 'eric-cnom-server.name'. But this fullname template is kept
anyway so that we can change the logic here in the future without having to update templates
referencing it.
*/}}
{{- define "eric-cnom-server.fullname" -}}
{{ include "eric-cnom-server.name" . }}
{{- end }}

{{/*
Create chart version as used by the chart label.
*/}}
{{- define "eric-cnom-server.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}}

{{/*
Create chart name and version as used by the chart label
*/}}
{{- define "eric-cnom-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "eric-cnom-server.labels" -}}
chart: {{ include "eric-cnom-server.chart" . | quote }}
{{ include "eric-cnom-server.selectorLabels" . }}
app.kubernetes.io/version: {{ include "eric-cnom-server.version" . | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote}}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "eric-cnom-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eric-cnom-server.name" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end }}

{{/*
Create image registry url
*/}}
{{- define "eric-cnom-server.registryUrl" -}}
{{- if .Values.imageCredentials.registry.url -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- else -}}
{{- $global := fromJson (include "eric-cnom-server.global" .) }}
{{- print $global.registry.url -}}
{{- end -}}
{{- end -}}

{{/*
Create image repoPath
*/}}
{{- define "eric-cnom-server.repoPath" -}}
{{- if .Values.imageCredentials.repoPath -}}
{{- print "/" .Values.imageCredentials.repoPath "/" -}}
{{- else -}}
{{- print "/" -}}
{{- end -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-cnom-server.pullSecret" -}}
{{- $global := fromJson (include "eric-cnom-server.global" .) }}
{{- if .Values.imageCredentials.pullSecret -}}
{{- print .Values.imageCredentials.pullSecret -}}
{{- else if $global.pullSecret -}}
{{- print $global.pullSecret -}}
{{- end -}}
{{- end -}}

{{/*
Create image pull policy
*/}}
{{- define "eric-cnom-server.imagePullPolicy" -}}
{{- if .Values.imageCredentials.registry.imagePullPolicy -}}
{{- print .Values.imageCredentials.registry.imagePullPolicy -}}
{{- else -}}
{{- $global := fromJson (include "eric-cnom-server.global" .) }}
{{- print $global.registry.imagePullPolicy -}}
{{- end -}}
{{- end -}}

{{/*
Create annotation for the product information (DR-D1121-064)
*/}}
{{- define "eric-cnom-server.product-info" -}}
ericsson.com/product-name: "Core Network Operations Manager"
ericsson.com/product-number: "CXC 174 2153"
ericsson.com/product-revision: {{ mustRegexReplaceAll "(.*)[+|-].*" .Chart.Version "${1}" | quote }}
{{- end }}

{{/*
Create a map from ".Values.global" with defaults if missing in values file.
This hides defaults from values file.
*/}}
{{ define "eric-cnom-server.global" }}
  {{- $globalDefaults := dict "security" (dict "tls" (dict "enabled" true)) -}}
  {{- $globalDefaults := mustMerge $globalDefaults (dict "security" (dict "policyBinding" (dict "create" false))) -}}
  {{- $globalDefaults := mustMerge $globalDefaults (dict "security" (dict "policyReferenceMap" (dict "default-restricted-security-policy" "default-restricted-security-policy"))) -}}
  {{- $globalDefaults := mustMerge $globalDefaults (dict "timezone" "UTC") -}}
  {{- $globalDefaults := mustMerge $globalDefaults (dict "nodeSelector" (dict)) -}}
  {{- $globalDefaults := mustMerge $globalDefaults (dict "registry" (dict "url" "selndocker.mo.sw.ericsson.se")) -}}
  {{- $globalDefaults := mustMerge $globalDefaults (dict "registry" (dict "imagePullPolicy" "IfNotPresent")) -}}
  {{- $globalDefaults := mustMerge $globalDefaults (dict "pullSecret" "") -}}
  {{ if .Values.global }}
    {{- mustMergeOverwrite $globalDefaults .Values.global | mustToJson -}}
  {{ else }}
    {{- $globalDefaults | mustToJson -}}
  {{ end }}
{{ end }}

{{/*
Create a merged set of nodeSelectors from global and service level.
*/}}
{{ define "eric-cnom-server.nodeSelector" }}
{{- $global := fromJson (include "eric-cnom-server.global" .) -}}
{{- if .Values.nodeSelector -}}
  {{- range $key, $localValue := .Values.nodeSelector -}}
    {{- if hasKey $global.nodeSelector $key -}}
        {{- $globalValue := index $global.nodeSelector $key -}}
        {{- if ne $globalValue $localValue -}}
          {{- printf "nodeSelector \"%s\" is specified in both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $key $key $globalValue $key $localValue | fail -}}
        {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml (mustMerge $global.nodeSelector .Values.nodeSelector) | trim -}}
{{- else -}}
  {{- toYaml $global.nodeSelector | trim -}}
{{- end -}}
{{ end }}

{{/*
TLS CA certificates for our API
*/}}
{{- define "eric-cnom-server.tls-ca" -}}
{{- if and (not .Values.service.endpoints.api.tls.disableSipTls) (.Capabilities.APIVersions.Has "siptls.sec.ericsson.com/v1") -}}
  {{- "/cnom/certificates/api/sip_tls/client-cacertbundle.pem" }}
{{- else -}}
  {{- "" }}
{{- end -}}
{{- end }}

{{/*
TLS certificates for our API
*/}}
{{- define "eric-cnom-server.tls-certs" -}}
{{- if .Values.service.endpoints.api.tls.secret -}}
  {{- "/cnom/certificates/api/manually_created_secret/server.crt" }}
{{- else if and (not .Values.service.endpoints.api.tls.disableSipTls) (.Capabilities.APIVersions.Has "siptls.sec.ericsson.com/v1") -}}
  {{- "/cnom/certificates/api/sip_tls/cert.pem" }}
{{- else -}}
  {{- "" }}
{{- end -}}
{{- end }}

{{/*
TLS keys for our API
*/}}
{{- define "eric-cnom-server.tls-keys" -}}
{{- if .Values.service.endpoints.api.tls.secret -}}
  {{- "/cnom/certificates/api/manually_created_secret/server.key" }}
{{- else if and (not .Values.service.endpoints.api.tls.disableSipTls) (.Capabilities.APIVersions.Has "siptls.sec.ericsson.com/v1") -}}
  {{- "/cnom/certificates/api/sip_tls/key.pem" }}
{{- else -}}
  {{- "" }}
{{- end -}}
{{- end }}

{{/*
Authentication providers
*/}}
{{- define "eric-cnom-server.authentication-providers" -}}
{{- $local := .Values.authentication.local.enabled | ternary "local" "" -}}
{{- $ldap := .Values.authentication.ldap.enabled | ternary "ldapADP" "" -}}
{{- $uniqueProviders := list $local $ldap | mustCompact -}}
{{- if and .Values.authentication.enabled (eq (len ($uniqueProviders)) 0) -}}
{{- "authentication.enabled is set to true, but no authentication providers have been configured. Please enable an authentication provider." | fail -}}
{{- else if and .Values.authentication.enabled (gt (len ($uniqueProviders)) 1) -}}
{{- printf "Only one authentication provider can be enabled. This limitation might be lifted in the future. Currently enabled providers: %s" $uniqueProviders | fail -}}
{{- else }}
{{- $uniqueProviders | join "," }}
{{- end }}
{{- end }}
