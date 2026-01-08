#!/usr/bin/env bash
# Dotfiles installation script
# One-time setup for development tools, shell plugins, and system configuration.
#
# This script is idempotent and can be run multiple times safely.
#
# Usage:
#   ./setup/install.bash [options]
#   ./setup/install.bash --help    # Show all options
#
# Common profiles:
#   ./setup/install.bash --vm       # Full VM setup
#   ./setup/install.bash --minimal  # Container-friendly (skip Docker, Tailscale, dev packages)
#
# For editor configurations (VS Code, Cursor, etc.), run separately:
#   ./apps/vscode-like/install.bash [--code|--cursor|--insiders|...]
#
# Note: This script uses `sudo` for privileged operations.
# If running as root (e.g., in containers), create this override at the top:
#
#   sudo() { "$@"; }  # No-op sudo for root environments
#

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/x/dotfiles}"
USER_BIN_DIR="${USER_BIN_DIR:-$HOME/bin}"
DOWNLOADS_DIR="${DOWNLOADS_DIR:-$USER_BIN_DIR/downloads}"

# -----------------------------------------------------------------------------
# Feature flags (all use SKIP_* pattern for consistency)
# Set via environment variables (DOTFILES_SKIP_*) or CLI arguments
# See: docs/adr/0005-development-tool-selection.md
# -----------------------------------------------------------------------------

# Core installation steps
SKIP_SYSTEM_PACKAGES="${DOTFILES_SKIP_SYSTEM_PACKAGES:-false}"
SKIP_DEV_PACKAGES="${DOTFILES_SKIP_DEV_PACKAGES:-true}"
SKIP_HOMEBREW="${DOTFILES_SKIP_HOMEBREW:-true}"
SKIP_CLI_TOOLS="${DOTFILES_SKIP_CLI_TOOLS:-false}"
SKIP_ZSH_PLUGINS="${DOTFILES_SKIP_ZSH_PLUGINS:-false}"
SKIP_NODE_LTS="${DOTFILES_SKIP_NODE_LTS:-false}"
SKIP_NPM_PACKAGES="${DOTFILES_SKIP_NPM_PACKAGES:-false}"

# Shell configuration
SKIP_EDITOR_LAUNCHER="${DOTFILES_SKIP_EDITOR_LAUNCHER:-true}"
SKIP_GIT_SHIMS="${DOTFILES_SKIP_GIT_SHIMS:-false}"
SKIP_SSH_CONFIG="${DOTFILES_SKIP_SSH_CONFIG:-false}"

# Infrastructure tools (skip by default in containers, install on VMs)
SKIP_DOCKER="${DOTFILES_SKIP_DOCKER:-false}"
SKIP_TAILSCALE="${DOTFILES_SKIP_TAILSCALE:-false}"

# Optional tool bundles (opt-in via CLI flags)
SKIP_EXTRA_TOOLS="${DOTFILES_SKIP_EXTRA_TOOLS:-true}"   # zoxide, eza, delta, lazygit, tldr, htop

# Script behavior
DEBUG="${DOTFILES_DEBUG:-0}"

# Locale and timezone configuration
# See: docs/adr/0003-locale-and-timezone-configuration.md
TZ_VAR="America/Sao_Paulo"
LANG_VAR="C.UTF-8"
LC_TIME_VAR="en_GB.UTF-8"

# Custom fork repositories (for security - you control the source)
FORK_FZF_REPO="${FORK_FZF_REPO:-https://github.com/marcelocra/fzf.git}"
FORK_ZSH_AUTOSUGGESTIONS="${FORK_ZSH_AUTOSUGGESTIONS:-https://github.com/marcelocra/zsh-autosuggestions.git}"
FORK_ZSH_SYNTAX_HIGHLIGHTING="${FORK_ZSH_SYNTAX_HIGHLIGHTING:-https://github.com/marcelocra/zsh-syntax-highlighting.git}"

# =============================================================================
# ARGUMENT PARSING
# =============================================================================

