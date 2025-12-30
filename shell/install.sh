#!/usr/bin/env bash
# Dotfiles installation script
# One-time setup for development tools, shell plugins, and editor configurations.
#
# This script is idempotent and can be run multiple times safely.
# It handles:
#   - Homebrew installation (Linux)
#   - CLI tools (fzf, hugo, babashka, etc.) from custom forks for security
#   - Zsh plugins from custom forks
#   - Shell configuration symlinks
#   - VS Code settings/keybindings symlinks (if VS Code detected)
#   - Editor launcher 'e' command symlink
#   - Git shims for 1Password SSH signing (cross-platform)
#   - SSH config for 1Password (native Linux/macOS only)
#
# Usage:
#   $DOTFILES_DIR/shell/install.sh
#
# Environment variables:
#   DOTFILES_SKIP_SYSTEM_PACKAGES=true  - Skip apt system packages installation (Ubuntu/Debian)
#   DOTFILES_SKIP_DEV_PACKAGES=true     - Skip extended dev packages when installing system packages
#   DOTFILES_SKIP_HOMEBREW=true         - Skip Homebrew installation
#   DOTFILES_SKIP_CLI_TOOLS=true        - Skip CLI tools installation
#   DOTFILES_SKIP_ZSH_PLUGINS=true      - Skip zsh plugins installation
#   DOTFILES_SKIP_VSCODE=true           - Skip VS Code config symlinking
#   DOTFILES_SKIP_EDITOR_LAUNCHER=true  - Skip 'e' editor launcher setup
#   DOTFILES_SKIP_GIT_SHIMS=true        - Skip git shims for 1Password
#   DOTFILES_SKIP_SSH_CONFIG=true       - Skip SSH config for 1Password
#   DOTFILES_DEBUG=1                    - Enable debug logging

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/x/dotfiles}"

# Feature flags (can be disabled via environment variables)
SKIP_SYSTEM_PACKAGES="${DOTFILES_SKIP_SYSTEM_PACKAGES:-false}"
SKIP_DEV_PACKAGES="${DOTFILES_SKIP_DEV_PACKAGES:-true}"
SKIP_HOMEBREW="${DOTFILES_SKIP_HOMEBREW:-true}"
SKIP_CLI_TOOLS="${DOTFILES_SKIP_CLI_TOOLS:-false}"
SKIP_ZSH_PLUGINS="${DOTFILES_SKIP_ZSH_PLUGINS:-false}"
SKIP_VSCODE="${DOTFILES_SKIP_VSCODE:-true}"
SKIP_EDITOR_LAUNCHER="${DOTFILES_SKIP_EDITOR_LAUNCHER:-true}"
SKIP_GIT_SHIMS="${DOTFILES_SKIP_GIT_SHIMS:-false}"
SKIP_SSH_CONFIG="${DOTFILES_SKIP_SSH_CONFIG:-false}"
SKIP_NODE_LTS="${DOTFILES_SKIP_NODE_LTS:-false}"
SKIP_NPM_PACKAGES="${DOTFILES_SKIP_NPM_PACKAGES:-false}"
DEBUG="${DOTFILES_DEBUG:-0}"

# Custom fork repositories (for security - you control the source)
FORK_FZF_REPO="${FORK_FZF_REPO:-https://github.com/marcelocra/fzf.git}"
FORK_ZSH_AUTOSUGGESTIONS="${FORK_ZSH_AUTOSUGGESTIONS:-https://github.com/marcelocra/zsh-autosuggestions.git}"
FORK_ZSH_SYNTAX_HIGHLIGHTING="${FORK_ZSH_SYNTAX_HIGHLIGHTING:-https://github.com/marcelocra/zsh-syntax-highlighting.git}"

