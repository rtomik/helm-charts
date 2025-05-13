# qBittorrent with Gluetun VPN

A Helm chart for deploying qBittorrent with a Gluetun VPN sidecar container on Kubernetes.

## Introduction

This chart deploys [qBittorrent](https://www.qbittorrent.org/) alongside [Gluetun](https://github.com/qdm12/gluetun), a VPN client/tunnel in a container, to ensure all BitTorrent traffic is routed through the VPN. The chart supports all major VPN providers and protocols through Gluetun's comprehensive compatibility.

Note: Currently only tested with NordVPN an OpenVPN configuration.

## Features

- **Multiple VPN Providers**: Support for 30+ VPN providers including NordVPN, ProtonVPN, Private Internet Access, ExpressVPN, Surfshark, Mullvad, and more
- **Protocol Support**: Use OpenVPN or WireGuard based on your provider's capabilities
- **Server Selection**: Choose servers by country, city, or specific hostnames with optional randomization
- **Security**: Proper container security settings to ensure traffic only flows through the VPN
- **Health Monitoring**: Integrated health checks for both qBittorrent and the VPN connection
- **Persistence**: Separate volume storage for configuration and downloads
- **Web UI**: Access qBittorrent via web interface with optional ingress support
- **Proxy Services**: HTTP and Shadowsocks proxies for additional devices to use the VPN tunnel

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the cluster
- A valid subscription to a VPN service

## Installation

### Add the Repository

```bash
helm repo add rtomik-charts https://rtomik.github.io/helm-charts
helm repo update
```

### Create a Secret for VPN Credentials

For better security, store your VPN credentials in a Kubernetes secret:

```bash
# For OpenVPN authentication
kubectl create secret generic vpn-credentials \
  --namespace default \
  --from-literal=username='your-vpn-username' \
  --from-literal=password='your-vpn-password'

# For WireGuard authentication (if using WireGuard)
kubectl create secret generic wireguard-keys \
  --namespace default \
  --from-literal=private_key='your-wireguard-private-key'
```

Then reference this secret in your values:

```yaml
gluetun:
  credentials:
    create: false
    existingSecret: "vpn-credentials"
    usernameKey: "username"
    passwordKey: "password"
```

### Install the Chart

```bash
# Option 1: Installation with custom values file (recommended)
helm install qbittorrent-vpn rtomik-charts/qbittorrent-vpn -f values.yaml -n media

# Option 2: Installation with inline parameter overrides
helm install qbittorrent-vpn rtomik-charts/qbittorrent-vpn -n media \
  --set gluetun.vpn.provider=nordvpn \
  --set gluetun.vpn.serverCountries=Germany \
  --set-string gluetun.credentials.existingSecret=vpn-credentials
```

## Uninstallation

```bash
helm uninstall qbittorrent-vpn -n media
```

Note: This will not delete Persistent Volume Claims. To delete them:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=qbittorrent-vpn
```

## Configuration

### Key Parameters

| Parameter                             | Description                                           | Default                    |
|---------------------------------------|-------------------------------------------------------|----------------------------|
| `qbittorrent.image.repository`        | qBittorrent image repository                          | `linuxserver/qbittorrent`  |
| `qbittorrent.image.tag`               | qBittorrent image tag                                 | `latest`                   |
| `gluetun.image.repository`            | Gluetun image repository                              | `qmcgaw/gluetun`           |
| `gluetun.image.tag`                   | Gluetun image tag                                     | `v3.40.0`                  |
| `gluetun.vpn.provider`                | VPN provider name                                     | `nordvpn`                  |
| `gluetun.vpn.type`                    | VPN protocol (`openvpn` or `wireguard`)              | `openvpn`                  |
| `gluetun.vpn.serverCountries`         | Countries to connect to (comma-separated)            | `Germany`                  |
| `persistence.config.size`             | Size of PVC for qBittorrent config                    | `2Gi`                      |
| `persistence.downloads.size`          | Size of PVC for downloads                             | `100Gi`                    |
| `ingress.enabled`                     | Enable ingress controller resource                     | `true`                     |
| `ingress.hosts[0].host`               | Hostname for the ingress                              | `qbittorrent.domain.com`   |

For a complete list of parameters, see the [values.yaml](values.yaml) file.

### Example: Using with NordVPN

```yaml
gluetun:
  vpn:
    provider: "nordvpn"
    type: "openvpn"
    serverCountries: "United States"
    openvpn:
      NORDVPN_CATEGORY: "P2P"  # For torrent-optimized servers
  credentials:
    create: true
    username: "your-nordvpn-username"
    password: "your-nordvpn-password"
```

### Example: Using with ProtonVPN

```yaml
gluetun:
  vpn:
    provider: "protonvpn"
    type: "openvpn"
    serverCountries: "Switzerland"
    openvpn:
      PROTONVPN_TIER: "2"  # 0 is free, 2 is paid (Plus/Visionary)
      SERVER_FEATURES: "p2p"  # For torrent support
  credentials:
    create: true
    username: "protonvpn-username"
    password: "protonvpn-password"
```

### Example: Using with Private Internet Access

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
    VPN_PORT_FORWARDING: "on"  # PIA supports port forwarding
```

## VPN Provider Support

This chart supports all VPN providers compatible with Gluetun, including:

- AirVPN
- Cyberghost
- ExpressVPN
- FastestVPN
- HideMyAss
- IPVanish
- IVPN
- Mullvad
- NordVPN
- Perfect Privacy
- Private Internet Access (PIA)
- PrivateVPN
- ProtonVPN
- PureVPN
- Surfshark
- TorGuard
- VyprVPN
- WeVPN
- Windscribe

For the complete list and provider-specific options, see the [Gluetun Providers Documentation](https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers).

## Additional Features

### Accessing the HTTP Proxy

Gluetun provides an HTTP proxy on port 8888 that can be used by other applications to route traffic through the VPN. To expose this proxy:

```yaml
service:
  proxies:
    enabled: true
    httpPort: 8888
    socksPort: 8388
```

### Firewall Settings

By default, the chart enables the Gluetun firewall to prevent leaks if the VPN connection drops. You can customize this:

```yaml
gluetun:
  settings:
    FIREWALL: "on"
    FIREWALL_OUTBOUND_SUBNETS: "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
```

### Port Forwarding

For VPN providers that support port forwarding (like PIA):

```yaml
gluetun:
  settings:
    VPN_PORT_FORWARDING: "on"
    STATUS_FILE: "/tmp/gluetun-status.json"
```

## Troubleshooting

### VPN Connection Issues

If the VPN isn't connecting properly:

1. Check the Gluetun logs:
   ```bash
   kubectl logs deployment/qbittorrent-vpn -c gluetun
   ```

2. Verify your credentials are correct:
   ```bash
   kubectl describe secret vpn-credentials
   ```

3. Try setting the log level to debug for more detailed information:
   ```yaml
   gluetun:
     extraEnv:
       - name: LOG_LEVEL
         value: "debug"
   ```

### qBittorrent Can't Create Directories

If you see errors like "Could not create required directory":

1. Make sure the init container is enabled and properly configured
2. Ensure proper `fsGroup` is set in the `podSecurityContext`
3. Check that the persistence volume allows the correct permissions

### Firewall/Security Issues

If you encounter iptables or network issues:

1. Ensure the Gluetun container has `privileged: true`
2. Verify the `NET_ADMIN` capability is added
3. Check that the `/dev/net/tun` device is correctly mounted

## License

This chart is licensed under the MIT License.

## Acknowledgements

- [Gluetun](https://github.com/qdm12/gluetun) by [qdm12](https://github.com/qdm12)
- [LinuxServer.io](https://linuxserver.io/) for the qBittorrent container
- The qBittorrent team for the excellent torrent client