usage() {
    cat <<EOF
Usage: ./setup/install.bash [options]

Profiles:
  --vm              Full VM setup
                    Use cases: SSH-accessed cloud VMs, development servers
                    Includes: Homebrew, dev packages (cmake, g++, python3-dev),
                             editor launcher, debug logging enabled

  --minimal         Lightweight installation
                    Use cases: Containers, CI/CD, quick testing, resource-constrained environments
                    Skips: Docker, Tailscale, dev packages, extra tools
                    Includes: System packages, CLI tools (fzf, gh, aider), Node.js, shell configs

  (default)         Balanced setup for most environments
                    Includes: Docker, Tailscale, CLI tools, Node.js, shell configs
                    Skips: Homebrew, dev packages, extra tools (opt-in with --with-extras)

Options:
  --no-docker       Skip Docker installation
  --no-tailscale    Skip Tailscale installation
  --with-extras     Install extra tools (zoxide, eza, delta, lazygit, tldr, htop)
  --debug           Enable debug logging
  --help, -h        Show this help

Environment variables:
  DOTFILES_SKIP_SYSTEM_PACKAGES=true  Skip apt package installation
  DOTFILES_SKIP_HOMEBREW=true         Skip Homebrew installation
  DOTFILES_SKIP_DOCKER=true           Skip Docker installation
  (see source for full list)
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --vm)
            SKIP_DEV_PACKAGES="false"
            SKIP_HOMEBREW="false"
            SKIP_EDITOR_LAUNCHER="false"
            DEBUG="1"
            ;;
        --minimal)
            SKIP_DOCKER="true"
            SKIP_TAILSCALE="true"
            SKIP_DEV_PACKAGES="true"
            SKIP_EXTRA_TOOLS="true"
            ;;
        --no-docker)
            SKIP_DOCKER="true"
            ;;
        --no-tailscale)
            SKIP_TAILSCALE="true"
            ;;
        --with-extras)
            SKIP_EXTRA_TOOLS="false"
            ;;
        --debug)
            DEBUG="1"
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

log_info() { printf '\033[0;34m[dotfiles]\033[0m %s\n' "$*"; }
log_success() { printf '\033[0;32m[dotfiles]\033[0m %s\n' "$*"; }
log_warning() { printf '\033[1;33m[dotfiles]\033[0m %s\n' "$*"; }
log_error() { printf '\033[0;31m[dotfiles]\033[0m %s\n' "$*" >&2; }
log_debug() { [[ "${DEBUG}" == "1" ]] && printf '\033[0;90m[dotfiles:debug]\033[0m %s\n' "$*" >&2; }

# Secure curl for piping to shell (e.g., | bash)
# Forces HTTPS, TLS 1.2+, outputs to stdout
curl_cmd() {
    curl --proto '=https' --tlsv1.2 -fsSL -o- "$@"
}

