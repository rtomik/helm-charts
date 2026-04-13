# Tandoor Recipes Helm Chart

A Helm chart for deploying [Tandoor Recipes](https://github.com/TandoorRecipes/recipes), a recipe management application, on Kubernetes.

## Introduction

This chart deploys Tandoor Recipes on a Kubernetes cluster. Tandoor supports PostgreSQL databases, LDAP/OIDC authentication, S3 object storage, email notifications, AI features, and Food Data Central API integration for nutrition data.

Source code: https://github.com/rtomik/helm-charts/tree/main/charts/tandoor

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- **External PostgreSQL database** (required — this chart does not include PostgreSQL)
- PV provisioner support

## Installing the Chart

```bash
helm repo add rtomik https://rtomik.github.io/helm-charts
helm install tandoor rtomik/tandoor
```

## Uninstalling the Chart

```bash
helm uninstall tandoor
```

**Note**: PVCs are not deleted automatically. To remove them:

```bash
kubectl delete pvc -l app.kubernetes.io/name=tandoor
```

## Configuration Examples

### Minimal Installation

```yaml
postgresql:
  host: "postgresql.database.svc.cluster.local"
  database: "tandoor"
  username: "tandoor"
  password: "your-secure-password"

config:
  secretKey:
    value: "your-secret-key-at-least-50-characters-long-for-security-purposes"
```

### Production with Existing Secrets

```yaml
postgresql:
  host: "postgresql.database.svc.cluster.local"
  database: "tandoor"
  username: "tandoor"
  existingSecret: "tandoor-db-secret"
  passwordKey: "password"

config:
  secretKey:
    existingSecret: "tandoor-app-secret"
    secretKey: "secret-key"
  allowedHosts: "tandoor.example.com"
  csrfTrustedOrigins: "https://tandoor.example.com"
  timezone: "Europe/Berlin"

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: tandoor.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - tandoor.example.com
      secretName: tandoor-tls

persistence:
  staticfiles:
    enabled: true
    storageClass: "longhorn"
    size: 2Gi
  mediafiles:
    enabled: true
    storageClass: "longhorn"
    size: 10Gi

resources:
  limits:
    cpu: 1000m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 256Mi
```

### OIDC with Authentik

```yaml
config:
  oidc:
    enabled: true
    providerId: "authentik"
    providerName: "Authentik"
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
    serverUrl: "https://authentik.company/application/o/tandoor/.well-known/openid-configuration"
```

### S3 Object Storage

```yaml
config:
  s3:
    enabled: true
    bucketName: "tandoor-media"
    regionName: "us-east-1"
    endpointUrl: "https://minio.example.com"
    existingSecret: "tandoor-s3-secret"
```

### Email Configuration

```yaml
config:
  email:
    host: "smtp.example.com"
    port: 587
    useTls: true
    defaultFrom: "tandoor@example.com"
    existingSecret: "tandoor-email-secret"
    passwordKey: "email-password"
```

### LDAP Authentication

```yaml
config:
  ldap:
    enabled: true
    serverUri: "ldap://ldap.example.com"
    bindDn: "cn=admin,dc=example,dc=com"
    bindPassword: "bind-password"
    userSearchBaseDn: "ou=users,dc=example,dc=com"
    existingSecret: "tandoor-ldap-secret"
    bindPasswordKey: "ldap-bind-password"
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
| `image.repository` | Tandoor image repository | `vabene1111/recipes` |
| `image.tag` | Image tag | `2.3.5` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Deployment Parameters

| Name | Description | Default |
|------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `revisionHistoryLimit` | Revisions to retain | `3` |
| `podSecurityContext.fsGroup` | Filesystem group ID | `0` |
| `containerSecurityContext.runAsUser` | User ID | `0` |
| `containerSecurityContext.runAsGroup` | Group ID | `0` |
| `containerSecurityContext.allowPrivilegeEscalation` | Allow privilege escalation | `false` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |

### Service Parameters

| Name | Description | Default |
|------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |

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
| `postgresql.host` | PostgreSQL host | `postgresql.default.svc.cluster.local` |
| `postgresql.port` | PostgreSQL port | `5432` |
| `postgresql.database` | Database name | `tandoor` |
| `postgresql.username` | Username | `tandoor` |
| `postgresql.password` | Password | `""` |
| `postgresql.existingSecret` | Existing secret name | `""` |
| `postgresql.passwordKey` | Key for password in secret | `postgresql-password` |

### Security Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.secretKey.value` | Django secret key (min 50 chars) | `""` |
| `config.secretKey.existingSecret` | Existing secret for secret key | `""` |
| `config.secretKey.secretKey` | Key in secret | `secret-key` |
| `config.allowedHosts` | Allowed HTTP hosts | `*` |
| `config.csrfTrustedOrigins` | CSRF trusted origins | `""` |
| `config.corsAllowOrigins` | Allow all CORS origins | `false` |

### Server Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.tandoorPort` | Web server port | `8080` |
| `config.gunicornWorkers` | Gunicorn workers | `3` |
| `config.gunicornThreads` | Gunicorn threads per worker | `2` |
| `config.gunicornTimeout` | Gunicorn timeout (seconds) | `30` |
| `config.gunicornMedia` | Serve media via Gunicorn | `0` |
| `config.timezone` | Timezone | `UTC` |
| `config.scriptName` | URL path base for subfolder | `""` |
| `config.sessionCookieDomain` | Session cookie domain | `""` |
| `config.sessionCookieName` | Session cookie name | `sessionid` |

### Feature Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.enableSignup` | Allow user registration | `false` |
| `config.enableMetrics` | Enable Prometheus metrics | `false` |
| `config.enablePdfExport` | Enable PDF export | `false` |
| `config.sortTreeByName` | Sort keywords alphabetically | `false` |

### OIDC Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.oidc.enabled` | Enable OIDC | `false` |
| `config.oidc.providerId` | Provider ID | `authentik` |
| `config.oidc.providerName` | Provider display name | `Authentik` |
| `config.oidc.clientId` | Client ID | `""` |
| `config.oidc.clientSecret` | Client secret | `""` |
| `config.oidc.serverUrl` | Well-known configuration URL | `""` |

### LDAP Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.ldap.enabled` | Enable LDAP | `false` |
| `config.ldap.serverUri` | LDAP server URI | `""` |
| `config.ldap.bindDn` | Bind DN | `""` |
| `config.ldap.bindPassword` | Bind password | `""` |
| `config.ldap.userSearchBaseDn` | User search base DN | `""` |
| `config.ldap.tlsCacertFile` | TLS CA cert file | `""` |
| `config.ldap.startTls` | Enable StartTLS | `false` |
| `config.ldap.existingSecret` | Existing secret for LDAP | `""` |
| `config.ldap.bindPasswordKey` | Key for bind password in secret | `ldap-bind-password` |

### Email Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.email.host` | SMTP host | `""` |
| `config.email.port` | SMTP port | `25` |
| `config.email.user` | SMTP username | `""` |
| `config.email.password` | SMTP password | `""` |
| `config.email.useTls` | Enable TLS | `false` |
| `config.email.useSsl` | Enable SSL | `false` |
| `config.email.defaultFrom` | Default from address | `webmaster@localhost` |
| `config.email.accountEmailSubjectPrefix` | Email subject prefix | `[Tandoor Recipes]` |
| `config.email.existingSecret` | Existing secret for email | `""` |
| `config.email.passwordKey` | Key for password in secret | `email-password` |

### S3 Storage Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.s3.enabled` | Enable S3 storage | `false` |
| `config.s3.accessKey` | S3 access key | `""` |
| `config.s3.secretAccessKey` | S3 secret access key | `""` |
| `config.s3.bucketName` | S3 bucket name | `""` |
| `config.s3.regionName` | S3 region | `""` |
| `config.s3.endpointUrl` | Custom S3 endpoint (MinIO) | `""` |
| `config.s3.customDomain` | CDN/proxy domain | `""` |
| `config.s3.querystringAuth` | Use signed URLs | `true` |
| `config.s3.querystringExpire` | Signed URL expiration (seconds) | `3600` |
| `config.s3.existingSecret` | Existing secret for S3 | `""` |

### Social Authentication

| Name | Description | Default |
|------|-------------|---------|
| `config.socialDefaultAccess` | Space ID for auto-join | `0` |
| `config.socialDefaultGroup` | Default group (`guest`/`user`/`admin`) | `guest` |
| `config.socialProviders` | OAuth providers (comma-separated) | `""` |
| `config.remoteUserAuth` | Enable REMOTE-USER header auth | `false` |

### AI Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.ai.enabled` | Enable AI features | `false` |
| `config.ai.creditsMonthly` | Monthly credits per space | `100` |
| `config.ai.rateLimit` | AI rate limit | `60/hour` |

### External Services

| Name | Description | Default |
|------|-------------|---------|
| `config.fdcApiKey` | Food Data Central API key | `DEMO_KEY` |
| `config.disableExternalConnectors` | Disable external connectors | `false` |
| `config.externalConnectorsQueueSize` | External connectors queue size | `100` |

### Rate Limiting

| Name | Description | Default |
|------|-------------|---------|
| `config.ratelimitUrlImportRequests` | Rate limit for URL imports | `""` |
| `config.drfThrottleRecipeUrlImport` | DRF throttle for recipe URL import | `60/hour` |

### Space & User Defaults

| Name | Description | Default |
|------|-------------|---------|
| `config.spaceDefaultMaxRecipes` | Max recipes per space (0=unlimited) | `0` |
| `config.spaceDefaultMaxUsers` | Max users per space (0=unlimited) | `0` |
| `config.spaceDefaultMaxFiles` | Max file storage in MB (0=unlimited) | `0` |
| `config.spaceDefaultAllowSharing` | Allow public sharing | `true` |
| `config.fractionPrefDefault` | Default fraction display | `false` |
| `config.commentPrefDefault` | Comments enabled by default | `true` |
| `config.stickyNavPrefDefault` | Sticky navbar by default | `true` |
| `config.maxOwnedSpacesPrefDefault` | Max spaces per user | `100` |

### Performance & Cosmetic

| Name | Description | Default |
|------|-------------|---------|
| `config.shoppingMinAutosyncInterval` | Min auto-sync interval (minutes) | `5` |
| `config.exportFileCacheDuration` | Export cache duration (seconds) | `600` |
| `config.unauthenticatedThemeFromSpace` | Space ID for unauthenticated theme | `0` |
| `config.forceThemeFromSpace` | Space ID to enforce theme globally | `0` |

### Legal URLs

| Name | Description | Default |
|------|-------------|---------|
| `config.termsUrl` | Terms of service URL | `""` |
| `config.privacyUrl` | Privacy policy URL | `""` |
| `config.imprintUrl` | Legal imprint URL | `""` |

### hCaptcha Configuration

| Name | Description | Default |
|------|-------------|---------|
| `config.hcaptcha.siteKey` | hCaptcha site key | `""` |
| `config.hcaptcha.secret` | hCaptcha secret | `""` |
| `config.hcaptcha.existingSecret` | Existing secret for hCaptcha | `""` |

### Persistence Parameters

| Name | Description | Default |
|------|-------------|---------|
| `persistence.staticfiles.enabled` | Enable static files PVC | `true` |
| `persistence.staticfiles.existingClaim` | Existing PVC for static files | `""` |
| `persistence.staticfiles.storageClass` | Storage class | `""` |
| `persistence.staticfiles.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.staticfiles.size` | PVC size | `1Gi` |
| `persistence.mediafiles.enabled` | Enable media files PVC | `true` |
| `persistence.mediafiles.existingClaim` | Existing PVC for media files | `""` |
| `persistence.mediafiles.storageClass` | Storage class | `""` |
| `persistence.mediafiles.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.mediafiles.size` | PVC size | `5Gi` |

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
| `probes.readiness.initialDelaySeconds` | Readiness initial delay | `15` |
| `probes.readiness.periodSeconds` | Readiness period | `5` |

### Autoscaling Parameters

| Name | Description | Default |
|------|-------------|---------|
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Min replicas | `1` |
| `autoscaling.maxReplicas` | Max replicas | `3` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU | `80` |
| `autoscaling.targetMemoryUtilizationPercentage` | Target memory | `80` |

### Debugging

| Name | Description | Default |
|------|-------------|---------|
| `config.debug` | Enable Django debug mode | `false` |
| `config.debugToolbar` | Enable Debug Toolbar | `false` |
| `config.sqlDebug` | Enable SQL debug | `false` |
| `config.logLevel` | Application log level | `WARNING` |
| `config.gunicornLogLevel` | Gunicorn log level | `info` |

### Additional Configuration

| Name | Description | Default |
|------|-------------|---------|
| `env` | Extra environment variables | `[]` |
| `extraEnvFrom` | Extra env from secrets/configmaps | `[]` |
| `extraVolumes` | Extra volumes | `[]` |
| `extraVolumeMounts` | Extra volume mounts | `[]` |

## Troubleshooting

- **CSRF Errors**: Set `config.csrfTrustedOrigins` to your domain URL including the scheme
- **Login Issues**: Verify OIDC/LDAP configuration and callback URLs
- **Missing Media**: Check persistence configuration and S3 connectivity if enabled

```bash
kubectl logs -f deployment/tandoor
kubectl describe pod -l app.kubernetes.io/name=tandoor
```

## Links

- [Tandoor Recipes GitHub](https://github.com/TandoorRecipes/recipes)
- [Tandoor Documentation](https://docs.tandoor.dev/)
- [Configuration Reference](https://docs.tandoor.dev/system/configuration/)
- [Chart Source](https://github.com/rtomik/helm-charts/tree/main/charts/tandoor)
