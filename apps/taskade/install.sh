#!/bin/bash

cp -f $PWD/apps/taskade/taskade.desktop ~/.local/share/applications
cp -f $PWD/apps/taskade/taskade.svg ~/lib

sed -E -i "s|__HOME_PATH__|$HOME|g" ~/.local/share/applications/taskade.desktop

sudo update-desktop-database
