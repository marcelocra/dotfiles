#!/bin/bash

cp -f $PWD/apps/kiro/kiro.desktop ~/.local/share/applications
cp -f $PWD/apps/kiro/kiro.svg ~/lib

sed -E -i "s|__HOME_PATH__|$HOME|g" ~/.local/share/applications/kiro.desktop

sudo update-desktop-database
