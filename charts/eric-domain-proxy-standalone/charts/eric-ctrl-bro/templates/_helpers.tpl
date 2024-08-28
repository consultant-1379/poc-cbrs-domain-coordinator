
{{/*
Create a map from global values with defaults if not in the values file.
*/}}
{{ define "eric-ctrl-bro.globalMap" }}
{{- $globalDefaults := dict "security" (dict "policyBinding" (dict "create" false)) -}}
{{- $globalDefaults := merge $globalDefaults (dict "security" (dict "policyReferenceMap" (dict "default-restricted-security-policy" "default-restricted-security-policy"))) -}}
{{ if .Values.global }}
{{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
{{ else }}
{{- $globalDefaults | toJson -}}
{{ end }}
{{ end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-ctrl-bro.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Chart version.
*/}}
{{- define "eric-ctrl-bro.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Expand the name of the chart.
*/}}
{{- define "eric-ctrl-bro.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Template for k8s labels.
*/}}
{{- define "eric-ctrl-bro.k8sLabels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
chart: {{ template "eric-ctrl-bro.chart" . }}
app.kubernetes.io/name: {{ template "eric-ctrl-bro.name" . }}
app.kubernetes.io/version: {{ template  "eric-ctrl-bro.version" . }}
app.kubernetes.io/instance: {{.Release.Name | quote }}
{{- end -}}

{{/*
Ericsson product info values.
*/}}
{{- define "eric-ctrl-bro.productName" -}}
Backup and Restore Orchestrator
{{- end -}}
{{- define "eric-ctrl-bro.productNumber" -}}
CXC 201 2182
{{- end -}}

{{/*
Ericsson product info annotations. The Chart version should match the product information.
*/}}
{{- define "eric-ctrl-bro.prodInfoAnnotations" -}}
{{ template "eric-ctrl-bro.prodBaseAnnotations" . -}}
 {{- if .Values.annotations }}
{{- range $key, $value := .Values.annotations }}
{{ $key | indent 0 }}: {{ $value | quote }}
 {{- end }}
 {{- end -}}
{{- end -}}

{{/*
Ericsson product info labels.
*/}}
{{- define "eric-ctrl-bro.prodInfoLabels" -}}
 {{- if .Values.labels }}
{{- range $key, $value := .Values.labels }}
{{ $key | indent 0}}: {{ $value | quote }}
 {{- end }}
{{- end }}
{{- end -}}

{{/*
Ericsson product information annotations
*/}}
{{- define "eric-ctrl-bro.prodBaseAnnotations" }}
ericsson.com/product-name: "{{ template "eric-ctrl-bro.productName" . }}"
ericsson.com/product-number: "{{ template "eric-ctrl-bro.productNumber" . }}"
ericsson.com/product-revision: {{regexReplaceAll "(.*)[+].*" .Chart.Version "${1}" }}
{{- end -}}

{{/*
Comma separated list of product numbers
*/}}
{{- define "eric-ctrl-bro.productNumberList" }}
{{- range $i, $e := .Values.bro.productNumberList -}}
{{- if eq $i 0 -}}{{- printf " " -}}{{- else -}}{{- printf "," -}}{{- end -}}{{- . -}}
{{- end -}}
{{- end -}}

{{/*
LivenessProbe
*/}}
{{- define "eric-ctrl-bro.livenessProbe" }}
{{- if eq (include "eric-ctrl-bro.global.tls" .) "true" -}}
    {{- if eq .Values.service.endpoints.restActions.tls.enforced "required" -}}
        {{- if eq .Values.service.endpoints.restActions.tls.verifyClientCertificate "required" -}}
                      exec:
            command:
              - sh
              - -c
              - |
                grep -Rq Healthy /healthStatus/broLiveHealth.json && rm -rf /healthStatus/broLiveHealth.json
        {{- else -}}
                    httpGet:
            path: /v1/health
            port: {{ .Values.bro.restTlsPort }}
            scheme: HTTPS
        {{- end -}}
    {{- else -}}
                  httpGet:
            path: /v1/health
            port: {{ .Values.bro.restPort }}
    {{- end -}}
{{- else -}}
              httpGet:
            path: /v1/health
            port: {{ .Values.bro.restPort }}
{{- end -}}
{{- end -}}

{{/*
ReadinessProbe
*/}}
{{- define "eric-ctrl-bro.readinessProbe" }}
{{- if eq (include "eric-ctrl-bro.global.tls" .) "true" -}}
    {{- if eq .Values.service.endpoints.restActions.tls.enforced "required" -}}
        {{- if eq .Values.service.endpoints.restActions.tls.verifyClientCertificate "required" -}}
                      exec:
            command:
              - sh
              - -c
              - |
                grep -Rq Healthy /healthStatus/broReadyHealth.json && rm -rf /healthStatus/broReadyHealth.json
        {{- else -}}
                    httpGet:
            path: /v1/health
            port: {{ .Values.bro.restTlsPort }}
            scheme: HTTPS
        {{- end -}}
    {{- else -}}
                  httpGet:
            path: /v1/health
            port: {{ .Values.bro.restPort }}
    {{- end -}}
{{- else -}}
              httpGet:
            path: /v1/health
            port: {{ .Values.bro.restPort }}
{{- end -}}
{{- end -}}

{{/*
Define Template PDB
*/}}
{{- define "eric-ctrl-bro.podDisruptionBudget" -}}
{{- if .Values.podDisruptionBudget -}}
  {{ .Values.podDisruptionBudget.minAvailable }}
{{- else -}}
  0
{{- end -}}
{{- end -}}

{{/*
Global Security
*/}}
{{- define "eric-ctrl-bro.globalSecurity" -}}
{{- if .Values.global }}
    {{- if .Values.global.security -}}
       {{- if .Values.global.security.tls -}}
          {{- if eq .Values.global.security.tls.enabled false -}}
              false
          {{- else -}}
            true
          {{- end -}}
       {{- else -}}
           true
       {{- end -}}    
    {{- else -}}
        true
    {{- end -}}
{{- else -}}
    true
{{- end -}}
{{- end -}}

{{/*
PM Server Security Enabled
*/}}
{{- define "eric-ctrl-bro.pmServerSecurityType" -}}
{{- if eq .Values.service.endpoints.scrape.pm.tls.enforced "required" -}}
    {{- if eq .Values.service.endpoints.scrape.pm.tls.verifyClientCertificate "required" -}}
        need
    {{- else -}}
        want
    {{- end -}}
{{- else -}}
    all
{{- end -}}
{{- end -}}

{{/*
CMM Notification Server Security Enabled
*/}}
{{- define "eric-ctrl-bro.cmmNotifServer" -}}
{{- if eq .Values.service.endpoints.cmmHttpNotif.tls.enforced "required" -}}
    {{- if eq .Values.service.endpoints.cmmHttpNotif.tls.verifyClientCertificate "required" -}}
        need
    {{- else -}}
        want
    {{- end -}}
{{- else -}}
    all
{{- end -}}
{{- end -}}

{{/*
configmap volumes + additional volumes
*/}}
{{- define "eric-ctrl-bro.volumes" -}}
- name: health-status-volume
  emptyDir: {}
- name: {{ template "eric-ctrl-bro.name" . }}-logging
  configMap:
    defaultMode: 0444
    name: {{ template "eric-ctrl-bro.name" . }}-logging
{{- if (eq (include "eric-ctrl-bro.globalSecurity" .) "true") }}
- name: {{ template "eric-ctrl-bro.name" . }}-server-cert
  secret:
    secretName: {{ template "eric-ctrl-bro.name" . }}-server-cert
- name: {{ template "eric-ctrl-bro.name" . }}-ca
  secret:
    secretName: {{ template "eric-ctrl-bro.name" . }}-ca
- name: {{ template "eric-ctrl-bro.name" . }}-siptls-root-ca
  secret:
    secretName: eric-sec-sip-tls-trusted-root-cert
{{- if .Values.monitoring.enabled }}
- name: eric-pm-server-ca
  secret:
    secretName: eric-pm-server-ca
{{- end }}
{{- with . }}
{{- $logstreaming := include "eric-ctrl-bro.logstreaming" . | fromYaml }}
{{- if has "tcp" (get $logstreaming "logOutput") }}
- name: {{ template "eric-ctrl-bro.name" . }}-lt-client-cert
  secret:
    secretName: {{ template "eric-ctrl-bro.name" . }}-lt-client-certificate
{{- end }}
{{- end }}
{{- if .Values.bro.enableConfigurationManagement }}
- name: eric-cmm-tls-client-ca
  secret:
    secretName: eric-cm-mediator-tls-client-ca-secret
- name: eric-cmyp-server-ca
  secret:
    secretName: eric-cm-yang-provider-ca-secret
- name: {{ template "eric-ctrl-bro.name" . }}-cmm-client-cert
  secret:
    secretName: {{ template "eric-ctrl-bro.name" . }}-cmm-client-secret
{{- end }}
{{- if .Values.bro.enableNotifications }}
- name: {{ template "eric-ctrl-bro.name" . }}-mbkf-client-cert
  secret:
    secretName: {{ template "eric-ctrl-bro.name" . }}-mbkf-client-secret
{{ end }}
{{- end }}
- name: {{ template "eric-ctrl-bro.name" . }}-serviceproperties
  configMap:
    defaultMode: 0444
    name: {{ template "eric-ctrl-bro.name" . }}-serviceproperties
{{ if .Values.volumes -}}
{{ .Values.volumes -}}
{{ end -}}
{{ end -}}

{{/*
configmap volumemounts + additional volume mounts
*/}}
{{- define "eric-ctrl-bro.volumeMounts" -}}
- name: health-status-volume
  mountPath: /healthStatus
- name: {{ template "eric-ctrl-bro.name" . }}-logging
  mountPath: "{{ .Values.bro.logging.logDirectory }}/{{ .Values.bro.logging.log4j2File }}"
  subPath: "{{ .Values.bro.logging.log4j2File }}"
- name: {{ template "eric-ctrl-bro.name" . }}-serviceproperties
  mountPath: "/opt/ericsson/br/application.properties"
  subPath: "application.properties"
{{- if (eq (include "eric-ctrl-bro.globalSecurity" .) "true") }}
- name: {{ template "eric-ctrl-bro.name" . }}-server-cert
  mountPath: "/run/sec/certs/server"
- name: {{ template "eric-ctrl-bro.name" . }}-ca
  mountPath: "/run/sec/cas/broca/"
- name: {{ template "eric-ctrl-bro.name" . }}-siptls-root-ca
  readOnly: true
  mountPath: /run/sec/cas/siptls
{{ if .Values.monitoring.enabled }}
- name: eric-pm-server-ca
  readOnly: true
  mountPath: /run/sec/cas/pm
{{- end }}
{{- with . }}
{{- $logstreaming := include "eric-ctrl-bro.logstreaming" . | fromYaml }}
{{- if has "tcp" (get $logstreaming "logOutput") }}
- name: {{ template "eric-ctrl-bro.name" . }}-lt-client-cert
  readOnly: true
  mountPath: /run/sec/certs/logtransformer
{{- end }}
{{- end }}
{{- if .Values.bro.enableConfigurationManagement }}
- name: eric-cmm-tls-client-ca
  mountPath: "/run/sec/certs/cmmserver/ca"
- name: eric-cmyp-server-ca
  readOnly: true
  mountPath: /run/sec/cas/cmyp
- name: {{ template "eric-ctrl-bro.name" . }}-cmm-client-cert
  mountPath: "/run/sec/certs/cmmserver"
{{- end }}
{{- if .Values.bro.enableNotifications }}
- name: {{ template "eric-ctrl-bro.name" . }}-mbkf-client-cert
  readOnly: true
  mountPath: /run/sec/certs/mbkfserver
{{- end }}
{{- end }}
{{ if .Values.volumeMounts -}}
{{ .Values.volumeMounts -}}
{{ end -}}
{{ end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "eric-ctrl-bro.serviceAccountName" -}}
{{ include "eric-ctrl-bro.name" . }}-cm-key
{{- end -}}

{{/*
If the timezone isn't set by a global parameter, set it to UTC
*/}}
{{- define "eric-ctrl-bro.timezone" -}}
{{- if .Values.global -}}
    {{- .Values.global.timezone | default "UTC" -}}
{{- else -}}
    UTC
{{- end -}}
{{- end -}}

{{/*
Define TLS, note: returns boolean as string
*/}}
{{- define "eric-ctrl-bro.global.tls" -}}
{{- $cmmtls := true -}}
{{- if .Values.global -}}
    {{- if .Values.global.security -}}
        {{- if .Values.global.security.tls -}}
            {{- if hasKey .Values.global.security.tls "enabled" -}}
                {{- $cmmtls = .Values.global.security.tls.enabled -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- $cmmtls -}}
{{- end -}}

{{- define "eric-ctrl-bro.pullpolicy" -}}
imagePullPolicy: {{ .Values.imageCredentials.pullPolicy | quote }}
{{- end -}}

{{- define "eric-ctrl-bro.image.path" -}}
{{- if .Values.imageCredentials.repoPath -}}
    {{- .Values.imageCredentials.repoPath }}/{{ .Values.images.backupAndRestore.name }}:{{ .Values.images.backupAndRestore.tag }}
{{- end -}}
{{- end -}}

{{- define "eric-ctrl-bro.pullsecret" -}}
{{- if .Values.imageCredentials.pullSecret }}
      imagePullSecrets:
        - name: {{ .Values.imageCredentials.pullSecret | quote}}
{{- else if .Values.global -}}
    {{- if .Values.global.pullSecret }}
      imagePullSecrets:
        - name: {{ .Values.global.pullSecret | quote }}
    {{- end -}}
{{- end }}
{{- end -}}

{{- define "eric-ctrl-bro.image" -}}
{{- if .Values.imageCredentials.registry.url -}}
    "{{.Values.imageCredentials.registry.url }}/{{- include "eric-ctrl-bro.image.path" . }}"
{{- else if .Values.global -}}
    {{- if .Values.global.registry -}}
        {{- if .Values.global.registry.url -}}
            "{{ .Values.global.registry.url }}/{{- include "eric-ctrl-bro.image.path" . }}"
        {{- else -}}
             "armdocker.rnd.ericsson.se/{{- include "eric-ctrl-bro.image.path" . }}"
        {{- end -}}
    {{- else -}}
        "armdocker.rnd.ericsson.se/{{- include "eric-ctrl-bro.image.path" . }}"
    {{- end -}}
{{- else -}}
    "armdocker.rnd.ericsson.se/{{- include "eric-ctrl-bro.image.path" . }}"
{{- end -}}
{{- end -}}

{{/*
Return the GRPC port set via global parameter if it's set, otherwise 3000
*/}}
{{- define "eric-ctrl-bro.globalBroGrpcServicePort"}}
{{- if .Values.global -}}
    {{- if .Values.global.adpBR -}}
        {{- .Values.global.adpBR.broGrpcServicePort | default 3000 -}}
    {{- else -}}
        3000
    {{- end -}}
{{- else -}}
    3000
{{- end -}}
{{- end -}}

{{/*
Return the brLabelKey set via global parameter if it's set, otherwise adpbrlabelkey
*/}}
{{- define "eric-ctrl-bro.globalBrLabelKey"}}
{{- if .Values.global -}}
    {{- if .Values.global.adpBR -}}
        {{- .Values.global.adpBR.brLabelKey | default "adpbrlabelkey" -}}
    {{- else -}}
        adpbrlabelkey
    {{- end -}}
{{- else -}}
    adpbrlabelkey
{{- end -}}
{{- end -}}

{{/*
Create a merged set of nodeSelectors from global and service level.
*/}}
{{- define "eric-ctrl-bro.nodeSelector" -}}
{{- $globalNodeSelector := dict -}}
{{- if .Values.global -}}
    {{- if .Values.global.nodeSelector -}}
        {{- $globalNodeSelector = .Values.global.nodeSelector -}}
    {{- end -}}
{{- end -}}
{{- if .Values.nodeSelector -}}
    {{- range $key, $localValue := .Values.nodeSelector -}}
      {{- if hasKey $globalNodeSelector $key -}}
          {{- $globalValue := index $globalNodeSelector $key -}}
          {{- if ne $globalValue $localValue -}}
            {{- printf "nodeSelector \"%s\" is specified on both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $key $key $globalValue $key $localValue | fail -}}
          {{- end -}}
      {{- end -}}
    {{- end -}}
    nodeSelector: {{- toYaml (merge $globalNodeSelector .Values.nodeSelector) | trim | nindent 2 -}}
{{- else -}}
    {{- if not ( empty $globalNodeSelector ) -}}
    nodeSelector: {{- toYaml $globalNodeSelector | trim | nindent 2 -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the fsgroup set via global parameter if it's set, otherwise 10000
*/}}
{{- define "eric-ctrl-bro.fsGroup.coordinated" -}}
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

{{/*
Issuer for LT client cert
*/}}
{{- define "eric-ctrl-bro.certificate-authorities.eric-log-transformer" -}}
{{- if .Values.service.endpoints.lt -}}
  {{- if .Values.service.endpoints.lt.tls -}}
    {{- if .Values.service.endpoints.lt.tls.issuer -}}
      {{- .Values.service.endpoints.lt.tls.issuer -}}
    {{- else -}}
      eric-log-transformer
    {{- end -}}
  {{- else -}}
    eric-log-transformer
  {{- end -}}
{{- else -}}
  eric-log-transformer
{{- end -}}
{{- end -}}

{{/*
Issuer for MBKF client cert
*/}}
{{- define "eric-ctrl-bro.certificate-authorities.message-bug-kf" -}}
{{- if .Values.kafka -}}
  {{- if .Values.kafka.hostname -}}
    {{ .Values.kafka.hostname }}
  {{- else -}}
    eric-data-message-bus-kf
  {{- end -}}
{{- else -}}
  eric-data-message-bus-kf
{{- end -}}
{{- end -}}

{{/*
TCP log streaming buffer size, measured in bytes
*/}}
{{- define "eric-ctrl-bro.log-streaming.buffer" -}}
{{- if .Values.bro.logBuffer -}}
  {{ .Values.bro.logBuffer }}
{{- else -}}
  8192
{{- end -}}
{{- end -}}

{{/*
TCP log streaming connection timeout, in millis
*/}}
{{- define "eric-ctrl-bro.log-streaming.timeout" -}}
{{- if .Values.bro.logTimeout -}}
  {{ .Values.bro.logTimeout }}
{{- else -}}
  1000
{{- end -}}
{{- end -}}

{{/*
Service logging level. Preference order is log.level, bro.logging.level, default of "info"
log.level left purposefully unset in default values.yaml to avoid NBC
*/}}
{{- define "eric-ctrl-bro.log.level" -}}
{{- if .Values.log.level -}}
  {{ .Values.log.level }}
{{- else -}}
  {{- if .Values.bro.logging.level -}}
    {{ .Values.bro.logging.level }}
  {{- else -}}
    info
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Service logging root level. Preference order is log.rootLevel, bro.logging.rootLevel, default of "info"
log.rootLevel left purposefully unset in default values.yaml to avoid NBC
*/}}
{{- define "eric-ctrl-bro.log.rootLevel" -}}
{{- if .Values.log.rootLevel -}}
  {{ .Values.log.rootLevel }}
{{- else -}}
  {{- if .Values.bro.logging.rootLevel -}}
    {{ .Values.bro.logging.rootLevel }}
  {{- else -}}
    info
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Service logging log4j2 level. Preference order is log.log4j2Level, bro.logging.log4j2Level, default of "info"
log.log4j2Level left purposefully unset in default values.yaml to avoid NBC
*/}}
{{- define "eric-ctrl-bro.log.log4j2Level" -}}
{{- if .Values.log.log4j2Level -}}
  {{ .Values.log.log4j2Level }}
{{- else -}}
  {{- if .Values.bro.logging.log4j2Level -}}
    {{ .Values.bro.logging.log4j2Level }}
  {{- else -}}
    info
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "eric-ctrl-bro.tmpdir" -}}
{{- if .Values.tmpdir -}}
    {{ .Values.tmpdir }}
{{- else -}}
    /bro/tmp
{{- end -}}
{{- end -}}

