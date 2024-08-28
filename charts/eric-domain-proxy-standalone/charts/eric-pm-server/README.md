
## Configuration

The following tables lists the configurable parameters of the PM Server chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
`config.certm_tls` | TLS configuration for certm. Multiple endpoints can be configured | `[]`
`config.certm_tls.clientCertName` | Same name as used in the CLI action `keystore asymmetric-keys install-asymmetric-key-pkcs12 name <clientKeyName> certificate-name <clientCertName> ...` | `commented out`
`config.certm_tls.clientKeyName` | Same name as used in the CLI action `keystore asymmetric-keys install-asymmetric-key-pkcs12 name <clientKeyName> certificate-name <clientCertName> ...` | `commented out`
`config.certm_tls.name` | Name of the endpoint | `commented out`
`config.certm_tls.trustedCertName` | Same name as used in the CLI action `install-certificate-pem name <trustedCertName> pem ...` | `commented out`
`config.recording_rules` | Define recording rules | `{}`
`config.remote_write` | Define remote write endpoints | `{}`
`global.pullSecret` | PM Server's global registry pull secret  | `commented out`
`global.registry.pullSecret` | (deprecated) PM Server's global registry pull secret  | `commented out`
`global.registry.url`| PM Server's image global registry. |armdocker.rnd.ericsson.se
`global.timezone`| PM Server's timezone setting | `UTC`
`global.security.tls.enabled` | PM Server TLS support | `true`
`global.nodeSelector` | Node labels for PM server pod assignment. | `{}`
`imageCredentials.pullPolicy`| PM Server container images pull Policy. |IfNotPresent
`imageCredentials.pullSecret` | PM Server's registry pull secret  | `commented out`
`imageCredentials.registry.url`| Overrides global registry url. |""
`imageCredentials.repoPath`| PM Server's image path. |proj-common-assets-cd/monitoring/pm
`images.configmapReload.name`| eric-pm-configmap-reload image name. |eric-pm-configmap-reload
`images.configmapReload.tag`| eric-pm-configmap-reload container image tag. |1.1.0-buildNum
`images.pmExporter.name`| eric-pm-exporter image name. |eric-pm-exporter
`images.pmExporter.tag`| eric-pm-exporter container image tag. |1.1.0-buildNum
`images.reverseProxy.name`| eric-pm-reverseproxy image name. |eric-pm-reverseproxy
`images.reverseProxy.tag`| eric-pm-reverseproxy container image tag. |1.1.0-buildNum
`images.server.name`| PM Server image name. |eric-pm-server
`images.server.tag`| PM Server container image tag. |1.1.0-buildNum
`networkPolicy.enabled`| Enable creation of NetworkPolicy resources. | `false`
`podDisruptionBudget.minAvailable` | Minimum available pods | 0
`rbac.appMonitoring.configFileCreate`| Create Config file from ConfigMap template for Application Monitoring. | `true`
`rbac.appMonitoring.enabled`| Enables RBAC for single Application Monitoring. | `false`
`resources.configmapReload.limits.cpu`| The maximum amount of CPU allowed per instance for configmapReload. | `200m`
`resources.configmapReload.limits.memory`| The maximum amount of memory allowed per instance for configmapReload. | `32Mi`
`resources.configmapReload.limits.ephemeral-storage`| The maximum amount of ephemeral-storage allowed per instance for configmapReload. | `1Gi`
`resources.configmapReload.requests.cpu`| The requested amount of CPU per instance for configmapReload. | `100m`
`resources.configmapReload.requests.memory`| The requested amount of memory per instance for configmapReload. | `8Mi`
`resources.configmapReload.requests.ephemeral-storage`| The requested amount of ephemeral-storage per instance for configmapReload. | `8Mi`
`resources.reverseProxy.limits.cpu`| The maximum amount of CPU allowed per instance for reverseProxy. | `2`
`resources.reverseProxy.limits.memory`| The maximum amount of memory allowed per instance for reverseProxy. | `64Mi`
`resources.reverseProxy.requests.cpu`| The requested amount of CPU per instance for reverseProxy. | `100m`
`resources.reverseProxy.requests.memory`| The requested amount of memory per instance for reverseProxy. | `32Mi`
`resources.server.limits.cpu`| The maximum amount of CPU allowed per instance for the PM Service. | `2`
`resources.server.limits.memory`| The maximum amount of memory allowed per instance for the PM Service. | `2048Mi`
`resources.server.limits.ephemeral-storage`| The maximum amount of ephemeral-storage allowed per instance for the PM Service. | `8Gi`
`resources.server.requests.cpu`| The requested amount of CPU per instance for the PM Service. | `250m`
`resources.server.requests.memory`| The requested amount of memory per instance for the PM Service. | `512Mi`
`resources.server.requests.ephemeral-storage`| The requested amount of ephemeral-storage per instance for the PM Service. | `512Mi`
`server.baseURL`| The external url at which the server can be accessed. | `""`
`server.configMapOverrideName`| PM Server ConfigMap override where full-name is `{{.Values.server.configMapOverrideName}}` and setting this value will prevent the default server ConfigMap from being generated. | `""`
`server.extraArgs`| Additional PM Server container arguments. | `{}`
`server.extraHostPathMounts`| Additional PM Server hostPath mounts. | `[]`
`server.extraSecretMounts`| Additional PM Server secret mounts. | `[]`
`serverFiles.prometheus.yml` | PM Server scrape configuration. | `Kubernetes SD Endpoints`
`server.name`| PM Server container name. | `server`
`server.nodeSelector`| To be deprecated soon. Node labels for Prometheus server pod assignment. | `{}`
`server.persistentVolume.accessModes`| PM Server data Persistent Volume access modes. | `[ReadWriteOnce]`
`server.persistentVolume.annotations` | PM Server data Persistent Volume annotations. | `{}`
`server.persistentVolume.enabled`| If true, PM Server will create a Persistent Volume Claim. If set to false, with POD restarts & helm upgrades PM data will be erased/wiped off. | `false`
`server.persistentVolume.mountPath`| PM Server data Persistent Volume mount root path. | `/data`
`server.persistentVolume.size`| PM Server data Persistent Volume size. | `8Gi`
`server.persistentVolume.storageClass` | PM Server data Persistent Volume Storage Class | `commented out`
`server.persistentVolume.storageConnectivity` | The connectivity of the storage, either local or networked. | `networked`
`server.persistentVolume.subPath`| Subdirectory of PM Server data Persistent Volume to mount. | `""`
`server.podAnnotations` | Annotations to be added to PM Server pods. | `{}`
`server.prefixURL`| The prefix url at which the server can be accessed. | `""`
`server.replicaCount`| Desired number of PM Server pods. | `1`
`server.retention`| Determins how long data will be kept on the persistent volume. A time duration can be specified in different units where the most useful in in this case are (h)ours, (d)ays or (w)eeks. The prometheus default is 15d. | `""`
`server.serviceAccountName`| Service account name for server to use. | `default`
`server.service.annotations` | Annotations for PM Server service. | `{}`
`server.service.labels` | Labels for PM Server service. | `{}`
`server.terminationGracePeriodSeconds`| PM Server Pod termination grace period. | `300`
`server.tolerations`| Node taints to tolerate (requires Kubernetes >=1.6). | `[]`
`service.endpoints.scrapeTargets.tls.enforced`| This options applies to the default server ConfigMap for application monitoring. The option controls if both cleartext and TLS scrape targets or only TLS scrape targets will be considered for service discovery. Value optional will allow scraping of both cleartext and TLS targets. Value required will restrict scraping to TLS targets only. | `required`
'service.endpoints.reverseproxy.tls.enforced'| The option controls if cleartext and TLS or only TLS is allowed on the PM query interface. Value optional allows both cleartext and TLS. Value required allows only TLS. | `optional`
`service.endpoints.reverseproxy.tls.verifyClientCertificate` | It checks whether the client connection toward PM's reverseproxy using TLS requires authentication or not.  Non-authenticated connections will be logged and dropped in case this is enforced as required, otherwise the connection establishment will be granted. By default it is required, otherwise set it as optional. | `required`
`service.endpoints.reverseproxy.tls.certificateAuthorityBackwardCompatibility` | If true, SIP-TLS as CA will be used for query interface. | `false`
`nodeSelector` | Node labels for PM server pod assignment. | `{}`
`updateStrategy.server.type`| PM Server updateStrategy. | `{type: RollingUpdate}`
`securityContext`| Security Context for all containers. | `{}`

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install ./eric-pm-server --name my-release \
    --set server.terminationGracePeriodSeconds=360
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install ./eric-pm-server --name my-release -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

