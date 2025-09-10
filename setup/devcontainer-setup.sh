#!/bin/bash
# devcontainer-setup.sh
# Personal devcontainer setup script for development environment.
# Usage: curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/setup/devcontainer-setup.sh | bash

set -e

# Configuration from environment variables or defaults.
GITHUB_HANDLE="${MCRA_GITHUB_HANDLE:-marcelocra}"
CONFIG_DIR="${MCRA_CONFIG:-$HOME/.config/marcelocra}"
PROJECTS_DIR="${MCRA_PROJECTS:-$HOME/prj}"
DOTFILES_DIR="$CONFIG_DIR/dotfiles"
SETUP_DOTFILES="${MCRA_SETUP_DOTFILES:-true}"
SETUP_ZSH_PLUGINS="${MCRA_SETUP_ZSH_PLUGINS:-true}"

echo "🚀 Starting devcontainer setup"
echo "👤 User: $(whoami)"
echo "🏠 Home: $HOME"
echo "📋 GitHub Handle: $GITHUB_HANDLE"
echo "📁 Config Dir: $CONFIG_DIR"
echo "📁 Projects Dir: $PROJECTS_DIR"
echo "📦 Dotfiles Dir: $DOTFILES_DIR"

# Function to log with timestamps.
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# User Management Decision: Using default 'codespace' user.
#
# Attempted custom 'marcelo' user but encountered UID/GID mismatch issues:
# [1] Bind mounts break with permission conflicts (Claude Code settings fail).
# [2] Changing ownership affects host system files with wrong UID (525288).
# [3] Requires excessive sudo usage for basic operations.
#
# DevMagic v1.0.0 architecture: Stick with container defaults for better
# cross-platform compatibility and fewer permission headaches.
#
# # Change ownership of the mounted workspace first.
# sudo chown -R marcelo:marcelo /workspaces
# # Fix permissions for the NVM directory.
# sudo chown -R marcelo:marcelo /usr/local/share/nvm
# It also require sudo in the `cp -r ~/.ssh-from-host/. ~/.ssh` command below
# and in the command below it (chmod 700).

# Copy SSH keys with proper permissions for cross-platform compatibility.
if [ -d "$HOME/.ssh-from-host" ]; then
    log "🔑 Setting up SSH keys..."
    cp -r ~/.ssh-from-host/. ~/.ssh
    chmod 700 ~/.ssh
    find ~/.ssh -type f -exec chmod 600 {} \;
    log "✅ SSH keys configured"
else
    log "ℹ️  No SSH keys to copy (no .ssh-from-host directory found)"
fi

# Create directory structure.
log "📁 Creating directory structure..."
mkdir -p "$CONFIG_DIR"
mkdir -p "$PROJECTS_DIR"
log "✅ Directories created"

# Setup dotfiles.
if [ "$SETUP_DOTFILES" = "true" ]; then
    # Check if VS Code already cloned dotfiles.
    if [ -d "$HOME/dotfiles" ] && [ ! -d "$DOTFILES_DIR" ]; then
        log "🔗 Found VS Code dotfiles, creating symlink..."
        ln -sf "$HOME/dotfiles" "$DOTFILES_DIR"
        log "✅ VS Code dotfiles linked"
    elif [ ! -d "$DOTFILES_DIR" ]; then
        log "📦 Cloning dotfiles..."
        git clone --depth 1 "https://github.com/$GITHUB_HANDLE/dotfiles.git" "$DOTFILES_DIR"
        log "✅ Dotfiles cloned"
    else
        log "ℹ️  Dotfiles already exist, updating..."
        (cd "$DOTFILES_DIR" && git pull)
        log "✅ Dotfiles updated"
    fi

    # Create symlinks for shell configuration.
    log "🔗 Creating shell configuration symlinks..."
    ln -sf "$DOTFILES_DIR/shell/.tmux.conf" "$HOME/.tmux.conf"
    ln -sf "$DOTFILES_DIR/shell/init.sh" "$HOME/.bashrc"
    ln -sf "$DOTFILES_DIR/shell/init.sh" "$HOME/.zshrc"
    log "✅ Shell configuration symlinks created"
else
    log "⏭️  Skipping dotfiles setup (MCRA_SETUP_DOTFILES=false)"
fi

# Setup zsh plugins.
if [ "$SETUP_ZSH_PLUGINS" = "true" ]; then
    ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
        log "🔌 Installing zsh-autosuggestions plugin..."
        git clone --depth 1 "https://github.com/$GITHUB_HANDLE/zsh-autosuggestions" "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
        log "✅ zsh-autosuggestions installed"
    else
        log "ℹ️  zsh-autosuggestions already exists, updating..."
        (cd "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" && git pull)
    fi

    if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
        log "🔌 Installing zsh-syntax-highlighting plugin..."
        git clone --depth 1 "https://github.com/$GITHUB_HANDLE/zsh-syntax-highlighting.git" "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
        log "✅ zsh-syntax-highlighting installed"
    else
        log "ℹ️  zsh-syntax-highlighting already exists, updating..."
        (cd "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" && git pull)
    fi
else
    log "⏭️  Skipping zsh plugins setup (MCRA_SETUP_ZSH_PLUGINS=false)"
fi

# Setup mise for environment management.
if [ "${MCRA_USE_MISE:-false}" = "true" ] && ! command -v mise &> /dev/null; then
    log "🔌 Installing mise for runtime version management..."
    curl https://mise.run | sh
    # Add mise to the current shell's PATH to use it immediately.
    export PATH="$HOME/.local/bin:$PATH"
    mise use --global uv clojure babashka deno
    # Check if npm is available globally, if not install node/npm via mise.
    if ! command -v npm &> /dev/null; then
        log "📦 Installing Node.js/npm via mise..."
        mise use --global node@lts
    fi
    npm install -g @google/gemini-cli @anthropic-ai/claude-code
    log "✅ mise installed and configured."
else
    if command -v npm &> /dev/null; then
        log "Installing gemini-cli & claude code..."
        npm install -g @google/gemini-cli @anthropic-ai/claude-code
    fi
    log "ℹ️  Done. Skipping mise installation (MCRA_USE_MISE is false or mise is already installed)."
fi

# Additional project-specific setup can go here.
# This could be extended with project detection, language-specific tools, etc.

log "🎉 Container setup complete! Welcome to your development environment."
log "💡 Your dotfiles are linked and zsh plugins are ready to use."
log "🔧 To customize this setup, edit: https://github.com/$GITHUB_HANDLE/dotfiles/blob/main/setup/devcontainer-setup.sh"
