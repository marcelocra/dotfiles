# AI Agents Context - Dotfiles Repository

This file provides context for AI agents (Claude, Gemini, Copilot, etc.) working on this repository.

## Repository Purpose

Personal dotfiles and setup scripts for Marcelo Almeida's development environments.

**Supported environments:** Linux VMs (cloud), containers, WSL
**Primary use case:** Remote development via SSH + VS Code/Cursor

## Philosophy

- **Stability over latest** - Ubuntu LTS, Docker, mainstream tools (see ADR-0008)
- **Idempotency** - Scripts can be run multiple times safely
- **Monolithic simplicity** - Single install script, not many small modules (see ADR-0002)

## Directory Structure

| Directory | Purpose | Status |
|-----------|---------|--------|
| `setup/` | Installation scripts (`install.bash` is main entry) | ✅ Active |
| `shell/` | Shell configuration (`init.sh` sourced by .zshrc/.bashrc) | ✅ Active |
| `apps/` | Application configs (VS Code, Neovim, etc.) | ✅ Active |
| `docs/adr/` | Architecture Decision Records | ✅ Active |
| `tests/` | Docker-based integration tests | ✅ Active |
| `cli/` | AI development scripts | ✅ Active |
| `deprecated/` | Legacy files (do not use) | ⚠️ Cleanup pending |
| `git/` | Git configuration | ✅ Active |
| `nvim/` | Neovim configuration | 📋 Needs review |
| `pwsh/` | PowerShell (Windows) | 📋 Needs review |

## Key Files

| File | Purpose |
|------|---------|
| `setup/install.bash` | Main installation script (use this) |
| `shell/init.sh` | Shell initialization (sourced by .zshrc/.bashrc) |
| `install.bash` | Wrapper at repo root (calls setup/install.bash) |
| `PLAN.md` | High-level roadmap |

## Conventions

### Shell Scripts (see ADR-0001)

- **`.bash`** for Bash-specific scripts (arrays, `[[ ]]`, etc.)
- **`.sh`** for POSIX-compliant scripts
- **No extension** for commands in PATH (e.g., `x-mycommand`)
- **Strict mode**: All scripts use `set -euo pipefail`
- **Commands**: Prefixed with `x-` for easy tab completion

### Code Quality

- Run `shellcheck` on all shell scripts
- Format with `shfmt`
- Test with `./tests/docker-test.bash`

## Flag Pattern

All installation flags use `SKIP_*` pattern:
```bash
DOTFILES_SKIP_DOCKER=true     # Skip Docker installation
DOTFILES_SKIP_HOMEBREW=true   # Skip Homebrew installation
```

CLI equivalent: `--no-docker`, `--no-tailscale`, etc.

## Testing

```bash
# Run full test in clean container
./tests/docker-test.bash

# Dry-run to see what would happen
./setup/install.bash --dry-run
```

## CLI AI Development Scripts

Scripts in `cli/` provide containerized AI-enabled development environments:

```bash
./cli/ai-dev.sh              # quick mode (default)
./cli/ai-dev.sh full         # full development environment
./cli/ai-dev.sh minimal      # minimal Alpine environment
```

## Important ADRs

- **ADR-0001**: Shell script file extensions
- **ADR-0002**: Monolithic install script architecture
- **ADR-0003**: Locale and timezone configuration
- **ADR-0008**: Stability over latest philosophy
