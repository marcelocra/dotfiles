#!/usr/bin/env bash

# Creates a symbolic link to the latest version of Obsidian, to avoid having
# references to fixed versions.
ln -s ${HOME}/apps/Obsidian-0.15.9.AppImage \
    ${HOME}/apps/Obsidian-latest.AppImage

ln -s ${HOME}/projects/personal/dev/config-files/obsidian.desktop \
    ${HOME}/.local/share/applications/obsidian.desktop

ln -s ${HOME}/projects/personal/dev/config-files/obsidian.png \
    ${HOME}/.local/share/icons/obsidian.png 