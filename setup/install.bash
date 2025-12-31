#!/usr/bin/env bash
# Dotfiles installation script
# One-time setup for development tools, shell plugins, and editor configurations.
#
# This script is idempotent and can be run multiple times safely.
# It handles:
#   - System packages (apt)
#   - Docker & Tailscale (New)
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
#   ./setup/install.bash [options]
#
# Options:
#   --minimal       Skip optional tools (Docker, Tailscale, Extras)
#   --no-docker     Skip Docker installation
#   --no-tailscale  Skip Tailscale installation
#   --dry-run       Print commands without executing
#   --help          Show help
#
# Environment variables (Legacy support):
#   DOTFILES_SKIP_SYSTEM_PACKAGES=true
#   DOTFILES_SKIP_HOMEBREW=true
#   ... (all original flags supported)

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/x/dotfiles}"

# Default Flags (controlled by arguments or env vars)
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

# New Flags
INSTALL_DOCKER="true"
INSTALL_TAILSCALE="true"
DRY_RUN="false"

DEBUG="${DOTFILES_DEBUG:-0}"

# Localization
TZ_VAR="America/Sao_Paulo"
LOCALE_VAR="en_US.UTF-8"

# Custom fork repositories
FORK_FZF_REPO="${FORK_FZF_REPO:-https://github.com/marcelocra/fzf.git}"
FORK_ZSH_AUTOSUGGESTIONS="${FORK_ZSH_AUTOSUGGESTIONS:-https://github.com/marcelocra/zsh-autosuggestions.git}"
FORK_ZSH_SYNTAX_HIGHLIGHTING="${FORK_ZSH_SYNTAX_HIGHLIGHTING:-https://github.com/marcelocra/zsh-syntax-highlighting.git}"

# =============================================================================
# ARGUMENT PARSING
# =============================================================================

usage() {
    grep "^#   " "$0" | sed 's/#   //'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --minimal)
            INSTALL_DOCKER="false"
            INSTALL_TAILSCALE="false"
            SKIP_DEV_PACKAGES="true"
            ;;
        --no-docker)
            INSTALL_DOCKER="false"
            ;;
        --no-tailscale)
            INSTALL_TAILSCALE="false"
            ;;
        --dry-run)
            DRY_RUN="true"
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

curl_cmd() {
    curl --proto '=https' --tlsv1.2 -fsSL -o- "$@"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Run a command, respecting DRY_RUN
run_cmd() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] $*"
    else
        "$@"
    fi
}

format_duration() {
    local seconds="$1"
    if ((seconds < 60)); then echo "${seconds}s"; else echo "$((seconds / 60))m $((seconds % 60))s"; fi
}

timed() {
    local name="$1"
    local func="$2"
    local start_time=$SECONDS
    "$func"
    local exit_code=$?
    local elapsed=$((SECONDS - start_time))
    [[ $elapsed -gt 0 ]] && log_info "⏱️  $name took $(format_duration $elapsed)"
    return $exit_code
}

safe_symlink() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        log_warning "⚠️  Source not found: $source"
        return 1
    fi

    run_cmd mkdir -p "$(dirname "$target")"

    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
            log_debug "Symlink already correct: $target -> $source"
            return 0
        fi
        local timestamp
        timestamp=$(date +"%Y%m%d_%H%M%S")
        local backup="${target}.bak.${timestamp}"
        log_info "📦 Backing up existing file to: $backup"
        run_cmd mv "$target" "$backup"
    fi

    run_cmd ln -s "$source" "$target"
    log_debug "Created symlink: $target -> $source"
    return 0
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

    if grep -q Microsoft /proc/version 2>/dev/null || grep -q WSL2 /proc/version 2>/dev/null; then
        export DOTFILES_IN_WSL="true"
    fi

    if [[ -n "${REMOTE_CONTAINERS:-}" ]] || [[ -n "${CODESPACES:-}" ]]; then
        export DOTFILES_IN_REMOTE_VSCODE="true"
    fi

    if [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]]; then
        export DOTFILES_IN_SSH="true"
    fi

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
# NEW: LOCALE CONFIGURATION
# =============================================================================

