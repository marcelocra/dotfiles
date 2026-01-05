#!/usr/bin/env bash
# ⚠️  DEPRECATED: This script has been migrated to setup/install.bash
#
# This file is kept as a compatibility stub to warn users who may still
# reference the old path. All functionality has been moved to setup/install.bash
# which includes additional features (Docker, Tailscale, locale config, etc.)
#
# Please update your references to use: ./setup/install.bash
# Or use the root wrapper: ./install.bash

set -euo pipefail

log_warning() {
    printf '\033[1;33m[dotfiles:warning]\033[0m %s\n' "$*" >&2
}

log_info() {
    printf '\033[0;34m[dotfiles]\033[0m %s\n' "$*"
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/x/dotfiles}"

log_warning "⚠️  shell/install.sh is deprecated and has been migrated to setup/install.bash"
log_info ""
log_info "Redirecting to setup/install.bash..."
log_info ""

# Forward all arguments and environment variables
exec "$DOTFILES_DIR/setup/install.bash" "$@"
