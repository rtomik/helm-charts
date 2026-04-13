# Donetick Helm Chart

A Helm chart for deploying [Donetick](https://github.com/donetick/donetick) on Kubernetes.

## Introduction

This chart deploys Donetick, a task management application, on a Kubernetes cluster using the Helm package manager. Donetick supports SQLite or PostgreSQL databases, real-time updates via WebSockets, OAuth2 authentication, and push notifications via Telegram and Pushover.

Source code: https://github.com/rtomik/helm-charts/tree/main/charts/donetick

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (if persistence is needed)

## Installing the Chart

```bash
helm repo add rtomik https://rtomik.github.io/helm-charts
helm install donetick rtomik/donetick
```

## Uninstalling the Chart

```bash
helm uninstall donetick
```

## Configuration Examples

### Minimal Installation (SQLite)

The chart works out of the box with SQLite — no additional configuration required:

```bash
helm install donetick rtomik/donetick
```

### PostgreSQL Configuration

```yaml
config:
  database:
    type: "postgres"
    host: "postgresql.database.svc.cluster.local"
    port: 5432
    name: "donetick"
    secrets:
      existingSecret: "donetick-postgres-secret"
      userKey: "username"
      passwordKey: "password"

  jwt:
    secret: "your-secure-jwt-secret-at-least-32-characters-long"

  server:
    cors_allow_origins:
      - "https://your-domain.com"

  features:
    notifications: true
    realtime: true

ingress:
  enabled: true
  hosts:
    - host: donetick.your-domain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - donetick.your-domain.com

persistence:
  enabled: true
  size: "5Gi"
```

### Production with Existing Secrets

```yaml
config:
  database:
    type: "postgres"
    host: "postgresql.database.svc.cluster.local"
    port: 5432
    name: "donetick"
    secrets:
      existingSecret: "donetick-postgres-secret"
      userKey: "username"
      passwordKey: "password"

  jwt:
    existingSecret: "donetick-jwt-secret"
    secretKey: "jwtSecret"
    session_time: "168h"

  oauth2:
    existingSecret: "donetick-oauth-secret"
    clientIdKey: "client-id"
    clientSecretKey: "client-secret"
    auth_url: "https://your-oauth-provider.com/auth"
    token_url: "https://your-oauth-provider.com/token"
    user_info_url: "https://your-oauth-provider.com/userinfo"
    redirect_url: "https://donetick.your-domain.com/auth/callback"

  server:
    cors_allow_origins:
      - "https://donetick.your-domain.com"
    rate_limit: 100
    rate_period: "60s"

  features:
    notifications: true
    realtime: true
    oauth: true

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi

ingress:
  enabled: true
  hosts:
    - host: donetick.your-domain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - donetick.your-domain.com
```

Create the required secrets:

```bash
kubectl create secret generic donetick-postgres-secret \
  --from-literal=username='donetick' \
  --from-literal=password='your-secure-db-password'

kubectl create secret generic donetick-jwt-secret \
  --from-literal=jwtSecret='your-very-secure-jwt-secret-at-least-32-characters-long'

kubectl create secret generic donetick-oauth-secret \
  --from-literal=client-id='your-oauth-client-id' \
  --from-literal=client-secret='your-oauth-client-secret'
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
| `image.repository` | Donetick image repository | `donetick/donetick` |
| `image.tag` | Image tag | `v0.1.60` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |

### Deployment Parameters

| Name | Description | Default |
|------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `revisionHistoryLimit` | Revisions to retain | `3` |
| `startupArgs` | Optional startup arguments | `[]` |
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
| `service.port` | Service port | `2021` |
| `service.annotations` | Service annotations | `{}` |

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
| `persistence.enabled` | Enable persistence | `false` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.size` | PVC size | `1Gi` |
| `persistence.annotations` | PVC annotations | `{}` |

### Database Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.database.type` | Database type (`sqlite` or `postgres`) | `sqlite` |
| `config.database.migration` | Enable migrations | `true` |
| `config.database.migration_skip` | Skip migrations | `false` |
| `config.database.migration_retry` | Migration retry count | `3` |
| `config.database.migration_timeout` | Migration timeout | `600s` |
| `config.database.host` | PostgreSQL host | `""` |
| `config.database.port` | PostgreSQL port | `5432` |
| `config.database.name` | PostgreSQL database name | `""` |
| `config.database.secrets.existingSecret` | Existing secret for credentials | `""` |
| `config.database.secrets.userKey` | Key for username in secret | `username` |
| `config.database.secrets.passwordKey` | Key for password in secret | `password` |

### JWT Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.jwt.secret` | JWT signing secret (min 32 chars) | `changeme-...` |
| `config.jwt.session_time` | Session duration | `168h` |
| `config.jwt.max_refresh` | Max refresh duration | `168h` |
| `config.jwt.existingSecret` | Existing secret for JWT | `""` |
| `config.jwt.secretKey` | Key in secret | `jwtSecret` |

### Server Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.server.port` | Server port | `2021` |
| `config.server.read_timeout` | Read timeout | `10s` |
| `config.server.write_timeout` | Write timeout | `10s` |
| `config.server.rate_period` | Rate limiting period | `60s` |
| `config.server.rate_limit` | Rate limit per period | `300` |
| `config.server.serve_frontend` | Serve frontend files | `true` |
| `config.server.cors_allow_origins` | CORS allowed origins | See values.yaml |

### OAuth2 Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.oauth2.client_id` | OAuth2 client ID | `""` |
| `config.oauth2.client_secret` | OAuth2 client secret | `""` |
| `config.oauth2.existingSecret` | Existing secret for credentials | `""` |
| `config.oauth2.clientIdKey` | Key for client ID in secret | `client-id` |
| `config.oauth2.clientSecretKey` | Key for client secret in secret | `client-secret` |
| `config.oauth2.auth_url` | Authorization URL | `""` |
| `config.oauth2.token_url` | Token URL | `""` |
| `config.oauth2.user_info_url` | User info URL | `""` |
| `config.oauth2.redirect_url` | Redirect URL | `""` |

### Real-time Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.realtime.max_connections` | Max WebSocket connections | `100` |
| `config.realtime.ping_interval` | Ping interval | `30s` |
| `config.realtime.pong_wait` | Pong wait timeout | `60s` |
| `config.realtime.write_wait` | Write timeout | `10s` |
| `config.realtime.max_message_size` | Max message size | `512` |

### Notification Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.telegram.token` | Telegram bot token | `""` |
| `config.pushover.token` | Pushover token | `""` |

### Feature Flags

| Name | Description | Default |
|------|-------------|---------|
| `config.features.notifications` | Enable notifications | `true` |
| `config.features.realtime` | Enable real-time features | `true` |
| `config.features.oauth` | Enable OAuth | `false` |
| `config.is_user_creation_disabled` | Disable user registration | `false` |

### Resource Parameters

| Name | Description | Default |
|------|-------------|---------|
| `resources` | Resource limits and requests | `{}` |

### Health Check Parameters

| Name | Description | Default |
|------|-------------|---------|
| `probes.startup.enabled` | Enable startup probe | `true` |
| `probes.startup.path` | Startup probe path | `/health` |
| `probes.startup.initialDelaySeconds` | Startup initial delay | `30` |
| `probes.startup.periodSeconds` | Startup period | `15` |
| `probes.startup.failureThreshold` | Startup failure threshold | `80` |
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.liveness.path` | Liveness probe path | `/health` |
| `probes.liveness.initialDelaySeconds` | Liveness initial delay | `30` |
| `probes.liveness.periodSeconds` | Liveness period | `10` |
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `probes.readiness.path` | Readiness probe path | `/health` |
| `probes.readiness.initialDelaySeconds` | Readiness initial delay | `5` |
| `probes.readiness.periodSeconds` | Readiness period | `5` |

### Autoscaling Parameters

| Name | Description | Default |
|------|-------------|---------|
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Min replicas | `1` |
| `autoscaling.maxReplicas` | Max replicas | `5` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU | `80` |
| `autoscaling.targetMemoryUtilizationPercentage` | Target memory | `80` |

## Troubleshooting

### Real-time Configuration Panic

**Error**: `Invalid real-time configuration: maxConnections must be positive, got 0`

Ensure `config.realtime.max_connections` is set to a positive value (default: `100`).

### Database Connection Issues

- Verify PostgreSQL is running and accessible
- Check database credentials in secrets
- Ensure the database exists
- Verify network policies allow the connection

### JWT Authentication Failures

Ensure `config.jwt.secret` is at least 32 characters long. For production, use `config.jwt.existingSecret`.

### CORS Issues

Add your domain to `config.server.cors_allow_origins`:

```yaml
config:
  server:
    cors_allow_origins:
      - "https://your-domain.com"
```

### Debugging

```bash
kubectl logs deployment/donetick -f
kubectl get configmap donetick-configmap -o yaml
```

## Links

- [Donetick GitHub](https://github.com/donetick/donetick)
- [Chart Source](https://github.com/rtomik/helm-charts/tree/main/charts/donetick)
