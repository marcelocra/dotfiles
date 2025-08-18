#!/usr/bin/env bash

set -euo pipefail  # Exit on errors.

source ./.env

readonly DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.config/$USERNAME}"
readonly GIT_EMAIL="${GIT_EMAIL:-$(git config user.email)}"

devcontainers_create_essential_files() {
    # GitHub CLI.
    mkdir -p $HOME/.config/gh

    # Gemini CLI.
    mkdir -p $HOME/.gemini

    # Claude Code.
    mkdir -p $HOME/.claude
    touch $HOME/.claude.json

    # SSH.
    if [[ -d "$HOME/.ssh" ]]; then
        echo 'SSH folder exists. Remove/backup to generate new keys.'
    else
        ssh-keygen -t ed25519 -C "$GIT_EMAIL"
        ln -s ${DOTFILES_DIR}/shell/ssh_config $HOME/.ssh/config
    fi
}

main() {
    local now="$(date '+%F-%T' | tr ':' '-')"
    local zshrc="$HOME/.zshrc"
    local gitconfig="$HOME/.gitconfig"
    local tmuxconf="$HOME/.tmux.conf"
    local sublime_config="$HOME/.config/sublime-text/Packages/User"
    local vscode_config="$HOME/.config/Code/User"

    echo 'Creating symlinks...'

    # Zsh.
    if [[ -f "$zshrc" ]]; then
        echo "File exists: ${zshrc}. Ignoring... Remove/backup and run again."
    else
        ln -s ${DOTFILES_DIR}/shell/init.sh $zshrc
    fi

    # Tmux.
    if [[ -f "$tmuxconf" ]]; then
        echo "File exists: ${tmuxconf}. Ignoring... Remove/backup and run again."
    else
        ln -s ${DOTFILES_DIR}/shell/.tmux.conf $tmuxconf
    fi

    # Git.
    if [[ -f "$gitconfig" ]]; then
        echo "File exists: ${gitconfig}. Ignoring... Remove/backup and run again."
    else
        ln -s ${DOTFILES_DIR}/git/.gitconfig $gitconfig
    fi
    
    # Sublime.
    if [[ -d "$sublime_config" ]]; then
        echo "Folder exists: ${sublime_config}. Ignoring... Remove/backup and run again."
    else
        ln -s ${DOTFILES_DIR}/sublime-text/User $sublime_config
    fi

    # # VSCode.
    # if [[ -d "$vscode_config" ]]; then
    #     echo "Folder exists: ${vscode_config}. Ignoring... Remove/backup and run again."
    # else
    #     ln -s ${DOTFILES_DIR}/vscode/User $vscode_config
    # fi

    devcontainers_create_essential_files
    
    echo 'Done.'
}

main "$@"