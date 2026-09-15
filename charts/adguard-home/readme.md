# AdGuard Home Helm Chart

A Helm chart for deploying [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome), a network-wide DNS ad and tracker blocker, on Kubernetes.

## Introduction

This chart deploys AdGuard Home on a Kubernetes cluster using the Helm package manager. AdGuard Home is a self-hosted DNS server that blocks ads and trackers for every device on your network, and can also act as a DHCP server, DNS-over-TLS/HTTPS/QUIC resolver, and DNSCrypt server.

Source code: https://github.com/rtomik/helm-charts/tree/main/charts/adguard-home

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support (if persistence is needed)
- A way to route real LAN clients to the DNS Service (LoadBalancer/MetalLB, NodePort, or `hostNetwork: true`) if you intend to use it as your network's resolver

## Installing the Chart

```bash
helm repo add rtomik https://rtomik.github.io/helm-charts
helm install adguard-home rtomik/adguard-home
```

## Uninstalling the Chart

```bash
helm uninstall adguard-home
```

## Configuration Examples

### Minimal Installation (admin UI only, no DNS exposed on the LAN)

```yaml
persistence:
  work:
    enabled: true
    size: 2Gi
  conf:
    enabled: true
    size: 100Mi

ingress:
  enabled: true
  hosts:
    - host: adguard.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - adguard.example.com
      secretName: adguard-tls
```

### Expose DNS to the LAN via LoadBalancer (e.g. MetalLB)

```yaml
service:
  type: LoadBalancer
  loadBalancerIP: 192.168.1.53
  annotations:
    metallb.universe.tf/allow-shared-ip: adguard-home

hostNetwork: true  # preserves real client IPs in the query log/filters
```

### Enable DNS-over-TLS / DNS-over-QUIC and DNS-over-HTTPS

```yaml
ports:
  dot:
    enabled: true
  https:
    enabled: true
```

### Enable the DHCP server

DHCP requires `hostNetwork: true` - it cannot be proxied through a ClusterIP/LoadBalancer Service.

```yaml
hostNetwork: true
ports:
  dhcp:
    enabled: true
```

### Use an existing PVC

```yaml
persistence:
  work:
    existingClaim: "adguard-work-pvc"
  conf:
    existingClaim: "adguard-conf-pvc"
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
| `image.repository` | AdGuard Home image repository | `adguard/adguardhome` |
| `image.tag` | Image tag | `v0.107.79` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |

### Deployment Parameters

| Name | Description | Default |
|------|-------------|---------|
| `replicaCount` | Number of replicas (keep at 1 - AdGuard Home is not multi-writer safe) | `1` |
| `revisionHistoryLimit` | Revisions to retain | `3` |
| `podSecurityContext.runAsNonRoot` | Run as non-root | `true` |
| `podSecurityContext.runAsUser` | User ID | `1000` |
| `podSecurityContext.runAsGroup` | Group ID | `1000` |
| `podSecurityContext.fsGroup` | Filesystem group ID | `1000` |
| `containerSecurityContext.capabilities.add` | Capabilities added (NET_BIND_SERVICE for ports < 1024) | `["NET_BIND_SERVICE"]` |
| `hostNetwork` | Use host networking (required for DHCP, recommended for accurate client IPs) | `false` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |

### Ports Parameters

| Name | Description | Default |
|------|-------------|---------|
| `ports.web.port` | Admin dashboard / setup wizard | `3000` |
| `ports.dns.port` | Plain DNS (TCP+UDP) | `53` |
| `ports.dot.enabled` | Enable DNS-over-TLS / DNS-over-QUIC | `false` |
| `ports.dot.port` | DoT/DoQ port (TCP+UDP) | `853` |
| `ports.https.enabled` | Enable DNS-over-HTTPS / HTTPS admin dashboard | `false` |
| `ports.https.port` | HTTPS port (TCP+UDP) | `443` |
| `ports.dnscrypt.enabled` | Enable DNSCrypt | `false` |
| `ports.dnscrypt.port` | DNSCrypt port (TCP+UDP) | `5443` |
| `ports.dhcp.enabled` | Enable DHCP server (67/68 UDP, requires `hostNetwork: true`) | `false` |
| `ports.pprof.enabled` | Enable the debug pprof API | `false` |
| `ports.pprof.port` | pprof port | `6060` |

### Service Parameters

| Name | Description | Default |
|------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.annotations` | Service annotations | `{}` |
| `service.loadBalancerIP` | Static LoadBalancer IP (e.g. for MetalLB) | `""` |

### Ingress Parameters

| Name | Description | Default |
|------|-------------|---------|
| `ingress.enabled` | Enable ingress (routes to the admin dashboard only) | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | See values.yaml |
| `ingress.hosts` | Ingress hosts | See values.yaml |
| `ingress.tls` | TLS configuration | See values.yaml |

### Persistence Parameters

| Name | Description | Default |
|------|-------------|---------|
| `persistence.work.enabled` | Persist `/opt/adguardhome/work` (query log, filter cache, stats) | `true` |
| `persistence.work.existingClaim` | Use an existing PVC instead of creating one | `""` |
| `persistence.work.storageClass` | Storage class | `""` |
| `persistence.work.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.work.size` | PVC size | `1Gi` |
| `persistence.conf.enabled` | Persist `/opt/adguardhome/conf` (AdGuardHome.yaml) | `true` |
| `persistence.conf.existingClaim` | Use an existing PVC instead of creating one | `""` |
| `persistence.conf.storageClass` | Storage class | `""` |
| `persistence.conf.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.conf.size` | PVC size | `100Mi` |

### Resource Parameters

| Name | Description | Default |
|------|-------------|---------|
| `resources` | Resource limits and requests | `{}` |

### Health Check Parameters

| Name | Description | Default |
|------|-------------|---------|
| `probes.liveness.enabled` | Enable liveness probe (TCP check on the admin web port) | `true` |
| `probes.liveness.initialDelaySeconds` | Liveness initial delay | `15` |
| `probes.liveness.periodSeconds` | Liveness period | `30` |
| `probes.readiness.enabled` | Enable readiness probe (TCP check on the admin web port) | `true` |
| `probes.readiness.initialDelaySeconds` | Readiness initial delay | `5` |
| `probes.readiness.periodSeconds` | Readiness period | `10` |

### Other Parameters

| Name | Description | Default |
|------|-------------|---------|
| `extraEnv` | Additional environment variables | `[]` |
| `extraVolumeMounts` | Additional volume mounts | `[]` |
| `extraVolumes` | Additional volumes | `[]` |

## Notes

- AdGuard Home has no supported way to bootstrap its admin account or DNS settings via
  environment variables - complete the setup wizard once at `http://<web-service>:3000`
  after the first install. The resulting `AdGuardHome.yaml` is written to the `conf` PVC,
  so it survives pod restarts/upgrades.
- Because AdGuard Home stores state on disk and isn't multi-writer safe, do not scale
  `replicaCount` beyond `1`.
- If you plan to use this as your network's DNS resolver, prefer `hostNetwork: true` (or
  a LoadBalancer Service with `externalTrafficPolicy: Local`) so AdGuard Home sees real
  client IPs rather than a single Service/NAT IP for every device.

## Troubleshooting

- **Clients all show up as the same IP / filters by client don't work**: enable `hostNetwork` or use `externalTrafficPolicy: Local` on a LoadBalancer Service.
- **DHCP doesn't hand out leases**: DHCP only works with `hostNetwork: true`.
- **Setup wizard settings don't persist**: verify `persistence.conf.enabled` is `true` and the PVC is bound.

```bash
kubectl logs -f deployment/adguard-home
kubectl describe pod -l app.kubernetes.io/name=adguard-home
```

## Links

- [AdGuard Home GitHub](https://github.com/AdguardTeam/AdGuardHome)
- [AdGuard Home Docker documentation](https://adguard-dns.io/kb/adguard-home/docker/)
- [Chart Source](https://github.com/rtomik/helm-charts/tree/main/charts/adguard-home)
