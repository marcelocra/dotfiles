#!/usr/bin/env bash
# Symlinks VS Code-like editor settings from dotfiles to the editor's User directory.
# Supports VSCode, VSCode Insiders, Cursor, Kiro, and Antigravity. Backs up existing files.

set -euo pipefail

# Defaults
EDITOR_TYPE="code"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/x/dotfiles}"
DOTFILES_PATH="${DOTFILES_PATH:-${DOTFILES_DIR}/apps/vscode-like}"
USER_PATH_OVERRIDE=""
AUTO_DETECT_REMOTE="${AUTO_DETECT_REMOTE:-true}"

# Colors
RED='\033[31m' GREEN='\033[32m' YELLOW='\033[33m' CYAN='\033[36m' GRAY='\033[90m' NC='\033[0m'

# Detect remote VS Code config directory (for SSH/container scenarios)
detect_remote_vscode_path() {
    local editor_type="$1"

    # Check for remote VS Code server paths
    if [[ -n "${REMOTE_CONTAINERS:-}" ]] || [[ -n "${CODESPACES:-}" ]] || [[ -n "${SSH_CONNECTION:-}" ]]; then
        case "$editor_type" in
            insiders)
                if [[ -d "$HOME/.vscode-server-insiders/data/User" ]]; then
                    echo "$HOME/.vscode-server-insiders/data/User"
                    return 0
                fi
                ;;
            code|*)
                if [[ -d "$HOME/.vscode-server/data/User" ]]; then
                    echo "$HOME/.vscode-server/data/User"
                    return 0
                fi
                if [[ -d "$HOME/.vscode-remote/data/User" ]]; then
                    echo "$HOME/.vscode-remote/data/User"
                    return 0
                fi
                # Create default remote path if it doesn't exist
                if [[ -n "${REMOTE_CONTAINERS:-}" ]] || [[ -n "${CODESPACES:-}" ]]; then
                    local default_dir="$HOME/.vscode-server/data/User"
                    mkdir -p "$default_dir"
                    echo "$default_dir"
                    return 0
                fi
                ;;
        esac
    fi

    return 1
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --code             Setup for VSCode (default)"
    echo "  --insiders         Setup for VSCode Insiders"
    echo "  --cursor           Setup for Cursor"
    echo "  --kiro             Setup for Kiro"
    echo "  --antigravity      Setup for Antigravity"
    echo "  --dotfiles-path    Path to dotfiles vscode-like directory (default: \$DOTFILES_PATH or $DOTFILES_PATH)"
    echo "  --user-path        Override User directory path (for remote VS Code, etc.)"
    echo "  -h, --help         Show this help"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --code) EDITOR_TYPE="code"; shift ;;
        --insiders) EDITOR_TYPE="insiders"; shift ;;
        --cursor) EDITOR_TYPE="cursor"; shift ;;
        --kiro) EDITOR_TYPE="kiro"; shift ;;
        --antigravity) EDITOR_TYPE="antigravity"; shift ;;
        --dotfiles-path) DOTFILES_PATH="$2"; shift 2 ;;
        --user-path) USER_PATH_OVERRIDE="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# Determine User directory and editor-specific folder based on editor type
# Use override if provided, otherwise try auto-detection, then use defaults
if [[ -n "$USER_PATH_OVERRIDE" ]]; then
    USER_PATH="$USER_PATH_OVERRIDE"
    # Determine editor folder from editor type
    case $EDITOR_TYPE in
        cursor) EDITOR_FOLDER="cursor" ;;
        *) EDITOR_FOLDER="vscode" ;;
    esac
    # Determine edition name
    case $EDITOR_TYPE in
        code) EDITION="VSCode" ;;
        insiders) EDITION="VSCode Insiders" ;;
        cursor) EDITION="Cursor" ;;
        kiro) EDITION="Kiro" ;;
        antigravity) EDITION="Antigravity" ;;
    esac
