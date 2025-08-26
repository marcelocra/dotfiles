#!/bin/bash
# host-setup-linux.sh
# Host machine setup script for Linux (Ubuntu, Fedora, openSUSE)
# This script configures editors and host-specific tools that should NOT run in containers

set -e

# Configuration from environment variables or defaults
GITHUB_HANDLE="${MCRA_GITHUB_HANDLE:-marcelocra}"
CONFIG_DIR="${MCRA_CONFIG:-$HOME/.config/marcelocra}"
DOTFILES_DIR="$CONFIG_DIR/dotfiles"
SETUP_VSCODE="${MCRA_SETUP_VSCODE:-true}"
SETUP_SUBLIME="${MCRA_SETUP_SUBLIME:-true}"
SETUP_ZED="${MCRA_SETUP_ZED:-true}"

echo "🚀 Starting Linux host setup"
echo "👤 User: $(whoami)"
echo "🏠 Home: $HOME"
echo "📋 GitHub Handle: $GITHUB_HANDLE"
echo "📦 Dotfiles Dir: $DOTFILES_DIR"

# Function to log with timestamps
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Check if dotfiles are available
if [ ! -d "$DOTFILES_DIR" ]; then
    log "❌ Dotfiles not found at $DOTFILES_DIR"
    log "💡 Run devcontainer-setup.sh first or clone dotfiles manually"
    exit 1
fi

# VS Code configuration
if [ "$SETUP_VSCODE" = "true" ]; then
    if command -v code >/dev/null 2>&1 && [ -d "$DOTFILES_DIR/vscode" ]; then
        log "🔗 Setting up VS Code configuration..."
        mkdir -p "$HOME/.config/Code/User"
        
        # Only symlink specific VS Code config files, not the entire directory
        [ -f "$DOTFILES_DIR/vscode/settings.json" ] && ln -sf "$DOTFILES_DIR/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
        [ -f "$DOTFILES_DIR/vscode/keybindings.json" ] && ln -sf "$DOTFILES_DIR/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
        [ -d "$DOTFILES_DIR/vscode/snippets" ] && ln -sf "$DOTFILES_DIR/vscode/snippets" "$HOME/.config/Code/User/snippets"
        
        log "✅ VS Code configuration linked"
    else
        log "ℹ️  Skipping VS Code (not installed or no config found)"
    fi
fi

# Sublime Text configuration
if [ "$SETUP_SUBLIME" = "true" ]; then
    if [ -d "$DOTFILES_DIR/sublime" ]; then
        log "🔗 Setting up Sublime Text configuration..."
        mkdir -p "$HOME/.config/sublime-text-3/Packages/User"
        
        # Only symlink specific Sublime config files
        [ -f "$DOTFILES_DIR/sublime/Preferences.sublime-settings" ] && ln -sf "$DOTFILES_DIR/sublime/Preferences.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
        [ -f "$DOTFILES_DIR/sublime/Default.sublime-keymap" ] && ln -sf "$DOTFILES_DIR/sublime/Default.sublime-keymap" "$HOME/.config/sublime-text-3/Packages/User/Default.sublime-keymap"
        [ -f "$DOTFILES_DIR/sublime/Package Control.sublime-settings" ] && ln -sf "$DOTFILES_DIR/sublime/Package Control.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/Package Control.sublime-settings"
        
        # Symlink snippets if they exist
        [ -d "$DOTFILES_DIR/sublime/snippets" ] && ln -sf "$DOTFILES_DIR/sublime/snippets" "$HOME/.config/sublime-text-3/Packages/User/snippets"
        
        log "✅ Sublime Text configuration linked"
    else
        log "ℹ️  Skipping Sublime Text (no config found)"
    fi
fi

# Zed configuration
if [ "$SETUP_ZED" = "true" ]; then
    if [ -d "$DOTFILES_DIR/zed" ]; then
        log "🔗 Setting up Zed configuration..."
        mkdir -p "$HOME/.config/zed"
        
        # Only symlink specific Zed config files
        [ -f "$DOTFILES_DIR/zed/settings.json" ] && ln -sf "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
        [ -f "$DOTFILES_DIR/zed/keymap.json" ] && ln -sf "$DOTFILES_DIR/zed/keymap.json" "$HOME/.config/zed/keymap.json"
        [ -d "$DOTFILES_DIR/zed/themes" ] && ln -sf "$DOTFILES_DIR/zed/themes" "$HOME/.config/zed/themes"
        
        log "✅ Zed configuration linked"
    else
        log "ℹ️  Skipping Zed (no config found)"
    fi
fi

log "🎉 Linux host setup complete!"
log "💡 Editor configurations are now linked from your dotfiles"
log "🔧 To customize this setup, edit: https://github.com/$GITHUB_HANDLE/dotfiles/blob/main/host-setup-linux.sh"