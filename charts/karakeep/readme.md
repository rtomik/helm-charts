# Karakeep Helm Chart

A Helm chart for deploying [Karakeep](https://github.com/karakeep-app/karakeep), a bookmark management application, on Kubernetes.

## Introduction

This chart deploys Karakeep as a multi-container pod with three services:

1. **Karakeep** — Main bookmark management application
2. **Chrome** — Headless browser for web scraping and preview generation
3. **MeiliSearch** — Search engine for fast bookmark search

All containers share the same pod network and communicate via localhost.

Source code: https://github.com/rtomik/helm-charts/tree/main/charts/karakeep

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

```bash
helm repo add rtomik https://rtomik.github.io/helm-charts
helm install karakeep rtomik/karakeep
```

## Uninstalling the Chart

```bash
helm uninstall karakeep
```

## Configuration Examples

### Minimal Installation

```yaml
ingress:
  enabled: true
  hosts:
    - host: karakeep.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - karakeep.example.com
```

### Production with Secrets

For production, store `NEXTAUTH_SECRET` in a Kubernetes secret. When ingress is enabled, `NEXTAUTH_URL` is automatically set to the ingress hostname.

```yaml
secrets:
  create: true
  env:
    NEXTAUTH_SECRET: "your-secure-32-character-string"

ingress:
  enabled: true
  hosts:
    - host: karakeep.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - karakeep.example.com
```

### With OpenAI Integration

```yaml
secrets:
  create: true
  env:
    NEXTAUTH_SECRET: "your-secure-32-character-string"
    OPENAI_API_KEY: "your-openai-api-key"
```

## Parameters

### Global Parameters

| Name | Description | Default |
|------|-------------|---------|
| `nameOverride` | Override the chart name | `""` |
| `fullnameOverride` | Override the full chart name | `""` |
| `replicaCount` | Number of replicas | `1` |
| `revisionHistoryLimit` | Revisions to retain | `3` |

### Pod Security Parameters

| Name | Description | Default |
|------|-------------|---------|
| `podSecurityContext.runAsNonRoot` | Run as non-root | `false` |
| `podSecurityContext.runAsUser` | User ID | `0` |
| `podSecurityContext.fsGroup` | Filesystem group ID | `0` |

### Karakeep Parameters

| Name | Description | Default |
|------|-------------|---------|
| `karakeep.image.repository` | Karakeep image repository | `ghcr.io/karakeep-app/karakeep` |
| `karakeep.image.tag` | Karakeep image tag | `0.26.0` |
| `karakeep.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `karakeep.service.port` | Karakeep service port | `3000` |
| `karakeep.env` | Karakeep environment variables | See values.yaml |
| `karakeep.extraEnv` | Additional environment variables | `[]` |

### Chrome Parameters

| Name | Description | Default |
|------|-------------|---------|
| `chrome.image.repository` | Chrome image repository | `gcr.io/zenika-hub/alpine-chrome` |
| `chrome.image.tag` | Chrome image tag | `124` |
| `chrome.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `chrome.service.port` | Chrome debugging port | `9222` |

### MeiliSearch Parameters

| Name | Description | Default |
|------|-------------|---------|
| `meilisearch.image.repository` | MeiliSearch image repository | `getmeili/meilisearch` |
| `meilisearch.image.tag` | MeiliSearch image tag | `v1.13.3` |
| `meilisearch.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `meilisearch.service.port` | MeiliSearch port | `7700` |
| `meilisearch.resources.limits.cpu` | CPU limit | `500m` |
| `meilisearch.resources.limits.memory` | Memory limit | `1Gi` |
| `meilisearch.resources.requests.cpu` | CPU request | `100m` |
| `meilisearch.resources.requests.memory` | Memory request | `256Mi` |

### Service Parameters

| Name | Description | Default |
|------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `3000` |

### Ingress Parameters

| Name | Description | Default |
|------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | See values.yaml |
| `ingress.hosts` | Ingress hosts | See values.yaml |
| `ingress.tls` | TLS configuration | See values.yaml |

### Persistence Parameters

| Name | Description | Default |
|------|-------------|---------|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.data.storageClass` | Data volume storage class | `""` |
| `persistence.data.accessMode` | Data volume access mode | `ReadWriteOnce` |
| `persistence.data.size` | Data volume size | `5Gi` |
| `persistence.meilisearch.storageClass` | MeiliSearch volume storage class | `""` |
| `persistence.meilisearch.accessMode` | MeiliSearch volume access mode | `ReadWriteOnce` |
| `persistence.meilisearch.size` | MeiliSearch volume size | `2Gi` |

### Secret Parameters

| Name | Description | Default |
|------|-------------|---------|
| `secrets.create` | Create secret for environment variables | `false` |
| `secrets.existingSecret` | Use an existing secret | `""` |
| `secrets.env` | Environment variables for the secret | `{}` |

## Troubleshooting

### NEXTAUTH_SECRET Not Set

The default `NEXTAUTH_SECRET` is a placeholder. For production, override it:

```yaml
secrets:
  create: true
  env:
    NEXTAUTH_SECRET: "your-secure-32-character-string"
```

### Custom NEXTAUTH_URL

If not using ingress or using a custom domain, override `NEXTAUTH_URL` manually:

```yaml
karakeep:
  env:
    - name: NEXTAUTH_URL
      value: "https://your-domain.com"
```

## Links

- [Karakeep GitHub](https://github.com/karakeep-app/karakeep)
- [Chart Source](https://github.com/rtomik/helm-charts/tree/main/charts/karakeep)
