#!/usr/bin/env bash
set -euo pipefail

# Tests the installation within the Docker container.
# This script is called by docker-test.bash.

# Skip system packages by default in dev/test to save time,
# but can be enabled via environment variable.
export DOTFILES_SKIP_SYSTEM_PACKAGES="${DOTFILES_SKIP_SYSTEM_PACKAGES:-false}"
export DOTFILES_SKIP_HOMEBREW="${DOTFILES_SKIP_HOMEBREW:-true}" # Skip brew default to save time/bandwidth
export DOTFILES_SKIP_DOCKER="${DOTFILES_SKIP_DOCKER:-true}"     # Skip Docker-in-Docker
export DOTFILES_SKIP_TAILSCALE="${DOTFILES_SKIP_TAILSCALE:-true}" # Skip Tailscale in container
export DEBIAN_FRONTEND=noninteractive

SCRIPT_TO_TEST="${1:-setup/install.bash}"

echo "▶️  Running install script: $SCRIPT_TO_TEST"
# Ensure we run from workspace root
cd /workspace
./"$SCRIPT_TO_TEST"

echo "▶️  Verifying installation..."

fails=0

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "✅ Found command: $1"
    else
        echo "❌ Missing command: $1"
        fails=$((fails + 1))
    fi
}

check_file() {
    if [[ -e "$1" ]]; then
        echo "✅ Found file: $1"
    else
        echo "❌ Missing file: $1"
        fails=$((fails + 1))
    fi
}

check_env() {
    if [[ -n "${!1:-}" ]]; then
        echo "✅ Env var set: $1=${!1}"
    else
        echo "⚠️  Env var not set: $1"
    fi
}

# Core commands
check_command zsh
check_command git
check_command curl
check_command fzf
check_command node
check_command npm
check_command gh
check_command aider
# opencode might not be in path immediately or depends on install method, but let's check if we can
# check_command opencode

# Config files (symlinks)
check_file "$HOME/.gitconfig"
check_file "$HOME/.tmux.conf"

# Shell sources init.sh
if grep -q "shell/init.sh" "$HOME/.zshrc" 2>/dev/null; then
    echo "✅ .zshrc sources init.sh"
else
    echo "❌ .zshrc does not source init.sh"
    fails=$((fails + 1))
fi

# Environment variables (source init.sh and check)
source /workspace/shell/init.sh
check_env TZ
check_env LANG
check_env LC_ALL

if [[ "$fails" -eq 0 ]]; then
    echo "🎉 Test Passed!"
    exit 0
else
    echo "💥 Test Failed with $fails issues."
    exit 1
fi

