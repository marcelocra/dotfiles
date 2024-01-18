#!/usr/bin/env bash

if [[ "$1" != "0" && "$1" != "1" && "$1" != "2" ]]; then
    echo 'Invalid option'
    exit 1
fi

gdbus call --session \
    --dest org.gnome.Shell \
    --object-path /org/gnome/Shell \
    --method org.gnome.Shell.Eval \
    "imports.ui.status.keyboard.getInputSourceManager().inputSources[$1].activate()"

