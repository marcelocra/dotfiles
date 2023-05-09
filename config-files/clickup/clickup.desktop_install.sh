#!/usr/bin/env bash

# Creates a symbolic link to the latest version of the app, to avoid having
# references to fixed versions.
ln -s ${HOME}/bin/binaries/ClickUp-3.2.8.AppImage \
    ${HOME}/bin/clickup

ln -s $(pwd)/clickup.desktop \
    ${HOME}/.local/share/applications/clickup.desktop

ln -s "$(pwd)/icons/desktop app - gradient circle@2x.png" \
    ${HOME}/.local/share/icons/clickup.png 

# Update desktop files database.
update-desktop-database ~/.local/share/applications