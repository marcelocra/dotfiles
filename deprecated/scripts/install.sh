#!/usr/bin/env bash

# Dotfiles Installation Script
# A comprehensive installer for the dotfiles configuration

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Installation configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$DOTFILES_DIR/install.log"

# Function to print colored output
print_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                           DOTFILES INSTALLER                                ║"
    echo "║                      Personal Development Environment                       ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

print_step() {
    echo -e "${CYAN}🔧 $1${NC}" | tee -a "$LOG_FILE"
}

# Function to detect platform
detect_platform() {
    local platform="unknown"
    local in_container="false"
    local in_wsl="false"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q Microsoft /proc/version 2>/dev/null; then
            platform="wsl"
            in_wsl="true"
        else
            platform="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        platform="macos"
    fi
    
    if [[ -f /.dockerenv ]] || [[ -n "${CONTAINER:-}" ]]; then
        in_container="true"
    fi
    
    echo "platform=$platform,container=$in_container,wsl=$in_wsl"
}

# Function to check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check essential tools
    if ! command -v git >/dev/null 2>&1; then
        missing_tools+=("git")
    fi
    
    if ! command -v curl >/dev/null 2>&1; then
        missing_tools+=("curl")
    fi
    
    if ! command -v bash >/dev/null 2>&1; then
        missing_tools+=("bash")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_info "Please install the missing tools and run the installer again."
        exit 1
    fi
    
    print_success "All prerequisites satisfied"
}

# Function to create backup directory
create_backup() {
    print_step "Creating backup directory at $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    print_success "Backup directory created"
}

# Function to backup existing configuration
backup_existing_config() {
    local source="$1"
    local backup_path="$BACKUP_DIR/$(basename "$source")"
    
    if [[ -e "$source" ]]; then
        print_info "Backing up existing $source to $backup_path"
        cp -r "$source" "$backup_path"
        return 0
    fi
    
    return 1
}

# Function to create symlinks
create_symlink() {
    local source="$1"
    local target="$2"
    local force="${3:-false}"
    
    # Create target directory if it doesn't exist
    local target_dir
    target_dir="$(dirname "$target")"
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
    fi
    
    # Backup existing file if it exists
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        if [[ "$force" == "true" ]]; then
            backup_existing_config "$target"
            rm -rf "$target"
        else
            print_warning "Target $target already exists. Use --force to overwrite."
            return 1
        fi
    fi
    
    # Create symlink
    ln -sf "$source" "$target"
    print_success "Created symlink: $target -> $source"
}

# Function to set up environment variables
setup_environment() {
    print_step "Setting up environment variables..."
    
    local shell_config=""
    
    # Detect shell configuration file
    if [[ -n "${BASH_VERSION:-}" ]]; then
        shell_config="$HOME/.bashrc"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        shell_config="$HOME/.zshrc"
    else
        # Default to bashrc
        shell_config="$HOME/.bashrc"
    fi
    
    # Check if environment variables are already set
    if grep -q "MCRA_INIT_SHELL" "$shell_config" 2>/dev/null; then
        print_info "Environment variables already configured in $shell_config"
        return 0
    fi
    
    # Add environment variables
    backup_existing_config "$shell_config"
    
    cat >> "$shell_config" << EOF

# Dotfiles configuration
export MCRA_INIT_SHELL="$DOTFILES_DIR/init.sh"
export MCRA_LOCAL_SHELL="\$HOME/.local-shell"
export MCRA_TMP_PLAYGROUND="/tmp/playground"

# Source the main configuration
if [[ -f "\$MCRA_INIT_SHELL" ]]; then
    source "\$MCRA_INIT_SHELL"
fi
EOF
    
    print_success "Environment variables added to $shell_config"
}

