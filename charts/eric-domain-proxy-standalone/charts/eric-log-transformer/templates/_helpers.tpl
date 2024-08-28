{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "eric-log-transformer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eric-log-transformer.fullname" -}}
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
{{- define "eric-log-transformer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image url
*/}}
{{- define "eric-log-transformer.image-registry-url" -}}
{{- $g := fromJson (include "eric-log-transformer.global" .) }}
{{- $registryurl := or .Values.imageCredentials.registry.url $g.registry.url -}}
{{- printf "%s/%s/%s:%s" $registryurl .Values.imageCredentials.repoPath .Values.images.logtransformer.name .Values.images.logtransformer.tag -}}
{{- end -}}

{{/*
Create kubernetes.io name and version
*/}}
{{- define "eric-log-transformer.labels" }}
app.kubernetes.io/name: {{ include "eric-log-transformer.name" . }}
app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Values.labels }}
{{ toYaml .Values.labels }}
{{- end }}
{{- end }}

{{- define "eric-log-transformer.annotations" }}
ericsson.com/product-name: "Log Transformer"
ericsson.com/product-number: "CXC 201 1068"
ericsson.com/product-revision: {{ (split "-" (.Chart.Version | replace "+" "-" ))._0 | quote }}
{{- if .Values.annotations }}
{{ toYaml .Values.annotations }}
{{- end }}
{{- end }}

{{- define "eric-log-transformer.hooks" }}
postStart:
  exec:
    command:
      - /opt/logstash/lifecycle-events.sh
      - POSTSTART
preStop:
  exec:
    command:
      - /opt/logstash/lifecycle-events.sh
      - PRESTOP
{{- end}}

{{/*
Create Search Engine host address
*/}}
{{- define "eric-log-transformer.elasticsearch-host" -}}
{{- $g := fromJson (include "eric-log-transformer.global" .) -}}
{{- if $g.security.tls.enabled -}}
  {{- printf "%s-tls:%d" .Values.searchengine.host (int .Values.searchengine.port) -}}
{{- else -}}
  {{- printf "%s:%d" .Values.searchengine.host (int .Values.searchengine.port) -}}
{{- end -}}
{{- end -}}

{{- define "eric-log-transformer.beats-tls-config-options" -}}
{{- $d := fromJson (include "eric-log-transformer.deprecated" .) }}
{{- if not $d.security.tls.eda }}
ssl_certificate => "/opt/logstash/certificates/srvcert.pem"
ssl_key => "/opt/logstash/certificates/srvpriv_p8.key"
ssl_certificate_authorities => ["/run/secrets/ca-certificates/client-cacertbundle.pem"]
{{- else }}
ssl_certificate => "/run/secrets/eda-certificates/cert.pem"
ssl_key => "/run/secrets/eda-certificates/key.pem"
ssl_certificate_authorities => ["/run/secrets/eda-certificates/ca-cert.pem"]
{{- end }}
ssl => true
client_inactivity_timeout => 60
ssl_handshake_timeout => 10000
ssl_verify_mode => "force_peer"
tls_max_version => "1.2"
tls_min_version => "1.2"
{{- end -}}

{{/*
Creating secret volume for TLS between LT and LS
Creating Secret Volumes for Server Certificate and Client CA Certificate
*/}}
{{- define "eric-log-transformer.tls-volume" }}
- name: "server-certificate"
  secret:
    secretName: {{ include "eric-log-transformer.fullname" . }}-server-cert
- name: "client-ca-certificate"
  secret:
    secretName: {{ include "eric-log-transformer.fullname" . }}-client-ca
{{- end -}}

{{/*
Creating volume mount for TLS between LT and LS
Creating volumeMounts for Server certificate and Client CA certificate
*/}}
{{- define "eric-log-transformer.tls-volumemount" }}
- name: "server-certificate"
  mountPath: "/run/secrets/certificates/"
  readOnly: true
- name: "client-ca-certificate"
  mountPath: "/run/secrets/ca-certificates/"
  readOnly: true
{{- end -}}

{{/*
Creating secret volume for EDA TLS
*/}}
{{- define "eric-log-transformer.eda-tls-volume" }}
- name: "eda-certificates"
  secret:
    secretName: {{ include "eric-log-transformer.fullname" . }}-server-cert
{{- end -}}

