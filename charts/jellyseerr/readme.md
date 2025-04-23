# Jellyseerr Helm Chart

A Helm chart for deploying [Jellyseerr](https://github.com/fallenbagel/jellyseerr) on Kubernetes.

## Introduction

This chart deploys Jellyseerr on a Kubernetes cluster using the Helm package manager. Jellyseerr is a fork of Overseerr for Jellyfin support.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (if persistence is needed)

## Installing the Chart

To install the chart with the release name `jellyseerr`:

```bash
helm repo add rtomik-charts https://rtomik.github.io/helm-charts
helm install jellyseerr rtomik-charts/jellyseerr 
```

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `jellyseerr` deployment:

```bash
helm uninstall jellyseerr
```

## Parameters

### Global parameters

| Name                   | Description                                                   | Value  |
|------------------------|---------------------------------------------------------------|--------|
| `nameOverride`         | String to partially override the release name                 | `""`   |
| `fullnameOverride`     | String to fully override the release name                     | `""`   |

### Image parameters

| Name                    | Description                                                  | Value                          |
|-------------------------|--------------------------------------------------------------|--------------------------------|
| `image.repository`      | Jellyseerr image repository                                  | `ghcr.io/fallenbagel/jellyseerr` |
| `image.tag`             | Jellyseerr image tag                                         | `latest`                       |
| `image.pullPolicy`      | Jellyseerr image pull policy                                 | `IfNotPresent`                 |
| `imagePullSecrets`      | Global Docker registry secret names as an array              | `[]`                           |

### Deployment parameters

| Name                                 | Description                                      | Value     |
|--------------------------------------|--------------------------------------------------|-----------|
| `replicaCount`                       | Number of Jellyseerr replicas                    | `1`       |
| `revisionHistoryLimit`               | Number of revisions to retain for rollback       | `3`       |
| `podSecurityContext.runAsNonRoot`    | Run containers as non-root user                  | `true`    |
| `podSecurityContext.runAsUser`       | User ID for the container                        | `1000`    |
| `podSecurityContext.fsGroup`         | Group ID for the container filesystem            | `1000`    |
| `containerSecurityContext`           | Security context for the container               | See values.yaml |
| `nodeSelector`                       | Node labels for pod assignment                   | `{}`      |
| `tolerations`                        | Tolerations for pod assignment                   | `[]`      |
| `affinity`                           | Affinity for pod assignment                      | `{}`      |

### Service parameters

| Name                       | Description                                  | Value       |
|----------------------------|----------------------------------------------|-------------|
| `service.type`             | Kubernetes Service type                      | `ClusterIP` |
| `service.port`             | Service HTTP port                            | `5055`      |

### Ingress parameters

| Name                       | Description                                  | Value                 |
|----------------------------|----------------------------------------------|------------------------|
| `ingress.enabled`          | Enable ingress record generation             | `false`               |
| `ingress.className`        | IngressClass name                            | `""`                  |
| `ingress.annotations`      | Additional annotations for the Ingress resource | `{}`               |
| `ingress.hosts`            | Array of host and path objects               | See values.yaml       |
| `ingress.tls`              | TLS configuration                            | `[]`                  |

### Persistence parameters

| Name                          | Description                                  | Value           |
|-------------------------------|----------------------------------------------|-----------------|
| `persistence.enabled`         | Enable persistence using PVC                 | `true`          |
| `persistence.existingClaim`   | Use an existing PVC                          | `""`            |
| `persistence.storageClass`    | PVC Storage Class                            | `""`            |
| `persistence.accessMode`      | PVC Access Mode                              | `ReadWriteOnce` |
| `persistence.size`            | PVC Storage Size                             | `1Gi`           |
| `persistence.annotations`     | Additional custom annotations for the PVC    | `{}`            |

### Environment variables

| Name                     | Description                                  | Value           |
|--------------------------|----------------------------------------------|-----------------|
| `env`                    | Environment variables for Jellyseerr          | See values.yaml |
| `extraEnv`               | Additional environment variables             | `[]`            |

### Resources parameters

| Name                     | Description                                  | Value           |
|--------------------------|----------------------------------------------|-----------------|
| `resources.limits`       | The resources limits for containers          | See values.yaml |
| `resources.requests`     | The resources requests for containers        | See values.yaml |

## Configuration

The following table lists the configurable parameters of the Jellyseerr chart and their default values.

### Environment Variables

You can configure Jellyseerr by setting environment variables:

```yaml
env:
  - name: TZ
    value: "America/New_York"
  - name: LOG_LEVEL
    value: "info"
  - name: PORT
    value: "5055"
```

### Using Persistence

By default, persistence is enabled with a 1Gi volume:

```yaml
persistence:
  enabled: true
  size: 1Gi
```

You can also use an existing PVC:

```yaml
persistence:
  enabled: true
  existingClaim: my-jellyseerr-pvc
```