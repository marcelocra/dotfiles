#!/usr/bin/env bash
# Symlinks Zed editor settings from dotfiles to the editor's config directory.
# Backs up existing files, if any, with a .backup timestamped suffix.

CONFIG_DIR="$HOME/.config/zed"
DOTFILES_DIR="$HOME/prj/dotfiles/apps/zed"

# Create the config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Symlink the configuration files
for file in "$DOTFILES_DIR"/*; do
  filename=$(basename "$file")
  target="$CONFIG_DIR/$filename"

  # Backup existing files
  if [ -e "$target" ]; then
    mv "$target" "$target.backup.$(date +%Y%m%d%H%M%S)"
  fi

  ln -s "$file" "$target"
done