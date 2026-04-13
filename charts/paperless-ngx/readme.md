# Paperless-ngx Helm Chart

A Helm chart for deploying [Paperless-ngx](https://github.com/paperless-ngx/paperless-ngx), a document management system with OCR, on Kubernetes.

## Introduction

This chart deploys Paperless-ngx on a Kubernetes cluster. Paperless-ngx is a community-supported document scanner: scan, index, and archive all your physical documents. It requires external PostgreSQL and Redis services.

Source code: https://github.com/rtomik/helm-charts/tree/main/charts/paperless-ngx

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- **External PostgreSQL database** (PostgreSQL 11+ required)
- **External Redis server**
- PV provisioner support

## Installing the Chart

```bash
helm repo add rtomik https://rtomik.github.io/helm-charts
helm install paperless-ngx rtomik/paperless-ngx
```

## Uninstalling the Chart

```bash
helm uninstall paperless-ngx
```

**Note**: PVCs are not deleted automatically. To remove them:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=paperless-ngx
```

## Configuration Examples

### Minimal Installation

```yaml
postgresql:
  external:
    enabled: true
    host: "my-postgres.example.com"
    password: "secretpassword"

redis:
  external:
    host: "my-redis.example.com"
```

### Production with Existing Secrets

```yaml
config:
  url: "https://paperless.example.com"
  allowedHosts: "paperless.example.com"
  secretKey:
    existingSecret: "paperless-secrets"
    secretKey: "django-secret-key"
  admin:
    user: "admin"
    existingSecret: "paperless-admin-secrets"

postgresql:
  external:
    enabled: true
    host: "postgres-cluster-pooler.dbs.svc.cluster.local"
    port: 5432
    database: "paperless"
    username: "paperless"
    existingSecret: "paperless-db-credentials"
    passwordKey: "password"

redis:
  external:
    host: "redis.cache.svc.cluster.local"
    port: 6379
    database: 0
    existingSecret: "paperless-redis-credentials"
    passwordKey: "password"
    prefix: "paperless-prod"

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: paperless.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: paperless-tls
      hosts:
        - paperless.example.com
```

### Redis with Username and Password (ACL)

```yaml
redis:
  external:
    host: "redis.example.com"
    username: "paperless-user"
    password: "myredispassword"
```

### Sharing Redis Among Multiple Instances

Use the `prefix` parameter to avoid key collisions:

```yaml
# Instance 1
redis:
  external:
    host: "shared-redis.example.com"
    password: "sharedpassword"
    prefix: "paperless-prod"

# Instance 2
redis:
  external:
    host: "shared-redis.example.com"
    password: "sharedpassword"
    prefix: "paperless-staging"
```

### Using Existing PVCs

```yaml
persistence:
  data:
    enabled: true
    existingClaim: "my-existing-data-pvc"
  media:
    enabled: true
    existingClaim: "my-existing-media-pvc"
  export:
    enabled: true
  consume:
    enabled: true
```

When `existingClaim` is set, the chart skips PVC creation and `storageClass`/`size` are ignored for that volume.

## Parameters

### Global Parameters

| Name | Description | Default |
|------|-------------|---------|
| `nameOverride` | Override the release name | `""` |
| `fullnameOverride` | Fully override the release name | `""` |

### Image Parameters

| Name | Description | Default |
|------|-------------|---------|
| `image.repository` | Paperless-ngx image repository | `ghcr.io/paperless-ngx/paperless-ngx` |
| `image.tag` | Image tag | `2.20.3` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Deployment Parameters

| Name | Description | Default |
|------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `revisionHistoryLimit` | Revisions to retain | `3` |
| `podSecurityContext.runAsNonRoot` | Run as non-root | `false` |
| `podSecurityContext.runAsUser` | User ID | `0` |
| `podSecurityContext.fsGroup` | Filesystem group ID | `1000` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |

### Service Parameters

| Name | Description | Default |
|------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8000` |

### Ingress Parameters

| Name | Description | Default |
|------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | See values.yaml |
| `ingress.hosts` | Ingress hosts | See values.yaml |
| `ingress.tls` | TLS configuration | See values.yaml |

### PostgreSQL Configuration (Required)

| Name | Description | Default |
|------|-------------|---------|
| `postgresql.external.enabled` | Enable external PostgreSQL | `true` |
| `postgresql.external.host` | PostgreSQL host | `postgresql.default.svc.cluster.local` |
| `postgresql.external.port` | PostgreSQL port | `5432` |
| `postgresql.external.database` | Database name | `paperless` |
| `postgresql.external.username` | Username | `paperless` |
| `postgresql.external.password` | Password | `""` |
| `postgresql.external.existingSecret` | Existing secret name | `""` |
| `postgresql.external.passwordKey` | Key for password in secret | `postgresql-password` |

### Redis Configuration (Required)

| Name | Description | Default |
|------|-------------|---------|
| `redis.external.enabled` | Enable external Redis | `true` |
| `redis.external.host` | Redis host | `redis.default.svc.cluster.local` |
| `redis.external.port` | Redis port | `6379` |
| `redis.external.database` | Redis database number | `0` |
| `redis.external.username` | Redis username (6.0+ ACL) | `""` |
| `redis.external.password` | Redis password | `""` |
| `redis.external.existingSecret` | Existing secret name | `""` |
| `redis.external.urlKey` | Key for full Redis URL in secret | `redis-url` |
| `redis.external.passwordKey` | Key for password in secret | `redis-password` |
| `redis.external.prefix` | Key prefix for multi-instance | `""` |

### Application Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.url` | External URL | `""` |
| `config.allowedHosts` | Allowed hosts (comma-separated) | `*` |
| `config.csrfTrustedOrigins` | CSRF trusted origins | `""` |
| `config.timeZone` | Timezone | `UTC` |
| `config.ocr.language` | OCR language (3-letter code) | `eng` |
| `config.ocr.mode` | OCR mode (`skip`, `redo`, `force`) | `skip` |
| `config.consumer.recursive` | Recursive consume directory | `false` |
| `config.consumer.subdirsAsTags` | Use subdirectory names as tags | `false` |

### Security Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.secretKey.existingSecret` | Existing secret for Django secret key | `""` |
| `config.secretKey.secretKey` | Key in secret | `secret-key` |
| `config.admin.user` | Admin username to create on startup | `""` |
| `config.admin.password` | Admin password | `""` |
| `config.admin.email` | Admin email | `root@localhost` |
| `config.admin.existingSecret` | Existing secret for admin credentials | `""` |

### Persistence Parameters

| Name | Description | Default |
|------|-------------|---------|
| `persistence.data.enabled` | Enable data PVC | `true` |
| `persistence.data.existingClaim` | Existing data PVC | `""` |
| `persistence.data.size` | Data PVC size | `1Gi` |
| `persistence.media.enabled` | Enable media PVC | `true` |
| `persistence.media.existingClaim` | Existing media PVC | `""` |
| `persistence.media.size` | Media PVC size | `10Gi` |
| `persistence.consume.enabled` | Enable consume PVC | `true` |
| `persistence.consume.existingClaim` | Existing consume PVC | `""` |
| `persistence.consume.size` | Consume PVC size | `5Gi` |
| `persistence.export.enabled` | Enable export PVC | `true` |
| `persistence.export.existingClaim` | Existing export PVC | `""` |
| `persistence.export.size` | Export PVC size | `1Gi` |

### Resource Parameters

| Name | Description | Default |
|------|-------------|---------|
| `resources` | Resource limits and requests | `{}` |

### Health Check Parameters

| Name | Description | Default |
|------|-------------|---------|
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.liveness.path` | Liveness probe path | `/` |
| `probes.liveness.initialDelaySeconds` | Liveness initial delay | `60` |
| `probes.liveness.periodSeconds` | Liveness period | `10` |
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `probes.readiness.path` | Readiness probe path | `/` |
| `probes.readiness.initialDelaySeconds` | Readiness initial delay | `30` |
| `probes.readiness.periodSeconds` | Readiness period | `5` |

### Autoscaling Parameters

| Name | Description | Default |
|------|-------------|---------|
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Min replicas | `1` |
| `autoscaling.maxReplicas` | Max replicas | `3` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU | `80` |
| `autoscaling.targetMemoryUtilizationPercentage` | Target memory | `80` |

## Troubleshooting

- **Database Connection**: Verify PostgreSQL credentials and that the database exists
- **Redis Connection**: Ensure Redis is accessible; use `prefix` if sharing Redis between instances
- **Allowed Hosts Error**: Set `config.allowedHosts` to your domain when exposed externally
- **Container Security**: The container runs as root initially for s6-overlay setup, then drops to UID 1000. This is required by the Paperless-ngx image.

```bash
kubectl logs -f deployment/paperless-ngx
kubectl describe pod -l app.kubernetes.io/name=paperless-ngx
```

## Links

- [Paperless-ngx GitHub](https://github.com/paperless-ngx/paperless-ngx)
- [Paperless-ngx Documentation](https://docs.paperless-ngx.com/)
- [Chart Source](https://github.com/rtomik/helm-charts/tree/main/charts/paperless-ngx)
