cl# Norish Helm Chart

A Helm chart for deploying [Norish](https://github.com/norishapp/norish), a recipe management and meal planning application, on Kubernetes.

## Introduction

This chart bootstraps a Norish deployment on a Kubernetes cluster using the Helm package manager.

**IMPORTANT: This chart requires a central PostgreSQL database.** You must have a PostgreSQL server available before deploying this chart. The chart does not include a PostgreSQL deployment.

**Note:** This chart includes a Chrome headless sidecar container that is required for recipe parsing and scraping functionality. Chrome requires elevated security privileges (`SYS_ADMIN` capability) and additional resources (recommend 256Mi-512Mi memory).

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- **PostgreSQL database server** (required)
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `norish`:

```bash
$ helm repo add helm-charts https://rtomik.github.io/helm-charts
$ helm install norish helm-charts/norish
```

The command deploys Norish on the Kubernetes cluster with default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `norish` deployment:

```bash
helm uninstall norish
```

This command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

### Required Configuration

Before deploying, you must configure:

1. **PostgreSQL Database** (REQUIRED): A central PostgreSQL database must be available
   - Configure `database.host` to point to your PostgreSQL server
   - Ensure the database exists before deployment
   - Set appropriate credentials

2. **Master Key**: A 32-byte base64-encoded encryption key
   ```bash
   # Generate a master key
   openssl rand -base64 32
   ```

3. **Application URL**: Set `config.authUrl` to match your ingress hostname

### Authentication Configuration

**Authentication providers are now optional!** You can deploy Norish in two ways:

**Option 1: Password Authentication (Simple Setup)**
- No external authentication provider required
- Users can register and log in with email/password
- Perfect for self-hosted, single-tenant deployments
- Enabled automatically when no OAuth/OIDC provider is configured

**Option 2: OAuth/OIDC Provider (Enterprise Setup)**
- Configure ONE of the following:
  - OIDC/OAuth2
  - GitHub OAuth
  - Google OAuth
- Recommended for multi-user environments
- Can be combined with password authentication via `config.passwordAuthEnabled`

### Example: Minimal Installation (Password Authentication)

This is the simplest setup using built-in password authentication:

```yaml
# values.yaml
database:
  host: "postgresql.default.svc.cluster.local"
  port: 5432
  name: norish
  username: norish
  password: "secure-password"

config:
  authUrl: "https://norish.example.com"
  masterKey:
    value: "<your-32-byte-base64-key>"
  # passwordAuthEnabled defaults to true when no OAuth/OIDC is configured

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

Install with:
```bash
$ helm repo add helm-charts https://rtomik.github.io/helm-charts
$ helm install norish helm-charts/norish -f values.yaml
```

### Example: Installation with OIDC

For enterprise deployments with an external identity provider:

```yaml
# values.yaml
database:
  host: "postgresql.default.svc.cluster.local"
  port: 5432
  name: norish
  username: norish
  password: "secure-password"

config:
  authUrl: "https://norish.example.com"
  masterKey:
    value: "<your-32-byte-base64-key>"
  # Optional: Allow both OIDC and password authentication
  passwordAuthEnabled: "true"
  auth:
    oidc:
      enabled: true
      name: "MyAuth"
      issuer: "https://auth.example.com"
      clientId: "<your-client-id>"
      clientSecret: "<your-client-secret>"

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

Install with:
```bash
$ helm repo add helm-charts https://rtomik.github.io/helm-charts
$ helm install norish helm-charts/norish -f values.yaml
```

### Example: Using Existing Secrets

For production deployments, store sensitive data in Kubernetes secrets:

```yaml
# values.yaml
database:
  host: "postgresql.default.svc.cluster.local"
  existingSecret: "norish-db-secret"
  usernameKey: "username"
  passwordKey: "password"

config:
  masterKey:
    existingSecret: "norish-master-key"
    secretKey: "master-key"
  auth:
    oidc:
      enabled: true
      name: "MyAuth"
      issuer: "https://auth.example.com"
      existingSecret: "norish-oidc-secret"
      clientIdKey: "client-id"
      clientSecretKey: "client-secret"
```

Create the secrets:
```bash
# Database credentials
kubectl create secret generic norish-db-secret \
  --from-literal=username="norish" \
  --from-literal=password="secure-db-password"

# Master encryption key
kubectl create secret generic norish-master-key \
  --from-literal=master-key="$(openssl rand -base64 32)"

# OIDC credentials
kubectl create secret generic norish-oidc-secret \
  --from-literal=client-id="<your-client-id>" \
  --from-literal=client-secret="<your-client-secret>"
```

### Example: Using Existing PVC

If you want to use an existing PersistentVolumeClaim for uploads storage:

```yaml
# values.yaml
persistence:
  enabled: true
  existingClaim: "my-existing-pvc"
```

This is useful when:
- You want to reuse storage from a previous installation
- You have pre-provisioned PVCs with specific configurations
- You're managing PVCs separately from the Helm chart

### Optional Configuration

Version v0.13.6-beta introduces additional optional configuration options:

```yaml
config:
  # Log level configuration
  logLevel: "info"  # Options: trace, debug, info, warn, error, fatal

  # Additional trusted origins (useful when behind a proxy or using multiple domains)
  trustedOrigins: "http://192.168.1.100:3000,https://norish.example.com"

  # Enable/disable password authentication
  # Defaults to true when no OAuth/OIDC is configured, false otherwise
  # Set to "true" to enable password auth alongside OAuth/OIDC
  passwordAuthEnabled: "true"

  auth:
    oidc:
      enabled: true
      name: "MyAuth"
      issuer: "https://auth.example.com"
      # Optional: Custom well-known configuration URL
      # By default derived from issuer
      wellKnown: "https://auth.example.com/.well-known/openid-configuration"
      clientId: "<your-client-id>"
      clientSecret: "<your-client-secret>"
```

### Customizing Chrome Headless Resources

Chrome headless is required but you can customize its resource limits:

```yaml
chrome:
  enabled: true  # Must be true for v0.13.6+
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 256Mi
```

### Setting Up PostgreSQL Database

You need to create the database before deploying this chart:

```sql
-- Connect to your PostgreSQL server
CREATE DATABASE norish;
CREATE USER norish WITH ENCRYPTED PASSWORD 'secure-password';
GRANT ALL PRIVILEGES ON DATABASE norish TO norish;
```

Or if using a centralized PostgreSQL Helm chart or service, ensure the database is created and accessible from your Kubernetes cluster.

## Parameters

### Global Parameters

| Name | Description | Default |
|------|-------------|---------|
| `nameOverride` | Override the chart name | `""` |
| `fullnameOverride` | Override the full resource names | `""` |

### Image Parameters

| Name | Description | Default |
|------|-------------|---------|
| `image.repository` | Norish image repository | `norishapp/norish` |
| `image.tag` | Norish image tag | `v0.13.6-beta` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |

### Deployment Parameters

| Name | Description | Default |
|------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `revisionHistoryLimit` | Number of old ReplicaSets to retain | `3` |

### Service Parameters

| Name | Description | Default |
|------|-------------|---------|
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `3000` |
| `service.annotations` | Service annotations | `{}` |

### Ingress Parameters

| Name | Description | Default |
|------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{"traefik.ingress.kubernetes.io/router.entrypoints": "websecure"}` |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |
| `ingress.tls` | Ingress TLS configuration | See values.yaml |

### Persistence Parameters

| Name | Description | Default |
|------|-------------|---------|
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.existingClaim` | Use an existing PVC instead of creating a new one | `""` |
| `persistence.storageClass` | Storage class name | `""` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.size` | Storage size | `5Gi` |
| `persistence.annotations` | PVC annotations | `{}` |

### Application Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.authUrl` | Application URL (required) | `"http://norish.domain.com"` |
| `config.masterKey.value` | Master encryption key | `""` |
| `config.masterKey.existingSecret` | Use existing secret for master key | `""` |
| `config.logLevel` | Log level: trace, debug, info, warn, error, fatal | `""` |
| `config.trustedOrigins` | Additional trusted origins (comma-separated) | `""` |
| `config.passwordAuthEnabled` | Enable/disable password authentication (defaults to true when no OAuth/OIDC configured) | `""` |
| `config.auth.oidc.enabled` | Enable OIDC authentication | `false` |
| `config.auth.oidc.name` | OIDC provider name | `"MyAuth"` |
| `config.auth.oidc.issuer` | OIDC issuer URL | `""` |
| `config.auth.oidc.wellKnown` | OIDC well-known configuration URL (optional) | `""` |
| `config.auth.oidc.clientId` | OIDC client ID | `""` |
| `config.auth.oidc.clientSecret` | OIDC client secret | `""` |
| `config.auth.github.enabled` | Enable GitHub OAuth | `false` |
| `config.auth.github.clientId` | GitHub client ID | `""` |
| `config.auth.github.clientSecret` | GitHub client secret | `""` |
| `config.auth.google.enabled` | Enable Google OAuth | `false` |
| `config.auth.google.clientId` | Google client ID | `""` |
| `config.auth.google.clientSecret` | Google client secret | `""` |

### Database Parameters (REQUIRED)

| Name | Description | Default |
|------|-------------|---------|
| `database.host` | PostgreSQL database host (required) | `""` |
| `database.port` | PostgreSQL database port | `5432` |
| `database.name` | PostgreSQL database name | `norish` |
| `database.username` | PostgreSQL username | `postgres` |
| `database.password` | PostgreSQL password | `""` |
| `database.existingSecret` | Use existing secret for database credentials | `""` |
| `database.usernameKey` | Key in secret for username | `"username"` |
| `database.passwordKey` | Key in secret for password | `"password"` |
| `database.databaseKey` | Key in secret for database name | `"database"` |
| `database.hostKey` | Key in secret for host | `"host"` |

### Chrome Headless Parameters (REQUIRED)

| Name | Description | Default |
|------|-------------|---------|
| `chrome.enabled` | Enable Chrome headless sidecar (required for v0.13.6+) | `true` |
| `chrome.image.repository` | Chrome headless image repository | `zenika/alpine-chrome` |
| `chrome.image.tag` | Chrome headless image tag | `latest` |
| `chrome.image.pullPolicy` | Chrome image pull policy | `IfNotPresent` |
| `chrome.port` | Chrome remote debugging port | `3000` |
| `chrome.resources` | Chrome container resource limits/requests | `{}` |

### Security Parameters

| Name | Description | Default |
|------|-------------|---------|
| `podSecurityContext.runAsNonRoot` | Run as non-root user | `true` |
| `podSecurityContext.runAsUser` | User ID to run as | `1000` |
| `podSecurityContext.fsGroup` | Group ID for filesystem | `1000` |

### Resource Parameters

| Name | Description | Default |
|------|-------------|---------|
| `resources` | CPU/Memory resource requests/limits | `{}` |

### Health Check Parameters

| Name | Description | Default |
|------|-------------|---------|
| `probes.startup.enabled` | Enable startup probe | `true` |
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.readiness.enabled` | Enable readiness probe | `true` |

## What's New in v0.13.6-beta

This version introduces several improvements and new features:

**UI/UX Improvements:**
- Ability to change prompts used in Settings → Admin
- Improved transcriber logic
- Double tapping/clicking planned recipes now opens the recipe page
- Small icon that opens the original recipe page
- Add recipes button now opens a dropdown instead of instantly redirecting to manual creation

**New Features:**
- Support for trusting additional origins using `TRUSTED_ORIGINS` environment variable (comma-separated)
- Customizable password authentication via `PASSWORD_AUTH_ENABLED` flag
- Configurable log level via `NEXT_PUBLIC_LOG_LEVEL`

**Bug Fixes:**
- User menu remaining open when clicking import
- Text truncation no longer uses the tailwind truncate class in the calendar
- Comma decimals being parsed as nothing (e.g., 2,5 ended up as 25)
- Unicode character handling

**Breaking Changes:**
- Chrome headless is now mandatory for improved parsing functionality

## Authentication Setup

Norish v0.13.6-beta and later support multiple authentication methods:

### Password Authentication (Default)

When no external authentication provider is configured, Norish automatically enables password-based authentication. Users can:
- Register new accounts with email and password
- Log in using their credentials
- Manage their account through the web interface

This is the simplest setup and perfect for:
- Self-hosted, single-user or family deployments
- Testing and development environments
- Scenarios where external OAuth providers are not needed

### External Authentication Providers (Optional)

For enterprise or multi-tenant deployments, you can configure external authentication providers. After configuring a provider, you can manage additional authentication methods through the Settings → Admin interface.

### OIDC/OAuth2

```yaml
config:
  auth:
    oidc:
      enabled: true
      name: "Authentik"  # Display name
      issuer: "https://auth.example.com/application/o/norish/"
      clientId: "<your-client-id>"
      clientSecret: "<your-client-secret>"
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

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=norish
kubectl logs -l app.kubernetes.io/name=norish
```

### Check Database Connection

```bash
# Test connection from app pod
kubectl exec -it deployment/norish -- sh
nc -zv <your-postgres-host> 5432
```

### Common Issues

1. **Master Key Not Set**: Ensure you've generated and configured a master key
2. **Cannot Log In**:
   - Password authentication is enabled by default when no OAuth/OIDC is configured
   - If you configured an external provider, ensure the client ID/secret are correct
   - Check the callback URL matches your ingress hostname
3. **Database Connection Failed**:
   - Verify database host is correct and accessible from the cluster
   - Check database credentials
   - Ensure the database exists
   - Verify network policies allow connections to the database
4. **Application Not Accessible**: Verify ingress configuration and DNS records
5. **Chrome Headless Issues**:
   - Chrome requires `SYS_ADMIN` capability for proper operation
   - If pod fails to start, check if your cluster's security policies allow the required capabilities
   - Chrome container may require additional memory (256Mi-512Mi recommended)
   - Check Chrome container logs: `kubectl logs -l app.kubernetes.io/name=norish -c chrome-headless`
6. **Recipe Parsing Failures**:
   - Ensure Chrome headless is running: `kubectl get pods -l app.kubernetes.io/name=norish`
   - Verify `CHROME_WS_ENDPOINT` is set correctly (automatically configured by the chart)
   - Check if Chrome is accessible from the Norish container

## Upgrading

To upgrade the chart:

```bash
$ helm upgrade norish helm-charts/norish -f values.yaml
```

## Support

- Norish Repository: https://github.com/norishapp/norish
- Chart Repository: https://github.com/rtomik/helm-charts
- Issue Tracker: https://github.com/rtomik/helm-charts/issues

## License

This Helm chart is provided as-is under the same license as the Norish application.
