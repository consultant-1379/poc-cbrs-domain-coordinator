{{- define "eric-pm-server.helm-annotations" }}
  ericsson.com/product-name: "PM Server"
  ericsson.com/product-number: "CXC 201 1513"
  ericsson.com/product-revision: {{regexReplaceAll "(.*)[+].*" .Chart.Version "${1}" }}
{{- end}}