# Secure curl wrapper with TLS enforcement.
curl_cmd() {
    curl --proto '=https' --tlsv1.2 -fsSL -o- "$@"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

log_info() {
    printf '\033[0;34m[dotfiles]\033[0m %s\n' "$*"
}

log_success() {
    printf '\033[0;32m[dotfiles]\033[0m %s\n' "$*"
}

log_warning() {
    printf '\033[1;33m[dotfiles]\033[0m %s\n' "$*"
}

log_error() {
    printf '\033[0;31m[dotfiles]\033[0m %s\n' "$*" >&2
}

log_debug() {
    if [[ "${DEBUG}" == "1" ]]; then
        printf '\033[0;90m[dotfiles:debug]\033[0m %s\n' "$*" >&2
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Timing helper - returns elapsed time in human-readable format
format_duration() {
    local seconds="$1"
    if ((seconds < 60)); then
        echo "${seconds}s"
    else
        echo "$((seconds / 60))m $((seconds % 60))s"
    fi
}

# Run a function and report how long it took
timed() {
    local name="$1"
    local func="$2"
    local start_time=$SECONDS

    "$func"
    local exit_code=$?

    local elapsed=$((SECONDS - start_time))
    if ((elapsed > 0)); then
        log_info "⏱️  $name took $(format_duration $elapsed)"
    fi

    return $exit_code
}

# Creates a symlink, backing up any existing file with a timestamp.
# Returns 0 if symlink was created or already correct, 1 if source doesn't exist.
# Usage: safe_symlink <source> <target>
safe_symlink() {
    local source="$1"
    local target="$2"

    # Check if source exists
    if [[ ! -e "$source" ]]; then
        log_warning "⚠️  Source not found: $source"
        return 1
    fi

    # Ensure target directory exists
    mkdir -p "$(dirname "$target")"

    # Check if target already exists
    if [[ -e "$target" ]]; then
        # If it's already a correct symlink, we're done
        if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
            log_debug "Symlink already correct: $target -> $source"
            return 0
        fi
        # Back up existing file with timestamp
        local timestamp
        timestamp=$(date +"%Y%m%d_%H%M%S")
        local backup="${target}.bak.${timestamp}"
        log_info "📦 Backing up existing file to: $backup"
        mv "$target" "$backup"
    fi

    # Create the symlink
    ln -s "$source" "$target"
    log_debug "Created symlink: $target -> $source"
    return 0
}

# =============================================================================
# ENVIRONMENT DETECTION
# =============================================================================

detect_environment() {
    log_debug "Detecting environment..."

    # Check for Bunker env var (passed by setup-golden.bash).
    if [[ "${DOTFILES_IN_BUNKER:-false}" == "true" ]]; then
        export DOTFILES_IN_BUNKER="true"
        log_debug "Environment: DevBunker detected."
    else
        export DOTFILES_IN_BUNKER="false"
    fi

    # Container detection
    if [[ -f /.dockerenv ]] || [[ -n "${CONTAINER:-}" ]] || [[ -f /run/.containerenv ]]; then
        export DOTFILES_IN_CONTAINER="true"
    else
        export DOTFILES_IN_CONTAINER="false"
    fi

    # WSL detection
    if grep -q Microsoft /proc/version 2>/dev/null || \
       grep -q WSL2 /proc/version 2>/dev/null; then
        export DOTFILES_IN_WSL="true"
    else
        export DOTFILES_IN_WSL="false"
    fi

    # Remote VS Code detection
    if [[ -n "${REMOTE_CONTAINERS:-}" ]] || [[ -n "${CODESPACES:-}" ]]; then
        export DOTFILES_IN_REMOTE_VSCODE="true"
    else
        export DOTFILES_IN_REMOTE_VSCODE="false"
    fi

    # SSH session detection (remote connection without local 1Password)
    if [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]]; then
        export DOTFILES_IN_SSH="true"
    else
        export DOTFILES_IN_SSH="false"
    fi

    # Derived: Remote environment (no local 1Password access)
    # Includes: containers, SSH sessions, DevBunker
    # These environments use forwarded SSH agent and need ssh-keygen shim
    if [[ "${DOTFILES_IN_CONTAINER:-false}" == "true" ]] || \
       [[ "${DOTFILES_IN_SSH:-false}" == "true" ]] || \
       [[ "${DOTFILES_IN_BUNKER:-false}" == "true" ]]; then
        export DOTFILES_REMOTE_ENV="true"
    else
        export DOTFILES_REMOTE_ENV="false"
    fi

    log_debug "Container: $DOTFILES_IN_CONTAINER, WSL: $DOTFILES_IN_WSL, SSH: $DOTFILES_IN_SSH, Remote: $DOTFILES_REMOTE_ENV"
}

# Install essential system packages on Debian/Ubuntu systems (idempotent)
install_system_packages() {
    if [[ "$SKIP_SYSTEM_PACKAGES" == "true" ]]; then
        log_info "⏭️  Skipping system packages installation (DOTFILES_SKIP_SYSTEM_PACKAGES=true)"
        return 0
    fi

    if ! command_exists apt-get; then
        log_info "ℹ️  apt-get not found; skipping system packages installation"
        return 0
    fi

    log_info "📦 Installing essential system packages via apt (requires sudo)"

    # Use sudo when not running as root
    local sudo_cmd=""
    if [[ $EUID -ne 0 ]]; then
        if command_exists sudo; then
            sudo_cmd="sudo"
        else
            log_warning "sudo not available and not running as root; attempting apt-get directly"
        fi
    fi

    # Non-interactive install
    export DEBIAN_FRONTEND=noninteractive


    # Update package index
    ${sudo_cmd} apt-get update -y

    # Minimal packages required on a fresh Ubuntu install to compile/build and fetch tooling
    local minimal_packages=(
        apt-transport-https
        build-essential
        ca-certificates
        curl
        gcc
        git
        git-lfs
        gnupg
        jq
        lsb-release
        make
        software-properties-common
        wget
    )

    # Extended development packages (opt-in)
    local dev_packages=(
        cmake
        g++
        libbz2-dev
        libreadline-dev
        libsqlite3-dev
        libssl-dev
        pkg-config
        python3-dev
        python3-pip
        python3-venv
        unzip
        zip
        zlib1g-dev
    )

    local packages=("${minimal_packages[@]}")
    if [[ "${SKIP_DEV_PACKAGES}" == "true" ]]; then
        log_info "ℹ️  Skipping extended dev packages (DOTFILES_SKIP_DEV_PACKAGES=true)"
    else
        log_info "ℹ️  Including extended dev packages (not skipped)"
        packages+=("${dev_packages[@]}")
    fi

    # Install packages in one call; tolerate failure but warn
    if ! ${sudo_cmd} apt-get install -y "${packages[@]}"; then
        log_warning "Some apt packages failed to install"
    else
        log_success "✅ System packages installed"
    fi

    return 0
}

# =============================================================================
# HOMEBREW INSTALLATION
# =============================================================================

install_homebrew() {
    if [[ "$SKIP_HOMEBREW" == "true" ]]; then
        log_info "⏭️  Skipping Homebrew installation (DOTFILES_SKIP_HOMEBREW=true)"
        return 0
    fi

    if command_exists brew; then
        log_info "✅ Homebrew already installed"
        return 0
    fi

    log_info "📦 Installing Homebrew (Linuxbrew)..."

    # Install Homebrew using official script
    # Note: For even more security, you could fork the install script and use your fork
    curl_cmd https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

    # Add brew to current shell session
    if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        log_success "✅ Homebrew installed successfully"
    else
        log_error "❌ Homebrew installation failed - directory not found"
        return 1
    fi
}

# =============================================================================
# CLI TOOLS INSTALLATION
# =============================================================================

install_cli_tools() {
    if [[ "$SKIP_CLI_TOOLS" == "true" ]]; then
        log_info "⏭️  Skipping CLI tools installation (DOTFILES_SKIP_CLI_TOOLS=true)"
        return 0
    fi

    log_info "🔧 Installing CLI tools..."

    install_nvm
    install_node_lts
    install_global_npm_packages
    install_fzf
    install_just
    install_oh_my_zsh

    # Install other tools via Homebrew (if available)
    if command_exists brew; then
        install_brew_packages
    else
        log_warning "⚠️  Homebrew not available, skipping brew package installation"
    fi
}

install_nvm() {
    if command_exists nvm; then
        log_info "✅ nvm already installed"
        return 0
    fi

    log_info "📦 Installing nvm (Node Version Manager)..."

    # Install nvm using official script. Shell init.sh already loads nvm on new shells.
    curl_cmd https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

    log_success "✅ nvm installed successfully"
}

install_node_lts() {
    if [[ "$SKIP_NODE_LTS" == "true" ]]; then
        log_info "⏭️  Skipping Node.js LTS installation (DOTFILES_SKIP_NODE_LTS=true)"
        return 0
    fi

    local nvm_dir="${NVM_DIR:-$HOME/.nvm}"

    # Load nvm if not loaded (early return if unavailable)
    if ! command_exists nvm && [[ ! -s "$nvm_dir/nvm.sh" ]]; then
        log_warning "⚠️  nvm not found, skipping Node.js LTS installation"
        return 0
    fi

    export NVM_DIR="$nvm_dir"
    # shellcheck source=/dev/null
    source "$nvm_dir/nvm.sh"

    # Check if any Node version is installed
    if nvm ls --no-colors 2>/dev/null | grep -q 'v[0-9]'; then
        log_info "✅ Node.js already installed"
        return 0
    fi

    log_info "📦 Installing Node.js LTS..."
    nvm install --lts
    nvm alias default 'lts/*'
    log_success "✅ Node.js LTS installed and set as default"
}

install_global_npm_packages() {
    if [[ "$SKIP_NPM_PACKAGES" == "true" ]]; then
        log_info "⏭️  Skipping global npm packages (DOTFILES_SKIP_NPM_PACKAGES=true)"
        return 0
    fi

    log_info "📦 Installing global npm packages..."

    # Configure pnpm home for usage here (init.sh already adds this to PATH).
    export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
    mkdir -p "$PNPM_HOME"
    case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
    esac

    # Install pnpm if not available (using official installer, PNPM_HOME skips shell config)
    if ! command_exists pnpm; then
        log_info "   Installing pnpm..."
        curl_cmd https://get.pnpm.io/install.sh | sh - || {
            log_warning "⚠️  Failed to install pnpm, skipping global packages"
            return 0
        }
    fi

    # Packages to install globally (AI CLI tools, etc.)
    local packages=(
        "@anthropic-ai/claude-code"
        "@google/gemini-cli"
        "@github/copilot"
        "@google/jules"
        "@openai/codex"
    )

    log_info "   Installing: ${packages[*]}"
    pnpm add -g "${packages[@]}"

    log_success "✅ Global npm packages installed"
}

