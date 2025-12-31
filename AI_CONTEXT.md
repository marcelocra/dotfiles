# AI Context

 This file provides context for LLMs/AI agents working on this repository (`marcelocra/dotfiles`).

## Repository Purpose
This repository manages dotfiles and setup scripts for Marcelo Almeida. It supports:
- **Environments**: Linux (Ubuntu, openSUSE), macOS, WSL, DevContainers, Remote SSH.
- **Key Tools**: zsh, oh-my-zsh, neovim, vscode, git, fzf, tmux, node, docker, tailscale.
- **Philosophy**: Idempotency, Simplicity (monolithic scripts where appropriate), Reproducibility.

## Conventions

### Shell Scripts
- **Extensions**:
    - `.bash`: Scripts using Bash-specific features (arrays, `[[ ]]`).
    - `.sh`: POSIX-compliant scripts.
    - Reference: `docs/adr/0001-shell-script-file-extensions.md`
- **Strict Mode**: All scripts MUST start with `set -euo pipefail`.
- **Style**: Google Shell Style Guide (mostly).
- **Execution**: Scripts should be runnable from anywhere (resolve own path).

### Directory Structure
- `shell/`: Shell configuration (`.zshrc`, `init.sh`, aliases).
- `setup/`: Installation scripts (`install.bash`, `host-setup-linux.sh`).
- `apps/`: Application specific configs (vscode, neovim, etc).
- `docs/`: Documentation and Architecture Decision Records (ADR).
- `tests/`: Docker-based integration tests.

## Key Files
- `setup/install.bash`: The main installation script (monolithic).
- `shell/init.sh`: The main shell initialization (sourced by .zshrc/.bashrc).
- `Plan.md`: High-level roadmap.

## Testing
- Run `tests/docker-test.sh` to verify installation in a clean environment.