{{/*
Defines time in milliseconds before channel timeout for SFTP client.
*/}}
{{- define "eric-ctrl-bro.sftpTimeout" -}}
{{- if .Values.sftpTimeout -}}
    {{ .Values.sftpTimeout }}
{{- else -}}
    5000
{{- end -}}
{{- end -}}

{{/*
Create a merged set of parameters for log streaming from global and service level.
Expectation is that the user calls fromYaml on the other side, e.g.
  {{ $data := include "eric-ctrl-bro.logstreaming" . | fromYaml }}
  port={{ $data.logtransformer.port | quote }}
*/}}
{{ define "eric-ctrl-bro.logstreaming" }}
  {{- $globalValues := dict }}
  {{- $globalValues = merge $globalValues (dict "logOutput" (list)) -}}
  {{- $globalValues = merge $globalValues (dict "logtransformer" (dict "host" "eric-log-transformer")) -}}
  {{- $globalValues = merge $globalValues (dict "logtransformer" (dict "port" "5015")) -}}


{{/*
The ordering here is relevant, as we want local settings for host to be overridden by global host settings. The outputs
streams are merged in such a way that the order in which the merge occurs is irrelevant
*/}}
  {{- if .Values.log -}}
    {{- if .Values.log.outputs -}}
      {{- $globalValues = mergeOverwrite $globalValues (dict "logOutput" (uniq (concat .Values.log.outputs (get $globalValues "logOutput")))) -}}
    {{- end -}}
  {{- end -}}
  {{- if .Values.logtransformer -}}
    {{- $globalValues = mergeOverwrite $globalValues (dict "logtransformer" (dict "host" .Values.logtransformer.host)) -}}
  {{- end -}}

  {{- if .Values.global -}}
    {{- if .Values.global.logOutput }}
      {{- $globalValues = mergeOverwrite $globalValues (dict "logOutput" (uniq (concat .Values.global.logOutput (get $globalValues "logOutput")))) -}}
     {{- end }}
    {{- if .Values.global.logtransformer }}
      {{- $globalValues = mergeOverwrite $globalValues (dict "logtransformer" (dict "host" .Values.global.logtransformer.host)) -}}
    {{- end }}
  {{- end -}}

  {{- if (eq (include "eric-ctrl-bro.globalSecurity" .) "true") -}}
    {{- $globalValues = mergeOverwrite $globalValues (dict "logtransformer" (dict "port" .Values.logtransformer.tlsPort)) -}}
  {{- else -}}
   {{- $globalValues = mergeOverwrite $globalValues (dict "logtransformer" (dict "port" .Values.logtransformer.port)) -}}
  {{- end -}}
  {{ toJson $globalValues -}}
{{ end }}

{{/*
Define the security-policy reference
{{- define "eric-ctrl-bro.securityPolicy.reference" -}}
{{- $policyreference := index .Values "global" "security" "policyReferenceMap" "default-restricted-security-policy" -}}
{{- end -}}
*/}}

{{/*
Define the security-policy annotations
{{- define "eric-ctrl-bro.securityPolicy.annotations" -}}
ericsson.com/security-policy.name: "restricted/default"
ericsson.com/security-policy.privileged: "false"
ericsson.com/security-policy.capabilities: "N/A"
{{- end -}}
*/}}