{{/*
Creating volume mount for EDA TLS
*/}}
{{- define "eric-log-transformer.eda-tls-volumemount" }}
- name: "eda-certificates"
  mountPath: "/run/secrets/eda-certificates/"
  readOnly: true
{{- end -}}

{{- define "eric-log-transformer.tcp-eda-tls-config-options" -}}
{{- $d := fromJson (include "eric-log-transformer.deprecated" .) }}
{{- if $d.security.tls.eda }}
ssl_cert => "/run/secrets/eda-certificates/cert.pem"
ssl_key => "/run/secrets/eda-certificates/key.pem"
ssl_certificate_authorities => ["/run/secrets/eda-certificates/ca-cert.pem"]
ssl_enable => true
ssl_verify => true
{{- end }}
{{- end -}}

{{/*
Create a map from testInternals with defaults if missing in values file.
This hides defaults from values file.
Version: 1.0
*/}}
{{ define "eric-log-transformer.testInternal" }}
  {{- $tiDefaults := (dict "env" (dict) ) -}}
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
{{ define "eric-log-transformer.global" }}
  {{- $globalDefaults := dict "security" (dict "tls" (dict "enabled" true)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "nodeSelector" (dict)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "imagePullPolicy" "IfNotPresent")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "url" "armdocker.rnd.ericsson.se")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "pullSecret")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "pullSecret") -}}
  {{- $globalDefaults := merge $globalDefaults (dict "timezone" "UTC") -}}
  {{- $globalDefaults := merge $globalDefaults (dict "internalIPFamily" "") -}}
  {{- $globalDefaults := merge $globalDefaults (dict "security" (dict "policyBinding" (dict "create" false))) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "security" (dict "policyReferenceMap" (dict "default-restricted-security-policy" "default-restricted-security-policy"))) -}}
  {{ if .Values.global }}
    {{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
  {{ else }}
    {{- $globalDefaults | toJson -}}
  {{ end }}
{{ end }}

{{/*
Deprecated settings.
*/}}
{{ define "eric-log-transformer.deprecated" }}
  {{- $deprecated := dict "security" (dict "tls" (dict "logshipper" (dict "enabled" false))) -}}
  {{- mergeOverwrite $deprecated .Values | toJson -}}
{{ end }}

{{/*
Deprecation notices
*/}}
{{- define "eric-log-transformer.deprecation-notices" -}}
  {{- $d := fromJson (include "eric-log-transformer.deprecated" .) -}}
  {{- if $d.security.tls.logshipper.enabled }}
    {{ printf "'security.tls.logshipper.enabled' is deprecated as of release 4.6.0" }}
  {{- end }}
  {{- if .Values.syslog.defaultFacility }}
    {{ printf "'syslog.defaultFacility' is deprecated as of release 5.5.0"}}
  {{- end }}
  {{- if .Values.syslog.defaultSeverity }}
    {{ printf "'syslog.defaultSeverity' is deprecated as of release 5.5.0"}}
  {{- end }}
  {{- if .Values.syslog.output }}
    {{ printf "'syslog.output' is deprecated as of release 5.5.0"}}
  {{- end }}
{{- end }}

{{- define "eric-log-transformer.pod-anti-affinity" }}
affinity:
  podAntiAffinity:
  {{- if eq .Values.affinity.podAntiAffinity "hard" }}
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: "app"
              operator: "In"
              values:
                - {{ include "eric-log-transformer.fullname" . | quote }}
        topologyKey: "kubernetes.io/hostname"
  {{- else if eq .Values.affinity.podAntiAffinity  "soft" }}
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: "app"
                operator: "In"
                values:
                  - {{ include "eric-log-transformer.fullname" . | quote }}
          topologyKey: "kubernetes.io/hostname"
  {{- end -}}
{{- end -}}

{{/*
Create a merged set of nodeSelectors from global and service level.
*/}}
{{ define "eric-log-transformer.nodeSelector" }}
  {{- $g := fromJson (include "eric-log-transformer.global" .) -}}
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
Create asymmetric-key-certificate-name for lumberjack output.
*/}}
{{- define "eric-log-transformer.lumberjack-output-asymmetric-cert" -}}
{{- printf "%s/%s" .Values.egress.lumberjack.certificates.asymmetricKeyCertificateName .Values.egress.lumberjack.certificates.asymmetricKeyCertificateName -}}
{{- end -}}

