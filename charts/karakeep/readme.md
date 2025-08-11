# Karakeep Helm Chart

This Helm chart deploys [Karakeep](https://github.com/karakeep-app/karakeep), a bookmark management application, along with its required services on a Kubernetes cluster.

## Components

This chart deploys three containers in a single pod:

1. **Karakeep**: The main bookmark management application
2. **Chrome**: Headless Chrome browser for web scraping and preview generation
3. **MeiliSearch**: Search engine for fast bookmark search functionality

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `karakeep`:

```bash
helm repo add karakeep-chart https://rtomik.github.io/helm-charts
helm install karakeep karakeep-chart/karakeep
```

## Uninstalling the Chart

To uninstall/delete the `karakeep` deployment:

```bash
helm delete karakeep
```

## Configuration

The following table lists the configurable parameters and their default values.

### Global Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nameOverride` | Override the name of the chart | `""` |
| `fullnameOverride` | Override the full name of the chart | `""` |
| `replicaCount` | Number of replicas | `1` |

### Karakeep Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `karakeep.image.repository` | Karakeep image repository | `ghcr.io/karakeep-app/karakeep` |
| `karakeep.image.tag` | Karakeep image tag | `"release"` |
| `karakeep.image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Chrome Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `chrome.image.repository` | Chrome image repository | `gcr.io/zenika-hub/alpine-chrome` |
| `chrome.image.tag` | Chrome image tag | `"124"` |

### MeiliSearch Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `meilisearch.image.repository` | MeiliSearch image repository | `getmeili/meilisearch` |
| `meilisearch.image.tag` | MeiliSearch image tag | `"v1.13.3"` |

### Persistence

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.data.size` | Size of data volume | `5Gi` |
| `persistence.data.storageClass` | Storage class for data volume | `""` |
| `persistence.meilisearch.size` | Size of MeiliSearch volume | `2Gi` |
| `persistence.meilisearch.storageClass` | Storage class for MeiliSearch volume | `""` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.hosts[0].host` | Hostname | `karakeep.domain.com` |

### Secrets

| Parameter | Description | Default |
|-----------|-------------|---------|
| `secrets.create` | Create secret for environment variables | `false` |
| `secrets.existingSecret` | Use existing secret | `""` |
| `secrets.env` | Environment variables to store in secret | `{}` |

**Important Configuration:**
1. The default `NEXTAUTH_SECRET` is set to a placeholder value. For production deployments, you should either:
   - Override the value: `--set karakeep.env[3].value="your-secure-32-character-string"`
   - Use secrets: `--set secrets.create=true --set secrets.env.NEXTAUTH_SECRET="your-secure-32-character-string"`

2. When ingress is enabled, `NEXTAUTH_URL` is automatically set to the ingress hostname. For custom configurations:
   - Override manually: `--set karakeep.env[4].value="https://your-domain.com"`

## Notes

- This chart creates a multi-container pod with all three services running together
- Data persistence is enabled by default with separate volumes for Karakeep data and MeiliSearch indices
- The services communicate via localhost since they share the same pod network
- Chrome runs with security flags for containerized environments