configure_locale() {
    log_info "🌐 Configuring locale ($LOCALE_VAR) and timezone ($TZ_VAR)..."
    
    if command_exists timedatectl; then
        run_cmd sudo timedatectl set-timezone "$TZ_VAR" || log_warning "Failed to set timezone to $TZ_VAR"
    fi

    if [[ -f /etc/locale.gen ]] && command_exists locale-gen; then
        if ! grep -q "^${LOCALE_VAR//./\.}" /etc/locale.gen; then
            log_info "Generating locale $LOCALE_VAR..."
            run_cmd sudo sed -i "s/^# *${LOCALE_VAR//./\.}/${LOCALE_VAR//./\.}/" /etc/locale.gen
            run_cmd sudo locale-gen
        else
            log_debug "Locale $LOCALE_VAR already configured in /etc/locale.gen"
        fi
    fi
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

    local sudo_cmd=""
    if [[ $EUID -ne 0 ]]; then
        if command_exists sudo; then
            sudo_cmd="sudo"
        else
            log_warning "sudo not available and not running as root; attempting apt-get directly"
        fi
    fi

    export DEBIAN_FRONTEND=noninteractive

    # Update package index
    run_cmd ${sudo_cmd} apt-get update -y

    local minimal_packages=(
        apt-transport-https build-essential ca-certificates curl gcc git git-lfs gnupg
        jq lsb-release make software-properties-common wget
    )

    local dev_packages=(
        cmake g++ libbz2-dev libreadline-dev libsqlite3-dev libssl-dev pkg-config
        python3-dev python3-pip python3-venv unzip zip zlib1g-dev
    )

    local packages=("${minimal_packages[@]}")
    if [[ "${SKIP_DEV_PACKAGES}" == "true" ]]; then
        log_info "ℹ️  Skipping extended dev packages (DOTFILES_SKIP_DEV_PACKAGES=true)"
    else
        log_info "ℹ️  Including extended dev packages (not skipped)"
        packages+=("${dev_packages[@]}")
    fi

    if ! run_cmd ${sudo_cmd} apt-get install -y "${packages[@]}"; then
        log_warning "Some apt packages failed to install"
    else
        log_success "✅ System packages installed"
    fi
}

# NEW: Docker Installation
install_docker() {
    if [[ "$INSTALL_DOCKER" == "false" ]]; then
        log_info "⏭️  Skipping Docker installation (--no-docker or --minimal)"
        return 0
    fi

    if command_exists docker; then
        log_info "✅ Docker already installed"
        return 0
    fi

    log_info "🐳 Installing Docker..."
    run_cmd curl_cmd https://get.docker.com | run_cmd sudo sh

    if getent group docker >/dev/null; then
        log_info "🐳 Adding $USER to docker group..."
        run_cmd sudo usermod -aG docker "$USER" || true
    fi
    log_success "✅ Docker installed"
}

# NEW: Tailscale Installation
install_tailscale() {
    if [[ "$INSTALL_TAILSCALE" == "false" ]]; then
        log_info "⏭️  Skipping Tailscale installation (--no-tailscale or --minimal)"
        return 0
    fi

    if command_exists tailscale; then
        log_info "✅ Tailscale already installed"
        return 0
    fi

    log_info "🔌 Installing Tailscale..."
    run_cmd curl_cmd https://tailscale.com/install.sh | run_cmd sudo sh
    log_success "✅ Tailscale installed"
}

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
    run_cmd curl_cmd https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | run_cmd bash

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
    run_cmd curl_cmd https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | run_cmd bash
    log_success "✅ nvm installed successfully"
}

install_node_lts() {
    if [[ "$SKIP_NODE_LTS" == "true" ]]; then
        log_info "⏭️  Skipping Node.js LTS installation (DOTFILES_SKIP_NODE_LTS=true)"
        return 0
    fi

    local nvm_dir="${NVM_DIR:-$HOME/.nvm}"
    if ! command_exists nvm && [[ ! -s "$nvm_dir/nvm.sh" ]]; then
        log_warning "⚠️  nvm not found, skipping Node.js LTS installation"
        return 0
    fi

    export NVM_DIR="$nvm_dir"
    # shellcheck source=/dev/null
    [[ -s "$nvm_dir/nvm.sh" ]] && source "$nvm_dir/nvm.sh"

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
    export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
    run_cmd mkdir -p "$PNPM_HOME"
    run_cmd curl_cmd https://get.pnpm.io/install.sh | run_cmd sh -
    log_success "✅ pnpm installed successfully"
}

