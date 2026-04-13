# qBittorrent VPN Helm Chart

A Helm chart for deploying [qBittorrent](https://www.qbittorrent.org/) with a [Gluetun](https://github.com/qdm12/gluetun) VPN sidecar on Kubernetes.

## Introduction

This chart deploys qBittorrent alongside Gluetun, ensuring all BitTorrent traffic is routed through a VPN. It supports 30+ VPN providers via OpenVPN or WireGuard, includes a kill-switch firewall, and exposes HTTP/Socks proxy services.

Source code: https://github.com/rtomik/helm-charts/tree/main/charts/qbittorrent-vpn

**Note**: Currently only tested with NordVPN and OpenVPN configuration.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the cluster
- A valid VPN subscription

## Installing the Chart

```bash
helm repo add rtomik https://rtomik.github.io/helm-charts
helm install qbittorrent-vpn rtomik/qbittorrent-vpn
```

## Uninstalling the Chart

```bash
helm uninstall qbittorrent-vpn
```

**Note**: PVCs are not deleted automatically. To remove them:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=qbittorrent-vpn
```

## Configuration Examples

### NordVPN with Existing Secret

First, create a secret with your VPN credentials:

```bash
kubectl create secret generic vpn-credentials \
  --from-literal=username='your-vpn-username' \
  --from-literal=password='your-vpn-password'
```

```yaml
gluetun:
  vpn:
    provider: "nordvpn"
    type: "openvpn"
    serverCountries: "United States"
    openvpn:
      NORDVPN_CATEGORY: "P2P"
  credentials:
    create: false
    existingSecret: "vpn-credentials"
    usernameKey: "username"
    passwordKey: "password"

ingress:
  enabled: true
  hosts:
    - host: qbittorrent.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - qbittorrent.example.com
```

### ProtonVPN

```yaml
gluetun:
  vpn:
    provider: "protonvpn"
    type: "openvpn"
    serverCountries: "Switzerland"
    openvpn:
      PROTONVPN_TIER: "2"
      SERVER_FEATURES: "p2p"
  credentials:
    create: true
    username: "protonvpn-username"
    password: "protonvpn-password"
```

### Private Internet Access with Port Forwarding

```yaml
gluetun:
  vpn:
    provider: "private internet access"
    type: "openvpn"
    serverCountries: "US"
  credentials:
    create: true
    username: "pia-username"
    password: "pia-password"
  settings:
    VPN_PORT_FORWARDING: "on"
    STATUS_FILE: "/tmp/gluetun-status.json"
```

### Proxy Services

```yaml
service:
  proxies:
    enabled: true
    httpPort: 8888
    socksPort: 8388
```

### Custom Sidecar (NATMap)

Sidecars can access shared volumes: `config`, `downloads`, and `gluetun-config`.

```yaml
sidecars:
  - name: natmap
    image: ghcr.io/muink/natmap:latest
    imagePullPolicy: IfNotPresent
    env:
      - name: GATEWAY
        value: "10.2.0.1"
      - name: INTERFACE
        value: "tun0"
      - name: INTERVAL
        value: "30"
    volumeMounts:
      - name: config
        mountPath: /config
        subPath: natmap
```

## Parameters

### qBittorrent Parameters

| Name | Description | Default |
|------|-------------|---------|
| `qbittorrent.image.repository` | qBittorrent image repository | `linuxserver/qbittorrent` |
| `qbittorrent.image.tag` | qBittorrent image tag | `5.1.0` |
| `qbittorrent.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `qbittorrent.bittorrentPort` | BitTorrent traffic port | `6881` |
| `qbittorrent.service.port` | Web UI port | `8080` |

### Gluetun VPN Parameters

| Name | Description | Default |
|------|-------------|---------|
| `gluetun.enabled` | Enable Gluetun VPN sidecar | `true` |
| `gluetun.image.repository` | Gluetun image repository | `qmcgaw/gluetun` |
| `gluetun.image.tag` | Gluetun image tag | `v3.40.0` |
| `gluetun.vpn.provider` | VPN provider name | `nordvpn` |
| `gluetun.vpn.type` | VPN protocol (`openvpn` or `wireguard`) | `openvpn` |
| `gluetun.vpn.serverCountries` | Countries to connect (comma-separated) | `Netherlands` |
| `gluetun.vpn.serverCities` | Cities to connect (optional) | `""` |
| `gluetun.vpn.serverNames` | Specific server names (optional) | `""` |
| `gluetun.vpn.randomize` | Randomize server selection | `true` |

### VPN Credentials

| Name | Description | Default |
|------|-------------|---------|
| `gluetun.credentials.create` | Create credentials secret | `true` |
| `gluetun.credentials.username` | VPN username (if creating secret) | `""` |
| `gluetun.credentials.password` | VPN password (if creating secret) | `""` |
| `gluetun.credentials.existingSecret` | Existing secret name | `""` |
| `gluetun.credentials.usernameKey` | Key for username in secret | `username` |
| `gluetun.credentials.passwordKey` | Key for password in secret | `password` |

### Gluetun Settings

| Name | Description | Default |
|------|-------------|---------|
| `gluetun.settings.FIREWALL` | Enable firewall | `on` |
| `gluetun.settings.FIREWALL_OUTBOUND_SUBNETS` | Allowed outbound subnets | `10.0.0.0/8,172.16.0.0/12,192.168.0.0/16` |
| `gluetun.settings.FIREWALL_INPUT_PORTS` | Ports allowed through firewall | `8080` |
| `gluetun.settings.FIREWALL_DEBUG` | Enable firewall debug | `on` |
| `gluetun.settings.VPN_PORT_FORWARDING` | Enable port forwarding | `off` |
| `gluetun.settings.DNS_ADDRESS` | DNS server address | `1.1.1.1` |
| `gluetun.resources.limits.cpu` | CPU limit | `300m` |
| `gluetun.resources.limits.memory` | Memory limit | `256Mi` |

### WireGuard Configuration (when using WireGuard)

| Name | Description | Default |
|------|-------------|---------|
| `gluetun.vpn.wireguard.privateKey` | WireGuard private key | `""` |
| `gluetun.vpn.wireguard.privateKeyExistingSecret` | Existing secret with private key | `""` |
| `gluetun.vpn.wireguard.addresses` | WireGuard addresses | `""` |
| `gluetun.vpn.wireguard.endpointIP` | Server endpoint IP (optional) | `""` |
| `gluetun.vpn.wireguard.endpointPort` | Server endpoint port (optional) | `""` |

### Deployment Parameters

| Name | Description | Default |
|------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `revisionHistoryLimit` | Revisions to retain | `3` |
| `podSecurityContext.runAsNonRoot` | Run as non-root | `false` |
| `podSecurityContext.runAsUser` | User ID | `0` |
| `podSecurityContext.fsGroup` | Filesystem group ID | `0` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |

### Service Parameters

| Name | Description | Default |
|------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |
| `service.proxies.enabled` | Enable HTTP/Socks proxy services | `false` |
| `service.proxies.httpPort` | HTTP proxy port | `8888` |
| `service.proxies.socksPort` | Socks proxy port | `8388` |

### Ingress Parameters

| Name | Description | Default |
|------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `[]` |
| `ingress.hosts` | Ingress hosts | See values.yaml |
| `ingress.tls` | TLS configuration | See values.yaml |

### Persistence Parameters

| Name | Description | Default |
|------|-------------|---------|
| `qbittorrent.persistence.config.enabled` | Enable config PVC | `true` |
| `qbittorrent.persistence.config.existingClaim` | Existing config PVC | `""` |
| `qbittorrent.persistence.config.size` | Config PVC size | `2Gi` |
| `qbittorrent.persistence.downloads.enabled` | Enable downloads PVC | `true` |
| `qbittorrent.persistence.downloads.existingClaim` | Existing downloads PVC | `""` |
| `qbittorrent.persistence.downloads.size` | Downloads PVC size | `2Gi` |
| `gluetun.persistence.enabled` | Enable Gluetun config PVC | `true` |
| `gluetun.persistence.size` | Gluetun config PVC size | `100Mi` |

### Sidecar Parameters

| Name | Description | Default |
|------|-------------|---------|
| `sidecars` | Additional sidecar containers | `[]` |

### Health Check Parameters

| Name | Description | Default |
|------|-------------|---------|
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.liveness.path` | Liveness probe path | `/` |
| `probes.liveness.periodSeconds` | Liveness period | `30` |
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `probes.readiness.path` | Readiness probe path | `/` |
| `probes.readiness.periodSeconds` | Readiness period | `10` |

## Supported VPN Providers

AirVPN, Cyberghost, ExpressVPN, FastestVPN, HideMyAss, IPVanish, IVPN, Mullvad, NordVPN, Perfect Privacy, Private Internet Access, PrivateVPN, ProtonVPN, PureVPN, Surfshark, TorGuard, VyprVPN, WeVPN, Windscribe, and more.

See the [Gluetun Providers Documentation](https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers) for the full list and provider-specific options.

## Troubleshooting

### VPN Not Connecting

```bash
kubectl logs deployment/qbittorrent-vpn -c gluetun
kubectl describe secret vpn-credentials
```

Enable debug logging for more detail:

```yaml
gluetun:
  extraEnv:
    - name: LOG_LEVEL
      value: "debug"
```

### Directory Creation Errors

Ensure the init container is enabled and `fsGroup` is set in `podSecurityContext`.

### Firewall / Network Issues

Gluetun requires `privileged: true` and `NET_ADMIN` capability. Verify `/dev/net/tun` is mounted correctly.

## Links

- [qBittorrent](https://www.qbittorrent.org/)
- [Gluetun GitHub](https://github.com/qdm12/gluetun)
- [Gluetun Provider Setup](https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers)
- [Chart Source](https://github.com/rtomik/helm-charts/tree/main/charts/qbittorrent-vpn)