install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_info "✅ oh-my-zsh already installed"
        return 0
    fi

    log_info "📦 Installing oh-my-zsh..."

    # Install oh-my-zsh using official script
    # Note: For more security, you could fork the install script and use your fork
    curl_cmd https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended

    log_success "✅ oh-my-zsh installed successfully"
}

install_just() {
    if command_exists just; then
        log_info "✅ just already installed"
        return 0
    fi

    log_info "📦 Installing just..."

    mkdir -p $HOME/bin
    curl_cmd https://just.systems/install.sh | bash -s -- --to $HOME/bin

    log_success "✅ just installed successfully"
}

# Install fzf from custom fork for security
install_fzf() {
    local fzf_dir="$HOME/.fzf"
    local fzf_bin="$HOME/bin/fzf"

    if command_exists fzf && [[ -L "$fzf_bin" ]]; then
        log_info "✅ fzf already installed (custom fork)"
        return 0
    fi

    log_info "📦 Installing fzf from custom fork..."

    if [[ -d "$fzf_dir" ]]; then
        log_debug "Updating existing fzf installation..."
        (cd "$fzf_dir" && git pull) || log_warning "Failed to update fzf"
    else
        log_debug "Cloning fzf from $FORK_FZF_REPO..."
        git clone --depth 1 "$FORK_FZF_REPO" "$fzf_dir"
    fi

    # Install binary only (skip shell integration - that's in init.sh)
    "$fzf_dir/install" --bin

    # Create symlink in ~/bin
    mkdir -p "$HOME/bin"
    ln -sf "$fzf_dir/bin/fzf" "$fzf_bin"

    log_success "✅ fzf installed from custom fork"
}

