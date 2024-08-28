{{- define "eric-log-transformer.metrics-container" }}
{{- $g := fromJson (include "eric-log-transformer.global" .) }}
- name: metrics
  imagePullPolicy: {{ .Values.imageCredentials.registry.imagePullPolicy | default $g.registry.imagePullPolicy | quote }}
  {{- if .Values.imageCredentials.registry.url }}
  image: "{{ .Values.imageCredentials.registry.url }}/{{ .Values.imageCredentials.repoPath }}/{{ .Values.images.metrics.name }}:{{ .Values.images.metrics.tag }}"
  {{- else }}
  image: "{{ $g.registry.url }}/{{ .Values.imageCredentials.repoPath }}/{{ .Values.images.metrics.name }}:{{ .Values.images.metrics.tag }}"
  {{- end }}
  {{- $redirect := "stdout" }}
  {{- if has "stream" .Values.log.outputs }}
    {{- $redirect = "file" }}
    {{- if has "stdout" .Values.log.outputs }}
      {{- $redirect = "all" }}
    {{- end }}
  {{- end }}
  command: ["/bin/sh"]
  args:
  - -c
  - /opt/redirect/stdout-redirect -redirect={{ $redirect }} -size=1 -logfile=/logs/metrics.log -container=metrics -service-id={{ include "eric-log-transformer.fullname" . }} -run="java -jar /opt/ls_exporter/bin/ls-metrics-exporter.jar /opt/ls_exporter/bin/application.properties"
  securityContext:
    allowPrivilegeEscalation: false
    privileged: false
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    capabilities:
      drop:
        - all
  env:
  - name: TZ
    value: {{ $g.timezone | quote }}
  - name: LOG_LEVEL
    value: {{ .Values.logLevel | quote | default "error" | lower }}
  ports:
  - name: "metrics"
    containerPort: 9114
    protocol: "TCP"
  readinessProbe:
    httpGet:
      path: /
      port: {{ .Values.service.portApi }}
    initialDelaySeconds: {{ .Values.readinessProbe.metrics.initialDelaySeconds }}
    timeoutSeconds: {{ .Values.readinessProbe.metrics.timeoutSeconds }}
    periodSeconds: {{ .Values.readinessProbe.metrics.periodSeconds }}
    successThreshold: {{ .Values.readinessProbe.metrics.successThreshold }}
    failureThreshold: {{ .Values.readinessProbe.metrics.failureThreshold }}
  livenessProbe:
    httpGet:
      path: /-/healthy
      port: 9114
    initialDelaySeconds: {{ .Values.livenessProbe.metrics.initialDelaySeconds }}
    timeoutSeconds: {{ .Values.livenessProbe.metrics.timeoutSeconds }}
    periodSeconds: {{ .Values.livenessProbe.metrics.periodSeconds }}
    successThreshold: {{ .Values.livenessProbe.metrics.successThreshold }}
    failureThreshold: {{ .Values.livenessProbe.metrics.failureThreshold }}
  resources:
    limits:
      cpu: {{ .Values.resources.metrics.limits.cpu  | quote }}
      memory: {{ .Values.resources.metrics.limits.memory  | quote }}
    requests:
      cpu: {{ .Values.resources.metrics.requests.cpu  | quote }}
      memory: {{ .Values.resources.metrics.requests.memory  | quote }}
  volumeMounts:
  - name: "metrics-exporter-cfg"
    mountPath: /opt/ls_exporter/bin/application.properties
    subPath: application.properties
    {{- if has "stream" .Values.log.outputs }}
      {{- include "eric-log-transformer.logshipper-storage-path" (mergeOverwrite . (fromJson (include "eric-log-transformer.logshipper-context" .))) | indent 2 }}
    {{- end }}
{{- end -}}

{{- define "eric-log-transformer.metrics-annotations" }}
prometheus.io/scrape: {{ .Values.metrics.enabled | quote }}
prometheus.io/port: "9114"
prometheus.io/path: "/metrics"
{{- end }}