install_global_npm_packages() {
    if [[ "$SKIP_NPM_PACKAGES" == "true" ]]; then
        log_info "⏭️  Skipping global npm packages (DOTFILES_SKIP_NPM_PACKAGES=true)"
        return 0
    fi

    install_pnpm
    if ! command_exists pnpm; then
        log_warning "⚠️  pnpm not available, skipping global npm packages"
        return 0
    fi

    log_info "📦 Installing global npm packages..."
    local packages=(
        "@anthropic-ai/claude-code"
        "@google/gemini-cli"
        "@github/copilot"
        "@google/jules"
        "@openai/codex"
    )

    log_info "   Installing: ${packages[*]}"
    run_cmd pnpm add -g "${packages[@]}"
    log_success "✅ Global npm packages installed"
}

install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_info "✅ oh-my-zsh already installed"
        return 0
    fi

    log_info "📦 Installing oh-my-zsh..."
    run_cmd curl_cmd https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | run_cmd sh -s -- --unattended
    log_success "✅ oh-my-zsh installed successfully"
}

install_just() {
    if command_exists just; then
        log_info "✅ just already installed"
        return 0
    fi

    log_info "📦 Installing just..."
    run_cmd mkdir -p "$HOME/bin"
    run_cmd curl_cmd https://just.systems/install.sh | run_cmd bash -s -- --to "$HOME/bin"
    log_success "✅ just installed successfully"
}

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
        (cd "$fzf_dir" && run_cmd git pull) || log_warning "Failed to update fzf"
    else
        log_debug "Cloning fzf from $FORK_FZF_REPO..."
        run_cmd git clone --depth 1 "$FORK_FZF_REPO" "$fzf_dir"
    fi

    run_cmd "$fzf_dir/install" --bin
    run_cmd mkdir -p "$HOME/bin"
    run_cmd ln -sf "$fzf_dir/bin/fzf" "$fzf_bin"
    log_success "✅ fzf installed from custom fork"
}

install_brew_packages() {
    log_info "📦 Installing packages via Homebrew..."

    local packages=("bat" "borkdude/brew/babashka" "fd" "ripgrep")
    local to_install=()

    for pkg in "${packages[@]}"; do
        if ! brew list "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        log_info "Installing: ${to_install[*]}"
        run_cmd brew install "${to_install[@]}" || log_warning "Some brew packages failed to install"
        log_success "✅ Brew packages installed"
    else
        log_info "✅ All brew packages already installed"
    fi
}

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

    if command_exists brew; then
        install_brew_packages
    else
        log_warning "⚠️  Homebrew not available, skipping brew package installation"
    fi
}

install_zsh_plugins() {
    if [[ "$SKIP_ZSH_PLUGINS" == "true" ]]; then
        log_info "⏭️  Skipping zsh plugins installation (DOTFILES_SKIP_ZSH_PLUGINS=true)"
        return 0
    fi

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_warning "⚠️  oh-my-zsh not found, skipping plugin installation"
        return 0
    fi

    log_info "🔌 Installing zsh plugins from custom forks..."
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    install_zsh_plugin "zsh-autosuggestions" "$FORK_ZSH_AUTOSUGGESTIONS" "$zsh_custom/plugins/zsh-autosuggestions"
    install_zsh_plugin "zsh-syntax-highlighting" "$FORK_ZSH_SYNTAX_HIGHLIGHTING" "$zsh_custom/plugins/zsh-syntax-highlighting"
    
    log_success "✅ Zsh plugins installed"
}

install_zsh_plugin() {
    local name="$1"
    local repo="$2"
    local dest="$3"

    if [[ -d "$dest" ]]; then
        log_debug "Updating $name..."
        (cd "$dest" && run_cmd git pull) || log_warning "Failed to update $name"
    else
        log_debug "Cloning $name from $repo..."
        run_cmd git clone --depth 1 "$repo" "$dest"
    fi
}

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

    if [[ -f "$DOTFILES_DIR/shell/.tmux.conf" ]]; then
        safe_symlink "$DOTFILES_DIR/shell/.tmux.conf" "$HOME/.tmux.conf"
    fi

    if [[ -f "$DOTFILES_DIR/git/.gitconfig" ]]; then
        safe_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    fi

    log_success "✅ Shell configuration symlinks created"
}

