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

alias tmux='TERM=xterm-256color tmux'

alias pip=pip3
alias python=python3

alias l='ls -lFh -t'
alias ll='l -a -t'

alias p=pnpm
alias pr='p run'

alias rc='vim ~/.zshrc'
alias src='source ~/.zshrc'

# Git native
# ----------

alias g='git'

alias ga='git add'
alias gaa='git add --all'

alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbl='git blame -b -w'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'

alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gcn!='git commit -v --no-edit --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcan!='git commit -v -a --no-edit --amend'
alias gcam='git commit -a -m'
alias gcb='git checkout -b'
alias gcf='git config --list'
alias gcfso='git config --show-origin'

alias gcl='git clone'
alias gclr='git clone --recurse-submodules'
alias gclean='git clean -id'
alias gpristine='git reset --hard && git clean -dffx'
alias gcm='git commit -m'
alias gco='git checkout'
alias gc-='git checkout -'
alias gcor='git checkout --recurse-submodules'
alias gcount='git shortlog -sn'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

alias gd='git d'
alias gdf='git diff'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gdct='git describe --tags $(git rev-list --tags --max-count=1)'
alias gds='git diff --staged'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdw='git diff --word-diff'

alias gf='git fetch'
alias gfo='git fetch origin'

alias gfg='git ls-files | grep'

alias ggpull='git pull origin'
alias ggpush='git push origin'

alias gpsup='git push --set-upstream origin'

alias ghh='git help'

alias gpl="git pull"
alias glg="git log"
alias glg='git log --stat'
alias glgp='git log --stat -p'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glm='git log --graph --max-count=10'
alias glo='git log --oneline --decorate'
alias glol="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'"
alias glols="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat"
alias glod="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
alias gl="glod"
alias gls="gl -5"
alias glods="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short"
alias glola="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all"
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'

alias gm='git merge'
alias gma='git merge --abort'

alias gps="git push"
alias gpd='git push --dry-run'
alias gpf!='git push --force'

alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grbo='git rebase --onto'
alias grbs='git rebase --skip'
alias grev='git revert'
alias grh='git reset'
alias grhh='git reset --hard'
alias grm='git rm'
alias grmc='git rm --cached'
alias grmv='git remote rename'
alias grrm='git remote remove'
alias grs='git restore'
alias grset='git remote set-url'
alias grss='git restore --source'
alias grst='git restore --staged'
alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'
alias gru='git reset --'
alias grup='git remote update'
alias grv='git remote -v'

alias gsb='git status -sb'
alias gsh='git show'
alias gsps='git show --pretty=short --show-signature'
alias gss='git status -s'
alias gs="git status"

alias gst='git stash'
alias gsta='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gstall='git stash --all'

alias gts='git tag -s'
alias gtv='git tag | sort -V'

alias gunignore='git update-index --no-assume-unchanged'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
alias gup='git pull --rebase'
alias gupv='git pull --rebase -v'
alias gupa='git pull --rebase --autostash'
alias gupav='git pull --rebase --autostash -v'

alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'

alias gi='git init'

# Git lfs
# -------

alias glfsdry="git lfs push origin main --dry-run --all"
alias glfss="git lfs status"

# Docker
# ------

alias dc="docker-compose"


# [ Exports ] ------------------------------------------------------------------


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

# Other.
export EDITOR=vim
export PATH="${PATH}:${HOME}/bin"


# [ Commands ] -----------------------------------------------------------------


# Ignore commands for Mac and run them in Ubuntu (should work in other Unixes
# too, but I haven't tested).
if [[ ! `uname` == "Darwin" ]]; then
    # Activate Linuxbrew.
    if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi
