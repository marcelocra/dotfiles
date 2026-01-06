#!/usr/bin/env bash
# Convenience wrapper for common SSH machine setup.
# Sets environment variables for typical SSH-accessed development machines.
#
# For editor configurations, run separately:
#   ./apps/vscode-like/install.bash [--code|--cursor|...]

set -euo pipefail

export DOTFILES_SKIP_HOMEBREW="false"
export DOTFILES_SKIP_CLI_TOOLS="false"
export DOTFILES_SKIP_ZSH_PLUGINS="false"
export DOTFILES_SKIP_EDITOR_LAUNCHER="true"
export DOTFILES_SKIP_GIT_SHIMS="false"
export DOTFILES_SKIP_SSH_CONFIG="false"
export DOTFILES_SKIP_NODE_LTS="false"
export DOTFILES_SKIP_NPM_PACKAGES="false"

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/x/dotfiles}"
export DOTFILES_DEBUG="${DOTFILES_DEBUG:-1}"

./setup/install.bash "$@"
