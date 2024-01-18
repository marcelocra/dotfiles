#!/usr/bin/env bash

gdbus call --session \
    --dest org.gnome.Shell \
    --object-path /org/gnome/Shell \
    --method org.gnome.Shell.Eval \
    "imports.ui.status.keyboard.getInputSourceManager().currentSource.index" \
    | awk -F'[^0-9]*' '{print $2}'

