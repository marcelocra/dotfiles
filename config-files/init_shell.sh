#!/usr/bin/env sh
# vim: fdm=marker:fmr={{{,}}}:foldlevel=0:fen

# [ Exports ] ------------------------------------------------------------------{{{

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
export FZF_TMUX_OPTS='-p80%,60%'

# Nextjs.
# Print what would be collected to stderr without sending it. Set this to 0 to
# allow telemetry, along with a 0 in the next one.
export NEXT_TELEMETRY_DEBUG=0
# Disable telemetry by setting this to 1.
export NEXT_TELEMETRY_DISABLED=1

# next export


# }}}
# [ Functions ] ----------------------------------------------------------------{{{

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


if [[ ! -z "${MCRA_PROJECTS_FOLDER}" ]]; then
  easy_jump_to_project() {
    if [[ ! -z "$1" ]]; then
      pushd ${MCRA_PROJECTS_FOLDER}/$1
    else
      popd
    fi
  }

  alias j="easy_jump_to_project"
fi

editor() {
  if command -v nvim &> /dev/null; then
    export EDITOR=nvim
    return
  fi

  if command -v vim &> /dev/null; then
    export EDITOR=vim
    return
  fi

  if command -v vi &> /dev/null; then
    export EDITOR=vi
    return
  fi

  echo "You don't have neovim, vim or vi installed. EDITOR var not defined"
}

editor


# }}}
# [ Aliases ] ------------------------------------------------------------------{{{
# General stuff.{{{

alias vim="$EDITOR"
alias vi=vim
if [[ $EDITOR == "nvim" ]]; then
  alias vimdiff="nvim -d"
fi

alias tmux='TERM=xterm-256color tmux'

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

if [[ ! -z "${MCRA_INIT_SHELL}" ]]; then
  alias init='vim ${MCRA_INIT_SHELL}'
  alias erc='vim ~/.zshrc'
  alias src='source ~/.zshrc'
else
  alias init="echo 'Define \$MCRA_INIT_SHELL in your rc file'"
  alias erc=init
  alias src=init
fi

# }}}
# Git: shortcuts I use frequently{{{
# -------------------------------

alias g='git'

alias ga='git add'
alias gaa='git add --all'

alias gb='git branch'
alias gbd='git branch -d'
alias gbD='git branch -D'

alias gcb='git checkout -b'
alias gcf='git config'
alias gcfl='git config --list'
alias gcfso='git config --show-origin'

alias gcl='git clone'

alias gc='git commit -v'
alias gcm='git commit -m'

alias gco='git checkout'
alias gc-='git checkout -'

alias gd='git d'
alias gdiff='git diff'

alias gf='git fetch'
alias gfo='git fetch origin'

alias gpsup='git push --set-upstream origin'

alias gpl="git pull"

alias glg="git log"
alias glgs='git log --stat'
alias gld="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
alias gl="gld -5"
alias gla="gld"
alias glga='git log --oneline --decorate --graph --all'
alias gls='git log --oneline --no-decorate -5'
alias glsa='git log --oneline --no-decorate'
alias glt='git log --pretty=format:"* %s"'

# alias gm='git merge'
# alias gma='git merge --abort'

alias gps="git push"
alias gpd='git push --dry-run'

alias gra='git remote add'

alias gr='git remote'
# alias grb='git rebase'
# alias grba='git rebase --abort'
# alias grbc='git rebase --continue'
# alias grbi='git rebase -i'

alias grs='git restore'
alias grset='git remote set-url'
alias grss='git restore --staged'
alias grv='git remote -v'

alias gsb='git status -sb'
alias gsh='git show'
alias gsps='git show --pretty=short --show-signature'
alias gss='git status -s'
alias gs="git status"

alias gst='git stash'
alias gsta='git stash apply'
# alias gstc='git stash clear'
# alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash push -m'
alias gsts='git stash show --text'
alias gstall='git stash --all'

alias gt='git tag'
alias gta='git tag -a'
alias gts='git tag -s'
alias gtv='git tag | sort -V'

alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'

alias gi='git init'

alias git-undo-last="git reset HEAD~"

# }}}
# Git: shortcuts I keep here as reference{{{
# ---------------------------------------
# Should either move them above or remove them.

# alias gba='git branch -a'
# alias gbl='git blame -b -w'
# alias gbnm='git branch --no-merged'
# alias gbr='git branch --remote'
# alias gbs='git bisect'
# alias gbsb='git bisect bad'
# alias gbsg='git bisect good'
# alias gbsr='git bisect reset'
# alias gbss='git bisect start'

# alias gc!='git commit -v --amend'
# alias gcn!='git commit -v --no-edit --amend'
# alias gca='git commit -v -a'
# alias gca!='git commit -v -a --amend'
# alias gcan!='git commit -v -a --no-edit --amend'
# alias gcam='git commit -a -m'

# alias gclr='git clone --recurse-submodules'
# alias gclean='git clean -id'
# alias gpristine='git reset --hard && git clean -dffx'
# alias gcor='git checkout --recurse-submodules'
# alias gcount='git shortlog -sn'
# alias gcp='git cherry-pick'
# alias gcpa='git cherry-pick --abort'
# alias gcpc='git cherry-pick --continue'

# alias gdca='git diff --cached'
# alias gdcw='git diff --cached --word-diff'
# alias gdct='git describe --tags $(git rev-list --tags --max-count=1)'
# alias gds='git diff --staged'
# alias gdt='git diff-tree --no-commit-id --name-only -r'
# alias gdw='git diff --word-diff'

# alias gfg='git ls-files | grep'

# alias ggpull='git pull origin'
# alias ggpush='git push origin'

# alias ghh='git help'

# alias glgp='git log --stat -p'
# alias glgg='git log --graph'
# alias glgga='git log --graph --decorate --all'
# alias glm='git log --graph --max-count=10'
# alias glo='git log --oneline --decorate'
# alias glol="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'"
# alias glols="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat"
# alias glods="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short"
# alias glola="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all"
# alias glog='git log --oneline --decorate --graph'

# alias gpf!='git push --force'

# alias grbo='git rebase --onto'
# alias grbs='git rebase --skip'
# alias grev='git revert'
# alias grh='git reset'
# alias grhh='git reset --hard'
# alias grm='git rm'
# alias grmc='git rm --cached'
# alias grmv='git remote rename'
# alias grrm='git remote remove'

# alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'
# alias gru='git reset --'
# alias grup='git remote update'

# alias gunignore='git update-index --no-assume-unchanged'
# alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
# alias gup='git pull --rebase'
# alias gupv='git pull --rebase -v'
# alias gupa='git pull --rebase --autostash'
# alias gupav='git pull --rebase --autostash -v'

# }}}
# Git lfs{{{
# -------

alias glfsdry="git lfs push origin main --dry-run --all"
alias glfss="git lfs status"

# }}}
# Docker{{{
# ------

alias dc="docker-compose"
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
# Add aliases that are not grouped by some context below{{{
# ------------------------------------------------------
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


# Next aliases above!

# }}}
# }}}
# [ Commands ] -----------------------------------------------------------------{{{


# Ignore commands for Mac and run them in Ubuntu (should work in other Unixes
# too, but I haven't tested).
if [[ ! `uname` == "Darwin" ]]; then
    # Activate Linuxbrew.
    if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi
# }}}