install_brew_packages() {
    log_info "📦 Installing packages via Homebrew..."

    # bat: better cat
    # babashka: clojure scripting
    # fd: better find
    # ripgrep: better grep
    # ---------- Other tools that might be useful one day. -----------------
    # "jq"   # JSON processor. Already present in the image I'm using.
    # "hugo" # Static site generator. I usually prefer Astro or Next.
    # "eza"  # Better ls. TODO: Compare with exa and decide which to use.
    # "yq"   # YAML processor. I don't deal that much with yaml files.
    local packages=(
        "bat"
        "borkdude/brew/babashka"
        "fd"
        "ripgrep"
    )

    local to_install=()

    # Check which packages need to be installed
    for pkg in "${packages[@]}"; do
        if ! brew list "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        log_info "Installing: ${to_install[*]}"
        brew install "${to_install[@]}" || log_warning "Some brew packages failed to install"
        log_success "✅ Brew packages installed"
    else
        log_info "✅ All brew packages already installed"
    fi
}

# =============================================================================
# ZSH PLUGINS INSTALLATION
# =============================================================================

install_zsh_plugins() {
    if [[ "$SKIP_ZSH_PLUGINS" == "true" ]]; then
        log_info "⏭️  Skipping zsh plugins installation (DOTFILES_SKIP_ZSH_PLUGINS=true)"
        return 0
    fi

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_warning "⚠️  oh-my-zsh not found, skipping plugin installation"
        log_info "ℹ️  Install oh-my-zsh first or use a devcontainer with common-utils feature"
        return 0
    fi

    log_info "🔌 Installing zsh plugins from custom forks..."

    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Install zsh-autosuggestions from custom fork
    install_zsh_plugin \
        "zsh-autosuggestions" \
        "$FORK_ZSH_AUTOSUGGESTIONS" \
        "$zsh_custom/plugins/zsh-autosuggestions"

    # Install zsh-syntax-highlighting from custom fork
    install_zsh_plugin \
        "zsh-syntax-highlighting" \
        "$FORK_ZSH_SYNTAX_HIGHLIGHTING" \
        "$zsh_custom/plugins/zsh-syntax-highlighting"

    log_success "✅ Zsh plugins installed from custom forks"
}

