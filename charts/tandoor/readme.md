# Tandoor Recipes Helm Chart

A Helm chart for deploying [Tandoor Recipes](https://github.com/TandoorRecipes/recipes) on Kubernetes.

Tandoor is a recipe management application that allows you to manage your recipes, plan meals, and create shopping lists.

Source code can be found here:
- https://github.com/rtomik/helm-charts/tree/main/charts/tandoor

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure
- **External PostgreSQL database** (required - this chart does NOT include PostgreSQL)

## Installing the Chart

```bash
helm repo add rtomik https://rtomik.github.io/helm-charts
helm repo update
helm install tandoor rtomik/tandoor -f values.yaml
```

## Usage Examples

### Minimal Configuration

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

### Production Configuration

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

  # Optional: OpenID Connect with Authentik
  # oidc:
  #   enabled: true
  #   providerId: "authentik"
  #   providerName: "Authentik"
  #   clientId: "your-client-id"
  #   clientSecret: "your-client-secret"
  #   serverUrl: "https://authentik.company/application/o/tandoor/.well-known/openid-configuration"

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
    # existingClaim: "my-existing-pvc"
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


## Configuration

All configuration options are based on the official Tandoor documentation:
https://docs.tandoor.dev/system/configuration/

The following table lists the configurable parameters and their default values.

### Global Parameters

| Name | Description | Value |
|------|-------------|-------|
| `nameOverride` | String to partially override the release name | `""` |
| `fullnameOverride` | String to fully override the release name | `""` |

### Image Parameters

| Name | Description | Value |
|------|-------------|-------|
| `image.repository` | Tandoor image repository | `vabene1111/recipes` |
| `image.tag` | Tandoor image tag | `2.3.5` |
| `image.pullPolicy` | Tandoor image pull policy | `IfNotPresent` |

### Deployment Parameters

| Name | Description | Value |
|------|-------------|-------|
| `replicaCount` | Number of Tandoor replicas | `1` |
| `revisionHistoryLimit` | Number of old ReplicaSets to retain | `3` |

### PostgreSQL Parameters

| Name | Description | Value |
|------|-------------|-------|
| `postgresql.host` | PostgreSQL host | `postgresql.default.svc.cluster.local` |
| `postgresql.port` | PostgreSQL port | `5432` |
| `postgresql.database` | PostgreSQL database name | `tandoor` |
| `postgresql.username` | PostgreSQL username | `tandoor` |
| `postgresql.password` | PostgreSQL password (not recommended for production) | `""` |
| `postgresql.existingSecret` | Existing secret with PostgreSQL credentials | `""` |
| `postgresql.passwordKey` | Key in existing secret for PostgreSQL password | `postgresql-password` |

### Security Configuration

| Name | Description | Value |
|------|-------------|-------|
| `config.secretKey.value` | Django secret key (at least 50 characters) | `""` |
| `config.secretKey.existingSecret` | Existing secret for Django secret key | `""` |
| `config.secretKey.secretKey` | Key in existing secret for Django secret key | `secret-key` |
| `config.allowedHosts` | Allowed hosts for HTTP Host Header validation | `*` |
| `config.csrfTrustedOrigins` | CSRF trusted origins | `""` |
| `config.corsAllowOrigins` | Enable CORS allow all origins | `false` |

### Server Configuration

| Name | Description | Value |
|------|-------------|-------|
| `config.tandoorPort` | Port where Tandoor exposes its web server | `8080` |
| `config.gunicornWorkers` | Number of Gunicorn worker processes | `3` |
| `config.gunicornThreads` | Number of Gunicorn threads per worker | `2` |
| `config.gunicornTimeout` | Gunicorn request timeout in seconds | `30` |
| `config.gunicornMedia` | Enable media serving via Gunicorn | `0` |
| `config.timezone` | Application timezone | `UTC` |
| `config.scriptName` | URL path base for subfolder deployments | `""` |
| `config.sessionCookieDomain` | Session cookie domain | `""` |
| `config.sessionCookieName` | Session cookie identifier | `sessionid` |

### Feature Configuration

| Name | Description | Value |
|------|-------------|-------|
| `config.enableSignup` | Allow user registration | `false` |
| `config.enableMetrics` | Enable Prometheus metrics at /metrics | `false` |
| `config.enablePdfExport` | Enable recipe PDF export | `false` |
| `config.sortTreeByName` | Sort keywords/foods alphabetically | `false` |

### Social Authentication

| Name | Description | Value |
|------|-------------|-------|
| `config.socialDefaultAccess` | Space ID for auto-joining new social auth users | `0` |
| `config.socialDefaultGroup` | Default group for new users (guest/user/admin) | `guest` |
| `config.socialProviders` | Comma-separated OAuth provider list | `""` |
| `config.socialAccountProviders` | SOCIALACCOUNT_PROVIDERS JSON (for complex setups) | `""` |

### OpenID Connect (OIDC) Configuration

| Name | Description | Value |
|------|-------------|-------|
| `config.oidc.enabled` | Enable OpenID Connect authentication | `false` |
| `config.oidc.providerId` | Provider ID (e.g., authentik, keycloak) | `authentik` |
| `config.oidc.providerName` | Display name on login page | `Authentik` |
| `config.oidc.clientId` | Client ID from OIDC provider | `""` |
| `config.oidc.clientSecret` | Client Secret from OIDC provider | `""` |
| `config.oidc.serverUrl` | OpenID Connect well-known configuration URL | `""` |

### LDAP Configuration

| Name | Description | Value |
|------|-------------|-------|
| `config.ldap.enabled` | Enable LDAP authentication | `false` |
| `config.ldap.serverUri` | LDAP server URI | `""` |
| `config.ldap.bindDn` | LDAP bind distinguished name | `""` |
| `config.ldap.bindPassword` | LDAP bind password | `""` |
| `config.ldap.userSearchBaseDn` | LDAP user search base | `""` |
| `config.ldap.tlsCacertFile` | LDAP TLS CA certificate file | `""` |
| `config.ldap.startTls` | Enable LDAP StartTLS | `false` |
| `config.ldap.existingSecret` | Existing secret for LDAP credentials | `""` |
| `config.ldap.bindPasswordKey` | Key in existing secret for LDAP password | `ldap-bind-password` |

### Remote User Authentication

| Name | Description | Value |
|------|-------------|-------|
| `config.remoteUserAuth` | Enable REMOTE-USER header authentication | `false` |

### Email Configuration

| Name | Description | Value |
|------|-------------|-------|
| `config.email.host` | SMTP server hostname | `""` |
| `config.email.port` | SMTP server port | `25` |
| `config.email.user` | SMTP authentication username | `""` |
| `config.email.password` | SMTP authentication password | `""` |
| `config.email.useTls` | Enable TLS for email | `false` |
| `config.email.useSsl` | Enable SSL for email | `false` |
| `config.email.defaultFrom` | Default from email address | `webmaster@localhost` |
| `config.email.accountEmailSubjectPrefix` | Email subject prefix | `[Tandoor Recipes]` |
| `config.email.existingSecret` | Existing secret for email credentials | `""` |
| `config.email.passwordKey` | Key in existing secret for email password | `email-password` |

### S3/Object Storage Configuration

| Name | Description | Value |
|------|-------------|-------|
| `config.s3.enabled` | Enable S3 storage for media files | `false` |
| `config.s3.accessKey` | S3 access key | `""` |
| `config.s3.secretAccessKey` | S3 secret access key | `""` |
| `config.s3.bucketName` | S3 bucket name | `""` |
| `config.s3.regionName` | S3 region name | `""` |
| `config.s3.endpointUrl` | Custom S3 endpoint URL (for MinIO) | `""` |
| `config.s3.customDomain` | CDN/proxy domain for S3 | `""` |
| `config.s3.querystringAuth` | Use signed URLs for S3 objects | `true` |
| `config.s3.querystringExpire` | Signed URL expiration (seconds) | `3600` |
| `config.s3.existingSecret` | Existing secret for S3 credentials | `""` |

### AI Features

| Name | Description | Value |
|------|-------------|-------|
| `config.ai.enabled` | Enable AI features | `false` |
| `config.ai.creditsMonthly` | Monthly AI credits per space | `100` |
| `config.ai.rateLimit` | AI API rate limit | `60/hour` |

### External Services

| Name | Description | Value |
|------|-------------|-------|
| `config.fdcApiKey` | Food Data Central API key | `DEMO_KEY` |
| `config.disableExternalConnectors` | Disable all external connectors | `false` |
| `config.externalConnectorsQueueSize` | External connectors queue size | `100` |

### Rate Limiting

| Name | Description | Value |
|------|-------------|-------|
| `config.ratelimitUrlImportRequests` | Rate limit for URL imports | `""` |
| `config.drfThrottleRecipeUrlImport` | DRF throttle for recipe URL import | `60/hour` |

### Space Defaults

| Name | Description | Value |
|------|-------------|-------|
| `config.spaceDefaultMaxRecipes` | Max recipes per space (0=unlimited) | `0` |
| `config.spaceDefaultMaxUsers` | Max users per space (0=unlimited) | `0` |
| `config.spaceDefaultMaxFiles` | Max file storage in MB (0=unlimited) | `0` |
| `config.spaceDefaultAllowSharing` | Allow public recipe sharing | `true` |

### User Preference Defaults

| Name | Description | Value |
|------|-------------|-------|
| `config.fractionPrefDefault` | Default fraction display | `false` |
| `config.commentPrefDefault` | Enable comments by default | `true` |
| `config.stickyNavPrefDefault` | Sticky navbar by default | `true` |
| `config.maxOwnedSpacesPrefDefault` | Max spaces per user | `100` |

### Cosmetic Configuration

| Name | Description | Value |
|------|-------------|-------|
| `config.unauthenticatedThemeFromSpace` | Space ID for unauthenticated theme | `0` |
| `config.forceThemeFromSpace` | Space ID to enforce theme globally | `0` |

### Performance Configuration

| Name | Description | Value |
|------|-------------|-------|
| `config.shoppingMinAutosyncInterval` | Min auto-sync interval (minutes) | `5` |
| `config.exportFileCacheDuration` | Export cache duration (seconds) | `600` |

### Legal URLs

| Name | Description | Value |
|------|-------------|-------|
| `config.termsUrl` | Terms of service URL | `""` |
| `config.privacyUrl` | Privacy policy URL | `""` |
| `config.imprintUrl` | Legal imprint URL | `""` |

### hCaptcha Configuration

| Name | Description | Value |
|------|-------------|-------|
| `config.hcaptcha.siteKey` | hCaptcha site key | `""` |
| `config.hcaptcha.secret` | hCaptcha secret key | `""` |
| `config.hcaptcha.existingSecret` | Existing secret for hCaptcha | `""` |

### Debugging

| Name | Description | Value |
|------|-------------|-------|
| `config.debug` | Enable Django debug mode | `false` |
| `config.debugToolbar` | Enable Django Debug Toolbar | `false` |
| `config.sqlDebug` | Enable SQL debug output | `false` |
| `config.logLevel` | Application log level | `WARNING` |
| `config.gunicornLogLevel` | Gunicorn log level | `info` |

### Service Parameters

| Name | Description | Value |
|------|-------------|-------|
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | Service HTTP port | `8080` |

### Ingress Parameters

| Name | Description | Value |
|------|-------------|-------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | See values.yaml |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |
| `ingress.tls` | Ingress TLS configuration | See values.yaml |

### Persistence Parameters

| Name | Description | Value |
|------|-------------|-------|
| `persistence.staticfiles.enabled` | Enable static files persistence | `true` |
| `persistence.staticfiles.existingClaim` | Use existing PVC for static files | `""` |
| `persistence.staticfiles.storageClass` | Storage class for static files | `""` |
| `persistence.staticfiles.accessMode` | Access mode for static files PVC | `ReadWriteOnce` |
| `persistence.staticfiles.size` | Size of static files PVC | `1Gi` |
| `persistence.mediafiles.enabled` | Enable media files persistence | `true` |
| `persistence.mediafiles.existingClaim` | Use existing PVC for media files | `""` |
| `persistence.mediafiles.storageClass` | Storage class for media files | `""` |
| `persistence.mediafiles.accessMode` | Access mode for media files PVC | `ReadWriteOnce` |
| `persistence.mediafiles.size` | Size of media files PVC | `5Gi` |

### Pod Security Context

| Name | Description | Value |
|------|-------------|-------|
| `podSecurityContext.runAsNonRoot` | Run as non-root user | `true` |
| `podSecurityContext.runAsUser` | User ID to run as | `1000` |
| `podSecurityContext.fsGroup` | Group ID for filesystem | `1000` |

### Container Security Context

| Name | Description | Value |
|------|-------------|-------|
| `containerSecurityContext.allowPrivilegeEscalation` | Allow privilege escalation | `false` |
| `containerSecurityContext.readOnlyRootFilesystem` | Read-only root filesystem | `false` |

### Autoscaling Parameters

| Name | Description | Value |
|------|-------------|-------|
| `autoscaling.enabled` | Enable autoscaling | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `3` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization | `80` |
| `autoscaling.targetMemoryUtilizationPercentage` | Target memory utilization | `80` |

### Probes Configuration

| Name | Description | Value |
|------|-------------|-------|
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.liveness.initialDelaySeconds` | Initial delay for liveness probe | `30` |
| `probes.liveness.periodSeconds` | Period for liveness probe | `10` |
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `probes.readiness.initialDelaySeconds` | Initial delay for readiness probe | `15` |
| `probes.readiness.periodSeconds` | Period for readiness probe | `5` |

### Additional Configuration

| Name | Description | Value |
|------|-------------|-------|
| `env` | Additional environment variables | `[]` |
| `extraEnvFrom` | Additional environment variables from secrets | `[]` |
| `extraVolumes` | Additional volumes | `[]` |
| `extraVolumeMounts` | Additional volume mounts | `[]` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |

## Uninstalling the Chart

```bash
helm uninstall tandoor
```

**Note:** PVCs are not automatically deleted. To remove them:

```bash
kubectl delete pvc -l app.kubernetes.io/name=tandoor
```

## Links

- [Tandoor Recipes GitHub](https://github.com/TandoorRecipes/recipes)
- [Tandoor Documentation](https://docs.tandoor.dev/)
- [Configuration Reference](https://docs.tandoor.dev/system/configuration/)