{{- define "eric-log-transformer.tlsproxy-container" }}
{{- $g := fromJson (include "eric-log-transformer.global" .) }}
- name: tlsproxy
  imagePullPolicy: {{ .Values.imageCredentials.registry.imagePullPolicy | default $g.registry.imagePullPolicy | quote }}
  {{- if .Values.imageCredentials.registry.url }}
  image: "{{ .Values.imageCredentials.registry.url }}/{{ .Values.imageCredentials.repoPath }}/{{ .Values.images.tlsproxy.name }}:{{ .Values.images.tlsproxy.tag }}"
  {{- else }}
  image: "{{ $g.registry.url }}/{{ .Values.imageCredentials.repoPath }}/{{ .Values.images.tlsproxy.name }}:{{ .Values.images.tlsproxy.tag }}"
  {{- end }}
  {{- $redirect := "stdout" }}
  {{- if has "stream" .Values.log.outputs }}
    {{- $redirect = "file" }}
    {{- if has "stdout" .Values.log.outputs }}
      {{- $redirect = "all" }}
    {{- end }}
  {{- end }}
  command: ["/bin/sh"]
  args:
  - -c
  - /opt/redirect/stdout-redirect -redirect={{ $redirect }} -size=1 -logfile=/logs/tlsproxy.log -format=json -container=tlsproxy -service-id={{ include "eric-log-transformer.fullname" . }} -run="/opt/tls_proxy/bin/tlsproxy"
  securityContext:
    allowPrivilegeEscalation: false
    privileged: false
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    capabilities:
      drop:
        - all
  ports:
  - name: "metrics-tls"
    containerPort: 9115
    protocol: "TCP"
  env:
  - name: "TZ"
    value: {{ $g.timezone | quote }}
  - name: "LOGLEVEL"
    value: {{ .Values.logLevel | quote }}
  - name: "TARGET"
    value: "http://localhost:9114"
  - name: "PORT"
    value: "9115"
  - name: "CERT"
    value: "/run/secrets/pm-server-certificates/srvcert.pem"
  - name: "KEY"
    value: "/run/secrets/pm-server-certificates/srvprivkey.pem"
  - name: "CLIENT_CA"
    value: "/run/secrets/pm-trusted-ca/client-cacertbundle.pem"
  livenessProbe:
    exec:
      command:
      - /liveness-probe.sh
    initialDelaySeconds: {{ .Values.livenessProbe.tlsproxy.initialDelaySeconds }}
    timeoutSeconds: {{ .Values.livenessProbe.tlsproxy.timeoutSeconds }}
    periodSeconds: {{ .Values.livenessProbe.tlsproxy.periodSeconds }}
    successThreshold: {{ .Values.livenessProbe.tlsproxy.successThreshold }}
    failureThreshold: {{ .Values.livenessProbe.tlsproxy.failureThreshold }}
  resources:
    limits:
      cpu: {{ .Values.resources.tlsproxy.limits.cpu  | quote }}
      memory: {{ .Values.resources.tlsproxy.limits.memory  | quote }}
    requests:
      cpu: {{ .Values.resources.tlsproxy.requests.cpu  | quote }}
      memory: {{ .Values.resources.tlsproxy.requests.memory  | quote }}
  volumeMounts:
  - name: "pm-server-cert"
    mountPath: "/run/secrets/pm-server-certificates"
    readOnly: true
  - name: "pm-trusted-ca"
    mountPath: "/run/secrets/pm-trusted-ca"
    readOnly: true
  - name: "tlsproxy-client"
    mountPath: "/run/secrets/tlsproxy-client"
    readOnly: true
  - name: "sip-tls-trusted-root-cert"
    mountPath: "/run/secrets/sip-tls-trusted-root-cert"
    readOnly: true
    {{- if has "stream" .Values.log.outputs }}
      {{- include "eric-log-transformer.logshipper-storage-path" (mergeOverwrite . (fromJson (include "eric-log-transformer.logshipper-context" .))) | indent 2 }}
    {{- end }}
{{- end }}