# Secure curl for general downloads (with custom flags)
# Forces HTTPS, TLS 1.2+ but allows other flags like -o, -O
curl_safer() {
    curl --proto '=https' --tlsv1.2 -fsSL "$@"
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
# PATH MANAGEMENT
# =============================================================================

# Loads common installation paths into PATH for tools we install.
# This ensures tools from previous runs are found by command_exists checks.
load_path() {
    # User bin directory (just, e, git shims)
    if [[ -d "$USER_BIN_DIR" ]]; then
        export PATH="$USER_BIN_DIR:$PATH"
    fi

    # Local bin directory (pipx tools like aider)
    if [[ -d "$HOME/.local/bin" ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # pnpm home directory
    local pnpm_home="${PNPM_HOME:-$HOME/.local/share/pnpm}"
    if [[ -d "$pnpm_home" ]]; then
        export PNPM_HOME="$pnpm_home"
        export PATH="$PNPM_HOME:$PATH"
    fi

    # Homebrew (Linux)
    local brew_path="/home/linuxbrew/.linuxbrew"
    if [[ -d "$brew_path" ]]; then
        eval "$($brew_path/bin/brew shellenv)"
    fi
}

# =============================================================================
# ENVIRONMENT DETECTION
# =============================================================================

detect_environment() {
    log_debug "Detecting environment..."

    export DOTFILES_IN_BUNKER="${DOTFILES_IN_BUNKER:-false}"
    export DOTFILES_IN_CONTAINER="false"
    export DOTFILES_IN_WSL="false"
    export DOTFILES_IN_REMOTE_VSCODE="false"
    export DOTFILES_IN_SSH="false"
    export DOTFILES_REMOTE_ENV="false"

    if [[ -f /.dockerenv ]] || [[ -n "${CONTAINER:-}" ]] || [[ -f /run/.containerenv ]]; then
        export DOTFILES_IN_CONTAINER="true"
    fi

    # WSL detection
    if grep -q Microsoft /proc/version 2>/dev/null || grep -q WSL2 /proc/version 2>/dev/null; then
        export DOTFILES_IN_WSL="true"
    fi

    # Remote VS Code detection
    if [[ -n "${REMOTE_CONTAINERS:-}" ]] || [[ -n "${CODESPACES:-}" ]]; then
        export DOTFILES_IN_REMOTE_VSCODE="true"
    fi

    # SSH session detection (remote connection without local 1Password)
    if [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]]; then
        export DOTFILES_IN_SSH="true"
    fi

    # Derived: Remote environment (no local 1Password access)
    # Includes: containers, SSH sessions, DevBunker
    # These environments use forwarded SSH agent and need ssh-keygen shim
    if [[ "${DOTFILES_IN_CONTAINER}" == "true" ]] || \
       [[ "${DOTFILES_IN_SSH}" == "true" ]] || \
       [[ "${DOTFILES_IN_BUNKER}" == "true" ]]; then
        export DOTFILES_REMOTE_ENV="true"
    fi

    log_debug "Container: $DOTFILES_IN_CONTAINER, WSL: $DOTFILES_IN_WSL, SSH: $DOTFILES_IN_SSH, Remote: $DOTFILES_REMOTE_ENV"
}

detect_platform() {
    detect_environment
    if [[ "${DOTFILES_REMOTE_ENV}" == "true" ]]; then echo "linux"; return 0; fi
    if [[ "${DOTFILES_IN_WSL}" == "true" ]]; then echo "wsl"; return 0; fi
    echo "linux"
}

# =============================================================================
# LOCALE CONFIGURATION
# See: docs/adr/0003-locale-and-timezone-configuration.md
# =============================================================================

configure_locale() {
    log_info "🌐 Configuring locale ($LANG_VAR) and timezone ($TZ_VAR)..."

    # Set system timezone (affects logs, cron, systemd services)
    if command_exists timedatectl; then
        sudo timedatectl set-timezone "$TZ_VAR" || log_warning "Failed to set timezone to $TZ_VAR"
    fi

    # Generate required locales
    if [[ -f /etc/locale.gen ]] && command_exists locale-gen; then
        local locales_to_generate=("$LANG_VAR" "$LC_TIME_VAR")
        local needs_regen=false

        for locale in "${locales_to_generate[@]}"; do
            if ! grep -q "^${locale}" /etc/locale.gen 2>/dev/null; then
                log_info "Enabling locale $locale..."
                sudo sed -i "s/^# *${locale}/${locale}/" /etc/locale.gen 2>/dev/null || true
                needs_regen=true
            fi
        done

        if [[ "$needs_regen" == "true" ]]; then
            log_info "Generating locales..."
            sudo locale-gen
        else
            log_debug "Required locales already configured"
        fi
    fi

    log_success "✅ Locale and timezone configured"
}

# =============================================================================
# INSTALLATION STEPS
# =============================================================================

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

    # Non-interactive install
    export DEBIAN_FRONTEND=noninteractive

    # Update package index
    sudo apt-get update -y

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
        pipx
        software-properties-common
        wget
        xclip
        zsh
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
    if ! sudo apt-get install -y "${packages[@]}"; then
        log_warning "Some apt packages failed to install"
    else
        log_success "✅ System packages installed"
    fi

    # Set zsh as default shell
    local zsh_path
    zsh_path=$(command -v zsh)

    if [[ -z "$zsh_path" ]]; then
        log_warning "⚠️  zsh not found, skipping default shell change"
        return 0
    fi

    # Check if zsh is already the default shell
    if [[ "$SHELL" == "$zsh_path" ]]; then
        log_info "✅ zsh is already the default shell"
        return 0
    fi

    log_info "🔧 Setting zsh as default shell..."

    # Ensure zsh is in /etc/shells
    if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
        echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
    fi

    # Change default shell (non-interactive)
    sudo chsh -s "$zsh_path" "$USER"
    log_success "✅ Default shell changed to zsh (restart session to use)"

    return 0
}

# Uses official installation instructions copy/pasted from:
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
__install_docker() {
    # 1// Remove conflicting packages.
    sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)

    # 2// Configure apt.
    # Add Docker's official GPG key:
    sudo apt update
    sudo apt install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt update

    # 3// Install the latest version.
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    # 4// Add docker group (if it doesn't exist) and add user to it.
    if ! getent group docker > /dev/null; then
      sudo groupadd docker
    fi
    sudo usermod -aG docker "$USER"

    # 5// (Optional) To update or install specific versions, do the following:
    #
    #   a. Find which version you want to install
    #
    #       $ apt list --all-versions docker-ce
    #       docker-ce/noble 5:29.1.3-1~ubuntu.24.04~noble <arch>
    #       docker-ce/noble 5:29.1.2-1~ubuntu.24.04~noble <arch>
    #       ...
    #
    #   b. Select the desired version and install:
    #
    #       $ VERSION_STRING=5:29.1.3-1~ubuntu.24.04~noble
    #       $ sudo apt install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin

}