{{ define "eric-log-transformer.syslog-output-config" }}
  {{- $sc := .Values.egress.syslog -}}
  {{ if .Values.syslog.output }}
    {{- $sc = mergeOverwrite $sc .Values.syslog.output -}}
    {{ if .Values.syslog.output.tls }}
      {{ if .Values.syslog.output.tls.certificates }}
        {{- $sc = set $sc "certificates" .Values.syslog.output.tls.certificates -}}
        {{ if .Values.syslog.output.tls.certificates.asymmetricKeyCertificateName }}
        {{- $sc = set $sc "oldCert" .Values.syslog.output.tls.certificates.asymmetricKeyCertificateName -}}
        {{ end }}
      {{ end }}
    {{ end }}
  {{ end }}
  {{ if .Values.syslog.defaultFacility }}
    {{- $sc = set $sc "defaultFacility" .Values.syslog.defaultFacility -}}
  {{ end }}
  {{ if .Values.syslog.defaultSeverity }}
    {{- $sc = set $sc "defaultSeverity" .Values.syslog.defaultSeverity -}}
  {{ end }}
  {{- $sc | toJson -}}
{{ end }}

{{- define "eric-log-transformer.total-queue-size" -}}
  {{- $syslogOutput := fromJson (include "eric-log-transformer.syslog-output-config" .) -}}
  {{- $sizePerPipeline := max 128 .Values.queue.sizePerPipeline -}}
  {{- $totalSize := add $sizePerPipeline 10 -}}
  {{- $totalSize = add $totalSize $sizePerPipeline -}}
  {{- if $syslogOutput.enabled -}}
    {{- $totalSize = add $totalSize $sizePerPipeline -}}
  {{- end -}}
  {{- if .Values.egress.lumberjack.enabled -}}
    {{- $totalSize = add $totalSize $sizePerPipeline -}}
  {{- end -}}
  {{- if .Values.config.output -}}
    {{- range .Values.config.output -}}
      {{- $totalSize = add $totalSize $sizePerPipeline -}}
    {{- end -}}
  {{- end -}}
  {{- printf "%dMi" $totalSize -}}
{{- end -}}

{{- define "eric-log-transformer.logshipper-context" -}}
  {{- $logplane := default "adp-app-logs" .Values.log.logplane.default -}}
  {{- $transformer := dict "logplane" (default $logplane .Values.log.logplane.logtransformer) -}}
  {{- $transformer := merge $transformer (dict "multiline" (dict "pattern" "''^\\[''")) -}}
  {{- $transformer := merge $transformer (dict "multiline" (dict "negate" "true")) -}}
  {{- $transformer := merge $transformer (dict "multiline" (dict "match" "after")) -}}
  {{- $transformer := merge $transformer (dict "subPaths" (list "logtransformer.log*")) -}}
  {{- $tlsproxy := dict "logplane" (default $logplane .Values.log.logplane.tlsproxy ) -}}
  {{- $tlsproxy := merge $tlsproxy (dict "subPaths" (list "tlsproxy.log*")) -}}
  {{- $metrics := dict "logplane" (default $logplane .Values.log.logplane.metrics) -}}
  {{- $metrics := merge $metrics (dict "subPaths" (list "metrics.log*")) -}}
  {{- $logshipperContext :=  (dict "Values" (dict "logshipper" (dict "storagePath" "/logs/"))) -}}
  {{- $logshipperContext := merge $logshipperContext (dict "Values" (dict "logshipper" (dict "logplane" .Values.log.logplane.default))) -}}
  {{- $logshipperContext := merge $logshipperContext (dict "Values" (dict "logshipper" (dict "storageAllocation" "123Mi"))) -}}
  {{- $logshipperContext := merge $logshipperContext (dict "Values" (dict "logshipper" (dict "harvester" (dict "closeTimeout" "5m")))) -}}
  {{- $logshipperContext := merge $logshipperContext (dict "Values" (dict "logshipper" (dict "harvester" (dict "logData" (list $transformer $tlsproxy $metrics))))) -}}
  {{- $logshipperContext := merge $logshipperContext (dict "Values" (dict "logshipper" (dict "logtransformer" (dict "host" "eric-log-transformer"))))  -}}
  {{- $logshipperContext | toJson -}}
{{ end }}