else
    # Try auto-detecting remote VS Code paths first (for SSH/container scenarios)
    if [[ "$AUTO_DETECT_REMOTE" == "true" ]] && remote_path=$(detect_remote_vscode_path "$EDITOR_TYPE"); then
        USER_PATH="$remote_path"
        case $EDITOR_TYPE in
            code) EDITION="VSCode (Remote)"; EDITOR_FOLDER="vscode" ;;
            insiders) EDITION="VSCode Insiders (Remote)"; EDITOR_FOLDER="vscode" ;;
            *) EDITION="$EDITOR_TYPE (Remote)"; EDITOR_FOLDER="vscode" ;;
        esac
    else
        # Use default native paths
        case $EDITOR_TYPE in
            code)
                USER_PATH="$HOME/.config/Code/User"
                EDITION="VSCode"
                EDITOR_FOLDER="vscode"
                ;;
            insiders)
                USER_PATH="$HOME/.config/Code - Insiders/User"
                EDITION="VSCode Insiders"
                EDITOR_FOLDER="vscode"
                ;;
            cursor)
                USER_PATH="$HOME/.config/Cursor/User"
                EDITION="Cursor"
                EDITOR_FOLDER="cursor"
                ;;
            kiro)
                USER_PATH="$HOME/.config/Kiro/User"
                EDITION="Kiro"
                EDITOR_FOLDER="vscode"  # Kiro uses VS Code configs
                ;;
            antigravity)
                USER_PATH="$HOME/.config/Antigravity/User"
                EDITION="Antigravity"
                EDITOR_FOLDER="vscode"  # Antigravity uses VS Code configs
                ;;
        esac
    fi
fi

echo -e "${CYAN}Setting up $EDITION configurations...${NC}"
echo -e "${GRAY}Source: $DOTFILES_PATH${NC}"
echo -e "${GRAY}Target: $USER_PATH${NC}\n"

# Shared files/folders
SHARED_ITEMS=("snippets" "tasks.json" "mcp.json")
# Editor-specific files
EDITOR_ITEMS=("settings.json" "keybindings.json")

TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Ensure target directory exists
mkdir -p "$USER_PATH"

# Symlink shared items
for item in "${SHARED_ITEMS[@]}"; do
    SOURCE="$DOTFILES_PATH/shared/$item"
    TARGET="$USER_PATH/$item"

    if [ ! -e "$SOURCE" ]; then
        echo -e "${YELLOW}⚠ Skip: $item (source not found)${NC}"
        continue
    fi

    if [ -L "$TARGET" ]; then
        echo -e "${GRAY}→ $item already symlinked${NC}"
        continue
    fi

    if [ -e "$TARGET" ]; then
        BACKUP="$TARGET.backup.$TIMESTAMP"
        echo -e "${YELLOW}📦 Backup: $item → ${BACKUP##*/}${NC}"
        mv "$TARGET" "$BACKUP"
    fi

    ln -s "$SOURCE" "$TARGET"
    echo -e "${GREEN}✓ Linked: $item${NC}"
done

# Symlink editor-specific items
for item in "${EDITOR_ITEMS[@]}"; do
    SOURCE="$DOTFILES_PATH/$EDITOR_FOLDER/$item"
    TARGET="$USER_PATH/$item"

    if [ ! -e "$SOURCE" ]; then
        echo -e "${YELLOW}⚠ Skip: $item (source not found)${NC}"
        continue
    fi

    if [ -L "$TARGET" ]; then
        echo -e "${GRAY}→ $item already symlinked${NC}"
        continue
    fi

    if [ -e "$TARGET" ]; then
        BACKUP="$TARGET.backup.$TIMESTAMP"
        echo -e "${YELLOW}📦 Backup: $item → ${BACKUP##*/}${NC}"
        mv "$TARGET" "$BACKUP"
    fi

    ln -s "$SOURCE" "$TARGET"
    echo -e "${GREEN}✓ Linked: $item${NC}"
done

echo -e "\n${GREEN}✅ Done!${NC}"
