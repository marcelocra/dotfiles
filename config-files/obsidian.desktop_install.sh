#!/usr/bin/env bash

# Creates a symbolic link to the latest version of Obsidian, to avoid having
# references to fixed versions.
ln -s ${HOME}/bin/Obsidian-0.15.9.AppImage \
    ${HOME}/bin/Obsidian-latest

ln -s ${HOME}/projects/personal/dev/config-files/obsidian.desktop \
    ${HOME}/.local/share/applications/obsidian.desktop

# Credits to the creator of the icons here:
# https://forum.obsidian.md/t/big-sur-icon/8121
ln -s ${HOME}/projects/personal/dev/config-files/obsidian.png \
    ${HOME}/.local/share/icons/obsidian.png 