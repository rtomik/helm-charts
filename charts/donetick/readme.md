# Donetick Helm Chart

A Helm chart for deploying the Donetick task management application on Kubernetes.

## Introduction

This chart deploys [Donetick](https://github.com/donetick/donetick) on a Kubernetes cluster using the Helm package manager. 

Source code can be found here:
- https://github.com/rtomik/helm-charts/tree/main/charts/donetick


## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (if persistence is needed)

## Installing the Chart

To install the chart with the release name `donetick`:

```bash
$ helm repo add donetick-chart https://rtomik.github.io/helm-charts
$ helm install donetick donetick-chart/donetick
```

> **Tip**: List all releases using `helm list`

## Configuration Examples

### Basic Installation with SQLite (Default)

```bash
helm install donetick donetick-chart/donetick
```

### Installation with External PostgreSQL

Create a values file for PostgreSQL configuration:

```yaml
# values-postgres.yaml
config:
  database:
    type: "postgres"
    host: "postgresql.database.svc.cluster.local"
    port: 5432
    user: "donetick"
    password: "your-secure-password"
    name: "donetick"
    migration: true

  # Update JWT secret for production
  jwt:
    secret: "your-secure-jwt-secret-at-least-32-characters-long"

  # Configure server settings
  server:
    cors_allow_origins:
      - "https://your-domain.com"
      - "http://localhost:5173"

  # Enable features as needed
  features:
    notifications: true
    realtime: true
    oauth: false

# Enable ingress for external access
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: donetick.your-domain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: donetick-tls
      hosts:
        - donetick.your-domain.com

# Configure persistence
persistence:
  enabled: true
  storageClass: "fast-ssd"
  size: "5Gi"
```

Install with PostgreSQL configuration:

```bash
helm install donetick donetick-chart/donetick -f values-postgres.yaml
```

### Production Installation with External Secrets

For production deployments, use Kubernetes secrets for sensitive data:

```yaml
# values-production.yaml
config:
  database:
    type: "postgres"
    host: "postgresql.database.svc.cluster.local"
    port: 5432
    user: "donetick"
    name: "donetick"
    # Use existing secret for database credentials
    existingSecret: "donetick-db-secret"
    passwordKey: "postgresql-password"

  # Use existing secret for JWT
  jwt:
    existingSecret: "donetick-jwt-secret"
    secretKey: "jwt-secret"
    session_time: "168h"
    max_refresh: "168h"

  # OAuth2 configuration with secrets
  oauth2:
    existingSecret: "donetick-oauth-secret"
    clientIdKey: "client-id"
    clientSecretKey: "client-secret"
    auth_url: "https://your-oauth-provider.com/auth"
    token_url: "https://your-oauth-provider.com/token"
    user_info_url: "https://your-oauth-provider.com/userinfo"
    redirect_url: "https://donetick.your-domain.com/auth/callback"

  # Production server settings
  server:
    cors_allow_origins:
      - "https://donetick.your-domain.com"
    rate_limit: 100
    rate_period: "60s"

  # Enable production features
  features:
    notifications: true
    realtime: true
    oauth: true

# Security context for production
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000

# Resource limits for production
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi

# Ingress with TLS
ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: donetick.your-domain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: donetick-tls
      hosts:
        - donetick.your-domain.com
```

Create the required secrets:

```bash
# Database secret
kubectl create secret generic donetick-db-secret \
  --from-literal=postgresql-password='your-secure-db-password'

# JWT secret
kubectl create secret generic donetick-jwt-secret \
  --from-literal=jwt-secret='your-very-secure-jwt-secret-at-least-32-characters-long'

# OAuth secret (if using OAuth)
kubectl create secret generic donetick-oauth-secret \
  --from-literal=client-id='your-oauth-client-id' \
  --from-literal=client-secret='your-oauth-client-secret'
```

Install with production configuration:

```bash
helm install donetick donetick-chart/donetick -f values-production.yaml
```

## Uninstalling the Chart

To uninstall/delete the `donetick` deployment:

```bash
helm uninstall donetick
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
| `image.tag`             | Donetick image tag                                                                  | `v0.1.60`          |
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

### Pod Configuration

| Name                       | Description                                          | Value       |
|----------------------------|------------------------------------------------------|-------------|
| `podAnnotations`           | Additional annotations for pods                      | `{}`        |

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
| `persistence.enabled`         | Enable persistence using PVC                         | `false`         |
| `persistence.storageClass`    | PVC Storage Class                                    | `""`            |
| `persistence.accessMode`      | PVC Access Mode                                      | `ReadWriteOnce` |
| `persistence.size`            | PVC Size                                             | `1Gi`           |

### Health Checks

| Name                                    | Description                                          | Value         |
|----------------------------------------|------------------------------------------------------|---------------|
| `probes.startup.enabled`               | Enable startup probe                                 | `true`        |
| `probes.startup.initialDelaySeconds`   | Initial delay for startup probe                      | `10`          |
| `probes.startup.periodSeconds`         | Period for startup probe                             | `10`          |
| `probes.startup.failureThreshold`      | Failure threshold for startup probe                  | `30`          |
| `probes.liveness.enabled`              | Enable liveness probe                                | `true`        |
| `probes.liveness.initialDelaySeconds`  | Initial delay for liveness probe                     | `30`          |
| `probes.liveness.periodSeconds`        | Period for liveness probe                            | `10`          |
| `probes.readiness.enabled`             | Enable readiness probe                               | `true`        |
| `probes.readiness.initialDelaySeconds` | Initial delay for readiness probe                    | `5`           |
| `probes.readiness.periodSeconds`       | Period for readiness probe                           | `5`           |

### Application Configuration

| Name                                    | Description                                          | Value         |
|----------------------------------------|------------------------------------------------------|---------------|
| `config.name`                          | Application name                                     | `selfhosted`  |
| `config.is_done_tick_dot_com`          | Enable donetick.com features                         | `false`       |
| `config.is_user_creation_disabled`     | Disable user registration                            | `false`       |

### Real-time Configuration

| Name                                    | Description                                          | Value         |
|----------------------------------------|------------------------------------------------------|---------------|
| `config.realtime.max_connections`      | Maximum WebSocket connections                        | `100`         |
| `config.realtime.ping_interval`        | WebSocket ping interval                              | `30s`         |
| `config.realtime.pong_wait`            | WebSocket pong wait timeout                          | `60s`         |
| `config.realtime.write_wait`           | WebSocket write timeout                              | `10s`         |
| `config.realtime.max_message_size`     | Maximum WebSocket message size                       | `512`         |

### Database Configuration

| Name                                    | Description                                          | Value         |
|----------------------------------------|------------------------------------------------------|---------------|
| `config.database.type`                 | Database type (sqlite or postgres)                   | `sqlite`      |
| `config.database.migration`            | Enable database migrations                           | `true`        |
| `config.database.host`                 | PostgreSQL host (when type=postgres)                 | `""`          |
| `config.database.port`                 | PostgreSQL port (when type=postgres)                 | `5432`        |
| `config.database.user`                 | PostgreSQL user (when type=postgres)                 | `""`          |
| `config.database.password`             | PostgreSQL password (when type=postgres)             | `""`          |
| `config.database.name`                 | PostgreSQL database name (when type=postgres)        | `""`          |

### JWT Configuration

| Name                                    | Description                                          | Value         |
|----------------------------------------|------------------------------------------------------|---------------|
| `config.jwt.secret`                    | JWT signing secret                                   | `changeme-this-secret-should-be-at-least-32-characters-long` |
| `config.jwt.session_time`              | JWT session duration                                 | `168h`        |
| `config.jwt.max_refresh`               | JWT maximum refresh duration                         | `168h`        |

### Server Configuration

| Name                                    | Description                                          | Value         |
|----------------------------------------|------------------------------------------------------|---------------|
| `config.server.port`                   | Server port                                          | `2021`        |
| `config.server.read_timeout`           | Server read timeout                                  | `10s`         |
| `config.server.write_timeout`          | Server write timeout                                 | `10s`         |
| `config.server.rate_period`            | Rate limiting period                                 | `60s`         |
| `config.server.rate_limit`             | Rate limiting requests per period                    | `300`         |
| `config.server.serve_frontend`         | Serve frontend files                                 | `true`        |

### Feature Flags

| Name                                    | Description                                          | Value         |
|----------------------------------------|------------------------------------------------------|---------------|
| `config.features.notifications`        | Enable notifications                                 | `true`        |
| `config.features.realtime`             | Enable real-time features                           | `true`        |
| `config.features.oauth`                | Enable OAuth authentication                         | `false`       |

## Database Setup

### PostgreSQL Requirements

When using PostgreSQL, ensure you have:

1. **Database Created**: Create a database for Donetick
```sql
CREATE DATABASE donetick;
CREATE USER donetick WITH PASSWORD 'your-secure-password';
GRANT ALL PRIVILEGES ON DATABASE donetick TO donetick;
```

2. **Network Access**: Ensure Donetick can reach your PostgreSQL instance
3. **Proper Credentials**: Configure database credentials in values or secrets

### Database Migration

Donetick automatically runs database migrations on startup when `config.database.migration: true`. For production:

1. **Review Migrations**: Check what migrations will be applied
2. **Backup Database**: Always backup before running migrations
3. **Monitor Startup**: Watch pod logs during initial deployment

## Troubleshooting

### Common Issues

#### 1. Real-time Configuration Panic
**Error**: `Invalid real-time configuration: maxConnections must be positive, got 0`

**Solution**: Ensure the real-time configuration is properly set:
```yaml
config:
  realtime:
    max_connections: 100  # Must be > 0
```

#### 2. Database Connection Issues
**Error**: Database connection failures

**Solutions**:
- Verify PostgreSQL is running and accessible
- Check database credentials in secrets
- Ensure database name exists
- Verify network policies allow connection

#### 3. JWT Secret Issues
**Error**: JWT authentication failures

**Solution**: Ensure JWT secret is at least 32 characters:
```yaml
config:
  jwt:
    secret: "your-very-secure-jwt-secret-at-least-32-characters-long"
```

#### 4. CORS Issues
**Error**: Cross-origin request blocked

**Solution**: Configure CORS origins:
```yaml
config:
  server:
    cors_allow_origins:
      - "https://your-domain.com"
      - "http://localhost:5173"
```

### Debugging

Check application logs:
```bash
kubectl logs deployment/donetick -f
```

Check configuration:
```bash
kubectl get configmap donetick-configmap -o yaml
```

Verify secrets:
```bash
kubectl get secret donetick-secrets -o yaml
```

## Contributing

Please feel free to contribute by opening issues or pull requests at:
https://github.com/rtomik/helm-charts

## License

This Helm chart is licensed under the MIT License.
