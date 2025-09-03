#!/usr/bin/env bash

# VSCode Extensions Installation Script
# Enhanced version with better organization and options

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Extension lists
ESSENTIAL_EXTENSIONS="$SCRIPT_DIR/extensions-essential.txt"
LANGUAGE_EXTENSIONS="$SCRIPT_DIR/extensions-language-specific.txt"
ALL_EXTENSIONS="$SCRIPT_DIR/extensions-installed.txt"

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if code command exists
check_vscode() {
    if ! command -v code >/dev/null 2>&1; then
        print_error "VSCode CLI 'code' command not found. Please install VSCode first."
        exit 1
    fi
}

# Function to install extensions from a file
install_extensions_from_file() {
    local file="$1"
    local description="$2"
    
    if [[ ! -f "$file" ]]; then
        print_error "Extension file not found: $file"
        return 1
    fi
    
    print_info "Installing $description..."
    
    local installed_count=0
    local failed_count=0
    
    while IFS= read -r extension || [[ -n "$extension" ]]; do
        # Skip empty lines and comments
        if [[ -z "$extension" || "$extension" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # Remove any trailing whitespace
        extension=$(echo "$extension" | xargs)
        
        print_info "Installing: $extension"
        
        if code --install-extension "$extension" --force; then
            print_success "Installed: $extension"
            ((installed_count++))
        else
            print_error "Failed to install: $extension"
            ((failed_count++))
        fi
    done < "$file"
    
    print_info "Summary for $description:"
    print_success "Installed: $installed_count extensions"
    if [[ $failed_count -gt 0 ]]; then
        print_error "Failed: $failed_count extensions"
    fi
    
    return 0
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --essential     Install only essential extensions"
    echo "  -l, --language      Install only language-specific extensions"
    echo "  -a, --all           Install all extensions (default)"
    echo "  -c, --check         Check which extensions are installed"
    echo "  -u, --update        Update all installed extensions"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  # Install all extensions"
    echo "  $0 --essential      # Install only essential extensions"
    echo "  $0 --check          # Check installed extensions"
    echo "  $0 --update         # Update all extensions"
}

# Function to check installed extensions
check_installed_extensions() {
    print_info "Checking installed extensions..."
    
    local installed_extensions
    installed_extensions=$(code --list-extensions)
    
    if [[ -z "$installed_extensions" ]]; then
        print_warning "No extensions are currently installed"
        return 0
    fi
    
    print_success "Currently installed extensions:"
    echo "$installed_extensions" | sort
    
    local count
    count=$(echo "$installed_extensions" | wc -l)
    print_info "Total: $count extensions installed"
}

# Function to update all extensions
update_extensions() {
    print_info "Updating all installed extensions..."
    
    local installed_extensions
    installed_extensions=$(code --list-extensions)
    
    if [[ -z "$installed_extensions" ]]; then
        print_warning "No extensions are currently installed"
        return 0
    fi
    
    local updated_count=0
    
    while IFS= read -r extension; do
        print_info "Updating: $extension"
        if code --install-extension "$extension" --force; then
            print_success "Updated: $extension"
            ((updated_count++))
        else
            print_error "Failed to update: $extension"
        fi
    done <<< "$installed_extensions"
    
    print_success "Updated $updated_count extensions"
}

# Main function
main() {
    local install_essential=false
    local install_language=false
    local install_all=false
    local check_extensions=false
    local update_extensions_flag=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--essential)
                install_essential=true
                shift
                ;;
            -l|--language)
                install_language=true
                shift
                ;;
            -a|--all)
                install_all=true
                shift
                ;;
            -c|--check)
                check_extensions=true
                shift
                ;;
            -u|--update)
                update_extensions_flag=true
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
    
    # Check if VSCode is available
    check_vscode
    
    # If no specific options, install all
    if [[ "$install_essential" == false && "$install_language" == false && "$install_all" == false && "$check_extensions" == false && "$update_extensions_flag" == false ]]; then
        install_all=true
    fi
    
    # Execute based on options
    if [[ "$check_extensions" == true ]]; then
        check_installed_extensions
    elif [[ "$update_extensions_flag" == true ]]; then
        update_extensions
    else
        print_info "Starting VSCode extensions installation..."
        
        if [[ "$install_essential" == true ]]; then
            install_extensions_from_file "$ESSENTIAL_EXTENSIONS" "essential extensions"
        fi
        
        if [[ "$install_language" == true ]]; then
            install_extensions_from_file "$LANGUAGE_EXTENSIONS" "language-specific extensions"
        fi
        
        if [[ "$install_all" == true ]]; then
            install_extensions_from_file "$ESSENTIAL_EXTENSIONS" "essential extensions"
            install_extensions_from_file "$LANGUAGE_EXTENSIONS" "language-specific extensions"
        fi
        
        print_success "Extension installation completed!"
        print_info "You may need to restart VSCode for all extensions to work properly."
    fi
}

# Run main function with all arguments
main "$@"