install_zsh_plugin() {
    local name="$1"
    local repo="$2"
    local dest="$3"

    if [[ -d "$dest" ]]; then
        log_debug "Updating $name..."
        (cd "$dest" && git pull) || log_warning "Failed to update $name"
    else
        log_debug "Cloning $name from $repo..."
        git clone --depth 1 "$repo" "$dest"
    fi
}

# =============================================================================
# SHELL CONFIGURATION SYMLINKS
# =============================================================================

link_shell_configs() {
    log_info "🔗 Creating shell configuration symlinks..."

    # .zshrc - source init.sh
    local zshrc="$HOME/.zshrc"
    local init_source="source $DOTFILES_DIR/shell/init.sh"
    if [[ -f "$zshrc" ]]; then
        if ! grep -q "source.*shell/init.sh" "$zshrc"; then
            log_debug "Adding init.sh source to .zshrc..."
            echo "" >> "$zshrc"
            echo "# Dotfiles initialization" >> "$zshrc"
            echo "$init_source" >> "$zshrc"
        else
            log_debug ".zshrc already sources init.sh"
        fi
    else
        log_debug "Creating .zshrc with init.sh source..."
        echo "# Dotfiles initialization" > "$zshrc"
        echo "$init_source" >> "$zshrc"
    fi

    # .bashrc - source init.sh
    local bashrc="$HOME/.bashrc"
    if [[ -f "$bashrc" ]]; then
        if ! grep -q "source.*shell/init.sh" "$bashrc"; then
            log_debug "Adding init.sh source to .bashrc..."
            echo "" >> "$bashrc"
            echo "# Dotfiles initialization" >> "$bashrc"
            echo "$init_source" >> "$bashrc"
        else
            log_debug ".bashrc already sources init.sh"
        fi
    else
        log_debug "Creating .bashrc with init.sh source..."
        echo "# Dotfiles initialization" > "$bashrc"
        echo "$init_source" >> "$bashrc"
    fi

    # .tmux.conf - symlink if exists in dotfiles
    if [[ -f "$DOTFILES_DIR/shell/.tmux.conf" ]]; then
        safe_symlink "$DOTFILES_DIR/shell/.tmux.conf" "$HOME/.tmux.conf"
    fi

    # .gitconfig - symlink if exists in dotfiles
    if [[ -f "$DOTFILES_DIR/git/.gitconfig" ]]; then
        safe_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    fi

    log_success "✅ Shell configuration symlinks created"
}

# =============================================================================
# VS CODE CONFIGURATION
# =============================================================================

