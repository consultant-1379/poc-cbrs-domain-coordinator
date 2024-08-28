{{- define "eric-data-search-engine.ingest-pod" -}}
{{- $g := fromJson (include "eric-data-search-engine.global" .root ) -}}
kind: Deployment
apiVersion: apps/v1
metadata:
  {{- if eq .context "tls" }}
  name: {{ include "eric-data-search-engine.fullname" .root }}-ingest-tls
  {{- else }}
  name: {{ include "eric-data-search-engine.fullname" .root }}-ingest
  {{- end -}}
  {{- include "eric-data-search-engine.helm-labels" .root | indent 2 }}
  annotations:
  {{- include "eric-data-search-engine.annotations" .root | indent 4 }}
spec:
  replicas: {{ .root.Values.replicaCount.ingest }}
  strategy:
    type: {{ .root.Values.updateStrategy.ingest.type | quote }}
    {{- if eq .root.Values.updateStrategy.ingest.type "RollingUpdate" }}
    rollingUpdate:
      maxUnavailable: {{ .root.Values.updateStrategy.ingest.rollingUpdate.maxUnavailable }}
      maxSurge: {{ .root.Values.updateStrategy.ingest.rollingUpdate.maxSurge }}
    {{- end }}
  selector:
    matchLabels:
      app: {{ include "eric-data-search-engine.fullname" .root | quote }}
      {{- if eq .context "tls" }}
      role: ingest-tls
      {{- else }}
      role: ingest
      {{- end }}
  template:
    metadata:
      {{- if eq .context "tls" }}
      name: {{ include "eric-data-search-engine.fullname" .root }}-ingest-tls
      {{- else }}
      name: {{ include "eric-data-search-engine.fullname" .root }}-ingest
      {{- end }}
      labels:
        {{- include "eric-data-search-engine.labels" .root | indent 8 }}
        release: "{{ .root.Release.Name }}"
        app: {{ include "eric-data-search-engine.fullname" .root | quote }}
        component: "eric-data-search-engine"
        {{- if eq .context "tls" }}
        role: ingest-tls
        {{- else }}
        role: ingest
        {{- end }}
      annotations:
        {{- include "eric-data-search-engine.annotations" .root | indent 8 }}
        checksum/config: {{ include (print .root.Template.BasePath "/es-configmap.yaml") .root | sha256sum }}
        {{- if and (.root.Values.metrics.enabled) (not $g.security.tls.enabled) }}
          {{- include "eric-data-search-engine.metrics-annotations" .root | indent 8 }}
        {{- end }}
    spec:
      serviceAccount: ""
      serviceAccountName: {{ include "eric-data-search-engine.fullname" .root }}-sa
    {{- if eq .context "tls" }}
      {{- include "eric-data-search-engine.pod-anti-affinity" (dict "context" "ingest-tls" "root" .root) | indent 6 }}
    {{- else }}
      {{- include "eric-data-search-engine.pod-anti-affinity" (dict "context" "ingest" "root" .root) | indent 6 }}
    {{- end }}
{{- include "eric-data-search-engine.pullSecrets" .root | indent 6 }}
      initContainers:
      {{- if .root.Values.autoSetRequiredWorkerNodeSysctl }}
        {{- include "eric-data-search-engine.deployment-init-containers" .root | nindent 6 }}
      {{- end }}
      containers:
      - name: "searchengine"
        readinessProbe:
          exec:
            command:
              - /readiness-probe.sh
          initialDelaySeconds: {{ .root.Values.readinessProbe.ingest.initialDelaySeconds }}
          periodSeconds: {{ .root.Values.readinessProbe.ingest.periodSeconds }}
          timeoutSeconds: {{ .root.Values.readinessProbe.ingest.timeoutSeconds }}
          successThreshold: {{ .root.Values.readinessProbe.ingest.successThreshold }}
          failureThreshold: {{ .root.Values.readinessProbe.ingest.failureThreshold }}
        livenessProbe:
          exec:
            command:
              - /liveness-probe.sh
          initialDelaySeconds: {{ .root.Values.livenessProbe.ingest.initialDelaySeconds }}
          periodSeconds: {{ .root.Values.livenessProbe.ingest.periodSeconds }}
          timeoutSeconds: {{ .root.Values.livenessProbe.ingest.timeoutSeconds }}
          successThreshold: {{ .root.Values.livenessProbe.ingest.successThreshold }}
          failureThreshold: {{ .root.Values.livenessProbe.ingest.failureThreshold }}
        resources:
          limits:
            cpu: {{ .root.Values.resources.ingest.limits.cpu | quote }}
            memory: {{ .root.Values.resources.ingest.limits.memory | quote }}
          requests:
            cpu: {{ .root.Values.resources.ingest.requests.cpu | quote }}
            memory: {{ .root.Values.resources.ingest.requests.memory | quote }}
      {{- if eq .context "tls" }}
        {{- include "eric-data-search-engine.deployment-containers" (dict "context" (dict "pod" "ingest" "tls" true) "root" .root) | indent 8 }}
      {{- else }}
        {{- include "eric-data-search-engine.deployment-containers" (dict "context" (dict "pod" "ingest" "tls" false) "root" .root) | indent 8 }}
      {{- end }}
        env:
        {{- include "eric-data-search-engine.deployment-env" . | indent 8 }}
        - name: ES_ENV_NI
          value: node.ingest=true
        - name: ES_ENV_NM
          value: node.master=false
        - name: ES_ENV_ND
          value: node.data=false
        - name: ES_JAVA_OPTS
          value: "-Xms{{ .root.Values.jvmHeap.ingest }} -Xmx{{ .root.Values.jvmHeap.ingest }}"
        ports:
        - containerPort: {{ .root.Values.ingest.httpPort }}
          name: http
          protocol: TCP
        - containerPort: {{ .root.Values.master.tcpPort }}
          name: transport
          protocol: TCP
      {{- if .root.Values.metrics.enabled }}
        {{- include "eric-data-search-engine.metrics-container" . | indent 6 }}
      {{- if $g.security.tls.enabled }}
        {{- include "eric-data-search-engine.tlsproxy-container" . | indent 6 }}
      {{- end }}
      {{- if has "stream" .root.Values.log.outputs }}
        {{- include "eric-data-search-engine.logshipper-container" .root | indent 6 }}
      {{- end }}
      {{- end }}
    {{- if (or .root.Values.nodeSelector.ingest $g.nodeSelector) }}
      nodeSelector: {{- include "eric-data-search-engine.nodeSelector" (dict "context" "ingest" "root" .root) | nindent 8 }}
    {{- end }}
      {{- if eq .context "tls" }}
        {{- include "eric-data-search-engine.deployment-volume-empty" (dict "context" (dict "pod" "ingest" "tls" true) "root" .root) | nindent 6 }}
      {{- else }}
        {{- include "eric-data-search-engine.deployment-volume-empty" (dict "context" (dict "pod" "ingest" "tls" false) "root" .root) | nindent 6 }}
      {{- end }}
      {{- if has "stream" .root.Values.log.outputs }}
        {{- include "eric-data-search-engine.logshipper-volume" .root | indent 8 }}
      {{- end }}
{{ end }}
