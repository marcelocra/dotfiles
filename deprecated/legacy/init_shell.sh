#!/usr/bin/env bash
#
# TODO: this file is too big already. Perhaps move each section to its own
# file, in the shell subdir?

# envs and programs(((

# Important envs and programs that I need:

is_defined() {
    if [[ -z "$1" ]]; then
        echo "'$2' is not defined"
    fi
}

is_defined "$MCRA_PROJECTS_FOLDER" "MCRA_PROJECTS_FOLDER"
is_defined "$MCRA_INIT_SHELL" "MCRA_INIT_SHELL"
is_defined "$MCRA_LOCAL_SHELL" "MCRA_LOCAL_SHELL"
is_defined "$MCRA_TMP_PLAYGROUND" "MCRA_TMP_PLAYGROUND"


# Defines pnpm home for globally installed scripts.
if [[ -z "$PNPM_HOME" ]]; then
    export PNPM_HOME="/home/marcelocra/.local/share/pnpm"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
fi

# Node version manager.
if [[ -z "$NVM_DIR" ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# )))envs and programs
# exports(((

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
# # TODO: set this up only for tmux above 3.2
# # export FZF_TMUX_OPTS='-p80%,60%'
# export FZF_TMUX_OPTS='-d50%'
export FZF_TMUX=0
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Nextjs.
# Print what would be collected to stderr without sending it. Set this to 0 to
# allow telemetry, along with a 0 in the next one.
# export NEXT_TELEMETRY_DEBUG=0
# Disable telemetry by setting this to 1.
export NEXT_TELEMETRY_DISABLED=1

# Astro.build
# Disable telemetry by setting this to 1.
export ASTRO_TELEMETRY_DISABLED=1

# Install Ruby Gems to ~/bin/packages/ruby/gems
export GEM_HOME="$HOME/bin/packages/ruby/gems"
if [[ ! -d "$GEM_HOME" ]]; then mkdir -p "$GEM_HOME"; fi
export PATH="$GEM_HOME/bin:$PATH"

# bun
[ -s "/home/marcelocra/.bun/_bun" ] && source "/home/marcelocra/.bun/_bun"  # completions
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# )))exports
# functions(((

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

# Setup the default text editor based on what is installed.
if command -v nvim &> /dev/null; then
    export EDITOR=nvim
elif command -v vim &> /dev/null; then
    export EDITOR=vim
elif command -v vi &> /dev/null; then
    export EDITOR=vi
else
    echo "You don't have neovim, vim or vi installed. EDITOR env not defined"
fi


# Desktop notification to help me change tasks.
function timer_notification() {
    local summary="$1"
    local default_summary='TEMPO ACABOU!'
    local content="$2"
    local default_content="Pronto! Hora de ir para a próxima tarefa!\n\nSe controla e faz isso, pra realmente conseguir avançar e não se sentir mal mais.\n\n\n----- IGNORE BELOW -----\n\n\nAgora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco."

    if [ -z "$summary" ]; then
        summary=$default_summary
    else
        summary="$(echo $summary | tr '[:lower:]' '[:upper:]')"
        summary="$summary - $default_summary"
    fi

    if [ -z "$content" ]; then
        content="$default_content"
    fi

    notify-send -u critical "$summary" "$content"
}

function timer() {
    local time="$1"
    local default_time="30m"

    if [[ -z "$time" ]]; then
        echo "Not time provided, using default ($default_time). You can either provide a value (format: 1s, 20m, 2h, 1h20m) or use an existing template (currently: t1, t5, t15, t30, t60) all in minutes."
        time="$default_time"
    fi

    sleep "$time" && timer_notification
}
alias t1="sleep 1m && timer_notification"
alias t5="sleep 5m && timer_notification"
alias t15="sleep 15m && timer_notification"
alias t30="sleep 30m && timer_notification"
alias t60="sleep 1h && timer_notification"



# )))functions
# aliases(((
# one lettered(((

# Used in the next sections:

# b = popd
# l = ls ...
# n = reserved
# r = js run
# s = reserved
# t = go to my temp dir
# v = vim
# x = npx

alias x="npx"

# )))one lettered
# general(((

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

# Always use the same tmp and make it easy to go there.
if [[ ! -d "$MCRA_TMP_PLAYGROUND" ]]; then
    mkdir $MCRA_TMP_PLAYGROUND
fi
alias t="pushd $MCRA_TMP_PLAYGROUND"

# As in 'back'.
alias b="popd"

js () {
    if [[ -f 'pnpm-lock.yaml' ]]; then
        pnpm "$@"
    elif [[ -f 'package-lock.json' ]]; then
        npm "$@"
    elif [[ -f 'yarn.lock' ]]; then
        yarn "$@"
    elif [[ -f 'bun.lockb' ]]; then
        bun "$@"
    else
        echo 'This project does not have a lockfile'
    fi
}
alias r="js run"

alias bbg="bb --config ~/.config/babashka/bb.edn"
alias bbge="v ~/.config/babashka/bb.edn"

alias colines='echo "Columns: $COLUMNS, Lines: $LINES"'

alias shad='npx shadow-cljs'
alias shads='shad server'
alias shadw='shad watch'

alias path="echo $PATH | tr ':' '\n'"

# Next aliases above!


# )))general
# git frequent(((

alias gs='git status'
# simple and resumed, no branches
alias gss='git status -s'
# simple and resumed, with branches
alias gsb='git status -sb'

alias ga='git add'
alias gaa='git add --all'

alias gb='git branch'
alias gbd='git branch -d'

alias gco='git checkout'
# Go back to previous branch.
alias gco-='git checkout -'

alias gc='git commit -v'
alias gcm='git commit -m'

alias gac='gaa && gc'
alias gacm='gaa && gcm'

alias gd='git d'

alias gpl="git pull"
alias gps="git push"
alias gpsso="git push --set-upstream origin main"
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
alias grssa='git restore --staged .'

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

# )))git frequent
# git lfs(((

alias glfsdry="git lfs push origin main --dry-run --all"
alias glfss="git lfs status"

# )))git lfs
# docker(((

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

# )))docker
# )))aliases
# commands(((

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# )))commands

# vim: foldmethod=marker foldmarker=(((,))) foldlevel=1 foldenable autoindent expandtab tabstop=4 shiftwidth=4
