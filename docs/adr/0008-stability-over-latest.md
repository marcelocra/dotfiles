# 8. Stability Over Latest Philosophy

Date: 2025-12-30

## Status

Accepted

## Context

When choosing tools, runtimes, and infrastructure for development environments, there's a tension between:
- **Latest**: Newest features, best performance, but potentially unstable
- **Stable**: Proven reliability, wide support, but may lack newest features

For cloud VMs used for remote development work (accessed via SSH), reliability is paramount. A broken development environment costs hours of debugging time.

## Decision

We adopt a **"Stability Over Latest"** philosophy for core infrastructure choices.

### Guiding Principles

1. **Prefer LTS releases** over rolling/latest
2. **Prefer mainstream tools** over cutting-edge alternatives
3. **Prefer official installers** over third-party
4. **Wait for adoption** before switching (let others find the bugs)

### Current Choices

| Category | Choice | Rationale |
|----------|--------|-----------|
| OS | Ubuntu 24.04 LTS | 5-year support, wide compatibility |
| Container Runtime | Docker | Industry standard, best documentation |
| Node.js | LTS via nvm | Stability, enterprise support |
| Python | System python3 + venv | Avoid pyenv complexity |
| Shell | zsh + oh-my-zsh | Mature ecosystem, not fish (less portable) |
| Package Manager | Homebrew | Cross-platform, large package selection |
| Process Manager | systemd (OS default) | Already there, well-documented |

### What We Don't Use (and Why)

| Tool | Why Not |
|------|---------|
| Podman (for VMs) | Docker has better remote tooling support |
| NixOS | Steep learning curve, debugging complexity |
| Arch/Fedora | Rolling release = potential breakage |
| Fish shell | Less POSIX-compatible, smaller ecosystem |
| fnm/volta | nvm is known, widely documented |

### When to Deviate

- **Containers**: Can use newer/experimental tools (isolated, disposable)
- **Personal projects**: Experimentation is encouraged
- **Specific needs**: If stable tool genuinely doesn't work

## Consequences

### Positive
- Fewer surprises when setting up new VMs
- Extensive documentation and Stack Overflow answers available
- Lower debugging time for environment issues
- Easier onboarding for collaborators

### Negative
- May miss performance improvements in newer tools
- "Boring" choices may feel less exciting
- Some cutting-edge features require manual installation
