# Mealie Helm Chart

A Helm chart for deploying [Mealie](https://github.com/mealie-recipes/mealie), a recipe management and meal planning application, on Kubernetes.

## Introduction

This chart deploys Mealie on a Kubernetes cluster using the Helm package manager. Mealie is a self-hosted recipe manager with a reactive frontend and RestAPI backend, supporting PostgreSQL or SQLite databases, LDAP/OIDC authentication, and OpenAI integration.

Source code: https://github.com/rtomik/helm-charts/tree/main/charts/mealie

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- External PostgreSQL database (recommended, e.g. [CloudNativePG](https://cloudnative-pg.io/))
- PV provisioner support (if persistence is needed)

## Installing the Chart

```bash
helm repo add rtomik https://rtomik.github.io/helm-charts
helm install mealie rtomik/mealie
```

## Uninstalling the Chart

```bash
helm uninstall mealie
```

## Configuration Examples

### Minimal Installation

```yaml
persistence:
  enabled: true
  size: 10Gi

ingress:
  enabled: true
  hosts:
    - host: mealie.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - mealie.example.com
      secretName: mealie-tls
```

### PostgreSQL Configuration

```yaml
postgresql:
  external:
    enabled: true
    host: "postgresql.example.com"
    port: 5432
    database: "mealie"
    user: "mealie"
    existingSecret: "mealie-postgresql-secret"
    userKey: "username"
    passwordKey: "password"

env:
  DB_ENGINE: "postgres"
```

### OIDC Authentication

```yaml
oidc:
  enabled: true
  configurationUrl: "https://auth.example.com/.well-known/openid-configuration"
  clientId: "mealie-client"
  existingSecret: "mealie-oidc-secret"
  clientIdKey: "client-id"
  clientSecretKey: "client-secret"
  autoRedirect: true
  providerName: "CompanySSO"
```

### OpenAI Integration

```yaml
openai:
  enabled: true
  baseUrl: "https://api.openai.com/v1"
  existingSecret: "mealie-openai-secret"
  apiKeyKey: "api-key"
  model: "gpt-4"
  enableImageServices: true
```

### LDAP Authentication

```yaml
ldap:
  enabled: true
  serverUrl: "ldap://ldap.example.com"
  baseDn: "ou=users,dc=example,dc=com"
  queryBind: "cn=admin,dc=example,dc=com"
  queryPassword: "bind-password"
  userFilter: "(objectClass=inetOrgPerson)"
  idAttribute: "uid"
  nameAttribute: "name"
  mailAttribute: "mail"
```

### Email Configuration

```yaml
email:
  enabled: true
  host: "smtp.example.com"
  port: 587
  fromName: "Mealie"
  fromEmail: "mealie@example.com"
  authStrategy: "TLS"
  existingSecret: "mealie-smtp-secret"
  userKey: "smtp-user"
  passwordKey: "smtp-password"
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
| `image.repository` | Mealie image repository | `ghcr.io/mealie-recipes/mealie` |
| `image.tag` | Image tag | `v3.2.1` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Deployment Parameters

| Name | Description | Default |
|------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `revisionHistoryLimit` | Revisions to retain | `3` |
| `podSecurityContext.runAsNonRoot` | Run as non-root | `false` |
| `podSecurityContext.runAsUser` | User ID | `911` |
| `podSecurityContext.fsGroup` | Filesystem group ID | `911` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |

### Service Parameters

| Name | Description | Default |
|------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `9000` |

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
| `persistence.size` | PVC size | `5Gi` |
| `persistence.annotations` | PVC annotations | `{}` |

### Environment Variables

| Name | Description | Default |
|------|-------------|---------|
| `env.PUID` | User ID for host permissions | `911` |
| `env.PGID` | Group ID for host permissions | `911` |
| `env.DEFAULT_GROUP` | Default group for users | `Home` |
| `env.DEFAULT_HOUSEHOLD` | Default household | `Family` |
| `env.BASE_URL` | Base URL for notifications | `http://localhost:9000` |
| `env.TOKEN_TIME` | Login token validity (hours) | `48` |
| `env.API_PORT` | Backend API port | `9000` |
| `env.API_DOCS` | Enable API documentation | `true` |
| `env.TZ` | Timezone | `UTC` |
| `env.ALLOW_SIGNUP` | Allow user sign-up | `false` |
| `env.ALLOW_PASSWORD_LOGIN` | Allow password login | `true` |
| `env.LOG_LEVEL` | Log level | `info` |
| `env.DAILY_SCHEDULE_TIME` | Daily task schedule (HH:MM) | `23:45` |
| `env.DB_ENGINE` | Database engine (`postgres` or `sqlite`) | `postgres` |
| `extraEnv` | Additional environment variables | `[]` |

### PostgreSQL Configuration

| Name | Description | Default |
|------|-------------|---------|
| `postgresql.enabled` | Enable PostgreSQL | `false` |
| `postgresql.external.enabled` | Use external PostgreSQL | `false` |
| `postgresql.external.host` | PostgreSQL host | `""` |
| `postgresql.external.port` | PostgreSQL port | `5432` |
| `postgresql.external.database` | Database name | `mealie` |
| `postgresql.external.user` | Username | `mealie` |
| `postgresql.external.password` | Password | `""` |
| `postgresql.external.existingSecret` | Existing secret name | `""` |
| `postgresql.external.userKey` | Key for username in secret | `username` |
| `postgresql.external.passwordKey` | Key for password in secret | `password` |

### LDAP Authentication

| Name | Description | Default |
|------|-------------|---------|
| `ldap.enabled` | Enable LDAP | `false` |
| `ldap.serverUrl` | LDAP server URL | `""` |
| `ldap.tlsInsecure` | Skip server cert verification | `false` |
| `ldap.tlsCaCertFile` | CA certificate path | `""` |
| `ldap.enableStartTls` | Use STARTTLS | `false` |
| `ldap.baseDn` | Base DN for authentication | `""` |
| `ldap.queryBind` | Bind user for searches | `""` |
| `ldap.queryPassword` | Bind user password | `""` |
| `ldap.userFilter` | User LDAP filter | `""` |
| `ldap.adminFilter` | Admin LDAP filter | `""` |
| `ldap.idAttribute` | User ID attribute | `uid` |
| `ldap.nameAttribute` | User name attribute | `name` |
| `ldap.mailAttribute` | User email attribute | `mail` |
| `ldap.existingSecret` | Existing secret for LDAP | `""` |
| `ldap.passwordKey` | Key for password in secret | `ldap-password` |

### OIDC Authentication

| Name | Description | Default |
|------|-------------|---------|
| `oidc.enabled` | Enable OIDC | `false` |
| `oidc.signupEnabled` | Allow new users via OIDC | `true` |
| `oidc.configurationUrl` | OIDC configuration URL | `""` |
| `oidc.clientId` | Client ID | `""` |
| `oidc.clientSecret` | Client secret | `""` |
| `oidc.userGroup` | Required user group | `""` |
| `oidc.adminGroup` | Admin group | `""` |
| `oidc.autoRedirect` | Redirect to IdP on login | `false` |
| `oidc.providerName` | Provider name on login button | `OAuth` |
| `oidc.rememberMe` | Extend session ("Remember Me") | `false` |
| `oidc.signingAlgorithm` | ID token signing algorithm | `RS256` |
| `oidc.userClaim` | Claim to identify user | `email` |
| `oidc.nameClaim` | Claim for user name | `name` |
| `oidc.groupsClaim` | Claim for groups | `groups` |
| `oidc.existingSecret` | Existing secret name | `""` |
| `oidc.clientIdKey` | Key for client ID in secret | `oidc-client-id` |
| `oidc.clientSecretKey` | Key for client secret in secret | `oidc-client-secret` |

### OpenAI Configuration

| Name | Description | Default |
|------|-------------|---------|
| `openai.enabled` | Enable OpenAI | `false` |
| `openai.baseUrl` | OpenAI API base URL | `""` |
| `openai.apiKey` | OpenAI API key | `""` |
| `openai.model` | Model to use | `gpt-4o` |
| `openai.enableImageServices` | Enable image services | `true` |
| `openai.workers` | Workers per request | `2` |
| `openai.sendDatabaseData` | Send DB data for accuracy | `true` |
| `openai.requestTimeout` | Request timeout (seconds) | `60` |
| `openai.existingSecret` | Existing secret name | `""` |
| `openai.apiKeyKey` | Key for API key in secret | `openai-api-key` |

### Email Configuration

| Name | Description | Default |
|------|-------------|---------|
| `email.enabled` | Enable SMTP email | `false` |
| `email.host` | SMTP host | `""` |
| `email.port` | SMTP port | `587` |
| `email.fromName` | From name | `Mealie` |
| `email.authStrategy` | Auth strategy (`TLS`, `SSL`, `NONE`) | `TLS` |
| `email.fromEmail` | From email address | `""` |
| `email.user` | SMTP username | `""` |
| `email.password` | SMTP password | `""` |
| `email.existingSecret` | Existing secret for SMTP | `""` |
| `email.userKey` | Key for username in secret | `smtp-user` |
| `email.passwordKey` | Key for password in secret | `smtp-password` |

### TLS Configuration

| Name | Description | Default |
|------|-------------|---------|
| `tls.enabled` | Enable TLS | `false` |
| `tls.certificatePath` | TLS certificate path | `""` |
| `tls.privateKeyPath` | TLS private key path | `""` |
| `tls.existingSecret` | Existing secret with TLS certs | `""` |
| `tls.certificateKey` | Key for certificate in secret | `tls.crt` |
| `tls.privateKeyKey` | Key for private key in secret | `tls.key` |

### Theme Configuration

| Name | Description | Default |
|------|-------------|---------|
| `theme.light.primary` | Light theme primary color | `#E58325` |
| `theme.light.accent` | Light theme accent color | `#007A99` |
| `theme.light.secondary` | Light theme secondary color | `#973542` |
| `theme.light.success` | Light theme success color | `#43A047` |
| `theme.light.info` | Light theme info color | `#1976D2` |
| `theme.light.warning` | Light theme warning color | `#FF6D00` |
| `theme.light.error` | Light theme error color | `#EF5350` |
| `theme.dark.primary` | Dark theme primary color | `#E58325` |
| `theme.dark.accent` | Dark theme accent color | `#007A99` |
| `theme.dark.secondary` | Dark theme secondary color | `#973542` |
| `theme.dark.success` | Dark theme success color | `#43A047` |
| `theme.dark.info` | Dark theme info color | `#1976D2` |
| `theme.dark.warning` | Dark theme warning color | `#FF6D00` |
| `theme.dark.error` | Dark theme error color | `#EF5350` |

### Resource Parameters

| Name | Description | Default |
|------|-------------|---------|
| `resources` | Resource limits and requests | `{}` |

### Health Check Parameters

| Name | Description | Default |
|------|-------------|---------|
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.liveness.path` | Liveness probe path | `/` |
| `probes.liveness.initialDelaySeconds` | Liveness initial delay | `60` |
| `probes.liveness.periodSeconds` | Liveness period | `30` |
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `probes.readiness.path` | Readiness probe path | `/` |
| `probes.readiness.initialDelaySeconds` | Readiness initial delay | `30` |
| `probes.readiness.periodSeconds` | Readiness period | `10` |

### Autoscaling Parameters

| Name | Description | Default |
|------|-------------|---------|
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Min replicas | `1` |
| `autoscaling.maxReplicas` | Max replicas | `3` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU | `80` |
| `autoscaling.targetMemoryUtilizationPercentage` | Target memory | `80` |

## Troubleshooting

- **Database connection issues**: Verify credentials and network connectivity
- **Persistence issues**: Check StorageClass and PVC configuration
- **Authentication problems**: Verify LDAP/OIDC configuration and network access
- **Performance issues**: Adjust resource limits and consider using an external database

```bash
kubectl logs -f deployment/mealie
kubectl describe pod -l app.kubernetes.io/name=mealie
```

## Links

- [Mealie GitHub](https://github.com/mealie-recipes/mealie)
- [Chart Source](https://github.com/rtomik/helm-charts/tree/main/charts/mealie)
