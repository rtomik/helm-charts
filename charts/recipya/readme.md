# Recipya Helm Chart

A Helm chart for deploying [Recipya](https://github.com/reaper47/recipya) on Kubernetes.

[Source Code](https://github.com/rtomik/helm-charts/tree/main/charts%2Frecipya)

## Introduction

This chart deploys Recipya recipe manager on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is needed)

## Installing the Chart

To install the chart with the release name `recipya`:

```bash
helm repo add recipya-chart https://rtomik.github.io/helm-charts
helm install recipya recipya-chart/recipya -n recipya
```

The command deploys Recipya on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `recipya` deployment:

```bash
helm uninstall recipya -n recipya
```

## Important Configuration Notes

### Server URL

When deploying with an ingress, it's **critical** to set `config.server.url` to match your ingress URL (including https if you're using TLS). This ensures that redirects after login work correctly:

```yaml
config:
  server:
    url: "https://your-recipya-domain.com"
```

### Ingress Configuration

This chart includes optimized ingress configurations for Traefik, with support for WebSockets and proper security headers. If you're using a different ingress controller, you may need to adjust annotations accordingly.

## Parameters

### Global parameters

| Name                     | Description                          | Value           |
|--------------------------|--------------------------------------|-----------------|
| `image.repository`       | Recipya image repository             | `reaper99/recipya` |
| `image.tag`              | Recipya image tag                    | `v1.2.2`        |
| `image.pullPolicy`       | Recipya image pull policy            | `IfNotPresent`  |
| `replicaCount`           | Number of Recipya replicas           | `1`             |
| `revisionHistoryLimit`   | Number of revisions to keep          | `3`             |

### Security parameters

| Name                                    | Description                                      | Value     |
|-----------------------------------------|--------------------------------------------------|-----------|
| `podSecurityContext.fsGroup`            | Group ID for the Recipya container               | `1000`    |
| `containerSecurityContext`              | Security context for the container               | `{}`      |

### Recipya configuration parameters

| Name                                    | Description                                           | Value                 |
|-----------------------------------------|-------------------------------------------------------|---------------------|
| `config.server.port`                    | Server port                                           | `8078`              |
| `config.server.autologin`               | Whether to login automatically                        | `false`             |
| `config.server.is_demo`                 | Whether the app is a demo version                     | `false`             |
| `config.server.is_prod`                 | Whether the app is in production                      | `false`             |
| `config.server.no_signups`              | Whether to disable user account registrations         | `false`             |
| `config.server.url`                     | Base URL for the application                          | `http://0.0.0.0`    |
| `config.email.address`                  | The email address for SendGrid                        | `""`                |
| `config.email.sendgrid`                 | SendGrid API key                                      | `""`                |
| `config.documentIntelligence.endpoint`  | Azure Document Intelligence endpoint                  | `""`                |
| `config.documentIntelligence.key`       | Azure Document Intelligence key                       | `""`                |

### Service parameters

| Name                     | Description                                      | Value       |
|--------------------------|--------------------------------------------------|-------------|
| `service.type`           | Recipya service type                             | `ClusterIP` |
| `service.port`           | Recipya service port                             | `8078`      |

### Ingress parameters

| Name                          | Description                                      | Value                  |
|-------------------------------|--------------------------------------------------|------------------------|
| `ingress.enabled`             | Enable ingress controller resource               | `false`                |
| `ingress.className`           | IngressClass that will be used                   | `"traefik"`            |
| `ingress.annotations`         | Additional ingress annotations                   | See values.yaml        |
| `ingress.hosts[0].host`       | Default host for the ingress resource            | `chart-example.local`  |
| `ingress.tls`                 | TLS configuration                                | `[]`                   |

### Persistence parameters

| Name                                 | Description                              | Value            |
|--------------------------------------|------------------------------------------|------------------|
| `persistence.enabled`                | Enable persistence using PVC             | `true`           |
| `persistence.accessMode`             | PVC Access Mode                          | `ReadWriteOnce`  |
| `persistence.size`                   | PVC Storage Request                      | `1Gi`            |
| `persistence.storageClass`           | Storage class of backing PVC             | `""`             |

### Resource parameters

| Name                          | Description                              | Value     |
|-------------------------------|------------------------------------------|-----------|
| `resources.limits.cpu`        | CPU limit                                | `500m`    |
| `resources.limits.memory`     | Memory limit                             | `512Mi`   |
| `resources.requests.cpu`      | CPU request                              | `100m`    |
| `resources.requests.memory`   | Memory request                           | `128Mi`   |

### Probe parameters

| Name                                 | Description                                | Value     |
|--------------------------------------|--------------------------------------------|-----------|
| `probes.liveness.enabled`            | Enable liveness probe                      | `true`    |
| `probes.liveness.path`               | Path for liveness probe                    | `/`       |
| `probes.readiness.enabled`           | Enable readiness probe                     | `true`    |
| `probes.readiness.path`              | Path for readiness probe                   | `/`       |

## Traefik Ingress Configuration

The chart includes specially configured middlewares for Traefik to ensure proper functioning of Recipya:

```yaml
ingress:
  enabled: true
  className: "traefik"
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.middlewares: recipya-recipya-headers@kubernetescrd
    traefik.ingress.kubernetes.io/service.sticky: "true"
    traefik.ingress.kubernetes.io/session-cookie-name: "recipya_session"
  hosts:
    - host: recipya.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - hosts:
      - recipya.example.com
```

This configuration includes:

1. Custom Content Security Policy allowing essential scripts from unpkg.com
2. Sticky sessions for maintaining authentication
3. Proper headers for proxy operation

## Content Security Policy Configuration

The chart includes a custom middleware that configures the proper Content Security Policy for Recipya. This is particularly important as the application requires access to external scripts from unpkg.com:

```yaml
contentSecurityPolicy: >-
  default-src 'self';
  script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: data: https://unpkg.com;
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: blob:;
  font-src 'self' data:;
  connect-src 'self' ws: wss: *;
  worker-src 'self' blob:;
  frame-src 'self';
  media-src 'self' blob:;
  object-src 'none';
  form-action 'self';
```

## Using Existing Secrets

If you want to use existing secrets for sensitive data:

```yaml
config:
  email:
    existingSecret: "my-email-secret"
    addressKey: "email"
    sendgridKey: "sendgrid"
  documentIntelligence:
    existingSecret: "my-di-secret"
    endpointKey: "di_endpoint"
    keyKey: "di_key"
```

## Configuration

See the [Recipya documentation](https://recipes.musicavis.ca/docs/installation/docker/#environment-variables) for details on all available configuration options.