detect_vscode_config_dir() {
    log_debug "Detecting VS Code config directory..."

    # Remote container (most common in DevMagic)
    if [[ "$DOTFILES_IN_REMOTE_VSCODE" == "true" ]]; then
        # Try different remote paths in order of preference
        if [[ -d "$HOME/.vscode-server-insiders/data/User" ]]; then
            echo "$HOME/.vscode-server-insiders/data/User"
            return 0
        elif [[ -d "$HOME/.vscode-server/data/User" ]]; then
            echo "$HOME/.vscode-server/data/User"
            return 0
        elif [[ -d "$HOME/.vscode-remote/data/User" ]]; then
            echo "$HOME/.vscode-remote/data/User"
            return 0
        else
            # Create default remote path
            local default_dir="$HOME/.vscode-server/data/User"
            mkdir -p "$default_dir"
            echo "$default_dir"
            return 0
        fi
    fi

    # Native VS Code on Linux
    if [[ -d "$HOME/.config/Code/User" ]]; then
        echo "$HOME/.config/Code/User"
        return 0
    fi

    # Native VS Code on macOS
    if [[ -d "$HOME/Library/Application Support/Code/User" ]]; then
        echo "$HOME/Library/Application Support/Code/User"
        return 0
    fi

    # VS Code Insiders on Linux
    if [[ -d "$HOME/.config/Code - Insiders/User" ]]; then
        echo "$HOME/.config/Code - Insiders/User"
        return 0
    fi

    log_debug "VS Code config directory not found"
    return 1
}

link_vscode_configs() {
    if [[ "$SKIP_VSCODE" == "true" ]]; then
        log_info "⏭️  Skipping VS Code config symlinking (DOTFILES_SKIP_VSCODE=true)"
        return 0
    fi

    log_info "🔗 Detecting VS Code configuration directory..."

    local vscode_dir
    vscode_dir=$(detect_vscode_config_dir) || {
        log_info "ℹ️  VS Code not detected, skipping config symlinks"
        return 0
    }

    log_info "📝 Linking VS Code configs to $vscode_dir"

    # Settings
    safe_symlink "$DOTFILES_DIR/apps/vscode/User/settings.json" "$vscode_dir/settings.json"

    # Keybindings
    safe_symlink "$DOTFILES_DIR/apps/vscode/User/keybindings.json" "$vscode_dir/keybindings.json"

    # Snippets
    safe_symlink "$DOTFILES_DIR/apps/vscode/User/snippets" "$vscode_dir/snippets"

    log_success "✅ VS Code configs symlinked"
}

# =============================================================================
# EDITOR LAUNCHER SETUP
# =============================================================================

setup_editor_launcher() {
    if [[ "$SKIP_EDITOR_LAUNCHER" == "true" ]]; then
        log_info "⏭️  Skipping editor launcher setup (DOTFILES_SKIP_EDITOR_LAUNCHER=true)"
        return 0
    fi

    local source_file="$DOTFILES_DIR/shell/e"
    local target_file="$HOME/bin/e"

    log_info "🔗 Setting up 'e' editor launcher command..."

    if safe_symlink "$source_file" "$target_file"; then
        log_success "✅ 'e' editor launcher set up"
    fi
}

# =============================================================================
# GIT SHIMS SETUP (1Password SSH Signing)
# =============================================================================

detect_platform() {
    # Ensure environment flags are available
    detect_environment

    # PRIORITY 1: Remote environments (Container, Bunker, SSH)
    # Use forwarded auth, no local 1Password binary.
    # IMPORTANT: This check MUST be before WSL detection.
    if [[ "${DOTFILES_REMOTE_ENV:-false}" == "true" ]]; then
        echo "linux"
        return 0
    fi

    # Determine platform using only DOTFILES_* environment flags
    if [[ "${DOTFILES_IN_WSL:-false}" == "true" ]]; then
        echo "wsl"
        return 0
    fi

    # If not WSL and not container, default to linux for native Linux usage
    # Note: macOS/windows detection isn't available via DOTFILES_* flags here,
    # but we preserve the set of possible outputs by falling back to linux.
    echo "linux"
}

