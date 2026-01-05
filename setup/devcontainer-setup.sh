#!/usr/bin/env bash
# DevMagic Container Setup Script
# Handles container-specific setup: clones dotfiles and runs install.sh
# This runs once when the container is created (postCreateCommand)
#
# All tooling installation (AI CLI tools, Node.js, etc.) is handled by
# dotfiles/setup/install.bash for consistency across all environments.





echo 'INFO: Notice that this is not the official devcontainer-setup.sh script,'
echo 'INFO: but just a reference to be used here when thinking about the whole'
echo 'INFO: system setup. To use this, you should check the latest version at'
echo 'INFO: https://devmagic.run'

return 1





set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging helpers
log() {
    echo -e "${BLUE}$1${NC}"
}

log_success() {
    echo -e "${GREEN}$1${NC}"
}

log_warning() {
    echo -e "${YELLOW}$1${NC}"
}

log_error() {
    echo -e "${RED}$1${NC}"
}

# ---------------------------------------------------------------------------
# Dotfiles Setup
# ---------------------------------------------------------------------------
setup_dotfiles() {
    local dotfiles_dir="$HOME/prj/dotfiles"
    # Override via host env vars: DEVMAGIC_DOTFILES_REPO, DEVMAGIC_DOTFILES_BRANCH
    # Set to empty string to disable: export DEVMAGIC_DOTFILES_REPO=""
    local dotfiles_repo="${DEVMAGIC_DOTFILES_REPO:-https://github.com/marcelocra/dotfiles.git}"
    local dotfiles_branch="${DEVMAGIC_DOTFILES_BRANCH:-main}"

    log "📦 Checking for dotfiles..."

    # Clone dotfiles if directory doesn't exist
    if [ ! -d "$dotfiles_dir" ]; then
        log "   Cloning dotfiles from $dotfiles_repo..."
        mkdir -p "$(dirname "$dotfiles_dir")"
        if git clone --depth=1 --branch "$dotfiles_branch" "$dotfiles_repo" "$dotfiles_dir"; then
            log_success "   Dotfiles cloned successfully"
        else
            log_warning "   Failed to clone dotfiles (network issue?). Skipping."
            return 0
        fi
    else
        log "   Dotfiles directory already exists at $dotfiles_dir"
    fi

    # Run dotfiles installation script if available
    local dotfiles_install="$dotfiles_dir/setup/install.bash"
    if [ -f "$dotfiles_install" ]; then
        log "🧩 Running dotfiles install script..."
        # Use bash to run the script for consistency and error handling.
        # While the script has a shebang and is executable, explicitly using bash:
        # - Ensures consistent interpreter (user's shebang might differ)
        # - Allows "bash -x" for debugging if needed
        # - Works even if execute bit is lost (git clone, file copy)
        # - Standard practice for CI/CD and automation scripts
        bash "$dotfiles_install" || log_warning "⚠️  Dotfiles install script failed"
    else
        log_warning "⚠️  No dotfiles install script found at $dotfiles_install"
        log "   Skipping dotfiles installation"
    fi

    log_success "✅ Dotfiles setup complete"
}

# ---------------------------------------------------------------------------
# Main execution
# ---------------------------------------------------------------------------
main() {
    log "🔧 Running DevMagic container setup..."
    echo

    setup_dotfiles
    echo

    log_success "✅ DevMagic container setup complete!"
    log "ℹ️  All tools installed via dotfiles/setup/install.bash"
}

# Run main function
main
