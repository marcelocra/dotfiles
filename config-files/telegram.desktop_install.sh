#!/usr/bin/env bash

# Creates a symbolic link to the latest version of Obsidian, to avoid having
# references to fixed versions.
ln -s ${HOME}/bin/Telegram/Telegram \
    ${HOME}/bin/Telegram-latest

ln -s ${HOME}/projects/personal/dev/config-files/telegram.desktop \
    ${HOME}/.local/share/applications/telegram.desktop

ln -s ${HOME}/projects/personal/dev/config-files/telegram.png \
    ${HOME}/.local/share/icons/telegram.png 