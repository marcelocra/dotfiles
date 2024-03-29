#!/usr/bin/env bash

# 1. Download the latest version of portacle from the website:
#    https://portacle.github.io/
# 2. Extract it to your desired folder. I use put all binaries
#    in ${HOME}/bin.
# 3. Symlink as follows.

# Create a top level binary, to be automatically exported in
# your PATH (I export ${HOME}/bin in my .zshrc.
ln -s ${HOME}/bin/portacle/portacle.run \
    ${HOME}/bin/Portacle

# Copy the desktop entry to the global desktop entry folder.
ln -s ${HOME}/projects/personal/dev/config-files/portacle.desktop \
    ${HOME}/.local/share/applications/portacle.desktop

# Copy the icon to the global icon folder.
ln -s ${HOME}/projects/personal/dev/config-files/portacle.svg \
    ${HOME}/.local/share/icons/portacle.svg 

# Update desktop files database. After this, searching for
# portacle in the system search bar should show it and allow
# launching the program.
update-desktop-database ~/.local/share/applications
