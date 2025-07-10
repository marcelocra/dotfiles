#!/usr/bin/env bash

# Dotfiles Backup and Restore System
# Creates versioned backups of existing configurations and provides restore functionality

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_BASE_DIR="$HOME/.dotfiles-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
CURRENT_BACKUP_DIR="$BACKUP_BASE_DIR/$TIMESTAMP"

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

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  backup              Create a backup of current configurations"
    echo "  restore <timestamp> Restore from a specific backup"
    echo "  list                List available backups"
    echo "  clean               Clean old backups (keeps last 10)"
    echo "  info <timestamp>    Show information about a backup"
    echo ""
    echo "Options:"
    echo "  -f, --force         Force operations without confirmation"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 backup           # Create a backup"
    echo "  $0 list             # List all backups"
    echo "  $0 restore 20241210-143022  # Restore specific backup"
    echo "  $0 clean --force    # Clean old backups without prompt"
}

# Configuration files to backup
declare -A CONFIG_FILES=(
    ["gitconfig"]="$HOME/.gitconfig"
    ["bashrc"]="$HOME/.bashrc"
    ["zshrc"]="$HOME/.zshrc"
    ["local-shell"]="$HOME/.local-shell"
    ["vimrc"]="$HOME/.vimrc"
    ["tmux.conf"]="$HOME/.tmux.conf"
)

declare -A CONFIG_DIRS=(
    ["nvim"]="$HOME/.config/nvim"
    ["kitty"]="$HOME/.config/kitty" 
    ["alacritty"]="$HOME/.config/alacritty"
    ["zed"]="$HOME/.config/zed"
    ["vscode-user"]="$HOME/.config/Code/User"
    ["vscode-user-alt"]="$HOME/Library/Application Support/Code/User"  # macOS
)

