# Joplin Server Helm Chart

A Helm chart for deploying Joplin Server on Kubernetes - Note-taking and synchronization server.

## Introduction

This chart deploys [Joplin Server](https://github.com/laurent22/joplin) on a Kubernetes cluster using the Helm package manager. Joplin Server is the synchronization server for Joplin, allowing you to sync your notes across devices.

Source code can be found here:
- https://github.com/rtomik/helm-charts/tree/main/charts/joplin-server

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- **External PostgreSQL database** (Required - Joplin Server does not support SQLite in production)
- PV provisioner support in the underlying infrastructure (if persistence is needed for file storage)

## Installing the Chart

To install the chart with the release name `joplin-server`:

```bash
$ helm repo add joplin-chart https://rtomik.github.io/helm-charts
$ helm install joplin-server joplin-chart/joplin-server
```

> **Important**: You must configure PostgreSQL database settings before installation.

## Uninstalling the Chart

To uninstall/delete the `joplin-server` deployment:

```bash
$ helm uninstall joplin-server
```

## Parameters

### Global parameters

| Name                   | Description                                    | Value |
|------------------------|------------------------------------------------|-------|
| `nameOverride`         | String to partially override the release name | `""`  |
| `fullnameOverride`     | String to fully override the release name     | `""`  |

### Image parameters

| Name                    | Description                       | Value              |
|-------------------------|-----------------------------------|--------------------|
| `image.repository`      | Joplin Server image repository    | `joplin/server`    |
| `image.tag`             | Joplin Server image tag           | `latest`           |
| `image.pullPolicy`      | Joplin Server image pull policy   | `IfNotPresent`     |

### Deployment parameters

| Name                                 | Description                                   | Value     |
|--------------------------------------|-----------------------------------------------|-----------|
| `replicaCount`                       | Number of Joplin Server replicas             | `1`       |
| `revisionHistoryLimit`               | Number of revisions to retain for rollback   | `3`       |
| `podSecurityContext.runAsNonRoot`    | Run containers as non-root user               | `true`    |
| `podSecurityContext.runAsUser`       | User ID for the container                     | `1001`    |
| `podSecurityContext.fsGroup`         | Group ID for the container filesystem        | `1001`    |
| `containerSecurityContext`           | Security context for the container           | See values.yaml |
| `nodeSelector`                       | Node labels for pod assignment               | `{}`      |
| `tolerations`                        | Tolerations for pod assignment               | `[]`      |
| `affinity`                           | Affinity for pod assignment                  | `{}`      |

### Service parameters

| Name           | Description           | Value       |
|----------------|-----------------------|-------------|
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | Service HTTP port     | `22300`     |

### Ingress parameters

| Name                    | Description                               | Value           |
|-------------------------|-------------------------------------------|-----------------|
| `ingress.enabled`       | Enable ingress record generation          | `false`         |
| `ingress.className`     | IngressClass name                         | `""`            |
| `ingress.annotations`   | Additional annotations for the Ingress    | See values.yaml |
| `ingress.hosts`         | Array of host and path objects            | See values.yaml |
| `ingress.tls`           | TLS configuration                         | See values.yaml |

### Environment variables

| Name                      | Description                                   | Value                    |
|---------------------------|-----------------------------------------------|--------------------------|
| `env.APP_PORT`            | Application port                              | `22300`                  |
| `env.APP_BASE_URL`        | Base URL for the application                  | `http://localhost:22300` |
| `env.DB_CLIENT`           | Database client (always pg for PostgreSQL)   | `pg`                     |

### PostgreSQL configuration (Required)

| Name                                   | Description                                   | Value     |
|----------------------------------------|-----------------------------------------------|-----------|
| `postgresql.external.enabled`          | Use external PostgreSQL database (required)  | `true`    |
| `postgresql.external.host`             | PostgreSQL host                              | `""`      |
| `postgresql.external.port`             | PostgreSQL port                              | `5432`    |
| `postgresql.external.database`         | PostgreSQL database name                     | `joplin`  |
| `postgresql.external.user`             | PostgreSQL username                          | `joplin`  |
| `postgresql.external.password`         | PostgreSQL password                          | `""`      |
| `postgresql.external.existingSecret`   | Name of existing secret with PostgreSQL credentials | `""`      |
| `postgresql.external.userKey`          | Key in the secret for username               | `username` |
| `postgresql.external.passwordKey`      | Key in the secret for password               | `password` |
| `postgresql.external.hostKey`          | Key in the secret for host (optional)        | `""`      |
| `postgresql.external.portKey`          | Key in the secret for port (optional)        | `""`      |
| `postgresql.external.databaseKey`      | Key in the secret for database name (optional) | `""`      |

### Joplin Server Configuration

#### Admin Settings

| Name                                   | Description                                   | Value     |
|----------------------------------------|-----------------------------------------------|-----------|
| `joplin.admin.email`                   | First admin user email                        | `""`      |
| `joplin.admin.password`                | First admin user password                     | `""`      |
| `joplin.admin.existingSecret`          | Name of existing secret with admin credentials | `""`      |
| `joplin.admin.emailKey`                | Key in the secret for admin email            | `admin-email` |
| `joplin.admin.passwordKey`             | Key in the secret for admin password         | `admin-password` |

#### Server Settings

| Name                                      | Description                                   | Value     |
|-------------------------------------------|-----------------------------------------------|-----------|
| `joplin.server.maxRequestBodySize`       | Maximum request body size                     | `200mb`   |
| `joplin.server.sessionTimeout`           | Session timeout in seconds                    | `86400`   |
| `joplin.server.enableUserRegistration`   | Enable/disable user registration              | `false`   |
| `joplin.server.enableSharing`            | Enable/disable sharing                        | `true`    |
| `joplin.server.enablePublicNotes`        | Enable/disable public notes                   | `true`    |

#### Storage Settings

| Name                                      | Description                                   | Value        |
|-------------------------------------------|-----------------------------------------------|--------------|
| `joplin.storage.driver`                  | Storage driver (filesystem, s3, azure)       | `filesystem` |
| `joplin.storage.filesystemPath`          | Path for filesystem storage                   | `/var/lib/joplin` |

##### S3 Storage (Optional)

| Name                                        | Description                                 | Value     |
|---------------------------------------------|---------------------------------------------|-----------|
| `joplin.storage.s3.bucket`                 | S3 bucket name                              | `""`      |
| `joplin.storage.s3.region`                 | S3 region                                   | `""`      |
| `joplin.storage.s3.accessKeyId`            | S3 access key ID                            | `""`      |
| `joplin.storage.s3.secretAccessKey`        | S3 secret access key                        | `""`      |
| `joplin.storage.s3.endpoint`               | S3 endpoint (for S3-compatible services)    | `""`      |
| `joplin.storage.s3.existingSecret`         | Name of existing secret with S3 credentials | `""`      |
| `joplin.storage.s3.accessKeyIdKey`         | Key in the secret for access key ID         | `access-key-id` |
| `joplin.storage.s3.secretAccessKeyKey`     | Key in the secret for secret access key     | `secret-access-key` |

#### Email Settings (Optional)

| Name                                   | Description                                   | Value     |
|----------------------------------------|-----------------------------------------------|-----------|
| `joplin.email.enabled`                 | Enable email notifications                    | `false`   |
| `joplin.email.host`                    | SMTP host                                     | `""`      |
| `joplin.email.port`                    | SMTP port                                     | `587`     |
| `joplin.email.username`                | SMTP username                                 | `""`      |
| `joplin.email.password`                | SMTP password                                 | `""`      |
| `joplin.email.fromEmail`               | From email address                            | `""`      |
| `joplin.email.fromName`                | From name                                     | `Joplin Server` |
| `joplin.email.secure`                  | Use TLS/SSL                                   | `true`    |
| `joplin.email.existingSecret`          | Name of existing secret with email credentials | `""`      |
| `joplin.email.usernameKey`             | Key in the secret for SMTP username          | `email-username` |
| `joplin.email.passwordKey`             | Key in the secret for SMTP password          | `email-password` |

#### Logging Settings

| Name                           | Description                          | Value     |
|--------------------------------|--------------------------------------|-----------|
| `joplin.logging.level`         | Log level (error, warn, info, debug) | `info`    |
| `joplin.logging.target`        | Log target (console, file)           | `console` |

### Persistence settings (for filesystem storage)

| Name                          | Description                      | Value           |
|-------------------------------|----------------------------------|-----------------|
| `persistence.enabled`         | Enable persistence using PVC     | `true`          |
| `persistence.storageClass`    | PVC Storage Class                | `""`            |
| `persistence.accessMode`      | PVC Access Mode                  | `ReadWriteOnce` |
| `persistence.size`            | PVC Size                         | `10Gi`          |
| `persistence.annotations`     | Annotations for PVC              | `{}`            |

### Transcribe Service (Optional AI Transcription)

| Name                                      | Description                                   | Value        |
|-------------------------------------------|-----------------------------------------------|--------------|
| `transcribe.enabled`                      | Enable transcribe service                     | `false`      |
| `transcribe.image.repository`             | Transcribe image repository                   | `joplin/transcribe` |
| `transcribe.image.tag`                    | Transcribe image tag                          | `latest`     |
| `transcribe.image.pullPolicy`             | Transcribe image pull policy                  | `IfNotPresent` |
| `transcribe.api.key`                      | Shared secret between Joplin and Transcribe  | `""`         |
| `transcribe.api.existingSecret`           | Name of existing secret with transcribe API key | `""`         |
| `transcribe.api.keyName`                  | Key in the secret for transcribe API key     | `transcribe-api-key` |
| `transcribe.service.type`                 | Transcribe service type                       | `ClusterIP`  |
| `transcribe.service.port`                 | Transcribe service port                       | `4567`       |
| `transcribe.htr.imagesFolder`             | HTR images folder path                        | `/app/images` |

#### Transcribe Database (Separate from main database)

| Name                                        | Description                                 | Value       |
|---------------------------------------------|---------------------------------------------|-------------|
| `transcribe.database.host`                  | Transcribe database host                    | `""`        |
| `transcribe.database.port`                  | Transcribe database port                    | `5432`      |
| `transcribe.database.database`              | Transcribe database name                    | `transcribe` |
| `transcribe.database.user`                  | Transcribe database username                | `transcribe` |
| `transcribe.database.password`              | Transcribe database password                | `""`        |
| `transcribe.database.existingSecret`        | Name of existing secret with transcribe DB credentials | `""`        |
| `transcribe.database.userKey`               | Key in the secret for username              | `username`  |
| `transcribe.database.passwordKey`           | Key in the secret for password              | `password`  |

### Resource Configuration

| Name        | Description                          | Value |
|-------------|--------------------------------------|-------|
| `resources` | Resource limits and requests         | `{}`  |

### Health Checks

| Name                                      | Description                              | Value |
|-------------------------------------------|------------------------------------------|-------|
| `probes.liveness.enabled`                 | Enable liveness probe                    | `true` |
| `probes.liveness.initialDelaySeconds`     | Initial delay for liveness probe         | `60`   |
| `probes.liveness.periodSeconds`           | Period for liveness probe                | `30`   |
| `probes.liveness.timeoutSeconds`          | Timeout for liveness probe               | `10`   |
| `probes.liveness.failureThreshold`        | Failure threshold for liveness probe     | `3`    |
| `probes.liveness.successThreshold`        | Success threshold for liveness probe     | `1`    |
| `probes.liveness.path`                    | Path for liveness probe                  | `/api/ping` |
| `probes.liveness.httpHeaders`             | HTTP headers for liveness probe          | `[{"name": "Host", "value": "joplin.domain.com"}]` |
| `probes.readiness.enabled`                | Enable readiness probe                   | `true` |
| `probes.readiness.initialDelaySeconds`    | Initial delay for readiness probe        | `30`   |
| `probes.readiness.periodSeconds`          | Period for readiness probe               | `10`   |
| `probes.readiness.timeoutSeconds`         | Timeout for readiness probe              | `5`    |
| `probes.readiness.failureThreshold`       | Failure threshold for readiness probe    | `3`    |
| `probes.readiness.successThreshold`       | Success threshold for readiness probe    | `1`    |
| `probes.readiness.path`                   | Path for readiness probe                 | `/api/ping` |
| `probes.readiness.httpHeaders`            | HTTP headers for readiness probe         | `[{"name": "Host", "value": "joplin.domain.com"}]` |

### Autoscaling

| Name                                        | Description                              | Value   |
|---------------------------------------------|------------------------------------------|---------|
| `autoscaling.enabled`                       | Enable horizontal pod autoscaling        | `false` |
| `autoscaling.minReplicas`                   | Minimum number of replicas               | `1`     |
| `autoscaling.maxReplicas`                   | Maximum number of replicas               | `3`     |
| `autoscaling.targetCPUUtilizationPercentage`| Target CPU utilization percentage        | `80`    |
| `autoscaling.targetMemoryUtilizationPercentage`| Target memory utilization percentage     | `80`    |

### Security Settings

| Name                              | Description                          | Value   |
|-----------------------------------|--------------------------------------|---------|
| `security.httpsRedirect`          | Enable/disable HTTPS redirect        | `false` |
| `security.tls.enabled`            | Enable custom TLS certificate        | `false` |
| `security.tls.existingSecret`     | Name of existing secret with TLS cert| `""`    |
| `security.tls.certificateKey`     | Key in the secret for TLS certificate| `tls.crt` |
| `security.tls.privateKeyKey`      | Key in the secret for TLS private key| `tls.key` |

## Configuration Examples

### Basic Installation with PostgreSQL

```yaml
postgresql:
  external:
    enabled: true
    host: "postgresql.example.com"
    port: 5432
    database: "joplin"
    user: "joplin"
    password: "secure-password"

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

env:
  APP_BASE_URL: "https://joplin.example.com"

# IMPORTANT: Update health check host headers to match your domain
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
```

### Using Kubernetes Secrets

#### Full Secret Configuration
```yaml
postgresql:
  external:
    enabled: true
    existingSecret: "joplin-postgresql-secret"
    hostKey: "host"
    portKey: "port"
    databaseKey: "database"
    userKey: "username"
    passwordKey: "password"

joplin:
  admin:
    existingSecret: "joplin-admin-secret"
    emailKey: "email"
    passwordKey: "password"
```

#### Mixed Configuration (Host in values, credentials in secret)
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
    # hostKey, portKey, databaseKey left empty - using values above
```

### S3 Storage Configuration

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

### Email Notifications Setup

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

### Transcribe Service (AI Features)

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

## First-time Setup

1. **Configure PostgreSQL**: Ensure your PostgreSQL database is accessible and credentials are configured
2. **Admin User**: Set admin email/password or access the web interface to create the first admin user
3. **User Registration**: Configure whether users can self-register or admin approval is required
4. **Storage**: Choose between filesystem (requires persistence) or cloud storage (S3/Azure)

## Security Considerations

For production deployments:

1. Use external secrets for all sensitive information (database passwords, admin credentials, etc.)
2. Enable TLS/SSL for all communications
3. Configure proper RBAC and network policies
4. Use dedicated databases with proper access controls
5. Disable user registration if not needed
6. Use cloud storage for better scalability and backup

## Troubleshooting

Common issues and solutions:

1. **Health Check Issues / "No Available Server"**: 
   - Ensure `probes.*.httpHeaders` includes the correct Host header matching your domain
   - Health checks use `/api/ping` endpoint which requires proper host validation
   - Example fix:
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

2. **Database connection issues**: Verify PostgreSQL credentials and network connectivity
3. **Storage permissions**: Check filesystem permissions for persistent volumes
4. **First admin user**: If no admin configured, access the web interface to create one
5. **Transcribe issues**: Verify Docker socket access and separate database configuration
6. **Origin validation errors**: Make sure `env.APP_BASE_URL` matches your ingress host

For detailed troubleshooting, check the application logs:

```bash
kubectl logs -f deployment/joplin-server
```

Check pod status and events:
```bash
kubectl describe pod -l app.kubernetes.io/name=joplin-server
```

## Backing Up

- **Database**: Use PostgreSQL backup tools (pg_dump, etc.)
- **File Storage**: 
  - Filesystem: Backup the PVC data
  - S3: Files are already stored in S3 (ensure proper S3 backup policies)
- **Configuration**: Backup your Kubernetes secrets and config