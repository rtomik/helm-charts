# Paperless-ngx Helm Chart

A Helm chart for deploying Paperless-ngx document management system on Kubernetes.

## Introduction

This chart deploys [Paperless-ngx](https://github.com/paperless-ngx/paperless-ngx) on a Kubernetes cluster using the Helm package manager.

Paperless-ngx is a community-supported supercharged version of paperless: scan, index and archive all your physical documents.

Source code can be found here:
- https://github.com/rtomik/helm-charts/tree/main/charts/paperless-ngx

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure
- **External PostgreSQL database** (required)
- **External Redis server** (required)

## External Dependencies

This chart requires external PostgreSQL and Redis services. It does not deploy these dependencies to avoid resource conflicts on centralized servers.

### PostgreSQL Setup
Paperless-ngx requires PostgreSQL 11+ as its database backend. Ensure you have:
- A PostgreSQL database created for Paperless-ngx
- Database credentials configured in values.yaml or via secrets

### Redis Setup
Redis is required for background task processing. Ensure you have:
- A Redis server accessible from the cluster
- Connection details configured in values.yaml
- Optional: Redis authentication credentials (username/password)
- Optional: Redis key prefix for sharing one Redis server among multiple Paperless instances

The chart supports all Redis authentication methods:
- No authentication: `redis://host:port/database`
- Password only (requirepass): `redis://:password@host:port/database`
- Username and password (Redis 6.0+ ACL): `redis://username:password@host:port/database`

## Installing the Chart

To install the chart with the release name `paperless-ngx`:

```bash
$ helm repo add paperless-chart https://rtomik.github.io/helm-charts
$ helm install paperless-ngx paperless-chart/paperless-ngx
```

Or install directly from this repository:

```bash
$ git clone https://github.com/rtomik/helm-charts.git
$ cd helm-charts/charts/paperless-ngx
$ helm install paperless-ngx .
```

> **Tip**: List all releases using `helm list`

## Configuration

The following table lists the configurable parameters and their default values.

### Global Parameters

| Name                   | Description                                                                         | Value |
|------------------------|-------------------------------------------------------------------------------------|-------|
| `nameOverride`         | String to partially override the release name                                       | `""`  |
| `fullnameOverride`     | String to fully override the release name                                           | `""`  |

### Image Parameters

| Name                    | Description                                                                          | Value              |
|-------------------------|--------------------------------------------------------------------------------------|--------------------|
| `image.repository`      | Paperless-ngx image repository                                                      | `ghcr.io/paperless-ngx/paperless-ngx` |
| `image.tag`             | Paperless-ngx image tag                                                             | `latest`          |
| `image.pullPolicy`      | Paperless-ngx image pull policy                                                     | `IfNotPresent`     |

### External Dependencies

| Name                                   | Description                                                        | Value                                     |
|----------------------------------------|--------------------------------------------------------------------|-------------------------------------------|
| `postgresql.external.enabled`         | Enable external PostgreSQL configuration                          | `true`                                    |
| `postgresql.external.host`            | External PostgreSQL host                                           | `postgresql.default.svc.cluster.local`   |
| `postgresql.external.port`            | External PostgreSQL port                                           | `5432`                                    |
| `postgresql.external.database`        | External PostgreSQL database name                                  | `paperless`                               |
| `postgresql.external.username`        | External PostgreSQL username                                       | `paperless`                               |
| `postgresql.external.existingSecret`  | Existing secret with PostgreSQL credentials                        | `""`                                      |
| `postgresql.external.passwordKey`     | Key in existing secret for PostgreSQL password                     | `postgresql-password`                     |
| `redis.external.enabled`              | Enable external Redis configuration                                | `true`                                    |
| `redis.external.host`                 | External Redis host                                                | `redis.default.svc.cluster.local`        |
| `redis.external.port`                 | External Redis port                                                | `6379`                                    |
| `redis.external.database`             | External Redis database number                                     | `0`                                       |
| `redis.external.username`             | Redis username (Redis 6.0+ with ACL)                               | `""`                                      |
| `redis.external.password`             | Redis password (leave empty if no auth required)                   | `""`                                      |
| `redis.external.existingSecret`       | Existing secret with Redis credentials                             | `""`                                      |
| `redis.external.passwordKey`          | Key in existing secret for Redis password                          | `redis-password`                          |
| `redis.external.prefix`               | Prefix for Redis keys/channels (for multi-instance)                | `""`                                      |

### Security Configuration

| Name                                   | Description                                                        | Value               |
|----------------------------------------|--------------------------------------------------------------------|---------------------|
| `config.secretKey.existingSecret`      | Name of existing secret for Django secret key                     | `""`                |
| `config.secretKey.secretKey`           | Key in the existing secret for Django secret key                  | `secret-key`        |
| `config.admin.user`                    | Admin username to create on startup                               | `""`                |
| `config.admin.password`                | Admin password (use existingSecret for production)                | `""`                |
| `config.admin.email`                   | Admin email address                                                | `root@localhost`    |
| `config.admin.existingSecret`          | Name of existing secret for admin credentials                     | `""`                |

### Application Configuration

| Name                                   | Description                                                        | Value               |
|----------------------------------------|--------------------------------------------------------------------|---------------------|
| `config.url`                           | External URL for Paperless-ngx (e.g., https://paperless.domain.com) | `""`                |
| `config.allowedHosts`                  | Comma-separated list of allowed hosts                             | `*`                 |
| `config.timeZone`                      | Application timezone                                               | `UTC`               |
| `config.ocr.language`                  | OCR language (3-letter code)                                      | `eng`               |
| `config.ocr.mode`                      | OCR mode (skip, redo, force)                                      | `skip`              |
| `config.consumer.recursive`            | Enable recursive consumption directory watching                     | `false`             |
| `config.consumer.subdirsAsTags`        | Use subdirectory names as tags                                     | `false`             |

### Persistence Parameters

| Name                                   | Description                                                        | Value               |
|----------------------------------------|--------------------------------------------------------------------|---------------------|
| `persistence.data.enabled`            | Enable persistence for data directory                             | `true`              |
| `persistence.data.size`               | Size of data PVC                                                  | `1Gi`               |
| `persistence.data.existingClaim`      | Name of existing PVC to use for data directory                    | `""`                |
| `persistence.media.enabled`           | Enable persistence for media directory                            | `true`              |
| `persistence.media.size`              | Size of media PVC                                                 | `10Gi`              |
| `persistence.media.existingClaim`     | Name of existing PVC to use for media directory                   | `""`                |
| `persistence.consume.enabled`         | Enable persistence for consume directory                          | `true`              |
| `persistence.consume.size`            | Size of consume PVC                                               | `5Gi`               |
| `persistence.consume.existingClaim`   | Name of existing PVC to use for consume directory                 | `""`                |
| `persistence.export.enabled`          | Enable persistence for export directory                           | `true`              |
| `persistence.export.size`             | Size of export PVC                                                | `1Gi`               |
| `persistence.export.existingClaim`    | Name of existing PVC to use for export directory                  | `""`                |

### Service Parameters

| Name                       | Description                                          | Value       |
|----------------------------|------------------------------------------------------|-------------|
| `service.type`             | Kubernetes Service type                              | `ClusterIP` |
| `service.port`             | Service HTTP port                                    | `8000`      |

### Ingress Parameters

| Name                       | Description                                          | Value                |
|----------------------------|------------------------------------------------------|----------------------|
| `ingress.enabled`          | Enable ingress record generation                     | `false`              |
| `ingress.className`        | IngressClass name                                    | `""`                 |
| `ingress.annotations`      | Additional annotations for the Ingress resource      | See values.yaml      |
| `ingress.hosts`            | Array of host and path objects                       | See values.yaml      |
| `ingress.tls`              | TLS configuration                                    | See values.yaml      |

## Usage Examples

### Basic Installation

```bash
helm install paperless-ngx . \
  --set postgresql.external.host=my-postgres.example.com \
  --set postgresql.external.password=secretpassword \
  --set redis.external.host=my-redis.example.com
```

### Production Installation with External Secrets

```yaml
# values-production.yaml
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
  # External PostgreSQL connection details
  external:
    enabled: true
    host: "postgres-cluster-pooler.dbs.svc.cluster.local"
    port: 5432
    database: "paperless"
    username: "paperless"
    # Use existingSecret for credentials
    existingSecret: "paperless-db-credentials"
    passwordKey: "password"

redis:
  external:
    host: "redis.cache.svc.cluster.local"
    port: 6379
    database: 0
    # Use existingSecret for Redis credentials
    existingSecret: "paperless-redis-credentials"
    passwordKey: "password"
    # Optional: Use prefix to share Redis among multiple instances
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

```bash
helm install paperless-ngx . -f values-production.yaml
```

### Redis Authentication Examples

#### Redis with Password Only (requirepass)

```bash
helm install paperless-ngx . \
  --set redis.external.host=redis.example.com \
  --set redis.external.password=myredispassword
```

Or with existing secret:

```yaml
redis:
  external:
    host: "redis.example.com"
    existingSecret: "redis-auth-secret"
    passwordKey: "redis-password"
```

#### Redis with Username and Password (Redis 6.0+ ACL)

```bash
helm install paperless-ngx . \
  --set redis.external.host=redis.example.com \
  --set redis.external.username=paperless-user \
  --set redis.external.password=myredispassword
```

#### Multiple Paperless Instances on One Redis Server

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

## Security Considerations

1. **Use external secrets** for production deployments to store sensitive data like database passwords, Redis passwords, and the Django secret key.
2. **Set a proper PAPERLESS_URL** when exposing the application externally.
3. **Configure ALLOWED_HOSTS** to restrict which hosts can access the application.
4. **Use HTTPS** when exposing the application to the internet.
5. **Secure Redis**: Always use authentication (password or username/password) for Redis in production environments. Use `existingSecret` instead of plain text passwords.
6. **Container Security**: The container runs as root initially to allow s6-overlay to set up the runtime environment, then drops privileges to UID 1000. This is required for the Paperless-ngx Docker image to function properly.

## Volumes and Data

Paperless-ngx uses several directories:

- **Data directory**: Contains the search index, classification model, and SQLite database (if used)
- **Media directory**: Contains all uploaded documents and thumbnails
- **Consume directory**: Drop documents here for automatic processing
- **Export directory**: Used for document exports

All directories can be configured with separate PVCs and storage classes.

## Uninstalling the Chart

To uninstall/delete the `paperless-ngx` deployment:

```bash
helm uninstall paperless-ngx
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Contributing

Please feel free to contribute by opening issues or pull requests at:
https://github.com/rtomik/helm-charts

## License

This Helm chart is licensed under the MIT License.

## Links

- [Paperless-ngx Documentation](https://docs.paperless-ngx.com/)
- [Paperless-ngx GitHub Repository](https://github.com/paperless-ngx/paperless-ngx)
- [Docker Hub](https://hub.docker.com/r/ghcr.io/paperless-ngx/paperless-ngx)