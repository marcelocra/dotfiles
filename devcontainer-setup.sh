#!/bin/bash
# devcontainer-setup.sh
# Personal devcontainer setup script for development environment.
# Usage: curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/devcontainer-setup.sh | bash

set -e

# Configuration from environment variables or defaults.
GITHUB_HANDLE="${MCRA_GITHUB_HANDLE:-marcelocra}"
CONFIG_DIR="${MCRA_CONFIG:-$HOME/.config/marcelocra}"
PROJECTS_DIR="${MCRA_PROJECTS:-$HOME/prj}"
DOTFILES_DIR="$CONFIG_DIR/dotfiles"
SETUP_DOTFILES="${MCRA_SETUP_DOTFILES:-true}"
SETUP_ZSH_PLUGINS="${MCRA_SETUP_ZSH_PLUGINS:-true}"
SETUP_VSCODE="${MCRA_SETUP_VSCODE:-true}"
SETUP_SUBLIME="${MCRA_SETUP_SUBLIME:-true}"
SETUP_ZED="${MCRA_SETUP_ZED:-true}"

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

    # Create symlinks for editor configurations.
    if [ "$SETUP_VSCODE" = "true" ] && [ -d "$DOTFILES_DIR/vscode" ]; then
        log "🔗 Setting up VS Code configuration..."
        mkdir -p "$HOME/.config/Code/User"
        ln -sf "$DOTFILES_DIR/vscode/"* "$HOME/.config/Code/User/"
        log "✅ VS Code configuration linked"
    fi

    if [ "$SETUP_SUBLIME" = "true" ] && [ -d "$DOTFILES_DIR/sublime" ]; then
        log "🔗 Setting up Sublime Text configuration..."
        mkdir -p "$HOME/.config/sublime-text-3/Packages/User"
        ln -sf "$DOTFILES_DIR/sublime/"* "$HOME/.config/sublime-text-3/Packages/User/"
        log "✅ Sublime Text configuration linked"
    fi

    if [ "$SETUP_ZED" = "true" ] && [ -d "$DOTFILES_DIR/zed" ]; then
        log "🔗 Setting up Zed configuration..."
        mkdir -p "$HOME/.config/zed"
        ln -sf "$DOTFILES_DIR/zed/"* "$HOME/.config/zed/"
        log "✅ Zed configuration linked"
    fi

    log "✅ All dotfile symlinks created"
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

# Additional project-specific setup can go here.
# This could be extended with project detection, language-specific tools, etc.

log "🎉 Container setup complete! Welcome to your development environment."
log "💡 Your dotfiles are linked and zsh plugins are ready to use."
log "🔧 To customize this setup, edit: https://github.com/$GITHUB_HANDLE/dotfiles/blob/main/devcontainer-setup.sh"
