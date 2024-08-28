# Standalone Domain Proxy Cloud Native PoC

Helm package which installs Standalone Domain Proxy Cloud Native PoC

## Helm package content

| Chart Name                       | 
| -------------------------------- |
| eric-cnom-document-database-mg   |
| eric-cnom-server                 |
| eric-ctrl-bro                    |
| eric-data-document-database-pg   |
| eric-data-search-engine          |
| eric-data-search-engine-curator  |
| eric-enm-monitoring-master       |
| eric-enm-monitoring-remotewriter |
| eric-enm-sfwkdb-schemamgt        |
| eric-enmsg-dpmediation           |
| eric-enmsg-gossiprouter-cache    |
| eric-enmsg-gossiprouter-eap7     |
| eric-log-shipper                 |
| eric-log-transformer             |
| eric-pm-server                   | 

## Install/Upgrade this package

Helm package contains `values.yaml` file with several `tags` fields, they will be evaluated
and used to control install flow.

### Install Common services required for Domain Proxy Mediation

```
NS=domainproxy
helm install dp-common-services eric-domain-proxy-standalone/ -f dp-values.yaml --set tags.eric-dp-common=true -n ${NS} --wait --timeout 30m --debug
```

### Install Domain Proxy Mediation

```
helm install dpmediation eric-domain-proxy-standalone/ -f dp-values.yaml --set tags.eric-enmsg-dpmediation=true -n ${NS} --wait --timeout 15m --debug
```

### Upgrade Common services 

```
NS=domainproxy                                                                                                                                    helm upgrade dp-common-services eric-domain-proxy-standalone/ -f dp-values.yaml --set tags.eric-dp-common=true -n ${NS} --wait --timeout 30m --debug                                                                                                                                                ```

### Upgrade Domain Proxy Mediation

```
helm upgrade dpmediation eric-domain-proxy-standalone/ -f dp-values.yaml --set tags.eric-enmsg-dpmediation=true -n ${NS} --wait --timeout 15m --debug                                                                                                                                               ```

## Uninstall this package

```
helm delete dp-common-services
helm delete dpmediation
```

## NOTES