# Returns the path to 1Password SSH signer binary if it exists, or fails
resolve_op_signer_binary() {
    local platform="$1"
    local binary_path=""

    # REMOTE ENVIRONMENT STRATEGY:
    # Since we cannot reach local 1Password, we mock the signer.
    # We point 'op-signer' to 'ssh-keygen'.
    # Git calls 'op-signer -Y sign ...', which maps to 'ssh-keygen -Y sign ...'
    # This works perfectly with standard SSH keys or forwarded agent keys.
    if [[ "${DOTFILES_REMOTE_ENV:-false}" == "true" ]]; then
        log_debug "Remote env detected: Mocking 1Password signer with native ssh-keygen."

        local ssh_keygen_path
        ssh_keygen_path=$(command -v ssh-keygen)

        if [[ -x "$ssh_keygen_path" ]]; then
            echo "$ssh_keygen_path"
            return 0
        else
            log_error "ssh-keygen not found! Cannot shim op-signer."
            return 1
        fi
    fi

    case "$platform" in
        wsl)
            log_debug "Environment: WSL2 detected. Resolving Windows user..."

            if ! command_exists cmd.exe; then
                log_warning "cmd.exe not found. Is this a valid WSL environment?"
                return 1
            fi

            local win_user
            win_user=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')

            if [[ -z "$win_user" ]]; then
                log_warning "Failed to detect Windows username."
                return 1
            fi

            binary_path="/mnt/c/Users/${win_user}/AppData/Local/Microsoft/WindowsApps/op-ssh-sign-wsl.exe"
            ;;

        linux)
            log_debug "Environment: Native Linux detected."
            binary_path="/opt/1Password/op-ssh-sign"
            ;;

        macos)
            log_debug "Environment: macOS detected."
            binary_path="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
            ;;

        windows)
            log_debug "Environment: Windows (Git Bash/Cygwin) detected."
            binary_path="${USERPROFILE:-}/AppData/Local/Microsoft/WindowsApps/op-ssh-sign.exe"
            ;;

        *)
            log_warning "Unsupported platform for git shims: $platform"
            return 1
            ;;
    esac

    # Validate the binary exists before returning
    if [[ ! -f "$binary_path" ]]; then
        log_warning "1Password signer binary not found at: $binary_path"
        log_info "ℹ️  Please ensure 1Password is installed and SSH signing is enabled"
        return 1
    fi

    echo "$binary_path"
}

setup_git_ssh_shim() {
    local platform
    platform=$(detect_platform)

    log_debug "🔗 Setting up git-ssh shim for platform: $platform"

    # Determine which SSH command to use based on platform
    local ssh_cmd
    case "$platform" in
        wsl|windows)
            ssh_cmd="ssh.exe"
            ;;
        *)
            ssh_cmd="ssh"
            ;;
    esac

    # Find the SSH binary in PATH
    local ssh_binary
    ssh_binary=$(command -v "$ssh_cmd" 2>/dev/null)

    log_debug "Using SSH command: $ssh_cmd -> $ssh_binary"

    if [[ ! "$ssh_binary" ]]; then
        log_warning "⚠️  $ssh_cmd not found in PATH, skipping git-ssh shim"
        return 1
    fi

    if safe_symlink "$ssh_binary" "$HOME/bin/git-ssh"; then
        log_success "✅ Git SSH shim created: git-ssh -> $ssh_binary"
        return 0
    fi

    log_info "ℹ️  Could not create git-ssh shim"
    return 1
}

setup_op_signer_shim() {
    # Remote environments are handled in resolve_op_signer_binary (uses ssh-keygen)

    local platform
    platform=$(detect_platform)

    log_debug "🔗 Setting up op-signer shim for platform: $platform"

    local source_binary
    # Check if any of the required platform binaries exist.
    if ! source_binary=$(resolve_op_signer_binary "$platform"); then
        # Warning already logged in resolve_op_signer_binary.
        return 1
    fi

    log_debug "Using op-signer binary: $source_binary"

    if safe_symlink "$source_binary" "$HOME/bin/op-signer"; then
        log_success "✅ Op-signer shim created: op-signer -> $source_binary"
        return 0
    fi

    # Binary not available and couldn't create symlink.
    log_info "ℹ️  Could not create op-signer shim"
    return 1
}

