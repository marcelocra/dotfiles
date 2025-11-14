#!/bin/bash
# devcontainer-setup.sh
# Personal devcontainer setup script for development environment.
# Usage: curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/setup/devcontainer-setup.sh | bash

set -e

# Configuration from environment variables or defaults.
GITHUB_HANDLE="${MCRA_GITHUB_HANDLE:-marcelocra}"
PROJECTS_DIR="${MCRA_PROJECTS:-$HOME/prj}"
DOTFILES_DIR="$PROJECTS_DIR/dotfiles"

SETUP_DOTFILES="${MCRA_SETUP_DOTFILES:-true}"
SETUP_ZSH_PLUGINS="${MCRA_SETUP_ZSH_PLUGINS:-true}"
SETUP_MISE="${MCRA_SETUP_MISE:-false}"

NPM_PACKAGES_UNUSED=(
    "@openai/codex"
)
NPM_PACKAGES=(
    "@google/gemini-cli"
    "@anthropic-ai/claude-code"
    "@github/copilot"
)
NPM_INSTALL="${MCRA_NPM_INSTALL:-${NPM_PACKAGES[*]}}"

echo "🚀 Starting devcontainer setup"
echo "👤 User: $(whoami)"
echo "🏠 Home: $HOME"
echo "📋 GitHub Handle: $GITHUB_HANDLE"
echo "📁 Projects Dir: $PROJECTS_DIR"
echo "📦 Dotfiles Dir: $DOTFILES_DIR"

# Function to log with timestamps.
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check if a command exists.
command_exists() {
    command -v "$1" &> /dev/null
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
    log "✅ Shell configuration symlinks created"
    
    # Source the shell initialization script.
    printf '\n\nsource $DOTFILES_DIR/shell/init.sh\n\n' >> $HOME/.bashrc
    printf '\n\nsource $DOTFILES_DIR/shell/init.sh\n\n' >> $HOME/.zshrc
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
if [ "$SETUP_MISE" = "true" ] && ! command_exists mise; then
    log "🔌 Installing mise for runtime version management..."
    curl https://mise.run | sh
    # Add mise to the current shell's PATH to use it immediately.
    export PATH="$HOME/.local/bin:$PATH"
    mise use --global uv clojure babashka deno
    # Check if npm is available globally, if not install node/npm via mise.
    if ! command_exists npm; then
        log "📦 Installing Node.js/npm via mise..."
        mise use --global node@lts
    fi
    log "✅ mise installed and configured."
else
    log "ℹ️  Done. Skipping mise installation (MCRA_SETUP_MISE is false or mise is already installed)."
fi

# Setup pnpm and install global packages.
if ! command_exists pnpm; then
    log "📦 Installing pnpm..."
    npm install -g pnpm
    log "✅ pnpm installed"
else
    log "ℹ️  pnpm already installed"
    log "⚙️  Configuring pnpm global store..."
    export PNPM_HOME="/home/node/.local/share/pnpm"
    mkdir -p "$PNPM_HOME"
    case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
    esac

    # install global packages with pnpm
    log "📦 Installing global npm packages with pnpm..."
    pnpm add -g $NPM_INSTALL
    log "✅ Global npm packages installed with pnpm"
fi

# Setup the `e` editor launcher command.
if [[ -f $DOTFILES_DIR/shell/e ]]; then
    [[ ! -d "$HOME/bin" ]] && mkdir -p "$HOME/bin"
    log "🔗 Setting up 'e' editor launcher command..."
    ln -sf "$DOTFILES_DIR/shell/e" "$HOME/bin/e"
    log "✅ 'e' editor launcher set up"
else
    log "⚠️ 'e' editor launcher script not found in dotfiles, skipping..."
fi

# Install essential system packages.
# Note: Assumes Debian/Ubuntu-based image (apt). If using different base images,
# this section may need adjustment for different package managers.
log "📦 Installing essential system packages..."
if command_exists apt-get; then
    # Update package list only if it's stale (older than 1 day).
    if [ ! -f /var/lib/apt/lists/lock ] || [ "$(find /var/lib/apt/lists -mtime +1 -print -quit)" ]; then
        sudo apt-get update
    fi
    
    # Install packages if not already present.
    PACKAGES_TO_INSTALL=()
    
    if ! command_exists tmux; then
        PACKAGES_TO_INSTALL+=(tmux)
    fi
    
    # git-lfs is typically handled by devcontainer feature, but check anyway.
    if ! command_exists git-lfs; then
        PACKAGES_TO_INSTALL+=(git-lfs)
    fi
    
    if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
        log "📦 Installing: ${PACKAGES_TO_INSTALL[*]}"
        sudo apt-get install -y "${PACKAGES_TO_INSTALL[@]}"
        log "✅ System packages installed"
    else
        log "ℹ️  All essential packages already installed"
    fi
    
    # Install fzf from GitHub (apt version is too old).
    if ! command_exists fzf; then
        log "📦 Installing fzf from GitHub..."
        git clone --depth 1 https://github.com/$GITHUB_HANDLE/fzf.git ~/.fzf
        ~/.fzf/install --bin
        # Move binary to user bin directory.
        mkdir -p "$HOME/bin"
        ln -sf ~/.fzf/bin/fzf "$HOME/bin/fzf"
        log "✅ fzf installed"
    else
        log "ℹ️  fzf already installed"
    fi
else
    log "⚠️  apt-get not found. Skipping system package installation."
    log "    If using non-Debian/Ubuntu image, install tmux, fzf manually."
fi

# Additional project-specific setup can go here.
# This could be extended with project detection, language-specific tools, etc.

log "🎉 Container setup complete! Welcome to your development environment."
log "💡 Your dotfiles are linked and zsh plugins are ready to use."
log "🔧 To customize this setup, edit: https://github.com/$GITHUB_HANDLE/dotfiles/blob/main/setup/devcontainer-setup.sh"
