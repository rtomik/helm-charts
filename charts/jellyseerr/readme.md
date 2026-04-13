# Jellyseerr Helm Chart

A Helm chart for deploying [Jellyseerr](https://github.com/fallenbagel/jellyseerr) on Kubernetes.

## Introduction

This chart deploys Jellyseerr, a media request management application for Jellyfin, on a Kubernetes cluster using the Helm package manager. Jellyseerr is a fork of Overseerr with native Jellyfin support.

Source code: https://github.com/rtomik/helm-charts/tree/main/charts/jellyseerr

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (if persistence is needed)

## Installing the Chart

```bash
helm repo add rtomik https://rtomik.github.io/helm-charts
helm install jellyseerr rtomik/jellyseerr
```

## Uninstalling the Chart

```bash
helm uninstall jellyseerr
```

## Configuration Examples

### Minimal Installation

```yaml
ingress:
  enabled: true
  hosts:
    - host: jellyseerr.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - jellyseerr.example.com
```

### Custom Timezone and Logging

```yaml
env:
  - name: TZ
    value: "America/New_York"
  - name: LOG_LEVEL
    value: "info"
  - name: PORT
    value: "5055"
```

### Using an Existing PVC

```yaml
persistence:
  enabled: true
  existingClaim: my-jellyseerr-pvc
```

## Parameters

### Global Parameters

| Name | Description | Default |
|------|-------------|---------|
| `nameOverride` | Override the release name | `""` |
| `fullnameOverride` | Fully override the release name | `""` |

### Image Parameters

| Name | Description | Default |
|------|-------------|---------|
| `image.repository` | Jellyseerr image repository | `ghcr.io/fallenbagel/jellyseerr` |
| `image.tag` | Image tag | `2.5.2` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Deployment Parameters

| Name | Description | Default |
|------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `revisionHistoryLimit` | Revisions to retain | `3` |
| `podSecurityContext.runAsNonRoot` | Run as non-root | `true` |
| `podSecurityContext.runAsUser` | User ID | `1000` |
| `podSecurityContext.fsGroup` | Filesystem group ID | `1000` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |
| `podAnnotations` | Pod annotations | `{}` |

### Service Parameters

| Name | Description | Default |
|------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `5055` |

### Ingress Parameters

| Name | Description | Default |
|------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts | See values.yaml |
| `ingress.tls` | TLS configuration | `[]` |

### Persistence Parameters

| Name | Description | Default |
|------|-------------|---------|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.existingClaim` | Use an existing PVC | `""` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.size` | PVC size | `1Gi` |
| `persistence.annotations` | PVC annotations | `{}` |

### Environment Variables

| Name | Description | Default |
|------|-------------|---------|
| `env` | Environment variables | See values.yaml |
| `extraEnv` | Additional environment variables | `[]` |

### Resource Parameters

| Name | Description | Default |
|------|-------------|---------|
| `resources` | Resource limits and requests | `{}` |

### Health Check Parameters

| Name | Description | Default |
|------|-------------|---------|
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.liveness.path` | Liveness probe path | `/api/v1/status` |
| `probes.liveness.initialDelaySeconds` | Liveness initial delay | `30` |
| `probes.liveness.periodSeconds` | Liveness period | `10` |
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `probes.readiness.path` | Readiness probe path | `/api/v1/status` |
| `probes.readiness.initialDelaySeconds` | Readiness initial delay | `5` |
| `probes.readiness.periodSeconds` | Readiness period | `5` |

## Troubleshooting

- **Application not starting**: Check that persistence is enabled and the PVC is accessible
- **Timezone issues**: Set the `TZ` environment variable to your local timezone

```bash
kubectl logs deployment/jellyseerr -f
kubectl describe pod -l app.kubernetes.io/name=jellyseerr
```

## Links

- [Jellyseerr GitHub](https://github.com/fallenbagel/jellyseerr)
- [Chart Source](https://github.com/rtomik/helm-charts/tree/main/charts/jellyseerr)
