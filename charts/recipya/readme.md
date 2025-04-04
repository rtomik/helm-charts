# Recipya Helm Chart

A Helm chart for deploying [Recipya](https://github.com/reaper47/recipya) on Kubernetes.

## Introduction

This chart deploys Recipya recipe manager on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is needed)

## Installing the Chart

To install the chart with the release name `recipya`:

```bash
helm repo add recipya-chart https://rtomik.github.io/helm-charts
helm install recipya recipya-chart/recipya -n recipya
```

The command deploys Recipya on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-recipya` deployment:

```bash
helm uninstall recipya -n recipya
```

## Parameters

### Global parameters

| Name                     | Description                          | Value           |
|--------------------------|--------------------------------------|-----------------|
| `image.repository`       | Recipya image repository             | `reaper99/recipya` |
| `image.tag`              | Recipya image tag                    | `v1.2.2`        |
| `image.pullPolicy`       | Recipya image pull policy            | `IfNotPresent`  |
| `replicaCount`           | Number of Recipya replicas           | `1`             |
| `revisionHistoryLimit`   | Number of revisions to keep          | `3`             |

### Security parameters

| Name                                    | Description                                      | Value     |
|-----------------------------------------|--------------------------------------------------|-----------|
| `podSecurityContext.fsGroup`            | Group ID for the Recipya container               | `1000`    |
| `containerSecurityContext.runAsUser`    | User ID for the Recipya container                | `1000`    |
| `containerSecurityContext.runAsGroup`   | Group ID for the Recipya container               | `1000`    |
| `containerSecurityContext.runAsNonRoot` | Run containers as non-root                       | `true`    |

### Recipya configuration parameters

| Name                                    | Description                                           | Value          |
|-----------------------------------------|-------------------------------------------------------|----------------|
| `config.server.port`                    | Server port                                           | `8078`         |
| `config.server.autologin`               | Whether to login automatically                        | `false`        |
| `config.server.is_demo`                 | Whether the app is a demo version                     | `false`        |
| `config.server.is_prod`                 | Whether the app is in production                      | `false`        |
| `config.server.no_signups`              | Whether to disable user account registrations         | `false`        |
| `config.server.url`                     | Base URL for the application                          | `http://0.0.0.0` |
| `config.email.address`                  | The email address for SendGrid                        | `""`           |
| `config.email.sendgrid`                 | SendGrid API key                                      | `""`           |
| `config.documentIntelligence.endpoint`  | Azure Document Intelligence endpoint                  | `""`           |
| `config.documentIntelligence.key`       | Azure Document Intelligence key                       | `""`           |

### Service parameters

| Name                     | Description                                      | Value       |
|--------------------------|--------------------------------------------------|-------------|
| `service.type`           | Recipya service type                             | `ClusterIP` |
| `service.port`           | Recipya service port                             | `8078`      |

### Ingress parameters

| Name                     | Description                                      | Value       |
|--------------------------|--------------------------------------------------|-------------|
| `ingress.enabled`        | Enable ingress controller resource               | `false`     |
| `ingress.className`      | IngressClass that will be used                   | `""`        |
| `ingress.hosts[0].host`  | Default host for the ingress resource            | `chart-example.local` |
| `ingress.tls`            | Create TLS Secret                                | `[]`        |

### Persistence parameters

| Name                                 | Description                              | Value     |
|--------------------------------------|------------------------------------------|-----------|
| `persistence.enabled`                | Enable persistence using PVC             | `true`    |
| `persistence.accessMode`             | PVC Access Mode                          | `ReadWriteOnce` |
| `persistence.size`                   | PVC Storage Request                      | `1Gi`     |
| `persistence.storageClass`           | Storage class of backing PVC             | `""`      |

### Resource parameters

| Name                     | Description                              | Value     |
|--------------------------|------------------------------------------|-----------|
| `resources.limits.cpu`   | CPU limit                                | `500m`    |
| `resources.limits.memory`| Memory limit                             | `512Mi`   |
| `resources.requests.cpu` | CPU request                              | `100m`    |
| `resources.requests.memory` | Memory request                        | `128Mi`   |

## Using Existing Secrets

If you want to use existing secrets for sensitive data:

```yaml
config:
  email:
    existingSecret: "my-email-secret"
    addressKey: "email"
    sendgridKey: "sendgrid"
  documentIntelligence:
    existingSecret: "my-di-secret"
    endpointKey: "di_endpoint"
    keyKey: "di_key"
```

## Configuration

See the [Recipya documentation](https://recipes.musicavis.ca/docs/installation/docker/#environment-variables) for details on all available configuration options.