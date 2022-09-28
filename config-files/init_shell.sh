#!/usr/bin/env zsh


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

alias l="ls -lFh"
alias ll="l -a"

alias p=pnpm
alias pr="p run"


# Exports


export DOTNET_CLI_TELEMETRY_OPTOUT=true
export HOMEBREW_NO_ANALYTICS=1
export EDITOR=vim


# Commands


# Are we running a Mac or Linux?
if [[ `uname` == "Darwin" ]]; then
    # Do mac stuff.
else
    # Do linux stuff.
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi