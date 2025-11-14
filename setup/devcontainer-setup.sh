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
SETUP_EDITOR_LAUNCHER="${MCRA_SETUP_EDITOR_LAUNCHER:-true}"
SETUP_SYSTEM_PACKAGES="${MCRA_SETUP_SYSTEM_PACKAGES:-true}"
SETUP_PNPM="${MCRA_SETUP_PNPM:-true}"

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

# Setup SSH keys with proper permissions.
setup_ssh_keys() {
    [ ! -d "$HOME/.ssh-from-host" ] && {
        log "ℹ️  No SSH keys to copy (no .ssh-from-host directory found)"
        return 0
    }

    log "🔑 Setting up SSH keys..."
    cp -r ~/.ssh-from-host/. ~/.ssh
    chmod 700 ~/.ssh
    find ~/.ssh -type f -exec chmod 600 {} \;
    log "✅ SSH keys configured"
}

# Create directory structure.
setup_directories() {
    log "📁 Creating directory structure..."
    mkdir -p "$PROJECTS_DIR"
    log "✅ Directories created"
}

# Setup dotfiles repository and configuration.
setup_dotfiles() {
    [ "$SETUP_DOTFILES" != "true" ] && {
        log "⏭️  Skipping dotfiles setup (MCRA_SETUP_DOTFILES=false)"
        return 0
    }

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
    printf "\n\nsource $DOTFILES_DIR/shell/init.sh\n\n" >> $HOME/.bashrc
    printf "\n\nsource $DOTFILES_DIR/shell/init.sh\n\n" >> $HOME/.zshrc
}

# Setup zsh plugins for enhanced shell experience.
setup_zsh_plugins() {
    [ "$SETUP_ZSH_PLUGINS" != "true" ] && {
        log "⏭️  Skipping zsh plugins setup (MCRA_SETUP_ZSH_PLUGINS=false)"
        return 0
    }

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
}

# Setup mise for runtime version management.
setup_mise() {
    [ "$SETUP_MISE" != "true" ] && {
        log "⏭️  Skipping mise setup (MCRA_SETUP_MISE=false)"
        return 0
    }

    command_exists mise && {
        log "ℹ️  mise already installed"
        return 0
    }

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
    log "✅ mise installed and configured"
}

# Setup editor launcher command.
setup_editor_launcher() {
    [ "$SETUP_EDITOR_LAUNCHER" != "true" ] && {
        log "⏭️  Skipping editor launcher setup (MCRA_SETUP_EDITOR_LAUNCHER=false)"
        return 0
    }

    [ ! -f "$DOTFILES_DIR/shell/e" ] && {
        log "⚠️  'e' editor launcher script not found in dotfiles, skipping..."
        return 0
    }

    [[ ! -d "$HOME/bin" ]] && mkdir -p "$HOME/bin"
    log "🔗 Setting up 'e' editor launcher command..."
    ln -sf "$DOTFILES_DIR/shell/e" "$HOME/bin/e"
    log "✅ 'e' editor launcher set up"
}

# Install essential system packages.
setup_system_packages() {
    [ "$SETUP_SYSTEM_PACKAGES" != "true" ] && {
        log "⏭️  Skipping system packages setup (MCRA_SETUP_SYSTEM_PACKAGES=false)"
        return 0
    }

    # Note: Assumes Debian/Ubuntu-based image (apt). If using different base images,
    # this section may need adjustment for different package managers.
    log "📦 Installing essential system packages..."
    
    ! command_exists apt-get && {
        log "⚠️  apt-get not found. Skipping system package installation."
        log "    If using non-Debian/Ubuntu image, install tmux, fzf manually."
        return 0
    }

    # Update package list only if it's stale (older than 1 day).
    if [ ! -f /var/lib/apt/lists/lock ] || [ "$(find /var/lib/apt/lists -mtime +1 -print -quit)" ]; then
        sudo apt-get update
    fi
    
    # Install packages if not already present.
    PACKAGES_TO_INSTALL=()
    
    ! command_exists tmux && PACKAGES_TO_INSTALL+=(tmux)
    ! command_exists git-lfs && PACKAGES_TO_INSTALL+=(git-lfs)
    
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
}

# Setup pnpm and install global npm packages.
setup_pnpm() {
    [ "$SETUP_PNPM" != "true" ] && {
        log "⏭️  Skipping pnpm setup (MCRA_SETUP_PNPM=false)"
        return 0
    }

    if ! command_exists pnpm; then
        log "📦 Installing pnpm..."
        npm install -g pnpm
        log "✅ pnpm installed"
    else
        log "ℹ️  pnpm already installed"
    fi

    log "⚙️  Configuring pnpm global store..."
    export PNPM_HOME="/home/node/.local/share/pnpm"
    mkdir -p "$PNPM_HOME"
    case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
    esac

    # Install global packages with pnpm.
    log "📦 Installing global npm packages with pnpm..."
    pnpm add -g $NPM_INSTALL
    log "✅ Global npm packages installed with pnpm"
}

# Main setup orchestration.
main() {
    setup_ssh_keys
    setup_directories
    setup_dotfiles
    setup_zsh_plugins
    setup_mise
    setup_editor_launcher
    setup_system_packages
    setup_pnpm

    log "🎉 Container setup complete! Welcome to your development environment."
    log "💡 Your dotfiles are linked and zsh plugins are ready to use."
    log "🔧 To customize this setup, edit: https://github.com/$GITHUB_HANDLE/dotfiles/blob/main/setup/devcontainer-setup.sh"
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

# Execute main function.
main "$@"