### ConfigMap Files
PM Server is configured through prometheus.yml. This file (and any others listed in `serverFiles`) will be mounted into the `server` pod.

### Enabling RBAC for Service Accounts
PM server needs proper access rights in the Kubernetes cluster to be able to scrape all the PM providers listed in the configuration file.
Below are the steps to achive this with cluster role, service account and cluster role binding.

1. Create a ClusterRole to monitor

Here is an example:

```
$ cat server-clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
  name: "eric-pm-server-staging"
rules:
  - apiGroups:
      - ""
    resources:
      - nodes
      - nodes/proxy
      - services
      - endpoints
      - pods
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - configmaps
    verbs:
      - get
  - apiGroups:
      - "extensions"
    resources:
      - ingresses/status
      - ingresses
    verbs:
      - get
      - list
      - watch
  - nonResourceURLs:
      - "/metrics"
    verbs:
      - get
```

```
$ kubectl  apply -f server-clusterrole.yaml
clusterrole "eric-pm-server-staging" configured
```
2. Create a Service Account

Below is an example of creating a service account named "monitoring" in the namespace "staging".
```
$ kubectl create sa monitoring --namespace staging
serviceaccount "monitoring" created
```
> **Tip** One must deploy the PM server in the same namespace in which the service account is created.
So in this case PM server should be deployed in staging namespace.

3. Create a ClusterRoleBinding

Below is an example of creating a cluster role binding named "eric-pm-server-staging" connecting the
cluster role "eric-pm-server-staging" with service account "monitoring" in the namespace "staging".
```
$ kubectl create clusterrolebinding eric-pm-server-staging \
  --clusterrole=eric-pm-server-staging --serviceaccount=staging:monitoring
clusterrolebinding "eric-pm-server-staging" created
```
