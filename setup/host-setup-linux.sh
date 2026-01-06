#!/bin/bash
# host-setup-linux.sh
# Host machine setup script for Linux (Ubuntu, Fedora, openSUSE).
# This script configures editors and host-specific tools that should NOT run in containers.

echo 'INFO: Most likely this is outdated.'
echo 'INFO: Remember, every time you are installing a new system you create one'
echo 'INFO: of these. But you never really use them, as most of the things'
echo 'INFO: become outdated really quickly, and you never use them again. Let'
echo 'INFO: us keep this one as a reminder, so you know NOT to try it again.'
exit 1

set -e

# Configuration from environment variables or defaults.
GITHUB_HANDLE="${MCRA_GITHUB_HANDLE:-marcelocra}"
CONFIG_DIR="${MCRA_CONFIG:-$HOME/.config/marcelocra}"
DOTFILES_APPS="$CONFIG_DIR/dotfiles/apps"
SETUP_VSCODE="${MCRA_SETUP_VSCODE:-true}"
SETUP_SUBLIME="${MCRA_SETUP_SUBLIME:-true}"
SETUP_ZED="${MCRA_SETUP_ZED:-true}"

echo "🚀 Starting Linux host setup"
echo "👤 User: $(whoami)"
echo "🏠 Home: $HOME"
echo "📋 GitHub Handle: $GITHUB_HANDLE"
echo "📦 Dotfiles Dir: $DOTFILES_APPS"

# Function to log with timestamps.
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Check if dotfiles are available.
if [ ! -d "$DOTFILES_APPS" ]; then
    log "❌ Dotfiles not found at $DOTFILES_APPS"
    log "💡 Run devcontainer-setup.sh first or clone dotfiles manually"
    exit 1
fi

# VS Code configuration.
if [ "$SETUP_VSCODE" = "true" ]; then
    VSCODE_LIKE_DIR="$DOTFILES_APPS/vscode-like"
    TARGET_DIR="$HOME/.config/Code/User"

    if command -v code >/dev/null 2>&1 && [ -d "$VSCODE_LIKE_DIR" ]; then
        log "🔗 Setting up VS Code configuration..."
        mkdir -p "$TARGET_DIR"
        
        # Use the new vscode-like structure
        # Editor-specific files
        if [ -f "$VSCODE_LIKE_DIR/vscode/settings.json" ]; then
            ln -sf "$VSCODE_LIKE_DIR/vscode/settings.json" "$TARGET_DIR/settings.json"
        fi
        if [ -f "$VSCODE_LIKE_DIR/vscode/keybindings.json" ]; then
            ln -sf "$VSCODE_LIKE_DIR/vscode/keybindings.json" "$TARGET_DIR/keybindings.json"
        fi
        
        # Shared files
        if [ -d "$VSCODE_LIKE_DIR/shared/snippets" ]; then
            ln -sf "$VSCODE_LIKE_DIR/shared/snippets" "$TARGET_DIR/snippets"
        fi
        if [ -f "$VSCODE_LIKE_DIR/shared/tasks.json" ]; then
            ln -sf "$VSCODE_LIKE_DIR/shared/tasks.json" "$TARGET_DIR/tasks.json"
        fi
        if [ -f "$VSCODE_LIKE_DIR/shared/mcp.json" ]; then
            ln -sf "$VSCODE_LIKE_DIR/shared/mcp.json" "$TARGET_DIR/mcp.json"
        fi

        log "✅ VS Code configuration linked"
    else
        log "ℹ️  Skipping VS Code (not installed or no config found)"
    fi
fi

# Sublime Text configuration.
if [ "$SETUP_SUBLIME" = "true" ]; then
    SRC_DIR="$DOTFILES_APPS/sublime-text/User"
    TARGET_DIR="$HOME/.config/sublime-text/Packages/User"

    if [ -d "$SRC_DIR" ]; then
        log "🔗 Setting up Sublime Text configuration..."
        mkdir -p "$TARGET_DIR"
        
        # Only symlink specific Sublime config files.
        TO_SYMLINK=(
            "_mcra_main.sublime-snippet"
            "_mcra_plugin_commands.py"
            "Default.sublime-keymap"
            "Default.sublime-mousemap"
            "Distraction Free.sublime-settings"
            "Preferences.sublime-settings"
            "snippets"
        )

        for file in "${TO_SYMLINK[@]}"; do
            if [ -f "$SRC_DIR/$file" ]; then
                ln -sf "$SRC_DIR/$file" "$TARGET_DIR/$file"
            elif [ -d "$SRC_DIR/$file" ]; then
                ln -sf "$SRC_DIR/$file" "$TARGET_DIR/$file"
            fi
        done

        log "✅ Sublime Text configuration linked"
    else
        log "ℹ️  Skipping Sublime Text (no config found)"
    fi
fi

# Zed configuration.
if [ "$SETUP_ZED" = "true" ]; then
    SRC_DIR="$DOTFILES_APPS/zed"
    TARGET_DIR="$HOME/.config/zed"

    if [ -d "$SRC_DIR" ]; then
        log "🔗 Setting up Zed configuration..."
        mkdir -p "$TARGET_DIR"
        
        # Only symlink specific Zed config files.

        TO_SYMLINK=(
            "settings.json"
            "keymap.json"
            "themes"
        )

        for file in "${TO_SYMLINK[@]}"; do
            if [ -f "$SRC_DIR/$file" ]; then
                ln -sf "$SRC_DIR/$file" "$TARGET_DIR/$file"
            elif [ -d "$SRC_DIR/$file" ]; then
                ln -sf "$SRC_DIR/$file" "$TARGET_DIR/$file"
            fi
        done
        
        log "✅ Zed configuration linked"
    else
        log "ℹ️  Skipping Zed (no config found)"
    fi
fi

log "🎉 Linux host setup complete!"
log "💡 Editor configurations are now linked from your dotfiles"
log "🔧 To customize this setup, edit: https://github.com/$GITHUB_HANDLE/dotfiles/blob/main/host-setup-linux.sh"