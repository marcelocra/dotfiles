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
#   ~/prj/dotfiles/shell/install.sh
#
# Environment variables:
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

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/prj/dotfiles}"

# Feature flags (can be disabled via environment variables)
SKIP_HOMEBREW="${DOTFILES_SKIP_HOMEBREW:-false}"
SKIP_CLI_TOOLS="${DOTFILES_SKIP_CLI_TOOLS:-false}"
SKIP_ZSH_PLUGINS="${DOTFILES_SKIP_ZSH_PLUGINS:-false}"
SKIP_VSCODE="${DOTFILES_SKIP_VSCODE:-false}"
SKIP_EDITOR_LAUNCHER="${DOTFILES_SKIP_EDITOR_LAUNCHER:-false}"
SKIP_GIT_SHIMS="${DOTFILES_SKIP_GIT_SHIMS:-false}"
SKIP_SSH_CONFIG="${DOTFILES_SKIP_SSH_CONFIG:-false}"
DEBUG="${DOTFILES_DEBUG:-0}"

# Custom fork repositories (for security - you control the source)
FORK_FZF_REPO="${FORK_FZF_REPO:-https://github.com/marcelocra/fzf.git}"
FORK_ZSH_AUTOSUGGESTIONS="${FORK_ZSH_AUTOSUGGESTIONS:-https://github.com/marcelocra/zsh-autosuggestions.git}"
FORK_ZSH_SYNTAX_HIGHLIGHTING="${FORK_ZSH_SYNTAX_HIGHLIGHTING:-https://github.com/marcelocra/zsh-syntax-highlighting.git}"

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

    log_debug "Container: $DOTFILES_IN_CONTAINER, WSL: $DOTFILES_IN_WSL, Remote VS Code: $DOTFILES_IN_REMOTE_VSCODE"
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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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

    # Install fzf from custom fork for security
    install_fzf

    # Install other tools via Homebrew (if available)
    if command_exists brew; then
        install_brew_packages
    else
        log_warning "⚠️  Homebrew not available, skipping brew package installation"
    fi
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

    local packages=(
        "bat"                     # Better cat
        "borkdude/brew/babashka"  # Clojure scripting
        "fd"                      # Better find
        "ripgrep"                 # Better grep
        # ---------- Other tools that might be useful one day. -----------------
        # "jq"   # JSON processor. Already present in the image I'm using.
        # "hugo" # Static site generator. I usually prefer Astro or Next.
        # "eza"  # Better ls. TODO: Compare with exa and decide which to use.
        # "yq"   # YAML processor. I don't deal that much with yaml files.
        
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
        ln -sf "$DOTFILES_DIR/shell/.tmux.conf" "$HOME/.tmux.conf"
        log_debug "Symlinked .tmux.conf"
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
    local settings_file="$DOTFILES_DIR/apps/vscode/User/settings.json"
    local keybindings_file="$DOTFILES_DIR/apps/vscode/User/keybindings.json"
    if [[ -f "$settings_file" ]]; then
        ln -sf "$settings_file" "$vscode_dir/settings.json"
        log_debug "Symlinked settings.json"
    else
        log_warning "⚠️  settings.json not found at $settings_file"
    fi

    # Keybindings
    if [[ -f "$keybindings_file" ]]; then
        ln -sf "$keybindings_file" "$vscode_dir/keybindings.json"
        log_debug "Symlinked keybindings.json"
    else
        log_warning "⚠️  keybindings.json not found at $keybindings_file"
    fi

    # Snippets
    local snippets_dir="$DOTFILES_DIR/apps/vscode/User/snippets"
    if [[ -d "$snippets_dir" ]]; then
        mkdir -p "$vscode_dir/snippets"
        ln -sf "$snippets_dir" "$vscode_dir/snippets"
        log_debug "Symlinked snippets directory"
    else
        log_warning "⚠️  snippets directory not found at $snippets_dir"
    fi

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
    local kernel
    kernel=$(uname -s)

    case "$kernel" in
        Linux*)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        Darwin*)
            echo "macos"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Returns the path to 1Password SSH signer binary if it exists, or fails
resolve_op_signer_binary() {
    local platform="$1"
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

setup_git_shims() {
    if [[ "$SKIP_GIT_SHIMS" == "true" ]]; then
        log_info "⏭️  Skipping git shims setup (DOTFILES_SKIP_GIT_SHIMS=true)"
        return 0
    fi

    # Skip in containers - 1Password isn't typically available
    if [[ "$DOTFILES_IN_CONTAINER" == "true" ]]; then
        log_info "⏭️  Skipping git shims setup (running in container)"
        return 0
    fi

    local shim_path="$HOME/bin/op-signer"

    log_info "🔗 Setting up git shims for 1Password SSH signing..."

    local platform
    platform=$(detect_platform)
    
    local source_binary
    if ! source_binary=$(resolve_op_signer_binary "$platform"); then
        # Warning already logged in resolve_op_signer_binary
        return 0
    fi

    if safe_symlink "$source_binary" "$shim_path"; then
        log_success "✅ Git shim created: op-signer -> $source_binary"
    fi

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

    # Only run on native Linux/macOS (not WSL, not containers)
    if [[ "$DOTFILES_IN_CONTAINER" == "true" ]]; then
        log_info "⏭️  Skipping SSH config setup (running in container)"
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
    log_info "   1. Restart your shell or run: source ~/.zshrc"
    log_info "   2. Reload VS Code window to apply settings (if using VS Code)"
    log_info "   3. Ensure ~/bin is in your PATH"
    log_info ""
    log_info "💡 To customize this installation:"
    log_info "   - Set environment variables (DOTFILES_SKIP_* flags)"
    log_info "   - Edit $DOTFILES_DIR/shell/install.sh"
    log_info ""
    log_info "📋 Available skip flags:"
    log_info "   DOTFILES_SKIP_HOMEBREW=true"
    log_info "   DOTFILES_SKIP_CLI_TOOLS=true"
    log_info "   DOTFILES_SKIP_ZSH_PLUGINS=true"
    log_info "   DOTFILES_SKIP_VSCODE=true"
    log_info "   DOTFILES_SKIP_EDITOR_LAUNCHER=true"
    log_info "   DOTFILES_SKIP_GIT_SHIMS=true"
    log_info "   DOTFILES_SKIP_SSH_CONFIG=true"
}

# Execute main function
main "$@"
