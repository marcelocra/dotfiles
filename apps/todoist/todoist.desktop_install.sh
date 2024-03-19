#!/usr/bin/env bash

# Creates a symbolic link to the latest version of the app, to avoid having
# references to fixed versions.
ln -s ${HOME}/bin/packages/todoist/Todoist-1.0.9.AppImage \
    ${HOME}/bin/todoist

ln -s ${MCRA_DOTFILES_FOLDER}/apps/todoist/todoist.desktop \
    ${HOME}/.local/share/applications/todoist.desktop

ln -s ${MCRA_DOTFILES_FOLDER}/apps/todoist/todoist.png \
    ${HOME}/.local/share/icons/todoist.png 

# Update desktop files database.
update-desktop-database ~/.local/share/applications