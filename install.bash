#!/usr/bin/env bash
# Most common options for machines accessed through SSH.
# TODO: Update to include options for other common use cases.

set -euo pipefail  # Exit on errors.

export DOTFILES_SKIP_HOMEBREW="false"
export DOTFILES_SKIP_CLI_TOOLS="false"
export DOTFILES_SKIP_ZSH_PLUGINS="false"
export DOTFILES_SKIP_VSCODE="true"
export DOTFILES_SKIP_EDITOR_LAUNCHER="true"
export DOTFILES_SKIP_GIT_SHIMS="false"
export DOTFILES_SKIP_SSH_CONFIG="false"
export DOTFILES_SKIP_NODE_LTS="false"
export DOTFILES_SKIP_NPM_PACKAGES="false"

export DOTFILES_DIR="$HOME/x/dotfiles"
export DOTFILES_DEBUG="1"

./shell/install.sh
