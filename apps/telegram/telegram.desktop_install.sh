#!/usr/bin/env bash

# Creates a symbolic link to the latest version of the app, to avoid having
# references to fixed versions.
ln -s ${HOME}/bin/packages/Telegram/Telegram \
    ${HOME}/bin/telegram

ln -s ${MCRA_DOTFILES_FOLDER}/apps/telegram/telegram.desktop \
    ${HOME}/.local/share/applications/telegram.desktop

ln -s ${MCRA_DOTFILES_FOLDER}/apps/telegram/telegram.png \
    ${HOME}/.local/share/icons/telegram.png 

# Update desktop files database.
update-desktop-database ~/.local/share/applications