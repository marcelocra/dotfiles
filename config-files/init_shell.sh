#!/usr/bin/env sh


# [ Functions ] ----------------------------------------------------------------


# Simplifies working with tmux. Tries to create
# a new session and if it already exists, just
# jump to it.
tmx() {
    local session_name
    session_name="$1"

    # If no session name was given, use a default one.
    if [ -z "$session_name" ]; then
        session_name="default"
    fi

    # Try to create a new session.
    tmux new -s $session_name > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 0
    fi

    echo "Trying to reuse session $session_name..."
    sleep 0.5
    # Try to load existing session.
    tmux attach-session -t $session_name > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 0
    fi

    # Something else happened.
    echo "An error happened. Couldn't load $session_name"
    return 1
}


# [ Aliases ] ------------------------------------------------------------------


alias vim=nvim
alias vi=nvim

alias tmux="TERM=xterm-256color tmux"

alias pip=pip3
alias python=python3

alias l="ls -lFh"
alias ll="l -a"

alias p=pnpm
alias pr="p run"

alias rc="vim ~/.zshrc"
alias src="source ~/.zshrc"

# Git

alias gs="git status"
alias gss="git status -s"
alias gp="git push"
alias gpl="git pull"
alias gl="git log"
alias gc="git commit"
alias gcm="git commit -m"
alias gco="git checkout"
alias gb="git branch"
alias gte="git remote"
alias grm="git rm"
alias grs="git restore"
alias glfsdry="git lfs push origin main --dry-run --all"


# [ Exports ] ------------------------------------------------------------------


export DOTNET_CLI_TELEMETRY_OPTOUT=true
export HOMEBREW_NO_ANALYTICS=1
export EDITOR=vim


# [ Commands ] -----------------------------------------------------------------


# Ignore commands for Mac and run them in Ubuntu (should work in other Unixes
# too, but I haven't tested).
if [[ ! `uname` == "Darwin" ]]; then
    # Make caps lock a new control.
    if command -v setxkbmap &> /dev/null; then
        setxkbmap -option caps:ctrl_modifier
    fi

    # Activate Linuxbrew.
    if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi
