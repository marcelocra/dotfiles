# 6. Network Security with Tailscale

Date: 2025-12-30

## Status

Accepted

## Context

Development VMs in the cloud need to be accessible for development work. The traditional approach is exposing SSH on port 22 to the public internet, protected by SSH keys.

This approach has security concerns:
- Public IP is visible and scannable
- Brute-force attempts on authentication (even if keys-only, it's noise)
- Requires careful firewall management
- Host key verification burden

## Decision

We will use **Tailscale** as the primary access method for cloud VMs, with port 22 closed to the public internet.

### Security Comparison

| Aspect | Open Port 22 | Tailscale |
|--------|--------------|-----------|
| Attack surface | Public internet | Only Tailscale peers |
| IP exposure | Public IP visible | WireGuard VPN, no public exposure |
| Authentication | SSH keys only | Zero-trust identity + SSH keys |
| Network scans | Visible, noisy logs | Invisible to scanners |
| Firewall config | Critical, manual | Minimal, automated |
| MitM protection | Host key verification | WireGuard cryptographic identity |

### Implementation

1. Install Tailscale on all VMs via `setup/install.bash`
2. Connect VM to Tailnet: `tailscale up`
3. Access via Tailscale IP: `ssh user@100.x.y.z`
4. Optional: Enable MagicDNS for hostname resolution

### When to Still Use Port 22

- Initial VM bootstrap (before Tailscale is installed)
- Emergency access if Tailscale is down
- In these cases, use IP allowlisting or VPN

## Consequences

### Positive
- Zero attack surface from public internet
- No brute-force attempts in logs
- Simplified firewall rules
- Works across NAT/firewalls automatically
- Exit nodes available for location flexibility

### Negative
- Dependency on Tailscale service availability
- Requires Tailscale client on connecting machine
- Initial setup requires alternative access method
