#!/bin/bash
set -euo pipefail

# Tests the installation within the Docker container.
# This script is called by docker-test.sh.

# Skip system packages by default in dev/test to save time,
# but can be enabled via environment variable.
export DOTFILES_SKIP_SYSTEM_PACKAGES="${DOTFILES_SKIP_SYSTEM_PACKAGES:-false}"
export DOTFILES_SKIP_HOMEBREW="${DOTFILES_SKIP_HOMEBREW:-true}" # Skip brew default to save time/bandwidth
export DEBIAN_FRONTEND=noninteractive

SCRIPT_TO_TEST="${1:-setup/install.bash}"

echo "▶️  Running install script: $SCRIPT_TO_TEST"
# Ensure we run from workspace root
cd /workspace
./"$SCRIPT_TO_TEST"

echo "▶️  Verifying installation..."

fails=0

check() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "✅ Found $1"
    else
        echo "❌ Missing $1"
        fails=$((fails + 1))
    fi
}

check zsh
check git
check curl
check fzf
# check nvim # Might be skipped
check node
check npm
check docker
check tailscale

if [[ "$fails" -eq 0 ]]; then
    echo "🎉 Test Passed!"
    exit 0
else
    echo "💥 Test Failed with $fails missing tools."
    exit 1
fi