setup_git_shims() {
    if [[ "$SKIP_GIT_SHIMS" == "true" ]]; then
        log_info "⏭️  Skipping git shims setup (DOTFILES_SKIP_GIT_SHIMS=true)"
        return 0
    fi

    log_info "🔗 Setting up git shims..."

    setup_git_ssh_shim
    setup_op_signer_shim

    # Check if shim directory is in PATH
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        log_warning "⚠️  ~/bin is not in your PATH"
        log_info "ℹ️  Add to your shell profile: export PATH=\"\$HOME/bin:\$PATH\""
    fi
}

# =============================================================================
# SSH CONFIG FOR 1PASSWORD
# =============================================================================

setup_ssh_config() {
    if [[ "$SKIP_SSH_CONFIG" == "true" ]]; then
        log_info "⏭️  Skipping SSH config setup (DOTFILES_SKIP_SSH_CONFIG=true)"
        return 0
    fi

    # Only run on local Linux/macOS (not WSL, not remote environments)
    if [[ "$DOTFILES_REMOTE_ENV" == "true" ]]; then
        log_info "⏭️  Skipping SSH config setup (remote env uses forwarded agent)"
        return 0
    fi
    if [[ "$DOTFILES_IN_WSL" == "true" ]]; then
        log_info "⏭️  Skipping SSH config setup (WSL uses Windows 1Password agent)"
        return 0
    fi

    log_info "🔗 Setting up SSH config for 1Password..."

    local agent_sock="$HOME/.1password/agent.sock"
    local source_file="$DOTFILES_DIR/shell/ssh-1password.config"
    local target_file="$HOME/.ssh/config"

    # Check if 1Password SSH agent socket exists
    if [[ ! -S "$agent_sock" ]]; then
        log_warning "⚠️  1Password SSH agent socket not found at $agent_sock"
        log_info "ℹ️  Please ensure 1Password is installed and SSH agent is enabled"
        return 0
    fi

    if safe_symlink "$source_file" "$target_file"; then
        log_success "✅ SSH config symlinked"
    fi
}

# =============================================================================
# MAIN INSTALLATION ORCHESTRATION
# =============================================================================

main() {
    log_info "🚀 Starting dotfiles installation..."
    log_info "📁 Dotfiles directory: $DOTFILES_DIR"

    # Verify dotfiles directory exists
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log_error "❌ Dotfiles directory not found: $DOTFILES_DIR"
        log_error "   Please clone your dotfiles first or set DOTFILES_DIR environment variable"
        return 1
    fi

    # Detect environment
    detect_environment

    # Run installation steps with timing
    local total_start=$SECONDS

    timed "System packages" install_system_packages

    timed "Homebrew" install_homebrew
    timed "CLI tools" install_cli_tools
    timed "Zsh plugins" install_zsh_plugins
    timed "Shell configs" link_shell_configs
    timed "VS Code configs" link_vscode_configs
    timed "Editor launcher" setup_editor_launcher
    timed "Git shims" setup_git_shims
    timed "SSH config" setup_ssh_config

    local total_elapsed=$((SECONDS - total_start))
    log_success "🎉 Dotfiles installation complete! (total: $(format_duration $total_elapsed))"
    log_info ""
    log_info "ℹ️  Next steps:"
    log_info "   1. Restart your shell: source ~/.zshrc (or ~/.bashrc)"
    log_info ""
    log_info "💡 To customize this installation:"
    log_info "   - Set environment variables (DOTFILES_SKIP_* flags)"
    log_info "   - Edit $DOTFILES_DIR/shell/install.sh"
    log_info ""
    log_info "📋 Available skip flags:"
    log_info "   DOTFILES_SKIP_SYSTEM_PACKAGES=true"
    log_info "   DOTFILES_SKIP_DEV_PACKAGES=true"
    log_info "   DOTFILES_SKIP_HOMEBREW=true"
    log_info "   DOTFILES_SKIP_CLI_TOOLS=true"
    log_info "   DOTFILES_SKIP_NODE_LTS=true"
    log_info "   DOTFILES_SKIP_NPM_PACKAGES=true"
    log_info "   DOTFILES_SKIP_ZSH_PLUGINS=true"
    log_info "   DOTFILES_SKIP_VSCODE=true"
    log_info "   DOTFILES_SKIP_EDITOR_LAUNCHER=true"
    log_info "   DOTFILES_SKIP_GIT_SHIMS=true"
    log_info "   DOTFILES_SKIP_SSH_CONFIG=true"
}

# Execute main function
main "$@"
