# Norish Helm Chart

A Helm chart for deploying [Norish](https://github.com/norish-recipes/norish), a recipe management and meal planning application, on Kubernetes.

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

Set the redirect URI in your provider to:
`https://norish.example.com/api/auth/oauth2/callback/oidc`

Optionally map OIDC group claims to the admin role and to households:

```yaml
config:
  auth:
    oidc:
      enabled: true
      claimMapping:
        enabled: true
        scopes: "groups"
        groupsClaim: "groups"
        adminGroup: "norish_admin"
        householdGroupPrefix: "norish_household_"
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

### Adopting an Existing (non-Helm) Norish Install

Resource names are derived from the chart name, not the release name, so this chart always
creates `norish-secret` and `norish-uploads`. If you already run Norish from hand-written
manifests using those same names, point the chart at the existing objects instead of
letting it template new ones:

```yaml
config:
  masterKey:
    existingSecret: "norish-secret"   # reuse the existing key
    secretKey: "master-key"
persistence:
  existingClaim: "norish-uploads"
redis:
  existingSecret: "norish-secret"
  urlKey: "redis-url"
```

⚠️ **Never let a new `MASTER_KEY` be generated for an existing database.** The key derives
the encryption keys, so replacing it makes every previously encrypted value unreadable.
Helm refuses to adopt resources it does not own, but a GitOps tool configured to replace or
prune resources will not stop you — set `existingSecret` before the first sync.

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
| `image.tag` | Image tag | `v0.20.0-beta` |
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
| `config.enableRegistration` | Allow self-registration of new users | `""` |
| `config.uploadsDir` | Uploads directory / volume mount path (`UPLOADS_DIR`) | `/app/uploads` |
| `config.parserApiTimeoutMs` | Recipe parser API timeout in ms | `""` |
| `config.defaultLocale` | Instance default locale | `""` |
| `config.enabledLocales` | Comma-separated list of enabled locales (empty = all) | `""` |
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
| `config.auth.oidc.claimMapping.enabled` | Assign admin role / households from OIDC claims | `false` |
| `config.auth.oidc.claimMapping.scopes` | Extra scopes to request (comma-separated) | `""` |
| `config.auth.oidc.claimMapping.groupsClaim` | Claim containing user groups | `groups` |
| `config.auth.oidc.claimMapping.adminGroup` | Group granting the server admin role | `norish_admin` |
| `config.auth.oidc.claimMapping.householdGroupPrefix` | Prefix for household groups | `norish_household_` |

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
| `probes.startup.path` | Startup probe path | `/api/v1/health` |
| `probes.startup.initialDelaySeconds` | Startup initial delay | `10` |
| `probes.startup.periodSeconds` | Startup period | `10` |
| `probes.startup.failureThreshold` | Startup failure threshold | `30` |
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.liveness.path` | Liveness probe path (see [Upgrading](#upgrading) for why this is not the health endpoint) | `/` |
| `probes.liveness.initialDelaySeconds` | Liveness initial delay | `30` |
| `probes.liveness.periodSeconds` | Liveness period | `10` |
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `probes.readiness.path` | Readiness probe path | `/api/v1/health` |
| `probes.readiness.initialDelaySeconds` | Readiness initial delay | `5` |
| `probes.readiness.periodSeconds` | Readiness period | `5` |

## Upgrading

### From v0.13.x to v0.14.x

**Breaking change**: Redis is now required. Configure Redis before upgrading (see [Redis Configuration](#redis-configuration-required)).

### From v0.14.x to v0.15.x

No configuration changes required. Redis, PostgreSQL, and Chrome headless are already configured. Back up your database before upgrading as a precaution.

### From chart 0.0.5 to chart 0.0.6 (app v0.20.0-beta)

⚠️ **Back up your database and your uploads volume before upgrading.**

**Which app version were you on?** Chart 0.0.5 declared `appVersion: v0.15.4-beta` but
shipped `image.tag: v0.16.2-beta` in values.yaml, and the tag always wins. So unless you
pinned `image.tag` yourself, you were already running **v0.16.2-beta** and the two
v0.16.x data-loss items below have already happened to you — skip them. Chart 0.0.6 fixes
that mismatch: both `appVersion` and `image.tag` are now `v0.20.0-beta`.

**v0.16.0-beta — data loss (calendar) — only if you pinned `image.tag` to v0.15.x or older**
All calendar data is permanently deleted on upgrade. The calendar was rebuilt on a new
database schema and upstream provides no migration path. Recipes, groceries and planning
data outside the calendar are unaffected.

**v0.16.1-beta — data loss (custom units) — only if you pinned `image.tag` to v0.16.0 or older**
Custom UOM (unit of measure) data is wiped as part of the move to a locale-aware schema.
Custom units have to be re-created after the upgrade.

The remaining items apply to everyone upgrading from chart 0.0.5.

**v0.17.0-beta — image restructure**
Upstream migrated to a pnpm/Turborepo monorepo. The Docker image, its internal paths and
the package layout all changed. The image name is unchanged (`norishapp/norish`), and this
chart needs no value changes for it, but the release is explicitly flagged as
"back up your data before upgrading" by upstream.

**v0.18.0-beta — breaking: health endpoint moved**
The previous `/api/health` endpoint was removed; the endpoint is now `/api/v1/health`.
Verified on both versions: on v0.17.3-beta `/api/health` returns `{"status":"ok"}`, on
v0.20.0-beta it falls through to the auth redirect. Note that a removed API path returns a
**307 redirect**, not a 404 — so an HTTP probe or uptime check still pointing at
`/api/health` reports *success* while checking nothing at all. Repoint it explicitly.

This chart's probe defaults changed accordingly:

| Value | Old default | New default |
|-------|-------------|-------------|
| `probes.startup.path` | `/` | `/api/v1/health` |
| `probes.readiness.path` | `/` | `/api/v1/health` |
| `probes.liveness.path` | `/` | `/` (unchanged — see below) |

If you pinned these paths in your own values, update them. Any external uptime monitor or
ingress health check pointing at the old endpoint must be updated as well.

**Why liveness deliberately does not use the health endpoint.** Since v0.18.1-beta the
endpoint also reports database health, and it returns **503** when PostgreSQL is
unreachable — verified on a test cluster by scaling the database to zero. With liveness
pointed at it, the sequence is:

1. Six consecutive 503s fail the liveness probe and the kubelet restarts the container.
2. On restart the app runs its migrations, cannot reach the database, and exits 1.
3. The pod enters `CrashLoopBackOff`, so it stays down for the backoff interval even
   after the database comes back.

A short database blip therefore becomes a multi-minute outage. With liveness on `/` (which
returns a 307 redirect — a probe success) a running pod rides out a DB blip: readiness
still fails, so the pod is removed from the Service endpoints, and it serves again as soon
as the database returns, with no restart.

Note that the app cannot start at all without a reachable database, by design — it runs
migrations at boot and exits on failure. Liveness on the app root does not hide that; it
only avoids restarting a process that is alive and would otherwise recover on its own.

**v0.18.0-beta — recipe import pipeline**
Imports moved to the `recipe-scrapers` Python package. The Chrome headless sidecar is
still required (upstream still ships it and still lists `CHROME_WS_ENDPOINT` as a core
required setting), so leave `chrome.enabled: true`. Import timeouts can be tuned with the
new `config.parserApiTimeoutMs`.

**Migration path — tested**
The v0.17.3-beta → v0.20.0-beta upgrade was verified on a Kubernetes test cluster against
a schema created by v0.17.3-beta: migrations applied automatically at boot (31 → 40
applied migrations, 29 → 34 tables), with no manual steps and no errors. The app applies
migrations itself on startup; there is nothing to run by hand.

**v0.19.0-beta / v0.20.0-beta — no configuration changes**
Web app refresh (HeroUI v3, home screen, cooking mode), offline support, recipe
provenance and AI workflow improvements. Nothing to change in this chart.

**New chart values in this release** (all optional, all default to the previous behaviour):
`config.enableRegistration`, `config.uploadsDir`, `config.parserApiTimeoutMs`,
`config.defaultLocale`, `config.enabledLocales` and `config.auth.oidc.claimMapping.*`.

The Chrome sidecar also now passes `--disable-features=dbus`, matching the upstream Docker
Compose example.

## Troubleshooting

- **Master Key Not Set**: Generate with `openssl rand -base64 32`
- **Login Failures**: Password auth is enabled by default when no OAuth/OIDC is configured. Verify callback URLs match your ingress hostname.
- **Database Connection Failed**: Verify host, credentials, and that the database exists.
- **Chrome Headless Issues**: Chrome requires `SYS_ADMIN` capability and 256Mi-512Mi memory. Check logs with `kubectl logs -l app.kubernetes.io/name=norish -c chrome-headless`
- **Recipe Parsing Failures**: Ensure Chrome is running. `CHROME_WS_ENDPOINT` is automatically configured by the chart. Raise `config.parserApiTimeoutMs` if imports time out.
- **Pod Never Becomes Ready After Upgrade**: On v0.18.0+ the health endpoint is `/api/v1/health`. Probes still pointing at the old endpoint will fail. Check with `kubectl exec deploy/norish -c norish -- wget -qO- http://127.0.0.1:3000/api/v1/health` (use `127.0.0.1`, not `localhost` — that resolves to `::1` in the container and is refused). A healthy response reports `status`, `db.status`, the app version and the `recipe-scrapers` version.
- **CrashLoopBackOff With "Migration failed" / "Server startup failed"**: The app runs migrations at boot and exits if PostgreSQL is unreachable. Verify `database.host`, credentials and that the database exists; the pod recovers on its own once the database is reachable.

```bash
kubectl get pods -l app.kubernetes.io/name=norish
kubectl logs -l app.kubernetes.io/name=norish
```

## Links

- [Norish GitHub](https://github.com/norish-recipes/norish)
- [Norish Documentation](https://docs.norish.dev)
- [Norish Releases](https://github.com/norish-recipes/norish/releases)
- [Chart Source](https://github.com/rtomik/helm-charts/tree/main/charts/norish)
