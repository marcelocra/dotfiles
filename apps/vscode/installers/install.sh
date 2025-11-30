#!/usr/bin/env bash
# Symlinks VSCode settings from dotfiles to the VSCode User directory.
# Supports both VSCode and VSCode Insiders. Backs up existing files.

set -euo pipefail

# Defaults
INSIDERS=false
DOTFILES_PATH="${DOTFILES_PATH:-$HOME/prj/dotfiles/apps/vscode/User}"

# Colors
RED='\033[31m' GREEN='\033[32m' YELLOW='\033[33m' CYAN='\033[36m' GRAY='\033[90m' NC='\033[0m'

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --insiders         Setup for VSCode Insiders"
    echo "  --dotfiles-path    Path to dotfiles User directory (default: \$DOTFILES_PATH or $DOTFILES_PATH)"
    echo "  -h, --help         Show this help"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --insiders) INSIDERS=true; shift ;;
        --dotfiles-path) DOTFILES_PATH="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# Determine VSCode User directory
if [ "$INSIDERS" = true ]; then
    VSCODE_USER_PATH="$HOME/.config/Code - Insiders/User"
    EDITION="VSCode Insiders"
else
    VSCODE_USER_PATH="$HOME/.config/Code/User"
    EDITION="VSCode"
fi

echo -e "${CYAN}Setting up $EDITION configurations...${NC}"
echo -e "${GRAY}Source: $DOTFILES_PATH${NC}"
echo -e "${GRAY}Target: $VSCODE_USER_PATH${NC}\n"

# Files and folders to symlink
ITEMS=("settings.json" "keybindings.json" "tasks.json" "mcp.json" "snippets")
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Ensure target directory exists
mkdir -p "$VSCODE_USER_PATH"

for item in "${ITEMS[@]}"; do
    SOURCE="$DOTFILES_PATH/$item"
    TARGET="$VSCODE_USER_PATH/$item"

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
