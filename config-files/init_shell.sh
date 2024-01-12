#!/usr/bin/env sh
# vim: foldmethod=marker foldmarker={{{,}}} foldlevel=1 foldenable autoindent expandtab tabstop=4 shiftwidth=4
#
# TODO: this file is too big already. Perhaps move each section to its own
# file, in the shell subdir?

# [ Exports ] ---------------------------------------------------------------{{{

# dotnet.
export DOTNET_ROOT="${HOME}/bin/dotnet"
export DOTNET_CLI_TELEMETRY_OPTOUT=true
export PATH="${PATH}:${DOTNET_ROOT}"

# Homebrew.
export HOMEBREW_NO_ANALYTICS=1

# Flutter.
export FLUTTER_SDK="${HOME}/bin/flutter"
export FLUTTER_ROOT="${FLUTTER_SDK}/bin"
export PATH="${PATH}:${FLUTTER_ROOT}"

# Deno.
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# Fly.io.
export FLYCTL_INSTALL="/home/marcelocra/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# Path.
export PATH="${PATH}:${HOME}/bin"

# fzf.
# TODO: set this up only for tmux above 3.2
# export FZF_TMUX_OPTS='-p80%,60%'
export FZF_TMUX_OPTS='-d50%'

# Nextjs.
# Print what would be collected to stderr without sending it. Set this to 0 to
# allow telemetry, along with a 0 in the next one.
export NEXT_TELEMETRY_DEBUG=0
# Disable telemetry by setting this to 1.
export NEXT_TELEMETRY_DISABLED=1

# Astro.build
# Disable telemetry by setting this to 1.
export ASTRO_TELEMETRY_DISABLED=1

# next export


# }}}
# [ Functions ] -------------------------------------------------------------{{{

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


easy_jump_to_project() {
    if [[ ! -z "${MCRA_PROJECTS_FOLDER}" ]]; then
        if [[ ! -z "$1" ]]; then
            pushd ${MCRA_PROJECTS_FOLDER}/$1
        else
            popd
        fi
    else
        echo '${MCRA_PROJECTS_FOLDER} not defined'
    fi
}
alias j="easy_jump_to_project"

if command -v nvim &> /dev/null; then
    export EDITOR=nvim
elif command -v vim &> /dev/null; then
    export EDITOR=vim
elif command -v vi &> /dev/null; then
    export EDITOR=vi
else
    echo "You don't have neovim, vim or vi installed. EDITOR env not defined"
fi



# }}}
# [ Aliases ] ---------------------------------------------------------------{{{
# General stuff {{{

alias vim="$EDITOR"
alias vi=vim
alias v=vim
if [[ $EDITOR == "nvim" ]]; then
    alias vimdiff="nvim -d"
fi

# The -T option sets terminal features for the client. Uses csv format.
# Features:
#   - 256: forces tmux to assume the terminal supports 256 colors. It is the
#     same as running tmux with -2: `tmux -2`.
# alias tmux='TERM=xterm-256color tmux -T 256'
# alias tmux='tmux -2'

alias pip=pip3

if [[ `uname` == "Darwin" ]]; then
    # Mac doesn't support the --time-style flag.
    alias l='ls -lFh -t'
else
    # -l: print as a list.
    # -F: classify (folder vs files).
    # -h: print human readable sizes (using K, M, G instead of bytes).
    # -t: sort by time, most recently updated first.
    # --time-style: how to show time. Currently, 30mar23[22:10].
    alias l='ls -lFh -t --time-style="+%d%b%y[%H:%M]"'
fi

alias ll='l -a'

alias n=npm
alias p=pnpm
alias y=yarn
alias r='n run'

if [[ ! -z "${MCRA_INIT_SHELL}" && ! -z "${MCRA_LOCAL_SHELL}" ]]; then
    alias rc='vim $MCRA_INIT_SHELL'
    alias rcl='vim $MCRA_LOCAL_SHELL'
    alias rcz='vim ~/.zshrc'
    alias rcb='vim ~/.bashrc'
    alias rc.='source $MCRA_INIT_SHELL && source $MCRA_LOCAL_SHELL'