# Function to create backup directory structure
create_backup_structure() {
    local backup_dir="$1"
    
    mkdir -p "$backup_dir"/{files,dirs,metadata}
    
    # Create metadata file
    cat > "$backup_dir/metadata/info.txt" << EOF
Backup created: $(date)
Platform: $(uname -s)
User: $(whoami)
Hostname: $(hostname)
Dotfiles version: $(cd "$SCRIPT_DIR" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")
EOF
}

# Function to backup configuration files
backup_files() {
    local backup_dir="$1"
    local backed_up_count=0
    
    print_info "Backing up configuration files..."
    
    for name in "${!CONFIG_FILES[@]}"; do
        local source="${CONFIG_FILES[$name]}"
        local target="$backup_dir/files/$name"
        
        if [[ -f "$source" ]]; then
            cp "$source" "$target"
            print_success "Backed up $name: $source"
            ((backed_up_count++))
        else
            print_warning "File not found: $source"
        fi
    done
    
    return $backed_up_count
}

# Function to backup configuration directories  
backup_directories() {
    local backup_dir="$1"
    local backed_up_count=0
    
    print_info "Backing up configuration directories..."
    
    for name in "${!CONFIG_DIRS[@]}"; do
        local source="${CONFIG_DIRS[$name]}"
        local target="$backup_dir/dirs/$name"
        
        if [[ -d "$source" ]]; then
            cp -r "$source" "$target"
            print_success "Backed up $name: $source"
            ((backed_up_count++))
        else
            print_warning "Directory not found: $source"
        fi
    done
    
    return $backed_up_count
}

# Function to create a backup
create_backup() {
    print_info "Creating backup at $CURRENT_BACKUP_DIR..."
    
    # Create backup structure
    create_backup_structure "$CURRENT_BACKUP_DIR"
    
    # Backup files and directories
    local files_count dirs_count
    backup_files "$CURRENT_BACKUP_DIR"
    files_count=$?
    backup_directories "$CURRENT_BACKUP_DIR" 
    dirs_count=$?
    
    # Update metadata with counts
    echo "Files backed up: $files_count" >> "$CURRENT_BACKUP_DIR/metadata/info.txt"
    echo "Directories backed up: $dirs_count" >> "$CURRENT_BACKUP_DIR/metadata/info.txt"
    
    print_success "Backup completed: $CURRENT_BACKUP_DIR"
    print_info "Backed up $files_count files and $dirs_count directories"
}

# Function to list available backups
list_backups() {
    print_info "Available backups:"
    
    if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
        print_warning "No backups directory found at $BACKUP_BASE_DIR"
        return 0
    fi
    
    local backup_count=0
    for backup in "$BACKUP_BASE_DIR"/*; do
        if [[ -d "$backup" ]]; then
            local backup_name
            backup_name=$(basename "$backup")
            local backup_date
            backup_date=$(date -d "${backup_name:0:8} ${backup_name:9:2}:${backup_name:11:2}:${backup_name:13:2}" 2>/dev/null || echo "unknown")
            
            echo "  📁 $backup_name ($backup_date)"
            
            # Show info if metadata exists
            if [[ -f "$backup/metadata/info.txt" ]]; then
                local files_count dirs_count
                files_count=$(grep "Files backed up:" "$backup/metadata/info.txt" | cut -d: -f2 | xargs)
                dirs_count=$(grep "Directories backed up:" "$backup/metadata/info.txt" | cut -d: -f2 | xargs)
                echo "     Files: ${files_count:-?}, Directories: ${dirs_count:-?}"
            fi
            
            ((backup_count++))
        fi
    done
    
    if [[ $backup_count -eq 0 ]]; then
        print_warning "No backups found"
    else
        print_info "Total backups: $backup_count"
    fi
}

# Function to show backup information
show_backup_info() {
    local timestamp="$1"
    local backup_dir="$BACKUP_BASE_DIR/$timestamp"
    
    if [[ ! -d "$backup_dir" ]]; then
        print_error "Backup not found: $timestamp"
        return 1
    fi
    
    print_info "Backup information for: $timestamp"
    echo ""
    
    if [[ -f "$backup_dir/metadata/info.txt" ]]; then
        cat "$backup_dir/metadata/info.txt"
    else
        print_warning "No metadata found for this backup"
    fi
    
    echo ""
    print_info "Backup contents:"
    
    if [[ -d "$backup_dir/files" ]]; then
        local file_count
        file_count=$(find "$backup_dir/files" -type f | wc -l)
        echo "  Files: $file_count"
        find "$backup_dir/files" -type f -exec basename {} \; | sort | sed 's/^/    - /'
    fi
    
    if [[ -d "$backup_dir/dirs" ]]; then
        local dir_count
        dir_count=$(find "$backup_dir/dirs" -maxdepth 1 -type d | wc -l)
        echo "  Directories: $((dir_count - 1))"  # Subtract 1 for the dirs directory itself
        find "$backup_dir/dirs" -maxdepth 1 -type d ! -path "$backup_dir/dirs" -exec basename {} \; | sort | sed 's/^/    - /'
    fi
}

# Function to restore from backup
restore_backup() {
    local timestamp="$1"
    local force="$2"
    local backup_dir="$BACKUP_BASE_DIR/$timestamp"
    
    if [[ ! -d "$backup_dir" ]]; then
        print_error "Backup not found: $timestamp"
        return 1
    fi
    
    if [[ "$force" != "true" ]]; then
        print_warning "This will overwrite your current configurations!"
        read -p "Are you sure you want to restore from $timestamp? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Restore cancelled"
            return 0
        fi
    fi
    
    # Create a backup of current state before restoring
    local pre_restore_backup="$BACKUP_BASE_DIR/pre-restore-$(date +%Y%m%d-%H%M%S)"
    print_info "Creating backup of current state before restore..."
    CURRENT_BACKUP_DIR="$pre_restore_backup"
    create_backup
    
    print_info "Restoring from backup: $timestamp"
    
    # Restore files
    if [[ -d "$backup_dir/files" ]]; then
        for backup_file in "$backup_dir/files"/*; do
            if [[ -f "$backup_file" ]]; then
                local name
                name=$(basename "$backup_file")
                local target="${CONFIG_FILES[$name]}"
                
                if [[ -n "$target" ]]; then
                    cp "$backup_file" "$target"
                    print_success "Restored file: $target"
                fi
            fi
        done
    fi
    
    # Restore directories
    if [[ -d "$backup_dir/dirs" ]]; then
        for backup_dir_item in "$backup_dir/dirs"/*; do
            if [[ -d "$backup_dir_item" ]]; then
                local name
                name=$(basename "$backup_dir_item")
                local target="${CONFIG_DIRS[$name]}"
                
                if [[ -n "$target" ]]; then
                    # Remove existing directory and restore
                    rm -rf "$target"
                    cp -r "$backup_dir_item" "$target"
                    print_success "Restored directory: $target"
                fi
            fi
        done
    fi
    
    print_success "Restore completed from backup: $timestamp"
    print_info "Pre-restore backup saved at: $pre_restore_backup"
}

# Function to clean old backups
clean_backups() {
    local force="$1"
    local keep_count=10
    
    if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
        print_warning "No backups directory found"
        return 0
    fi
    
    # Get sorted list of backups (newest first)
    local backups=()
    while IFS= read -r -d '' backup; do
        backups+=("$backup")
    done < <(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d ! -path "$BACKUP_BASE_DIR" -print0 | sort -rz)
    
    local total_backups=${#backups[@]}
    
    if [[ $total_backups -le $keep_count ]]; then
        print_info "Only $total_backups backups found. Nothing to clean (keeping last $keep_count)."
        return 0
    fi
    
    local to_remove=$((total_backups - keep_count))
    
    if [[ "$force" != "true" ]]; then
        print_warning "This will remove $to_remove old backups (keeping last $keep_count)."
        read -p "Are you sure? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Cleanup cancelled"
            return 0
        fi
    fi
    
    print_info "Cleaning old backups..."
    
    local removed_count=0
    for ((i = keep_count; i < total_backups; i++)); do
        local backup_to_remove="${backups[$i]}"
        local backup_name
        backup_name=$(basename "$backup_to_remove")
        
        rm -rf "$backup_to_remove"
        print_success "Removed backup: $backup_name"
        ((removed_count++))
    done
    
    print_success "Cleaned $removed_count old backups"
}

# Main function
main() {
    local command=""
    local force="false"
    local timestamp=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            backup|restore|list|clean|info)
                command="$1"
                shift
                ;;
            -f|--force)
                force="true"
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                if [[ "$command" == "restore" || "$command" == "info" ]] && [[ -z "$timestamp" ]]; then
                    timestamp="$1"
                else
                    print_error "Unknown option: $1"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Execute command
    case "$command" in
        backup)
            create_backup
            ;;
        restore)
            if [[ -z "$timestamp" ]]; then
                print_error "Timestamp required for restore command"
                show_usage
                exit 1
            fi
            restore_backup "$timestamp" "$force"
            ;;
        list)
            list_backups
            ;;
        clean)
            clean_backups "$force"
            ;;
        info)
            if [[ -z "$timestamp" ]]; then
                print_error "Timestamp required for info command"
                show_usage
                exit 1
            fi
            show_backup_info "$timestamp"
            ;;
        *)
            print_error "No command specified"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"