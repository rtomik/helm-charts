# Joplin Server Helm Chart

A Helm chart for deploying [Joplin Server](https://github.com/laurent22/joplin) on Kubernetes.

## Introduction

This chart deploys Joplin Server, the synchronization server for the Joplin note-taking application, on a Kubernetes cluster. Joplin Server allows syncing notes across devices and supports filesystem or S3 storage, email notifications, and an optional AI transcription service.

Source code: https://github.com/rtomik/helm-charts/tree/main/charts/joplin-server

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- **External PostgreSQL database** (required — Joplin Server does not support SQLite)
- PV provisioner support (if using filesystem storage)

## Installing the Chart

```bash
helm repo add rtomik https://rtomik.github.io/helm-charts
helm install joplin-server rtomik/joplin-server
```

> **Important**: Configure PostgreSQL database settings before installation.

## Uninstalling the Chart

```bash
helm uninstall joplin-server
```

## Configuration Examples

### Minimal Installation

> **Important**: Health check probes require a `Host` header matching your ingress domain. Update `probes.*.httpHeaders` accordingly.

```yaml
postgresql:
  external:
    enabled: true
    host: "postgresql.example.com"
    port: 5432
    database: "joplin"
    user: "joplin"
    password: "secure-password"

env:
  APP_BASE_URL: "https://joplin.example.com"

probes:
  liveness:
    httpHeaders:
      - name: Host
        value: joplin.example.com
  readiness:
    httpHeaders:
      - name: Host
        value: joplin.example.com

joplin:
  admin:
    email: "admin@example.com"
    password: "admin-password"
  server:
    enableUserRegistration: true

ingress:
  enabled: true
  hosts:
    - host: joplin.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - joplin.example.com
      secretName: joplin-tls
```

### Production with Existing Secrets

```yaml
postgresql:
  external:
    enabled: true
    host: "postgres-cluster-pooler.dbs.svc.cluster.local"
    port: 5432
    database: "joplin-server"
    existingSecret: "joplin-db-credentials"
    userKey: "username"
    passwordKey: "password"

joplin:
  admin:
    existingSecret: "joplin-admin-secret"
    emailKey: "email"
    passwordKey: "password"
```

### S3 Storage

```yaml
joplin:
  storage:
    driver: "s3"
    s3:
      bucket: "joplin-notes"
      region: "us-east-1"
      existingSecret: "joplin-s3-secret"
      accessKeyIdKey: "access-key-id"
      secretAccessKeyKey: "secret-access-key"

# No persistence needed when using S3
persistence:
  enabled: false
```

### Email Notifications

```yaml
joplin:
  email:
    enabled: true
    host: "smtp.example.com"
    port: 587
    fromEmail: "joplin@example.com"
    fromName: "Joplin Server"
    secure: true
    existingSecret: "joplin-email-secret"
    usernameKey: "username"
    passwordKey: "password"
```

### Transcribe Service (AI Transcription)

```yaml
transcribe:
  enabled: true
  api:
    existingSecret: "joplin-transcribe-secret"
    keyName: "api-key"
  database:
    host: "postgresql.example.com"
    port: 5432
    database: "transcribe"
    user: "transcribe"
    existingSecret: "transcribe-db-secret"
    userKey: "username"
    passwordKey: "password"
  persistence:
    enabled: true
    size: 5Gi
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
| `image.repository` | Joplin Server image repository | `joplin/server` |
| `image.tag` | Image tag | `3.4.2` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Deployment Parameters

| Name | Description | Default |
|------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `revisionHistoryLimit` | Revisions to retain | `3` |
| `podSecurityContext.runAsNonRoot` | Run as non-root | `true` |
| `podSecurityContext.runAsUser` | User ID | `1001` |
| `podSecurityContext.fsGroup` | Filesystem group ID | `1001` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |

### Service Parameters

| Name | Description | Default |
|------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `22300` |

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
| `postgresql.external.enabled` | Use external PostgreSQL | `true` |
| `postgresql.external.host` | PostgreSQL host | `""` |
| `postgresql.external.port` | PostgreSQL port | `5432` |
| `postgresql.external.database` | Database name | `joplin` |
| `postgresql.external.user` | Username | `joplin` |
| `postgresql.external.password` | Password | `""` |
| `postgresql.external.existingSecret` | Existing secret name | `""` |
| `postgresql.external.userKey` | Key for username in secret | `username` |
| `postgresql.external.passwordKey` | Key for password in secret | `password` |
| `postgresql.external.hostKey` | Key for host in secret (optional) | `""` |
| `postgresql.external.portKey` | Key for port in secret (optional) | `""` |
| `postgresql.external.databaseKey` | Key for database in secret (optional) | `""` |

### Admin Settings

| Name | Description | Default |
|------|-------------|---------|
| `joplin.admin.email` | Admin user email | `""` |
| `joplin.admin.password` | Admin user password | `""` |
| `joplin.admin.existingSecret` | Existing secret for admin credentials | `""` |
| `joplin.admin.emailKey` | Key for email in secret | `admin-email` |
| `joplin.admin.passwordKey` | Key for password in secret | `admin-password` |

### Server Settings

| Name | Description | Default |
|------|-------------|---------|
| `joplin.server.maxRequestBodySize` | Max request body size | `200mb` |
| `joplin.server.sessionTimeout` | Session timeout (seconds) | `86400` |
| `joplin.server.enableUserRegistration` | Enable user registration | `false` |
| `joplin.server.enableSharing` | Enable sharing | `true` |
| `joplin.server.enablePublicNotes` | Enable public notes | `true` |

### Storage Settings

| Name | Description | Default |
|------|-------------|---------|
| `joplin.storage.driver` | Storage driver (`filesystem`, `s3`, `azure`) | `filesystem` |
| `joplin.storage.filesystemPath` | Filesystem storage path | `/var/lib/joplin` |
| `joplin.storage.s3.bucket` | S3 bucket name | `""` |
| `joplin.storage.s3.region` | S3 region | `""` |
| `joplin.storage.s3.endpoint` | S3 endpoint (for S3-compatible services) | `""` |
| `joplin.storage.s3.accessKeyId` | S3 access key ID | `""` |
| `joplin.storage.s3.secretAccessKey` | S3 secret access key | `""` |
| `joplin.storage.s3.existingSecret` | Existing secret for S3 credentials | `""` |
| `joplin.storage.s3.accessKeyIdKey` | Key for access key in secret | `access-key-id` |
| `joplin.storage.s3.secretAccessKeyKey` | Key for secret access key in secret | `secret-access-key` |

### Email Settings

| Name | Description | Default |
|------|-------------|---------|
| `joplin.email.enabled` | Enable email | `false` |
| `joplin.email.host` | SMTP host | `""` |
| `joplin.email.port` | SMTP port | `587` |
| `joplin.email.username` | SMTP username | `""` |
| `joplin.email.password` | SMTP password | `""` |
| `joplin.email.fromEmail` | From email address | `""` |
| `joplin.email.fromName` | From name | `Joplin Server` |
| `joplin.email.secure` | Use TLS/SSL | `true` |
| `joplin.email.existingSecret` | Existing secret for credentials | `""` |
| `joplin.email.usernameKey` | Key for username in secret | `email-username` |
| `joplin.email.passwordKey` | Key for password in secret | `email-password` |

### Logging Settings

| Name | Description | Default |
|------|-------------|---------|
| `joplin.logging.level` | Log level (`error`, `warn`, `info`, `debug`) | `info` |
| `joplin.logging.target` | Log target (`console`, `file`) | `console` |

### Persistence Parameters

| Name | Description | Default |
|------|-------------|---------|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.size` | PVC size | `10Gi` |
| `persistence.annotations` | PVC annotations | `{}` |

### Transcribe Service

| Name | Description | Default |
|------|-------------|---------|
| `transcribe.enabled` | Enable transcribe service | `false` |
| `transcribe.image.repository` | Transcribe image repository | `joplin/transcribe` |
| `transcribe.image.tag` | Transcribe image tag | `latest` |
| `transcribe.api.key` | Shared API key | `""` |
| `transcribe.api.existingSecret` | Existing secret for API key | `""` |
| `transcribe.api.keyName` | Key name in secret | `transcribe-api-key` |
| `transcribe.service.type` | Transcribe service type | `ClusterIP` |
| `transcribe.service.port` | Transcribe service port | `4567` |
| `transcribe.database.host` | Transcribe DB host | `""` |
| `transcribe.database.port` | Transcribe DB port | `5432` |
| `transcribe.database.database` | Transcribe DB name | `transcribe` |
| `transcribe.database.user` | Transcribe DB user | `transcribe` |
| `transcribe.database.password` | Transcribe DB password | `""` |
| `transcribe.database.existingSecret` | Existing secret for transcribe DB | `""` |
| `transcribe.database.userKey` | Key for username in secret | `username` |
| `transcribe.database.passwordKey` | Key for password in secret | `password` |

### Security Settings

| Name | Description | Default |
|------|-------------|---------|
| `security.httpsRedirect` | Enable HTTPS redirect | `false` |
| `security.tls.enabled` | Enable custom TLS certificate | `false` |
| `security.tls.existingSecret` | Secret with TLS certificate | `""` |
| `security.tls.certificateKey` | Key for TLS certificate in secret | `tls.crt` |
| `security.tls.privateKeyKey` | Key for TLS private key in secret | `tls.key` |

### Resource Parameters

| Name | Description | Default |
|------|-------------|---------|
| `resources` | Resource limits and requests | `{}` |

### Health Check Parameters

| Name | Description | Default |
|------|-------------|---------|
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.liveness.path` | Liveness probe path | `/api/ping` |
| `probes.liveness.initialDelaySeconds` | Liveness initial delay | `60` |
| `probes.liveness.periodSeconds` | Liveness period | `30` |
| `probes.liveness.httpHeaders` | Liveness HTTP headers | Host matching ingress |
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `probes.readiness.path` | Readiness probe path | `/api/ping` |
| `probes.readiness.initialDelaySeconds` | Readiness initial delay | `30` |
| `probes.readiness.periodSeconds` | Readiness period | `10` |
| `probes.readiness.httpHeaders` | Readiness HTTP headers | Host matching ingress |

### Autoscaling Parameters

| Name | Description | Default |
|------|-------------|---------|
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Min replicas | `1` |
| `autoscaling.maxReplicas` | Max replicas | `3` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU | `80` |
| `autoscaling.targetMemoryUtilizationPercentage` | Target memory | `80` |

## Troubleshooting

### Health Check Failures / "No Available Server"

Health checks require the correct `Host` header matching your ingress domain:

```yaml
probes:
  liveness:
    httpHeaders:
      - name: Host
        value: your-joplin-domain.com
  readiness:
    httpHeaders:
      - name: Host
        value: your-joplin-domain.com
```

### Database Connection Issues

Verify PostgreSQL credentials, network connectivity, and that `env.APP_BASE_URL` matches your ingress host.

### Origin Validation Errors

Ensure `env.APP_BASE_URL` matches your ingress hostname exactly.

### Debugging

```bash
kubectl logs -f deployment/joplin-server
kubectl describe pod -l app.kubernetes.io/name=joplin-server
```

## Links

- [Joplin GitHub](https://github.com/laurent22/joplin)
- [Chart Source](https://github.com/rtomik/helm-charts/tree/main/charts/joplin-server)
