#!/usr/bin/env bash


# Functions


# Simplifies working with tmux. Tries to create
# a new session and if it already exists, just
# jump to it.
tmx() {
    # Try to create a new session.
    tmux new -s $1 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 0
    fi

    echo "Trying to reuse session $1..."
    sleep 0.5
    # Try to load existing session.
    tmux attach-session -t $1 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 0
    fi

    # Something else happened.
    echo "An error happened. Couldn't load $1"
    return 1
}


# Aliases


alias vim=nvim
alias vi=nvim

alias tmux="TERM=xterm-256color tmux"

alias pip=pip3
alias python=python3

alias l="ls -lFh --block-size=MB"
alias ll="l -a"


# Exports


export DOTNET_CLI_TELEMETRY_OPTOUT=true
export EDITOR=vim