else
    alias rc="echo 'Define \$MCRA_INIT_SHELL and \$MCRA_LOCAL_SHELL in your rc file'"
    alias rcl=rc
    alias rcz=rc
    alias rcb=rc
    alias rc.=rc
fi

# }}}
# Git: shortcuts I use frequently {{{
# -----------------------------------

alias gs='git status'
# simple and resumed, no branches
alias gss='git status -s'
# simple and resumed, with branches
alias gsb='git status -sb'

alias ga='git add'
alias gaa='git add --all'

alias gb='git branch'

alias gco='git checkout'
# Go back to previous branch.
alias gco-='git checkout -'

alias gc='git commit -v'
alias gcm='git commit -m'

alias gd='git d'

alias gpl="git pull"
alias gps="git push"
alias gpd='git push --dry-run'

alias gld="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
alias gl="gld -5"
alias gla="gld"
# git log graph
alias glg='git log --oneline --decorate --graph --all'
# git log simple
alias glsa="git log --oneline --no-decorate"
alias gls="glsa -5"
# git log messages
alias glm='git log --pretty=format:"* %s"'

alias grs='git restore'
alias grss='git restore --staged'

alias gst='git stash'
alias gsta='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash push -m'
# TODO: test this when stashing
alias gsts='git stash show --text'
alias gstall='git stash --all'

alias gsh='git show'
alias gsps='git show --pretty=short --show-signature'

alias gt='git tag'
alias gta='git tag -a'
alias gts='git tag -s'
alias gtv='git tag | sort -V'

# TODO: test this
alias gchanges='git whatchanged -p --abbrev-commit --pretty=medium'

alias git-undo-last='git reset HEAD~'

# }}}
# Git lfs {{{
# -----------

alias glfsdry="git lfs push origin main --dry-run --all"
alias glfss="git lfs status"

# }}}
# Docker {{{
# ----------

alias dc="docker compose"
alias docker-prune-month-old-images='docker image prune -a --filter "until=720h"'
alias docker-prune-two-week-old-images='docker image prune -a --filter "until=336h"'

docker_images_sorted() {
    docker images --format "table {{.ID}}\t{{.Size}}\t{{.Repository}}:{{.Tag}}" \
        | head -n1
            docker images --format "{{.ID}}\t{{.Size}}\t{{.Repository}}:{{.Tag}}" \
                | awk '{match($2, /([0-9.]+)([KMG]?B)/, a); size = a[1]; unit = a[2]; if (unit == "GB") size *= 1024; else if (unit == "KB") size /= 1024; printf "%s\t%09.2f MB\t%s \n", $1, size, $3}' \
                | (sed -u 1q; sort -k 2 -h)
            }

            alias di='docker_images_sorted'

# }}}
# Aliases that are not grouped by some context {{{
# ------------------------------------------------
# alias code="code-insiders"
alias code="code"
alias p1="code \$MCRA_P1"

alias td="turbo dev --filter"

# Speech synthesizer.
alias fala="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"
alias falar="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"

# AsciiDoc.
alias asciidoctor="docker run --rm -it -v $(pwd):/documents/ asciidoctor/docker-asciidoctor"
alias asciidoctor-gen="docker run --rm -v $(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf index.adoc"

# Supabase.
alias sup="supabase"

# Always use sed with extended regexes.
if [[ `uname` == "Darwin" ]]; then
    alias sed='sed -E'
else
    alias sed='sed -r'
fi

# I never remember how to extract tar files. Now I discovered that it
# automatically detect the compression format, so I only need to provide the -x
# (extract) and the -f (point to file) options (f has to be the last one if
# they are provided together).
alias untar="tar -xf"

# Next aliases above!

# }}}
# }}}
# [ Commands ] --------------------------------------------------------------{{{


# Ignore commands for Mac and run them in Ubuntu (should work in other Unixes
# too, but I haven't tested).
if [[ ! `uname` == "Darwin" ]]; then
    # Activate Linuxbrew.
    if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi
# }}}

# next commands above