# Function to install configurations
install_configurations() {
    local force="$1"
    
    print_step "Installing configuration files..."
    
    # Git configuration
    create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig" "$force"
    
    # Neovim configuration (LazyVim)
    if [[ -d "$DOTFILES_DIR/neovim/LazyVim" ]]; then
        create_symlink "$DOTFILES_DIR/neovim/LazyVim" "$HOME/.config/nvim" "$force"
    fi
    
    # Kitty terminal configuration
    if [[ -d "$DOTFILES_DIR/kitty" ]]; then
        create_symlink "$DOTFILES_DIR/kitty" "$HOME/.config/kitty" "$force"
    fi
    
    # Alacritty terminal configuration
    if [[ -d "$DOTFILES_DIR/alacritty" ]]; then
        create_symlink "$DOTFILES_DIR/alacritty" "$HOME/.config/alacritty" "$force"
    fi
    
    # Zed editor configuration
    if [[ -d "$DOTFILES_DIR/zed" ]]; then
        case "$(detect_platform | cut -d',' -f1 | cut -d'=' -f2)" in
            "macos")
                create_symlink "$DOTFILES_DIR/zed" "$HOME/Library/Application Support/Zed" "$force"
                ;;
            "linux"|"wsl")
                create_symlink "$DOTFILES_DIR/zed" "$HOME/.config/zed" "$force"
                ;;
        esac
    fi
    
    print_success "Configuration files installed"
}

# Function to install VSCode extensions
install_vscode_extensions() {
    print_step "Installing VSCode extensions..."
    
    if ! command -v code >/dev/null 2>&1; then
        print_warning "VSCode CLI not found. Skipping extension installation."
        return 0
    fi
    
    if [[ -f "$DOTFILES_DIR/vscode/install-extensions.sh" ]]; then
        bash "$DOTFILES_DIR/vscode/install-extensions.sh" --essential
        print_success "VSCode extensions installed"
    else
        print_warning "VSCode extension installer not found"
    fi
}

# Function to create local shell configuration
create_local_shell() {
    local local_shell="$HOME/.local-shell"
    
    if [[ ! -f "$local_shell" ]]; then
        print_step "Creating local shell configuration..."
        
        cat > "$local_shell" << EOF
#!/usr/bin/env bash
# Local shell configuration
# This file is not tracked by git and is for local customizations

# Add your local aliases, exports, and functions here
# Examples:
# export CUSTOM_VAR="value"
# alias myalias="command"

# Work-specific configurations
# export WORK_PROJECT_DIR="\$HOME/work"

# Personal configurations
# export PERSONAL_PROJECT_DIR="\$HOME/personal"
EOF
        
        print_success "Created local shell configuration at $local_shell"
    else
        print_info "Local shell configuration already exists"
    fi
}

# Function to show post-installation instructions
show_post_install() {
    print_success "Installation completed successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
    echo "  2. Run the dependency checker: ./check-dependencies.sh"
    echo "  3. Customize your local configuration: \$EDITOR ~/.local-shell"
    echo "  4. Install additional VSCode extensions if needed:"
    echo "     ./vscode/install-extensions.sh --language"
    echo ""
    print_info "Backup created at: $BACKUP_DIR"
    print_info "Installation log: $LOG_FILE"
    echo ""
    print_warning "If you encounter issues, check the backup directory and log file."
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -f, --force         Force overwrite existing configurations"
    echo "  -s, --skip-vscode   Skip VSCode extension installation"
    echo "  -e, --env-only      Only set up environment variables"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  # Install with prompts for overwrites"
    echo "  $0 --force          # Force overwrite existing configs"
    echo "  $0 --skip-vscode    # Install without VSCode extensions"
}

# Main installation function
main() {
    local force="false"
    local skip_vscode="false"
    local env_only="false"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--force)
                force="true"
                shift
                ;;
            -s|--skip-vscode)
                skip_vscode="true"
                shift
                ;;
            -e|--env-only)
                env_only="true"
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Start installation
    print_banner
    
    # Initialize log file
    echo "Dotfiles installation started at $(date)" > "$LOG_FILE"
    
    # Detect platform
    local platform_info
    platform_info=$(detect_platform)
    print_info "Platform detected: $platform_info"
    
    # Check prerequisites
    check_prerequisites
    
    # Create backup directory
    create_backup
    
    if [[ "$env_only" == "true" ]]; then
        setup_environment
    else
        # Install configurations
        install_configurations "$force"
        
        # Set up environment
        setup_environment
        
        # Create local shell configuration
        create_local_shell
        
        # Install VSCode extensions (if not skipped)
        if [[ "$skip_vscode" == "false" ]]; then
            install_vscode_extensions
        fi
    fi
    
    # Show post-installation instructions
    show_post_install
}

# Run main function with all arguments
main "$@"