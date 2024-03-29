#!/usr/bin/env bash

# Creates a symbolic link to the latest version of the app, to avoid having
# references to fixed versions.
ln -s ${HOME}/bin/Todoist-1.0.9.AppImage \
    ${HOME}/bin/Todoist-latest

ln -s ${HOME}/projects/personal/dev/config-files/todoist.desktop \
    ${HOME}/.local/share/applications/todoist.desktop

ln -s ${HOME}/projects/personal/dev/config-files/todoist.png \
    ${HOME}/.local/share/icons/todoist.png 

# Update desktop files database.
update-desktop-database ~/.local/share/applications