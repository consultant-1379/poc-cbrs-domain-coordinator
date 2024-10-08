{{- define "eric-data-search-engine.service-transport-ingest" -}}
kind: Service
apiVersion: v1
metadata:
  {{- if eq .context "tls" }}
  name: {{ include "eric-data-search-engine.fullname" .root }}-transport-ingest-tls
  {{- else }}
  name: {{ include "eric-data-search-engine.fullname" .root }}-transport-ingest
  {{- end -}}
  {{- include "eric-data-search-engine.helm-labels" .root | indent 2 }}
  annotations:
  {{- include "eric-data-search-engine.annotations" .root | indent 4 }}
spec:
  publishNotReadyAddresses: true
  selector:
    app: {{ include "eric-data-search-engine.fullname" .root | quote }}
    component: eric-data-search-engine
    {{- if eq .context "tls" }}
    role: ingest-tls
    {{- else }}
    role: ingest
    {{- end }}
  clusterIP: None
  type: ClusterIP
  ports:
  - name: transport
    port: {{ .root.Values.master.tcpPort }}
    protocol: TCP
{{ end }}
