{{- define "eric-data-search-engine.metrics-container" }}
{{- $g := fromJson (include "eric-data-search-engine.global" .root) }}
- name: metrics
  imagePullPolicy: {{ .root.Values.imageCredentials.registry.imagePullPolicy | default $g.registry.imagePullPolicy | quote }}
  {{- if .root.Values.imageCredentials.registry.url }}
  image: "{{ .root.Values.imageCredentials.registry.url }}/{{ .root.Values.imageCredentials.repoPath }}/{{ .root.Values.images.metrics.name }}:{{ .root.Values.images.metrics.tag }}"
  {{- else }}
  image: "{{ $g.registry.url }}/{{ .root.Values.imageCredentials.repoPath }}/{{ .root.Values.images.metrics.name }}:{{ .root.Values.images.metrics.tag }}"
  {{- end }}
  {{- $connection_settings := "--es.uri=http://localhost" }}
  {{- if and $g.security.tls.enabled (eq .context "tls") }}
    {{- $connection_settings = "--es.ca=/run/secrets/sip-tls-trusted-root-cert/ca.crt --es.client-private-key=/run/secrets/http-client-certificates/cliprivkey.pem --es.client-cert=/run/secrets/http-client-certificates/clicert.pem --es.uri=https://localhost" }}
  {{- end }}
  command:
    - /opt/redirect/stdout-redirect
    - -redirect
    - {{ include "eric-data-search-engine.log-redirect" .root }}
    - -run
    - elasticsearch_exporter {{ $connection_settings }}:{{ .root.Values.ingest.httpPort }} --log.level={{ .root.Values.logLevel }} --web.listen-address=:{{ .root.Values.metrics.httpPort }}
    {{- if has "stream" .root.Values.log.outputs }}
    - -logfile
    - {{ .root.Values.logshipper.storagePath }}/metrics.log
    - -size
    - "1"
    {{- end }}
  securityContext:
    allowPrivilegeEscalation: false
    privileged: false
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    capabilities:
      drop:
        - "all"
  ports:
  - name: http-metrics
    containerPort: {{ .root.Values.metrics.httpPort }}
    protocol: TCP
  env:
  - name: TZ
    value: {{ $g.timezone | quote }}
  - name: "ES_PORT"
    value: {{ .root.Values.ingest.httpPort | quote }}
  - name: "ES_TLS"
  {{- if and $g.security.tls.enabled (eq .context "tls") }}
    value: "true"
  {{- else }}
    value: "false"
  {{- end }}
  readinessProbe:
    exec:
      command:
      - /readiness-probe.sh
    initialDelaySeconds: {{ .root.Values.readinessProbe.metrics.initialDelaySeconds }}
    timeoutSeconds: {{ .root.Values.readinessProbe.metrics.timeoutSeconds }}
  livenessProbe:
    httpGet:
      path: /healthz
      port: {{ .root.Values.metrics.httpPort }}
    initialDelaySeconds: {{ .root.Values.livenessProbe.metrics.initialDelaySeconds }}
    timeoutSeconds: {{ .root.Values.livenessProbe.metrics.timeoutSeconds }}
  resources:
    limits:
      cpu: {{ .root.Values.resources.metrics.limits.cpu  | quote }}
      memory: {{ .root.Values.resources.metrics.limits.memory  | quote }}
    requests:
      cpu: {{ .root.Values.resources.metrics.requests.cpu  | quote }}
      memory: {{ .root.Values.resources.metrics.requests.memory  | quote }}
  volumeMounts:
{{- if and $g.security.tls.enabled (eq .context "tls") }}
  {{- include "eric-data-search-engine.security-tls-secret-volume-mounts-http-client" .root | indent 2 }}
{{- end }}
{{- if has "stream" .root.Values.log.outputs }}
  {{- include "eric-data-search-engine.logshipper-storage-path" .root | indent 2 }}
{{- end }}
{{- end -}}

{{- define "eric-data-search-engine.metrics-annotations" }}
prometheus.io/scrape: {{ .Values.metrics.enabled | quote }}
prometheus.io/port: {{ .Values.metrics.httpPort | quote }}
prometheus.io/path: "/metrics"
{{- end }}

{{- define "eric-data-search-engine.tlsproxy-container" }}
{{- $g := fromJson (include "eric-data-search-engine.global" .root) }}
- name: tlsproxy
  imagePullPolicy: {{ .root.Values.imageCredentials.registry.imagePullPolicy | default $g.registry.imagePullPolicy | quote }}
  {{- if .root.Values.imageCredentials.registry.url }}
  image: "{{ .root.Values.imageCredentials.registry.url }}/{{ .root.Values.imageCredentials.repoPath }}/{{ .root.Values.images.tlsproxy.name }}:{{ .root.Values.images.tlsproxy.tag }}"
  {{- else }}
  image: "{{ $g.registry.url }}/{{ .root.Values.imageCredentials.repoPath }}/{{ .root.Values.images.tlsproxy.name }}:{{ .root.Values.images.tlsproxy.tag }}"
  {{- end }}
  command:
    - /opt/redirect/stdout-redirect
    - -redirect
    - {{ include "eric-data-search-engine.log-redirect" .root }}
    - -run
    - /opt/tls_proxy/bin/tlsproxy
    {{- if has "stream" .root.Values.log.outputs }}
    - -logfile
    - {{ .root.Values.logshipper.storagePath }}/tlsproxy.log
    - -size
    - "1"
    {{- end }}
  securityContext:
    allowPrivilegeEscalation: false
    privileged: false
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    capabilities:
      drop:
        - "all"
  ports:
  - name: metrics-tls
    containerPort: 9115
    protocol: TCP
  env:
  - name: "TZ"
    value: {{ $g.timezone | quote }}
  - name: "ES_PORT"
  - name: "LOGLEVEL"
    value: {{ .root.Values.logLevel | quote }}
  - name: "TARGET"
    value: "http://localhost:{{ .root.Values.metrics.httpPort }}"
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
    initialDelaySeconds: {{ .root.Values.livenessProbe.tlsproxy.initialDelaySeconds }}
    timeoutSeconds: {{ .root.Values.livenessProbe.tlsproxy.timeoutSeconds }}
  resources:
    limits:
      cpu: {{ .root.Values.resources.tlsproxy.limits.cpu  | quote }}
      memory: {{ .root.Values.resources.tlsproxy.limits.memory  | quote }}
    requests:
      cpu: {{ .root.Values.resources.tlsproxy.requests.cpu  | quote }}
      memory: {{ .root.Values.resources.tlsproxy.requests.memory  | quote }}
  volumeMounts:
    {{- include "eric-data-search-engine.security-tls-secret-volume-mounts-metrics" .root | indent 2 }}
    {{- if has "stream" .root.Values.log.outputs }}
      {{- include "eric-data-search-engine.logshipper-storage-path" .root | indent 2 }}
    {{- end }}
{{- end }}