detect_vscode_config_dir() {
    log_debug "Detecting VS Code config directory..."

    if [[ "$DOTFILES_IN_REMOTE_VSCODE" == "true" ]]; then
        if [[ -d "$HOME/.vscode-server-insiders/data/User" ]]; then echo "$HOME/.vscode-server-insiders/data/User"; return 0; fi
        if [[ -d "$HOME/.vscode-server/data/User" ]]; then echo "$HOME/.vscode-server/data/User"; return 0; fi
        if [[ -d "$HOME/.vscode-remote/data/User" ]]; then echo "$HOME/.vscode-remote/data/User"; return 0; fi
        
        local default_dir="$HOME/.vscode-server/data/User"
        run_cmd mkdir -p "$default_dir"
        echo "$default_dir"
        return 0
    fi

    if [[ -d "$HOME/.config/Code/User" ]]; then echo "$HOME/.config/Code/User"; return 0; fi
    if [[ -d "$HOME/Library/Application Support/Code/User" ]]; then echo "$HOME/Library/Application Support/Code/User"; return 0; fi
    if [[ -d "$HOME/.config/Code - Insiders/User" ]]; then echo "$HOME/.config/Code - Insiders/User"; return 0; fi

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
    safe_symlink "$DOTFILES_DIR/apps/vscode/User/settings.json" "$vscode_dir/settings.json"
    safe_symlink "$DOTFILES_DIR/apps/vscode/User/keybindings.json" "$vscode_dir/keybindings.json"
    safe_symlink "$DOTFILES_DIR/apps/vscode/User/snippets" "$vscode_dir/snippets"
    log_success "✅ VS Code configs symlinked"
}

setup_editor_launcher() {
    if [[ "$SKIP_EDITOR_LAUNCHER" == "true" ]]; then
        log_info "⏭️  Skipping editor launcher setup (DOTFILES_SKIP_EDITOR_LAUNCHER=true)"
        return 0
    fi

    log_info "🔗 Setting up 'e' editor launcher command..."
    safe_symlink "$DOTFILES_DIR/shell/e" "$HOME/bin/e"
    log_success "✅ 'e' editor launcher set up"
}

resolve_op_signer_binary() {
    local platform="$1"
    
    if [[ "${DOTFILES_REMOTE_ENV:-false}" == "true" ]]; then
        local ssh_keygen_path
        ssh_keygen_path=$(command -v ssh-keygen)
        if [[ -x "$ssh_keygen_path" ]]; then echo "$ssh_keygen_path"; return 0; fi
        log_error "ssh-keygen not found! Cannot shim op-signer."
        return 1
    fi

    local binary_path=""
    case "$platform" in
        wsl)
            local win_user
            win_user=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
            [[ -n "$win_user" ]] && binary_path="/mnt/c/Users/${win_user}/AppData/Local/Microsoft/WindowsApps/op-ssh-sign-wsl.exe"
            ;;
        linux) binary_path="/opt/1Password/op-ssh-sign" ;;
        macos) binary_path="/Applications/1Password.app/Contents/MacOS/op-ssh-sign" ;;
        *) return 1 ;;
    esac

    if [[ -f "$binary_path" ]]; then echo "$binary_path"; return 0; fi
    log_warning "1Password signer binary not found at: $binary_path"
    return 1
}

setup_git_shims() {
    if [[ "$SKIP_GIT_SHIMS" == "true" ]]; then
        log_info "⏭️  Skipping git shims setup (DOTFILES_SKIP_GIT_SHIMS=true)"
        return 0
    fi

    log_info "🔗 Setting up git shims..."
    local platform
    platform=$(detect_platform)

    local ssh_cmd="ssh"
    [[ "$platform" == "wsl" ]] && ssh_cmd="ssh.exe"
    
    local ssh_binary
    ssh_binary=$(command -v "$ssh_cmd" 2>/dev/null)

    if [[ -n "$ssh_binary" ]]; then
        safe_symlink "$ssh_binary" "$HOME/bin/git-ssh"
        log_success "✅ Git SSH shim created"
    fi

    local op_binary
    if op_binary=$(resolve_op_signer_binary "$platform"); then
        safe_symlink "$op_binary" "$HOME/bin/op-signer"
        log_success "✅ Op-signer shim created"
    fi

    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        log_info "ℹ️  Note: Ensure ~/bin is in your PATH"
    fi
}

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
# MAIN
# =============================================================================

main() {
    log_info "🚀 Starting dotfiles installation..."
    log_info "📁 Dotfiles directory: $DOTFILES_DIR"

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
    log_info "   1. Restart your shell: source ~/.zshrc "
}

main "$@"
