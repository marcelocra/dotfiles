#!/usr/bin/env bash

# Creates a symbolic link to the latest version of Obsidian, to avoid having
# references to fixed versions.
ln -s ${HOME}/bin/packages/obsidian/Obsidian-0.15.9.AppImage \
    ${HOME}/bin/obsidian

ln -s ${MCRA_DOTFILES_FOLDER}/apps/obsidian/obsidian.desktop \
    ${HOME}/.local/share/applications/obsidian.desktop

# Credits to the creator of the icons here:
# https://forum.obsidian.md/t/big-sur-icon/8121
ln -s ${MCRA_DOTFILES_FOLDER}/apps/obsidian/obsidian.png \
    ${HOME}/.local/share/icons/obsidian.png 

# Update desktop files database.
update-desktop-database ~/.local/share/applications