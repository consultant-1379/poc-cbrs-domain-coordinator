{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eric-data-document-database-pg.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/* If .CapabilitiesKubeVersion.GitVersion is smaller then 1.4.0, what should we do is TBD */}}
{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "eric-data-document-database-pg.networkPolicy.apiVersion" -}}
{{- if and (semverCompare ">=1.4.0" .Capabilities.KubeVersion.GitVersion) (semverCompare "<1.7.0" .Capabilities.KubeVersion.GitVersion) -}}
"extensions/v1beta1"
{{- else if (semverCompare ">=1.7.0" .Capabilities.KubeVersion.GitVersion) -}}
"networking.k8s.io/v1"
{{- end -}}
{{- end -}}


{{ define "eric-data-document-database-pg.global" }}
  {{- $globalDefaults := dict "registry" (dict "url" "armdocker.rnd.ericsson.se") -}}
  {{- $globalDefaults := merge $globalDefaults (dict "pullSecret") -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "imagePullPolicy")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "adpBR" (dict "broServiceName" "eric-ctrl-bro")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "adpBR" (dict "broGrpcServicePort" "3000")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "adpBR" (dict "brLabelKey" "adpbrlabelkey")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "timezone" "UTC") -}}
  {{ if .Values.global }}
    {{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
  {{ else }}
    {{- $globalDefaults | toJson -}}
  {{ end }}
{{ end }}

{{- define "eric-data-document-database-pg.logRedirect" -}}
  {{- if and (has "stream" .Values.log.outputs) (has "stdout" .Values.log.outputs) }}
    {{- "all " -}}
  {{- else if has "stream" .Values.log.outputs }}
    {{- "file " -}}
  {{- else }}
    {{- "stdout " -}}
  {{- end }}
{{- end -}}

{{- define "eric-data-document-database-pg.stdRedirectCMD" -}}
{{ "/usr/local/bin/pipe_fifo.sh "  }}
{{- end -}}


{{/*
Return the mountpath using in the container's volume.
*/}}
{{- define "eric-data-document-database-pg.mountPath" -}}
{{- "/var/lib/postgresql/data" -}}
{{- end -}}

{{/*
Return the mountpath for postgres config dir.
*/}}
{{- define "eric-data-document-database-pg.configPath" -}}
{{- "/var/lib/postgresql/config" -}}
{{- end -}}

{{/*
Return the mountpath for postgres script dir.
*/}}
{{- define "eric-data-document-database-pg.scriptPath" -}}
{{- "/var/lib/postgresql/scripts" -}}
{{- end -}}

{{/*
Return the mountpath for hook script dir.
*/}}
{{- define "eric-data-document-database-pg.hook.scriptPath" -}}
{{- "/var/lib/scripts" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-data-document-database-pg.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image registry url
*/}}
{{- define "eric-data-document-database-pg.registryUrl" -}}
{{- $g := fromJson (include "eric-data-document-database-pg.global" .) -}}
{{- if .Values.imageCredentials.registry.url -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- else -}}
{{- print $g.registry.url -}}
{{- end -}}
{{- end -}}

{{/*
Create image repoPath
*/}}
{{- define "eric-data-document-database-pg.repoPath" -}}
{{- if .Values.imageCredentials.repoPath -}}
{{- print "/" .Values.imageCredentials.repoPath "/" -}}
{{- else -}}
{{- print "/" -}}
{{- end -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-data-document-database-pg.pullSecrets" -}}
{{- $g := fromJson (include "eric-data-document-database-pg.global" .) -}}
{{- if .Values.imageCredentials.pullSecret -}}
{{- print .Values.imageCredentials.pullSecret -}}
{{- else -}}
{{- print $g.pullSecret -}}
{{- end -}}
{{- end -}}

{{/*
Create image pull policy
*/}}
{{- define "eric-data-document-database-pg.imagePullPolicy" -}}
{{- $g := fromJson (include "eric-data-document-database-pg.global" .) -}}
{{- if .Values.imageCredentials.registry.imagePullPolicy -}}
{{- print .Values.imageCredentials.registry.imagePullPolicy -}}
{{- else if $g.registry.imagePullPolicy -}}
{{- print $g.registry.imagePullPolicy -}}
{{- else -}}
{{- print "IfNotPresent" -}}
{{- end -}}
{{- end -}}

{{/*
Transit pvc mount path
*/}}
{{- define "eric-data-document-database-pg.transit.mountpath" -}}
{{- "/shipment_data" -}}
{{- end -}}

{{/*
Expand the component of transit pvc.
*/}}
{{- define "eric-data-document-database-pg.transit.component" -}}
{{- "eric-data-document-database-pg-transit" -}}
{{- end -}}

{{/*
Define the default storage class name.
*/}}
{{- define "eric-data-document-database-pg.persistentVolumeClaim.defaultStorageClassName" -}}
{{- if .Values.persistentVolumeClaim.storageClassName}}
{{- print .Values.persistentVolumeClaim.storageClassName -}}
{{- else }}
{{- "" -}}
{{- end }}
{{- end -}}

{{/*
Define the default backup storage class name.
*/}}
{{- define "eric-data-document-database-pg.backup.defaultStorageClassName" -}}
{{- if .Values.persistence.backup.storageClassName }}
{{- if (eq "-" .Values.persistence.backup.storageClassName) }}
{{- "" -}}
{{- else }}
{{- print .Values.persistence.backup.storageClassName -}}
{{- end }}
{{- else }}
{{- "erikube-rbd" -}}
{{- end }}
{{- end -}}

{{/*
Define the persistentVolumeClaim size
*/}}
{{- define "eric-data-document-database-pg.persistentVolumeClaim.size" -}}
{{- if .Values.persistentVolumeClaim.size}}
{{- print .Values.persistentVolumeClaim.size }}
{{- end }}
{{- end -}}

{{/*
Create Ericsson product specific annotations
*/}}
{{- define "eric-data-document-database-pg.helm-annotations_product_name" -}}
{{- print "\"Document Database PG\"" }}
{{- end -}}
{{- define "eric-data-document-database-pg.helm-annotations_product_number" -}}
{{- print "\"CXC 201 1475\"" }}
{{- end -}}
{{- define "eric-data-document-database-pg.helm-annotations_product_revision" -}}
{{- $ddbMajorVersion := mustRegexFind "^([0-9]+)\\.([0-9]+)\\.([0-9]+)((-|\\+)EP[0-9]+)*((-|\\+)[0-9]+)*" .Chart.Version -}}
{{- print $ddbMajorVersion | quote }}
{{- end -}}

{{/*
Create Ericsson product app.kubernetes.io info
*/}}
{{- define "eric-data-document-database-pg_app_kubernetes_io_info" -}}
app.kubernetes.io/name: {{ .Chart.Name | quote }}
app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{/*
Define the secret that sip-tls produced
*/}}
{{- define "eric-data-document-database-pg.secretBaseName" -}}
{{- if .Values.nameOverride }}
{{- printf "%s" .Values.nameOverride -}}
{{- else }}
{{- printf "%s" .Chart.Name -}}
{{- end }}
{{- end -}}
{{/*
Define the mount path of brm-config 
*/}}
{{- define "eric-data-document-database-pg.br-configmap-path" -}}
{{- if .Values.brAgent.brmConfigmapPath -}}
{{- print .Values.brAgent.brmConfigmapPath -}}
{{- else }}
{{- print "/opt/brm_backup" -}}
{{- end }}
{{- end -}}

{{/*
check global.security.tls.enabled since it is removed from values.yaml 
*/}}
{{- define "eric-data-document-database-pg.global-security-tls-enabled" -}}
{{- if  .Values.global -}}
  {{- if  .Values.global.security -}}
    {{- if  .Values.global.security.tls -}}
       {{- .Values.global.security.tls.enabled | toString -}}
    {{- else -}}
       {{- "true" -}}
    {{- end -}}
  {{- else -}}
       {{- "true" -}}
  {{- end -}}
{{- else -}}
{{- "true" -}}
{{- end -}}
{{- end -}}

{{/*
check if postgresConfig.huge_pages is configured for ADPPRG-32783
*/}}
{{- define "eric-data-document-database-pg.hugepage-configured" -}}
{{- if  .Values.postgresConfig -}}
  {{- if  .Values.postgresConfig.huge_pages -}}
       {{- "true" -}}
  {{- else -}}
       {{- "false" -}}
  {{- end -}}
{{- else -}}
{{- "false" -}}
{{- end -}}
{{- end -}}

{{/*
Define affinity property in ddb
*/}}
{{- define "eric-data-document-database-pg.affinity" -}}
{{- if eq .Values.affinity.podAntiAffinity "hard" -}}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - {{ template "eric-data-document-database-pg.name" . }}
    topologyKey: "kubernetes.io/hostname"
{{- else if eq .Values.affinity.podAntiAffinity "soft" -}}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ template "eric-data-document-database-pg.name" . }}
      topologyKey: "kubernetes.io/hostname"
{{- end -}}
{{- end -}}

{{/*
To support Dual stack.
*/}}
{{- define "eric-data-document-database-pg.internalIPFamily" -}}
{{- if  .Values.global -}}
  {{- if  .Values.global.internalIPFamily -}}
    {{- .Values.global.internalIPFamily | toString -}}
  {{- else -}}
    {{- "none" -}}
  {{- end -}}
{{- else -}}
{{- "none" -}}

{{- end -}}
{{- end -}}

{{- define "eric-data-document-database-pg.global.nodeSelector" -}}
  {{- $globalNodeSelector := dict -}}
  {{- if .Values.global -}}
    {{- if not (empty .Values.global.nodeSelector) -}}
      {{- mergeOverwrite $globalNodeSelector .Values.global.nodeSelector | toJson -}}
    {{- else -}}
      {{- $globalNodeSelector | toJson -}}
    {{- end -}}
  {{- else -}}
    {{- $globalNodeSelector | toJson -}}
  {{- end -}}
{{- end -}}

{{- define "eric-data-document-database-pg.nodeSelector.postgres" -}}
  {{- $g := fromJson (include "eric-data-document-database-pg.global.nodeSelector" .) -}}
  {{- if not (empty .Values.nodeSelector.postgres) -}}
    {{- range $localkey, $localValue := .Values.nodeSelector.postgres -}}
      {{- if hasKey $g $localkey -}}
        {{- $globalValue := index $g $localkey -}}
        {{- if ne $localValue $globalValue -}}
          {{- printf "nodeSelector \"%s\" is specified in both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $localkey $localkey $globalValue $localkey $localValue  | fail -}}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- toYaml (merge $g .Values.nodeSelector.postgres) | trim -}}
  {{- else -}}
    {{- toYaml $g | trim -}}
  {{- end -}}
{{- end -}}

{{- define "eric-data-document-database-pg.nodeSelector.brAgent" -}}
  {{- $g := fromJson (include "eric-data-document-database-pg.global.nodeSelector" .) -}}
  {{- if not (empty .Values.nodeSelector.brAgent) -}}
    {{- range $localkey, $localValue := .Values.nodeSelector.brAgent -}}
      {{- if hasKey $g $localkey -}}
        {{- $globalValue := index $g $localkey -}}
        {{- if ne $localValue $globalValue -}}
          {{- printf "nodeSelector \"%s\" is specified in both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $localkey $localkey $globalValue $localkey $localValue  | fail -}}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- toYaml (merge $g .Values.nodeSelector.brAgent) | trim -}}
  {{- else -}}
    {{- toYaml $g | trim -}}
  {{- end -}}
{{- end -}}

{{- define "eric-data-document-database-pg.nodeSelector.cleanuphook" -}}
  {{- $g := fromJson (include "eric-data-document-database-pg.global.nodeSelector" .) -}}
  {{- if not (empty .Values.nodeSelector.cleanuphook) -}}
    {{- range $localkey, $localValue := .Values.nodeSelector.cleanuphook -}}
      {{- if hasKey $g $localkey -}}
        {{- $globalValue := index $g $localkey -}}
        {{- if ne $localValue $globalValue -}}
          {{- printf "nodeSelector \"%s\" is specified in both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $localkey $localkey $globalValue $localkey $localValue  | fail -}}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- toYaml (merge $g .Values.nodeSelector.cleanuphook) | trim -}}
  {{- else -}}
    {{- toYaml $g | trim -}}
  {{- end -}}
{{- end -}}

{{- define "eric-data-document-database-pg.tolerations.withoutHandleTS" -}}
{{- if .Values.tolerations.postgres -}}
  {{- if ne (len .Values.tolerations.postgres) 0 -}}
    {{- toYaml .Values.tolerations.postgres -}}
  {{- end -}}
{{- end -}}
{{- end -}}



{{- define "eric-data-document-database-pg.tolerations.HandleTS.brAgent" -}}
{{- if .Values.tolerations.brAgent -}}
  {{- if ne (len .Values.tolerations.brAgent) 0 -}}
    {{- $tolerations := .Values.tolerations.brAgent -}}
    {{- $newTlDict := dict -}}
    {{- range $index, $tlDict := $tolerations -}}
      {{- $tlKey := get $tlDict "key" -}}
      {{- $tlEffect := get $tlDict "effect" -}}
      {{- if and (eq $tlKey "node.kubernetes.io/not-ready") (eq $tlEffect "NoExecute") -}}
        {{- $tolerations = without $tolerations $tlDict -}}
      {{- else if and (eq $tlKey "node.kubernetes.io/unreachable") (eq $tlEffect "NoExecute") -}}
        {{- $tolerations = without $tolerations $tlDict -}}
      {{- end -}}
    {{- end -}}
    {{- if ne (len $tolerations ) 0 -}}
      {{- toYaml $tolerations -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}


{{- define "eric-data-document-database-pg.tolerations.HandleTS.cleanuphook" -}}
{{- if .Values.tolerations.cleanuphook -}}
  {{- if ne (len .Values.tolerations.cleanuphook) 0 -}}
    {{- $tolerations := .Values.tolerations.cleanuphook -}}
    {{- $newTlDict := dict -}}
    {{- range $index, $tlDict := $tolerations -}}
      {{- $tlKey := get $tlDict "key" -}}
      {{- $tlEffect := get $tlDict "effect" -}}
      {{- if and (eq $tlKey "node.kubernetes.io/not-ready") (eq $tlEffect "NoExecute") -}}
        {{- $tolerations = without $tolerations $tlDict -}}
      {{- else if and (eq $tlKey "node.kubernetes.io/unreachable") (eq $tlEffect "NoExecute") -}}
        {{- $tolerations = without $tolerations $tlDict -}}
      {{- end -}}
    {{- end -}}
    {{- if ne (len $tolerations ) 0 -}}
      {{- toYaml $tolerations -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "eric-data-document-database-pg.fsGroup.coordinated" -}}
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

{{- define "eric-data-document-database-pg.securityPolicy.reference" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.security -}}
      {{- if .Values.global.security.policyReferenceMap -}}
        {{ $mapped := index .Values "global" "security" "policyReferenceMap" "default-restricted-security-policy" }}
        {{- if $mapped -}}
          {{ $mapped }}
        {{- else -}}
          default-restricted-security-policy
        {{- end -}}
      {{- else -}}
        default-restricted-security-policy
      {{- end -}}
    {{- else -}}
      default-restricted-security-policy
    {{- end -}}
  {{- else -}}
    default-restricted-security-policy
  {{- end -}}
{{- end -}}
 
{{- define "eric-data-document-database-pg.HugePage.Volumes" }}
  {{- if and (index .Values "resources" "postgres" "limits" "hugepages-2Mi") (index .Values "resources" "postgres" "limits" "hugepages-1Gi") }}
    {{- if semverCompare "<1.19.0" .Capabilities.KubeVersion.GitVersion }}
      {{- fail "Multisize hugepage is only supported on Kuberentes 1.19 and later" }}
    {{- else }}
- name: hugepage-2mi
  emptyDir:
    medium: HugePages-2Mi
- name: hugepage-1gi
  emptyDir:
    medium: HugePages-1Gi
    {{- end }}
  {{- else if or (index .Values "resources" "postgres" "limits" "hugepages-2Mi") (index .Values "resources" "postgres" "limits" "hugepages-1Gi") }}
- name: hugepage
  emptyDir:
    medium: HugePages
  {{- end }}
{{- end }}


{{ define "eric-data-document-database-pg.HugePage.VolumeMounts" }}
  {{- if and (index .Values "resources" "postgres" "limits" "hugepages-2Mi") (index .Values "resources" "postgres" "limits" "hugepages-1Gi") }}
    {{- if semverCompare "<1.19.0" .Capabilities.KubeVersion.GitVersion }}
      {{- fail "Multisize hugepage is only supported on Kuberentes 1.19 and later" }}
    {{- else }}
- mountPath: /hugepages-2Mi
  name: hugepage-2mi
- mountPath: /hugepages-1Gi
  name: hugepage-1gi
    {{- end }}
  {{- else if or (index .Values "resources" "postgres" "limits" "hugepages-2Mi") (index .Values "resources" "postgres" "limits" "hugepages-1Gi") }}
- mountPath: /hugepages
  name: hugepage
  {{- end }}
{{- end }}