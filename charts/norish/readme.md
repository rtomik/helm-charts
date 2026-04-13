# Norish Helm Chart

A Helm chart for deploying [Norish](https://github.com/norishapp/norish), a recipe management and meal planning application, on Kubernetes.

## Introduction

This chart deploys Norish on a Kubernetes cluster. Norish requires an external PostgreSQL database, a Redis server, and includes a Chrome headless sidecar for recipe parsing. It supports multiple authentication methods including password auth, OIDC, GitHub OAuth, and Google OAuth.

Source code: https://github.com/rtomik/helm-charts/tree/main/charts/norish

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- **PostgreSQL database** (required)
- **Redis server** (required)
- PV provisioner support (if persistence is enabled)

## Installing the Chart

```bash
helm repo add rtomik https://rtomik.github.io/helm-charts
helm install norish rtomik/norish
```

## Uninstalling the Chart

```bash
helm uninstall norish
```

## Configuration Examples

### Minimal Installation (Password Authentication)

```yaml
database:
  host: "postgresql.default.svc.cluster.local"
  port: 5432
  name: norish
  username: norish
  password: "secure-password"

redis:
  host: "redis.default.svc.cluster.local"
  port: 6379
  database: 0

config:
  authUrl: "https://norish.example.com"
  masterKey:
    value: "<your-32-byte-base64-key>"  # Generate: openssl rand -base64 32

ingress:
  enabled: true
  hosts:
    - host: norish.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - norish.example.com
```

### Production with Existing Secrets

```yaml
database:
  host: "postgresql.default.svc.cluster.local"
  existingSecret: "norish-db-secret"
  usernameKey: "username"
  passwordKey: "password"

redis:
  existingSecret: "norish-redis-secret"
  urlKey: "redis-url"

config:
  authUrl: "https://norish.example.com"
  masterKey:
    existingSecret: "norish-master-key"
    secretKey: "master-key"
```

Create the required secrets:

```bash
kubectl create secret generic norish-db-secret \
  --from-literal=username="norish" \
  --from-literal=password="secure-db-password"

kubectl create secret generic norish-redis-secret \
  --from-literal=redis-url="redis://username:password@redis.default.svc.cluster.local:6379/0"

kubectl create secret generic norish-master-key \
  --from-literal=master-key="$(openssl rand -base64 32)"
```

### OIDC Authentication

```yaml
config:
  auth:
    oidc:
      enabled: true
      name: "Authentik"
      issuer: "https://auth.example.com/application/o/norish/"
      clientId: "<your-client-id>"
      clientSecret: "<your-client-secret>"
  # Optional: allow password auth alongside OIDC
  passwordAuthEnabled: "true"
```

### GitHub OAuth

1. Create a GitHub OAuth App at https://github.com/settings/developers
2. Set Authorization callback URL to: `https://norish.example.com/api/auth/callback/github`

```yaml
config:
  auth:
    github:
      enabled: true
      clientId: "<your-github-client-id>"
      clientSecret: "<your-github-client-secret>"
```

### Google OAuth

1. Create OAuth credentials at https://console.cloud.google.com/apis/credentials
2. Set Authorized redirect URI to: `https://norish.example.com/api/auth/callback/google`

```yaml
config:
  auth:
    google:
      enabled: true
      clientId: "<your-google-client-id>"
      clientSecret: "<your-google-client-secret>"
```

### Using Existing PVC

```yaml
persistence:
  enabled: true
  existingClaim: "my-existing-pvc"
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
| `image.repository` | Norish image repository | `norishapp/norish` |
| `image.tag` | Image tag | `v0.15.4-beta` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |

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
| `service.port` | Service port | `3000` |
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
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.existingClaim` | Use an existing PVC | `""` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.size` | PVC size | `5Gi` |
| `persistence.annotations` | PVC annotations | `{}` |

### Database Configuration (Required)

| Name | Description | Default |
|------|-------------|---------|
| `database.host` | PostgreSQL host | `""` |
| `database.port` | PostgreSQL port | `5432` |
| `database.name` | Database name | `norish` |
| `database.username` | Username | `postgres` |
| `database.password` | Password | `""` |
| `database.existingSecret` | Existing secret name | `""` |
| `database.usernameKey` | Key for username in secret | `username` |
| `database.passwordKey` | Key for password in secret | `password` |
| `database.databaseKey` | Key for database name in secret | `database` |
| `database.hostKey` | Key for host in secret | `""` |

### Redis Configuration (Required)

| Name | Description | Default |
|------|-------------|---------|
| `redis.host` | Redis host | `""` |
| `redis.port` | Redis port | `6379` |
| `redis.database` | Redis database number | `0` |
| `redis.username` | Redis username (6.0+) | `""` |
| `redis.password` | Redis password | `""` |
| `redis.existingSecret` | Existing secret name | `""` |
| `redis.urlKey` | Key for full Redis URL in secret | `redis-url` |
| `redis.passwordKey` | Key for password in secret | `password` |

### Application Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.authUrl` | Application URL (must match ingress) | `http://norish.domain.com` |
| `config.logLevel` | Log level (`trace`, `debug`, `info`, `warn`, `error`, `fatal`) | `""` |
| `config.trustedOrigins` | Additional trusted origins (comma-separated) | `""` |
| `config.passwordAuthEnabled` | Enable/disable password auth | `""` |
| `config.extraEnv` | Extra environment variables | `[]` |

### Master Key Configuration (Required)

| Name | Description | Default |
|------|-------------|---------|
| `config.masterKey.value` | 32-byte base64 encryption key | `""` |
| `config.masterKey.existingSecret` | Existing secret name | `""` |
| `config.masterKey.secretKey` | Key in secret | `master-key` |

Generate with: `openssl rand -base64 32`

### OIDC Authentication

| Name | Description | Default |
|------|-------------|---------|
| `config.auth.oidc.enabled` | Enable OIDC | `false` |
| `config.auth.oidc.name` | Provider display name | `MyAuth` |
| `config.auth.oidc.issuer` | OIDC issuer URL | `""` |
| `config.auth.oidc.clientId` | Client ID | `""` |
| `config.auth.oidc.clientSecret` | Client secret | `""` |
| `config.auth.oidc.wellKnown` | Well-known URL (optional) | `""` |
| `config.auth.oidc.existingSecret` | Existing secret name | `""` |
| `config.auth.oidc.clientIdKey` | Key for client ID in secret | `oidc-client-id` |
| `config.auth.oidc.clientSecretKey` | Key for client secret in secret | `oidc-client-secret` |

### GitHub OAuth

| Name | Description | Default |
|------|-------------|---------|
| `config.auth.github.enabled` | Enable GitHub OAuth | `false` |
| `config.auth.github.clientId` | Client ID | `""` |
| `config.auth.github.clientSecret` | Client secret | `""` |
| `config.auth.github.existingSecret` | Existing secret name | `""` |
| `config.auth.github.clientIdKey` | Key for client ID in secret | `github-client-id` |
| `config.auth.github.clientSecretKey` | Key for client secret in secret | `github-client-secret` |

### Google OAuth

| Name | Description | Default |
|------|-------------|---------|
| `config.auth.google.enabled` | Enable Google OAuth | `false` |
| `config.auth.google.clientId` | Client ID | `""` |
| `config.auth.google.clientSecret` | Client secret | `""` |
| `config.auth.google.existingSecret` | Existing secret name | `""` |
| `config.auth.google.clientIdKey` | Key for client ID in secret | `google-client-id` |
| `config.auth.google.clientSecretKey` | Key for client secret in secret | `google-client-secret` |

### Chrome Headless Parameters

| Name | Description | Default |
|------|-------------|---------|
| `chrome.enabled` | Enable Chrome sidecar | `true` |
| `chrome.image.repository` | Chrome image repository | `zenika/alpine-chrome` |
| `chrome.image.tag` | Chrome image tag | `latest` |
| `chrome.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `chrome.port` | Chrome debugging port | `9222` |
| `chrome.securityContext` | Chrome security context (requires root + SYS_ADMIN) | See values.yaml |
| `chrome.resources` | Chrome resource limits | `{}` |

### Resource Parameters

| Name | Description | Default |
|------|-------------|---------|
| `resources` | Resource limits and requests | `{}` |

### Health Check Parameters

| Name | Description | Default |
|------|-------------|---------|
| `probes.startup.enabled` | Enable startup probe | `true` |
| `probes.startup.initialDelaySeconds` | Startup initial delay | `10` |
| `probes.startup.periodSeconds` | Startup period | `10` |
| `probes.startup.failureThreshold` | Startup failure threshold | `30` |
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.liveness.initialDelaySeconds` | Liveness initial delay | `30` |
| `probes.liveness.periodSeconds` | Liveness period | `10` |
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `probes.readiness.initialDelaySeconds` | Readiness initial delay | `5` |
| `probes.readiness.periodSeconds` | Readiness period | `5` |

## Upgrading

### From v0.13.x to v0.14.x

**Breaking change**: Redis is now required. Configure Redis before upgrading (see [Redis Configuration](#redis-configuration-required)).

### From v0.14.x to v0.15.x

No configuration changes required. Redis, PostgreSQL, and Chrome headless are already configured. Back up your database before upgrading as a precaution.

## Troubleshooting

- **Master Key Not Set**: Generate with `openssl rand -base64 32`
- **Login Failures**: Password auth is enabled by default when no OAuth/OIDC is configured. Verify callback URLs match your ingress hostname.
- **Database Connection Failed**: Verify host, credentials, and that the database exists.
- **Chrome Headless Issues**: Chrome requires `SYS_ADMIN` capability and 256Mi-512Mi memory. Check logs with `kubectl logs -l app.kubernetes.io/name=norish -c chrome-headless`
- **Recipe Parsing Failures**: Ensure Chrome is running. `CHROME_WS_ENDPOINT` is automatically configured by the chart.

```bash
kubectl get pods -l app.kubernetes.io/name=norish
kubectl logs -l app.kubernetes.io/name=norish
```

## Links

- [Norish GitHub](https://github.com/norishapp/norish)
- [Chart Source](https://github.com/rtomik/helm-charts/tree/main/charts/norish)
