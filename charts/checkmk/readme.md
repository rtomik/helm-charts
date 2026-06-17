# Checkmk Helm Chart

Helm chart for deploying [Checkmk](https://checkmk.com/) — an infrastructure and application monitoring platform — on Kubernetes.

## Overview

Checkmk uses OMD (Open Monitoring Distribution) to manage monitoring sites. This chart deploys the Community Edition using the official Docker image with:

- Persistent storage for all site data (`/omd/sites`)
- RAM-backed tmpfs for the site temp directory (performance optimization from the official docs)
- Separate service ports for the web interface (5000) and agent receiver (8000)
- Admin password stored in a Kubernetes Secret

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- A default StorageClass or an existing PersistentVolumeClaim

## Quick Start

```bash
helm install checkmk ./charts/checkmk \
  --set config.adminPassword.value=mysecretpassword \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=checkmk.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

After installation, access the UI at `http://<host>/cmk/check_mk/` with username `cmkadmin`.

## Configuration

### Admin Password (recommended: use existing secret)

```bash
kubectl create secret generic checkmk-secrets \
  --from-literal=cmk-password=<your-password>
```

```yaml
config:
  adminPassword:
    existingSecret: "checkmk-secrets"
    passwordKey: "cmk-password"
```

### Site ID

The `config.siteId` value sets the Checkmk site name and determines the URL path (`/<siteId>/check_mk/`). Defaults to `cmk`.

### Livestatus TCP

Enable Livestatus TCP for distributed monitoring setups or external integrations:

```yaml
config:
  livestatusTcp: true
```

### Persistence

Site data (hosts, checks, RRD files) is stored in `/omd/sites`. A 5 Gi PVC is created by default. Adjust size or use an existing claim:

```yaml
persistence:
  size: 20Gi
  storageClass: "fast-ssd"
```

## Key Values

| Key | Default | Description |
|-----|---------|-------------|
| `image.tag` | `2.5.0p6` | Checkmk Community image tag |
| `config.siteId` | `cmk` | Monitoring site name |
| `config.timezone` | `UTC` | Container timezone |
| `config.adminPassword.value` | `changeme` | cmkadmin password (use existingSecret in production) |
| `config.livestatusTcp` | `false` | Enable Livestatus over TCP |
| `config.mailRelayHost` | `""` | SMTP relay for notifications |
| `service.port` | `5000` | Web interface port |
| `service.agentReceiverPort` | `8000` | Agent registration port |
| `persistence.enabled` | `true` | Enable persistent storage |
| `persistence.size` | `5Gi` | PVC size |

## Security Notes

Checkmk (OMD) requires root access inside the container to manage monitoring sites and switch to the site user account. The `podSecurityContext.runAsUser` is set to `0` and `containerSecurityContext.allowPrivilegeEscalation` is `true` by default.

Place a reverse proxy (e.g. Traefik or nginx) in front for TLS termination rather than exposing the container port directly.
