# Mealie Helm Chart

A Helm chart for deploying Mealie recipe management and meal planning application on Kubernetes.

## Introduction

This chart deploys [Mealie](https://github.com/mealie-recipes/mealie) on a Kubernetes cluster using the Helm package manager. Mealie is a self-hosted recipe manager and meal planner with a RestAPI backend and a reactive frontend application built in Vue for a pleasant user experience for the whole family.

Source code can be found here:
- https://github.com/rtomik/helm-charts/tree/main/charts/mealie

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (if persistence is needed)
- External Postgresql DB like https://cloudnative-pg.io/

## Installing the Chart

To install the chart with the release name `mealie`:

```bash
$ helm repo add mealie-chart https://rtomik.github.io/helm-charts
$ helm install mealie mealie-chart/mealie
```

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `mealie` deployment:

```bash
$ helm uninstall mealie
```

## Parameters

### Global parameters

| Name                   | Description                                    | Value |
|------------------------|------------------------------------------------|-------|
| `nameOverride`         | String to partially override the release name | `""`  |
| `fullnameOverride`     | String to fully override the release name     | `""`  |

### Image parameters

| Name                    | Description                       | Value                             |
|-------------------------|-----------------------------------|-----------------------------------|
| `image.repository`      | Mealie image repository           | `ghcr.io/mealie-recipes/mealie`   |
| `image.tag`             | Mealie image tag                  | `v3.1.1`                         |
| `image.pullPolicy`      | Mealie image pull policy          | `IfNotPresent`                    |

### Deployment parameters

| Name                                 | Description                                   | Value     |
|--------------------------------------|-----------------------------------------------|-----------|
| `replicaCount`                       | Number of Mealie replicas                     | `1`       |
| `revisionHistoryLimit`               | Number of revisions to retain for rollback   | `3`       |
| `podSecurityContext.runAsNonRoot`    | Run containers as non-root user               | `false`   |
| `podSecurityContext.runAsUser`       | User ID for the container                     | `911`     |
| `podSecurityContext.fsGroup`         | Group ID for the container filesystem        | `911`     |
| `containerSecurityContext`           | Security context for the container           | See values.yaml |
| `nodeSelector`                       | Node labels for pod assignment               | `{}`      |
| `tolerations`                        | Tolerations for pod assignment               | `[]`      |
| `affinity`                           | Affinity for pod assignment                  | `{}`      |

### Service parameters

| Name           | Description           | Value       |
|----------------|-----------------------|-------------|
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | Service HTTP port     | `9000`      |

### Ingress parameters

| Name                    | Description                               | Value           |
|-------------------------|-------------------------------------------|-----------------|
| `ingress.enabled`       | Enable ingress record generation          | `false`         |
| `ingress.className`     | IngressClass name                         | `""`            |
| `ingress.annotations`   | Additional annotations for the Ingress    | See values.yaml |
| `ingress.hosts`         | Array of host and path objects            | See values.yaml |
| `ingress.tls`           | TLS configuration                         | See values.yaml |

### Persistence parameters

| Name                          | Description                      | Value           |
|-------------------------------|----------------------------------|-----------------|
| `persistence.enabled`         | Enable persistence using PVC     | `true`          |
| `persistence.storageClass`    | PVC Storage Class                | `""`            |
| `persistence.accessMode`      | PVC Access Mode                  | `ReadWriteOnce` |
| `persistence.size`            | PVC Size                         | `5Gi`           |
| `persistence.annotations`     | Annotations for PVC              | `{}`            |

### Environment variables

| Name                                  | Description                                   | Value           |
|---------------------------------------|-----------------------------------------------|-----------------|
| `env.PUID`                           | UserID permissions between host OS and container | `911`           |
| `env.PGID`                           | GroupID permissions between host OS and container | `911`           |
| `env.DEFAULT_GROUP`                  | The default group for users                  | `Home`          |
| `env.DEFAULT_HOUSEHOLD`              | The default household for users in each group | `Family`        |
| `env.BASE_URL`                       | Used for Notifications                       | `http://localhost:9000` |
| `env.TOKEN_TIME`                     | The time in hours that a login/auth token is valid | `48`            |
| `env.API_PORT`                       | The port exposed by backend API              | `9000`          |
| `env.API_DOCS`                       | Turns on/off access to the API documentation | `true`          |
| `env.TZ`                             | Must be set to get correct date/time on the server | `UTC`           |
| `env.ALLOW_SIGNUP`                   | Allow user sign-up without token             | `false`         |
| `env.ALLOW_PASSWORD_LOGIN`           | Whether or not to display username+password input fields | `true`          |
| `env.LOG_LEVEL`                      | Logging level                                | `info`          |
| `env.DAILY_SCHEDULE_TIME`            | Time to run daily server tasks (HH:MM)       | `23:45`         |

### PostgreSQL configuration

| Name                                   | Description                                   | Value     |
|----------------------------------------|-----------------------------------------------|-----------|
| `postgresql.enabled`                   | Enable PostgreSQL support                    | `false`   |
| `postgresql.external.enabled`          | Use external PostgreSQL database             | `false`   |
| `postgresql.external.host`             | PostgreSQL host                              | `""`      |
| `postgresql.external.port`             | PostgreSQL port                              | `5432`    |
| `postgresql.external.database`         | PostgreSQL database name                     | `mealie`  |
| `postgresql.external.user`             | PostgreSQL username                          | `mealie`  |
| `postgresql.external.password`         | PostgreSQL password                          | `""`      |
| `postgresql.external.existingSecret`   | Name of existing secret with PostgreSQL credentials | `""`      |
| `postgresql.external.userKey`          | Key in the secret for username               | `username` |
| `postgresql.external.passwordKey`      | Key in the secret for password               | `password` |

### Email (SMTP) configuration

| Name                     | Description                          | Value     |
|--------------------------|--------------------------------------|-----------|
| `email.enabled`          | Enable SMTP email support            | `false`   |
| `email.host`             | SMTP host                            | `""`      |
| `email.port`             | SMTP port                            | `587`     |
| `email.fromName`         | From name for emails                 | `Mealie`  |
| `email.authStrategy`     | SMTP auth strategy (TLS, SSL, NONE)  | `TLS`     |
| `email.fromEmail`        | From email address                   | `""`      |
| `email.user`             | SMTP username                        | `""`      |
| `email.password`         | SMTP password                        | `""`      |
| `email.existingSecret`   | Name of existing secret with SMTP credentials | `""`      |
| `email.userKey`          | Key in the secret for SMTP username  | `smtp-user` |
| `email.passwordKey`      | Key in the secret for SMTP password  | `smtp-password` |

### LDAP Authentication

| Name                     | Description                          | Value     |
|--------------------------|--------------------------------------|-----------|
| `ldap.enabled`           | Enable LDAP authentication           | `false`   |
| `ldap.serverUrl`         | LDAP server URL                      | `""`      |
| `ldap.tlsInsecure`       | Do not verify server certificate     | `false`   |
| `ldap.tlsCaCertFile`     | Path to CA certificate file          | `""`      |
| `ldap.enableStartTls`    | Use STARTTLS to connect to server    | `false`   |
| `ldap.baseDn`            | Starting point for user authentication | `""`      |
| `ldap.queryBind`         | Optional bind user for LDAP searches | `""`      |
| `ldap.queryPassword`     | Password for the bind user            | `""`      |
| `ldap.userFilter`        | LDAP filter to narrow down eligible users | `""`      |
| `ldap.adminFilter`       | LDAP filter for admin users          | `""`      |
| `ldap.idAttribute`       | LDAP attribute for user ID            | `uid`     |
| `ldap.nameAttribute`     | LDAP attribute for user name          | `name`    |
| `ldap.mailAttribute`     | LDAP attribute for user email         | `mail`    |

### OpenID Connect (OIDC)

| Name                         | Description                              | Value     |
|------------------------------|------------------------------------------|-----------|
| `oidc.enabled`               | Enable OIDC authentication               | `false`   |
| `oidc.signupEnabled`         | Allow new users via OIDC                 | `true`    |
| `oidc.configurationUrl`      | URL to OIDC configuration                | `""`      |
| `oidc.clientId`              | OIDC client ID                           | `""`      |
| `oidc.clientSecret`          | OIDC client secret                       | `""`      |
| `oidc.userGroup`             | Required OIDC user group                 | `""`      |
| `oidc.adminGroup`            | OIDC admin group                         | `""`      |
| `oidc.autoRedirect`          | Bypass login page and redirect to IdP   | `false`   |
| `oidc.providerName`          | Provider name shown in login button     | `OAuth`   |
| `oidc.rememberMe`            | Extend session as if "Remember Me" was checked | `false`   |
| `oidc.signingAlgorithm`      | Algorithm used to sign the id token     | `RS256`   |
| `oidc.userClaim`             | Claim to look up existing user by       | `email`   |
| `oidc.nameClaim`             | Claim for user's full name               | `name`    |
| `oidc.groupsClaim`           | Claim for user groups                    | `groups`  |

### OpenAI Integration

| Name                               | Description                              | Value     |
|------------------------------------|------------------------------------------|-----------|
| `openai.enabled`                   | Enable OpenAI integration                | `false`   |
| `openai.baseUrl`                   | Base URL for OpenAI API                  | `""`      |
| `openai.apiKey`                    | OpenAI API key                           | `""`      |
| `openai.model`                     | OpenAI model to use                      | `gpt-4o`  |
| `openai.customHeaders`             | Custom HTTP headers for OpenAI requests | `""`      |
| `openai.customParams`              | Custom HTTP query params for OpenAI requests | `""`      |
| `openai.enableImageServices`       | Enable OpenAI image services            | `true`    |
| `openai.workers`                   | Number of OpenAI workers per request    | `2`       |
| `openai.sendDatabaseData`          | Send Mealie data to OpenAI to improve accuracy | `true`    |
| `openai.requestTimeout`            | Timeout for OpenAI requests in seconds  | `60`      |

### TLS Configuration

| Name                     | Description                          | Value     |
|--------------------------|--------------------------------------|-----------|
| `tls.enabled`            | Enable TLS configuration             | `false`   |
| `tls.certificatePath`    | Path to TLS certificate file         | `""`      |
| `tls.privateKeyPath`     | Path to TLS private key file         | `""`      |
| `tls.existingSecret`     | Name of existing secret with TLS certificates | `""`      |
| `tls.certificateKey`     | Key in the secret for TLS certificate | `tls.crt` |
| `tls.privateKeyKey`      | Key in the secret for TLS private key | `tls.key` |

### Theme Configuration

| Name                          | Description                    | Value     |
|-------------------------------|--------------------------------|-----------|
| `theme.light.primary`         | Light theme primary color      | `#E58325` |
| `theme.light.accent`          | Light theme accent color       | `#007A99` |
| `theme.light.secondary`       | Light theme secondary color    | `#973542` |
| `theme.light.success`         | Light theme success color      | `#43A047` |
| `theme.light.info`            | Light theme info color         | `#1976D2` |
| `theme.light.warning`         | Light theme warning color      | `#FF6D00` |
| `theme.light.error`           | Light theme error color        | `#EF5350` |
| `theme.dark.primary`          | Dark theme primary color       | `#E58325` |
| `theme.dark.accent`           | Dark theme accent color        | `#007A99` |
| `theme.dark.secondary`        | Dark theme secondary color     | `#973542` |
| `theme.dark.success`          | Dark theme success color       | `#43A047` |
| `theme.dark.info`             | Dark theme info color          | `#1976D2` |
| `theme.dark.warning`          | Dark theme warning color       | `#FF6D00` |
| `theme.dark.error`            | Dark theme error color         | `#EF5350` |

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
| `probes.liveness.path`                    | Path for liveness probe                  | `/`    |
| `probes.readiness.enabled`                | Enable readiness probe                   | `true` |
| `probes.readiness.initialDelaySeconds`    | Initial delay for readiness probe        | `30`   |
| `probes.readiness.periodSeconds`          | Period for readiness probe               | `10`   |
| `probes.readiness.timeoutSeconds`         | Timeout for readiness probe              | `5`    |
| `probes.readiness.failureThreshold`       | Failure threshold for readiness probe    | `3`    |
| `probes.readiness.successThreshold`       | Success threshold for readiness probe    | `1`    |
| `probes.readiness.path`                   | Path for readiness probe                 | `/`    |

### Autoscaling

| Name                                        | Description                              | Value   |
|---------------------------------------------|------------------------------------------|---------|
| `autoscaling.enabled`                       | Enable horizontal pod autoscaling        | `false` |
| `autoscaling.minReplicas`                   | Minimum number of replicas               | `1`     |
| `autoscaling.maxReplicas`                   | Maximum number of replicas               | `3`     |
| `autoscaling.targetCPUUtilizationPercentage`| Target CPU utilization percentage        | `80`    |
| `autoscaling.targetMemoryUtilizationPercentage`| Target memory utilization percentage     | `80`    |

## Configuration Examples

### Basic Installation with Persistence

```yaml
persistence:
  enabled: true
  size: 10Gi
  storageClass: "fast-ssd"

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

### PostgreSQL Database Configuration

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

### OIDC Authentication Setup

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

## Security Considerations

For production deployments, it's recommended to:

1. Use external secrets for sensitive information
2. Enable TLS/SSL for all communications
3. Configure proper RBAC and network policies
4. Use a dedicated database with proper access controls
5. Enable authentication (LDAP/OIDC) and disable public signup

## Troubleshooting

Common issues and solutions:

1. **Database connection issues**: Verify database credentials and network connectivity
2. **Persistence issues**: Check StorageClass and PVC configuration
3. **Authentication problems**: Verify LDAP/OIDC configuration and network access
4. **Performance issues**: Adjust resource limits and consider using external database

For more detailed troubleshooting, check the application logs:

```bash
kubectl logs -f deployment/mealie
```