# 4. Environment Detection

Date: 2025-12-30

## Status

Accepted

## Context

The dotfiles installation and shell initialization scripts need to detect the execution environment to:
- Skip certain installations in containers (e.g., Docker daemon)
- Use forwarded SSH agent in remote environments instead of local 1Password
- Skip GUI-related configuration in headless environments
- Adjust paths for WSL (Windows Subsystem for Linux)

## Decision

We define and export the following environment detection flags in both `shell/install.sh` and `shell/init.sh`:

| Flag | Purpose | Detection Method |
|------|---------|------------------|
| `DOTFILES_IN_CONTAINER` | Docker/Podman container | `/.dockerenv`, `$CONTAINER`, `/run/.containerenv` |
| `DOTFILES_IN_WSL` | Windows Subsystem for Linux | `/proc/version` contains "Microsoft" or "WSL2" |
| `DOTFILES_IN_SSH` | SSH session (remote connection) | `$SSH_CONNECTION` or `$SSH_CLIENT` set |
| `DOTFILES_IN_BUNKER` | DevBunker environment | Explicit `$DOTFILES_IN_BUNKER` env var |
| `DOTFILES_IN_REMOTE_VSCODE` | VS Code Remote | `$REMOTE_CONTAINERS` or `$CODESPACES` set |
| `DOTFILES_REMOTE_ENV` | Any remote environment | Derived: container OR SSH OR Bunker |

### Usage Pattern

```bash
detect_environment  # Sets all flags

if [[ "$DOTFILES_REMOTE_ENV" == "true" ]]; then
    # Use forwarded SSH agent, skip 1Password local binary
fi

if [[ "$DOTFILES_IN_CONTAINER" == "true" ]]; then
    # Skip Docker daemon installation
fi
```

## Consequences

### Positive
- Single source of truth for environment detection
- Consistent behavior across install and init scripts
- Easy to extend with new environment types

### Negative
- Flags must be kept in sync between scripts (or sourced from common file)
- Detection methods may need updates as container runtimes evolve
