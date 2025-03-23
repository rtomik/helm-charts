# Donetick Helm Chart

A Helm chart for deploying the Donetick task management application on Kubernetes.

## Introduction

This chart deploys [Donetick](https://github.com/donetick/donetick) on a Kubernetes cluster using the Helm package manager. 

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (if persistence is needed)

## Installing the Chart

To install the chart with the release name `my-donetick`:

```bash
$ helm repo add donetick-chart https://rtomik.github.io/helm-charts
$ helm install donetick donetick-chart/donetick
```

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-donetick` deployment:

```bash
$ helm delete my-donetick
```

## Parameters

### Global parameters

| Name                   | Description                                                                         | Value |
|------------------------|-------------------------------------------------------------------------------------|-------|
| `nameOverride`         | String to partially override the release name                                       | `""`  |
| `fullnameOverride`     | String to fully override the release name                                           | `""`  |

### Image parameters

| Name                    | Description                                                                          | Value              |
|-------------------------|--------------------------------------------------------------------------------------|--------------------|
| `image.repository`      | Donetick image repository                                                           | `donetick/donetick` |
| `image.tag`             | Donetick image tag                                                                  | `latest`          |
| `image.pullPolicy`      | Donetick image pull policy                                                          | `IfNotPresent`     |
| `imagePullSecrets`      | Global Docker registry secret names as an array                                      | `[]`               |

### Secret Management

| Name                                   | Description                                                        | Value               |
|----------------------------------------|--------------------------------------------------------------------|---------------------|
| `config.jwt.existingSecret`            | Name of existing secret for JWT token                             | `""`                |
| `config.jwt.secretKey`                 | Key in the existing secret for JWT token                          | `"jwtSecret"`       |
| `config.oauth2.existingSecret`         | Name of existing secret for OAuth2 credentials                    | `""`                |
| `config.oauth2.clientIdKey`            | Key in the existing secret for OAuth2 client ID                   | `"client-id"`       |
| `config.oauth2.clientSecretKey`        | Key in the existing secret for OAuth2 client secret               | `"client-secret"`   |
| `config.database.existingSecret`       | Name of existing secret for database credentials                  | `""`                |
| `config.database.hostKey`              | Key in the existing secret for database host                      | `"db-host"`         |
| `config.database.portKey`              | Key in the existing secret for database port                      | `"db-port"`         |
| `config.database.userKey`              | Key in the existing secret for database user                      | `"db-user"`         |
| `config.database.passwordKey`          | Key in the existing secret for database password                  | `"db-password"`     |
| `config.database.nameKey`              | Key in the existing secret for database name                      | `"db-name"`         |

### Deployment parameters

| Name                                 | Description                                                              | Value     |
|--------------------------------------|--------------------------------------------------------------------------|-----------|
| `replicaCount`                       | Number of Donetick replicas                                              | `1`       |
| `revisionHistoryLimit`               | Number of revisions to retain for rollback                               | `3`       |
| `podSecurityContext.runAsNonRoot`    | Run containers as non-root user                                          | `true`    |
| `podSecurityContext.runAsUser`       | User ID for the container                                                | `1000`    |
| `podSecurityContext.fsGroup`         | Group ID for the container filesystem                                    | `1000`    |
| `containerSecurityContext`           | Security context for the container                                       | See values.yaml |
| `nodeSelector`                       | Node labels for pod assignment                                           | `{}`      |
| `tolerations`                        | Tolerations for pod assignment                                           | `[]`      |
| `affinity`                           | Affinity for pod assignment                                              | `{}`      |

### Service parameters

| Name                       | Description                                          | Value       |
|----------------------------|------------------------------------------------------|-------------|
| `service.type`             | Kubernetes Service type                              | `ClusterIP` |
| `service.port`             | Service HTTP port                                    | `2021`      |
| `service.annotations`      | Additional annotations for Service                   | `{}`        |
| `service.nodePort`         | Service HTTP node port (when applicable)             | `""`        |

### Ingress parameters

| Name                       | Description                                          | Value                |
|----------------------------|------------------------------------------------------|----------------------|
| `ingress.enabled`          | Enable ingress record generation                     | `true`               |
| `ingress.className`        | IngressClass name                                    | `"traefik"`          |
| `ingress.annotations`      | Additional annotations for the Ingress resource      | See values.yaml      |
| `ingress.hosts`            | Array of host and path objects                       | See values.yaml      |
| `ingress.tlsSecretName`    | Global TLS secret name for all hosts                 | `""`                 |
| `ingress.tls`              | TLS configuration                                    | See values.yaml      |
| `ingress.tls[].secretName` | Host-specific TLS secret name (overrides global)     | `""`                 |

### Persistence parameters

| Name                          | Description                                          | Value         |
|-------------------------------|------------------------------------------------------|---------------|
| `persistence.enabled`         | Enable persistence using PVC                         | `true`        |
| `persistence.storageClass`    | PVC Storage Class                                    | `"longhorn"`  |
| `persistence.accessMode`      | PVC Access Mode                                      | `ReadWriteOnce` |
| `persistence.size`            |
