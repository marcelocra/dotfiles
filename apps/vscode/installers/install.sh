#!/usr/bin/env bash
# Symlinks VSCode settings from dotfiles to the editor's User directory.
# Supports VSCode, VSCode Insiders, Cursor, Kiro, and Antigravity. Backs up existing files.

set -euo pipefail

# Defaults
EDITOR_TYPE="code"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/x/dotfiles}"
DOTFILES_PATH="${DOTFILES_PATH:-${DOTFILES_DIR}/apps/vscode/User}"

# Colors
RED='\033[31m' GREEN='\033[32m' YELLOW='\033[33m' CYAN='\033[36m' GRAY='\033[90m' NC='\033[0m'

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --code             Setup for VSCode (default)"
    echo "  --insiders         Setup for VSCode Insiders"
    echo "  --cursor           Setup for Cursor"
    echo "  --kiro             Setup for Kiro"
    echo "  --antigravity      Setup for Antigravity"
    echo "  --dotfiles-path    Path to dotfiles User directory (default: \$DOTFILES_PATH or $DOTFILES_PATH)"
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
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# Determine User directory based on editor type
case $EDITOR_TYPE in
    code)
        USER_PATH="$HOME/.config/Code/User"
        EDITION="VSCode"
        ;;
    insiders)
        USER_PATH="$HOME/.config/Code - Insiders/User"
        EDITION="VSCode Insiders"
        ;;
    cursor)
        USER_PATH="$HOME/.config/Cursor/User"
        EDITION="Cursor"
        ;;
    kiro)
        USER_PATH="$HOME/.config/Kiro/User"
        EDITION="Kiro"
        ;;
    antigravity)
        USER_PATH="$HOME/.config/Antigravity/User"
        EDITION="Antigravity"
        ;;
esac

echo -e "${CYAN}Setting up $EDITION configurations...${NC}"
echo -e "${GRAY}Source: $DOTFILES_PATH${NC}"
echo -e "${GRAY}Target: $USER_PATH${NC}\n"

# Files and folders to symlink
ITEMS=("settings.json" "keybindings.json" "tasks.json" "mcp.json" "snippets")
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Ensure target directory exists
mkdir -p "$USER_PATH"

for item in "${ITEMS[@]}"; do
    SOURCE="$DOTFILES_PATH/$item"
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