# Docker Installation
# See: docs/adr/0008-stability-over-latest.md (Docker chosen for stability)
install_docker() {
    if [[ "$SKIP_DOCKER" == "true" ]]; then
        log_info "⏭️  Skipping Docker installation (DOTFILES_SKIP_DOCKER=true)"
        return 0
    fi

    if command_exists docker; then
        log_info "✅ Docker already installed"
        return 0
    fi

    log_info "🐳 Installing Docker..."
    __install_docker
    log_success "✅ Docker installed"
}

# Tailscale Installation
# See: docs/adr/0006-network-security-tailscale.md
install_tailscale() {
    if [[ "$SKIP_TAILSCALE" == "true" ]]; then
        log_info "⏭️  Skipping Tailscale installation (DOTFILES_SKIP_TAILSCALE=true)"
        return 0
    fi

    if command_exists tailscale; then
        log_info "✅ Tailscale already installed"
        return 0
    fi

    log_info "🔌 Installing Tailscale..."
    curl_cmd https://tailscale.com/install.sh | sh
    log_success "✅ Tailscale installed"
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

install_pnpm() {
    if command_exists pnpm; then
        log_info "✅ pnpm already installed"
        return 0
    fi

    log_info "📦 Installing pnpm..."

    # Configure pnpm home (init.sh already adds this to PATH)
    # PNPM_HOME set skips shell config modification by installer
    export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
    curl_cmd https://get.pnpm.io/install.sh | sh -

    # Add to current PATH for immediate use (load_path only adds existing dirs)
    export PATH="$PNPM_HOME:$PATH"

    log_success "✅ pnpm installed successfully"
}

install_global_npm_packages() {
    if [[ "$SKIP_NPM_PACKAGES" == "true" ]]; then
        log_info "⏭️  Skipping global npm packages (DOTFILES_SKIP_NPM_PACKAGES=true)"
        return 0
    fi

    # Ensure pnpm is available
    install_pnpm
    if ! command_exists pnpm; then
        log_warning "⚠️  pnpm not available, skipping global npm packages"
        return 0
    fi

    log_info "📦 Installing global npm packages..."

    # Packages to install globally (AI CLI tools, etc.)
    local packages=(
        "@anthropic-ai/claude-code"
        "@google/gemini-cli"
        "@github/copilot"
        "@google/jules"
        "@openai/codex"
        "@continuedev/cli"
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
    mkdir -p "$USER_BIN_DIR"
    curl_cmd https://just.systems/install.sh | bash -s -- --to "$USER_BIN_DIR"
    log_success "✅ just installed successfully"
}

# Install fzf from custom fork for security
install_fzf() {
    local fzf_dir="$HOME/.fzf"
    local fzf_bin="$USER_BIN_DIR/fzf"

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
    mkdir -p "$USER_BIN_DIR"
    ln -sf "$fzf_dir/bin/fzf" "$fzf_bin"

    log_success "✅ fzf installed from custom fork"
}

install_brew_packages() {
    if ! command_exists brew; then
        log_warning "⚠️  Homebrew not available, skipping brew package installation"
        return 0
    fi

    log_info "📦 Installing packages via Homebrew..."

    local packages=(
        "bat"                     # Better cat
        "borkdude/brew/babashka"  # Clojure
        "fd"                      # Better find
        "ripgrep"                 # Better grep
        "shellcheck"              # Shell code quality
        "shfmt"                   # Shell code quality
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

# Uses official installation instructions for GitHub CLI, copy/pasted from:
#   https://github.com/cli/cli/blob/trunk/docs/install_linux.md
__install_gh() {
    (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
}

install_gh() {
    if command_exists gh; then
        log_info "✅ GitHub CLI already installed"
        return 0
    fi

    log_info "📦 Installing GitHub CLI..."
    __install_gh
    log_success "✅ GitHub CLI installed"
}

install_aider() {
    if command_exists aider; then
        log_info "✅ Aider already installed"
        return 0
    fi

    log_info "📦 Installing Aider (AI Pair Programmer)..."
    # Use pipx for PEP 668 compliance (Ubuntu 24.04+ blocks system-wide pip installs)
    if command_exists pipx; then
        pipx install aider-chat
        log_success "✅ Aider installed"
    else
        log_warning "⚠️  pipx not found, skipping Aider installation"
    fi
}



install_neovim() {
    if command_exists nvim; then
        log_info "✅ Neovim already installed"
        return 0
    fi

    log_info "📦 Installing Neovim..."

    # Create directory structure
    local nvim_downloads="$DOWNLOADS_DIR/nvim"
    mkdir -p "$nvim_downloads"

    # Determine version (try to get latest tag using GitHub API)
    local version="latest"

    # Try to fetch release info
    local release_info
    release_info=$(curl_safer https://api.github.com/repos/neovim/neovim/releases/latest || echo "")

    local extracted_version=""

    if [[ -n "$release_info" ]]; then
        if command_exists jq; then
            extracted_version=$(echo "$release_info" | jq -r .tag_name 2>/dev/null) || true
        else
            # Fallback: parse "tag_name": "v0.10.0" using sed with robust regex
            # Matches "tag_name" : "VALUE" and captures VALUE
            extracted_version=$(echo "$release_info" | sed -nE 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p') || true
        fi
    fi

    if [[ -n "$extracted_version" && "$extracted_version" != "null" ]]; then
        version="$extracted_version"
    fi

    local install_dir="$nvim_downloads/$version"

    if [[ -d "$install_dir" ]]; then
	# Downloaded but not installed yet.
        log_info "✅ Neovim $version already downloaded in $install_dir"
    else
        log_info "⬇️  Downloading Neovim ($version)..."
        local tmp_dir
        tmp_dir=$(mktemp -d)

        # Construct download URL
        local download_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
        if [[ "$version" != "latest" ]]; then
            download_url="https://github.com/neovim/neovim/releases/download/$version/nvim-linux64.tar.gz"
        fi
        
        log_debug "Neovim version detected: $version"
        log_debug "Download URL: $download_url"

        # Download and extract
        if (cd "$tmp_dir" && curl_safer -O "$download_url" && tar -xzf nvim-linux64.tar.gz); then
             # Move extracted directory to install location
             # The tarball extracts to 'nvim-linux64'
             mv "$tmp_dir/nvim-linux64" "$install_dir"
        else
            log_error "❌ Failed to download or extract Neovim"
            rm -rf "$tmp_dir"
	    # Necessary to set proper error code.
            return 1
        fi
        rm -rf "$tmp_dir"
    fi

    # Create symlink
    # We want ~/bin/nvim -> .../bin/nvim
    # safe_symlink handles mkdir parent and backups
    safe_symlink "$install_dir/bin/nvim" "$USER_BIN_DIR/nvim"

    log_success "✅ Neovim installed ($version)"
}

install_opencode() {
    if command_exists opencode; then
        log_info "✅ OpenCode already installed"
        return 0
    fi

    log_info "📦 Installing OpenCode..."
    # OpenCode install script (curl | bash)
    curl_safer https://opencode.ai/install | bash
    log_success "✅ OpenCode installed"
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

    # Package managers & runtimes
    install_nvm
    install_node_lts
    install_global_npm_packages

    # Official installers (curl | bash or git clone)
    install_fzf
    install_just
    install_neovim
    install_oh_my_zsh

    # AI Agents "Team"
    install_aider
    install_opencode

    # Homebrew packages (checks internally if brew exists)
    install_brew_packages

    # APT packages (requires repo setup)
    install_gh
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

    log_success "✅ Zsh plugins installed"
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

    local init_source="source $DOTFILES_DIR/shell/init.sh"

    for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if [[ -f "$rc" ]]; then
            if ! grep -q "source.*shell/init.sh" "$rc"; then
                log_debug "Adding init.sh source to $rc..."
                echo "" >> "$rc"
                echo "# Dotfiles initialization" >> "$rc"
                echo "$init_source" >> "$rc"
            fi
        else
            log_debug "Creating $rc with init.sh source..."
            echo "# Dotfiles initialization" > "$rc"
            echo "$init_source" >> "$rc"
        fi
    done

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
# EDITOR LAUNCHER SETUP
# =============================================================================

setup_editor_launcher() {
    if [[ "$SKIP_EDITOR_LAUNCHER" == "true" ]]; then
        log_info "⏭️  Skipping editor launcher setup (DOTFILES_SKIP_EDITOR_LAUNCHER=true)"
        return 0
    fi

    log_info "🔗 Setting up 'e' editor launcher command..."
    safe_symlink "$DOTFILES_DIR/shell/e" "$USER_BIN_DIR/e"
    log_success "✅ 'e' editor launcher set up"
}

# =============================================================================
# GIT SHIMS SETUP (1Password SSH Signing)
# =============================================================================

resolve_op_signer_binary() {
    local platform="$1"

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
        fi

        log_error "ssh-keygen not found! Cannot shim op-signer."
        return 1
    fi

    local binary_path=""
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

setup_git_shims() {
    if [[ "$SKIP_GIT_SHIMS" == "true" ]]; then
        log_info "⏭️  Skipping git shims setup (DOTFILES_SKIP_GIT_SHIMS=true)"
        return 0
    fi

    log_info "🔗 Setting up git shims..."
    local platform
    platform=$(detect_platform)

    log_debug "🔗 Setting up git-ssh shim for platform: $platform"

    # Determine which SSH command to use based on platform
    local ssh_cmd="ssh"
    [[ "$platform" == "wsl" ]] && ssh_cmd="ssh.exe"

    # Find the SSH binary in PATH
    local ssh_binary
    ssh_binary=$(command -v "$ssh_cmd" 2>/dev/null)

    log_debug "Using SSH command: $ssh_cmd -> $ssh_binary"

    if [[ -n "$ssh_binary" ]]; then
        safe_symlink "$ssh_binary" "$USER_BIN_DIR/git-ssh"
        log_success "✅ Git SSH shim created: git-ssh -> $ssh_binary"
    fi

    # Remote environments are handled in resolve_op_signer_binary (uses ssh-keygen)

    local op_binary
    if op_binary=$(resolve_op_signer_binary "$platform"); then
        log_debug "Using op-signer binary: $op_binary"

        safe_symlink "$op_binary" "$USER_BIN_DIR/op-signer"
        log_success "✅ Op-signer shim created: op-signer -> $op_binary"
    fi

    # Check if shim directory is in PATH
    if [[ ":$PATH:" != *":$USER_BIN_DIR:"* ]]; then
        log_warning "⚠️  $USER_BIN_DIR is not in your PATH"
        log_info "ℹ️  Add to your shell profile: export PATH=\"\$USER_BIN_DIR:\$PATH\""
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

    if [[ "$DOTFILES_REMOTE_ENV" == "true" || "$DOTFILES_IN_WSL" == "true" ]]; then
        log_info "⏭️  Skipping SSH config setup (remote/WSL detected)"
        return 0
    fi

    log_info "🔗 Setting up SSH config for 1Password..."
    if [[ -S "$HOME/.1password/agent.sock" ]]; then
        safe_symlink "$DOTFILES_DIR/shell/ssh-1password.config" "$HOME/.ssh/config"
        log_success "✅ SSH config symlinked"
    else
        log_warning "⚠️  1Password agent socket not found, skipping"
    fi
}

# =============================================================================
# EXTRA TOOLS INSTALLATION (opt-in via --with-extras)
# =============================================================================

install_extra_tools() {
    if [[ "$SKIP_EXTRA_TOOLS" == "true" ]]; then
        log_info "⏭️  Skipping extra tools (use --with-extras to install zoxide, eza, delta, etc.)"
        return 0
    fi

    log_info "🔧 Installing extra tools..."

    # zoxide - smart cd replacement (learns from usage)
    if ! command_exists zoxide; then
        log_info "📦 Installing zoxide..."
        curl_cmd https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        log_success "✅ zoxide installed"
    else
        log_info "✅ zoxide already installed"
    fi

    # Install brew-based tools if available
    if command_exists brew; then
        local extra_brew_packages=(
            "eza"       # Better ls with colors and icons
            "git-delta" # Better git diff viewer
            "lazygit"   # Terminal UI for git
            "tealdeer"  # tldr - simplified man pages (Rust implementation)
            "htop"      # Interactive process viewer
        )

        log_info "📦 Installing via Homebrew: ${extra_brew_packages[*]}"
        brew install "${extra_brew_packages[@]}" || log_warning "Some extra tools failed to install"
    else
        log_warning "⚠️  Homebrew not available, some extra tools will be skipped"
    fi

    log_success "✅ Extra tools installed"
}

# =============================================================================
# MAIN INSTALLATION ORCHESTRATION
# =============================================================================

main() {
    # Load common installation paths into PATH
    load_path

    log_info "🚀 Starting dotfiles installation..."
    log_info "📁 Dotfiles directory: $DOTFILES_DIR"

    # TODO: Add y/n prompt to automatically clone the repo if not found, with a `-y` flag to auto-confirm.
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log_error "❌ Dotfiles directory not found: $DOTFILES_DIR"
        return 1
    fi

    detect_environment

    local total_start=$SECONDS

    configure_locale
    timed "System packages" install_system_packages
    timed "Docker" install_docker
    timed "Tailscale" install_tailscale
    timed "Homebrew" install_homebrew
    timed "CLI tools" install_cli_tools
    timed "Extra tools" install_extra_tools
    timed "Zsh plugins" install_zsh_plugins
    timed "Shell configs" link_shell_configs
    timed "Editor launcher" setup_editor_launcher
    timed "Git shims" setup_git_shims
    timed "SSH config" setup_ssh_config

    # TODO: Review if there's any next steps that are missing from here.
    local total_elapsed=$((SECONDS - total_start))
    log_success "🎉 Dotfiles installation complete! (total: $(format_duration $total_elapsed))"
    log_info ""
    log_info "ℹ️  Next steps:"
    log_info "   - Restart your shell: source ~/.zshrc"
    log_info "   - For Docker: Close and reopen your SSH session (or run: newgrp docker)"
    log_info "       Then test with: docker run hello-world"
    log_info "       If it doesn't work, run this: sudo systemctl start docker"
    log_info "       and then try again."
    log_info "   - For Tailscale: sudo tailscale up"
    log_info "   - For GitHub CLI: gh auth login"
    log_info "   - For editor configs: ./apps/vscode-like/install.bash [--code|--cursor|...]"
}

main "$@"
