# Recipya Helm Chart

A Helm chart for deploying [Recipya](https://github.com/reaper47/recipya), a recipe management application, on Kubernetes.

## Introduction

This chart deploys Recipya on a Kubernetes cluster using the Helm package manager. Recipya includes optimized Traefik ingress configuration with Content Security Policy support and sticky session handling for authentication.

Source code: https://github.com/rtomik/helm-charts/tree/main/charts/recipya

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support (if persistence is needed)

## Installing the Chart

```bash
helm repo add rtomik https://rtomik.github.io/helm-charts
helm install recipya rtomik/recipya
```

## Uninstalling the Chart

```bash
helm uninstall recipya
```

## Configuration Examples

### Minimal Installation

> **Important**: Set `config.server.url` to match your ingress URL including the scheme. This is required for post-login redirects to work correctly.

```yaml
config:
  server:
    url: "https://recipya.example.com"

ingress:
  enabled: true
  className: "traefik"
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.middlewares: recipya-recipya-headers@kubernetescrd
    traefik.ingress.kubernetes.io/service.sticky: "true"
    traefik.ingress.kubernetes.io/session-cookie-name: "recipya_session"
  hosts:
    - host: recipya.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - hosts:
        - recipya.example.com
```

### With SendGrid Email

```yaml
config:
  email:
    address: "your-email@example.com"
    sendgrid: "SG.your-sendgrid-api-key"
```

### With SendGrid and Azure Document Intelligence via Existing Secrets

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

## Parameters

### Global Parameters

| Name | Description | Default |
|------|-------------|---------|
| `nameOverride` | Override the release name | `""` |
| `fullnameOverride` | Fully override the release name | `""` |
| `replicaCount` | Number of replicas | `1` |
| `revisionHistoryLimit` | Revisions to retain | `3` |

### Image Parameters

| Name | Description | Default |
|------|-------------|---------|
| `image.repository` | Recipya image repository | `reaper99/recipya` |
| `image.tag` | Image tag | `v1.2.2` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |

### Pod Security Parameters

| Name | Description | Default |
|------|-------------|---------|
| `podSecurityContext.fsGroup` | Filesystem group ID | `1000` |
| `containerSecurityContext` | Container security context | `{}` |

### Application Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.server.port` | Server port | `8078` |
| `config.server.url` | Base URL (must match ingress) | `http://0.0.0.0` |
| `config.server.autologin` | Auto-login | `false` |
| `config.server.is_demo` | Demo mode | `false` |
| `config.server.is_prod` | Production mode | `true` |
| `config.server.no_signups` | Disable user registration | `false` |
| `config.email.address` | SendGrid email address | `""` |
| `config.email.sendgrid` | SendGrid API key | `""` |
| `config.email.existingSecret` | Existing secret for email | `""` |
| `config.email.addressKey` | Key for email address in secret | `email` |
| `config.email.sendgridKey` | Key for SendGrid key in secret | `sendgrid` |
| `config.documentIntelligence.endpoint` | Azure Document Intelligence endpoint | `""` |
| `config.documentIntelligence.key` | Azure Document Intelligence key | `""` |
| `config.documentIntelligence.existingSecret` | Existing secret for Azure DI | `""` |
| `config.documentIntelligence.endpointKey` | Key for endpoint in secret | `di_endpoint` |
| `config.documentIntelligence.keyKey` | Key for API key in secret | `di_key` |

### Service Parameters

| Name | Description | Default |
|------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8078` |

### Ingress Parameters

| Name | Description | Default |
|------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | See values.yaml |
| `ingress.hosts` | Ingress hosts | See values.yaml |
| `ingress.tls` | TLS configuration | `[]` |

### Persistence Parameters

| Name | Description | Default |
|------|-------------|---------|
| `persistence.enabled` | Enable persistence | `false` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.size` | PVC size | `5Gi` |
| `persistence.annotations` | PVC annotations | `{}` |

### Resource Parameters

| Name | Description | Default |
|------|-------------|---------|
| `resources` | Resource limits and requests | `{}` |

### Health Check Parameters

| Name | Description | Default |
|------|-------------|---------|
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.liveness.path` | Liveness probe path | `/` |
| `probes.liveness.initialDelaySeconds` | Liveness initial delay | `30` |
| `probes.liveness.periodSeconds` | Liveness period | `10` |
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `probes.readiness.path` | Readiness probe path | `/` |
| `probes.readiness.initialDelaySeconds` | Readiness initial delay | `30` |
| `probes.readiness.periodSeconds` | Readiness period | `10` |

## Troubleshooting

### Post-Login Redirect Fails

Ensure `config.server.url` matches your ingress URL exactly, including the scheme (`https://`).

### Content Security Policy Errors

The chart includes a Traefik middleware with a CSP policy allowing scripts from `unpkg.com`. If using a different ingress controller, configure an equivalent CSP policy:

```
default-src 'self';
script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: data: https://unpkg.com;
style-src 'self' 'unsafe-inline';
img-src 'self' data: blob:;
connect-src 'self' ws: wss: *;
```

### Debugging

```bash
kubectl logs deployment/recipya -f
kubectl describe pod -l app.kubernetes.io/name=recipya
```

## Links

- [Recipya GitHub](https://github.com/reaper47/recipya)
- [Recipya Documentation](https://recipes.musicavis.ca/docs/installation/docker/#environment-variables)
- [Chart Source](https://github.com/rtomik/helm-charts/tree/main/charts/recipya)
