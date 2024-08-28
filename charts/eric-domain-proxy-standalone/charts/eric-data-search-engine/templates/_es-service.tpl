{{- define "eric-data-search-engine.es-service" -}}
{{- $g := fromJson (include "eric-data-search-engine.global" .root ) }}
kind: Service
apiVersion: v1
metadata:
  {{- if eq .context "tls" }}
  name: {{ include "eric-data-search-engine.fullname" .root }}-tls
  {{- else }}
  name: {{ include "eric-data-search-engine.fullname" .root }}
  {{- end -}}
  {{- include "eric-data-search-engine.helm-labels" .root | indent 2 }}
  annotations:
  {{- include "eric-data-search-engine.annotations" .root | indent 4 }}
  {{- if and (.root.Values.metrics.enabled) $g.security.tls.enabled }}
    prometheus.io/scrape: {{ .root.Values.metrics.enabled | quote }}
    prometheus.io/port: "9115"
    prometheus.io/scheme: "https"
  {{- end }}
spec:
  {{- if $g.internalIPFamily }}
    {{- if semverCompare "<1.16" .root.Capabilities.KubeVersion.GitVersion }}
      {{- printf "Specifying global.internalIPFamily is only supported for deployment in Kubernetes clusters with version 1.16 or higher." | fail }}
    {{- end }}
  ipFamily: {{ $g.internalIPFamily | quote }}
  {{- end }}
  selector:
    app: {{ include "eric-data-search-engine.fullname" .root | quote }}
    component: eric-data-search-engine
    {{- if eq .context "tls" }}
    role: ingest-tls
    {{- else }}
    role: ingest
    {{- end }}
  type: ClusterIP
  ports:
  - name: http
    port: {{ .root.Values.ingest.httpPort }}
    protocol: TCP
  {{- if .root.Values.metrics.enabled }}
  {{- if $g.security.tls.enabled }}
  - name: metrics-tls
    port: 9114
    targetPort: 9115
    protocol: TCP
  {{- else }}
  - name: metrics
    port: {{ .root.Values.metrics.httpPort }}
    protocol: TCP
  {{- end }}
  {{- end }}
{{ end }}
