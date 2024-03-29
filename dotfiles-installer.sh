#!/usr/bin/env bash
# vim: ai:et:ts=4:sw=4
#
# Must be run from the root directory.

# -e: exit on error
# -o pipefail: exits on command pipe failures
set -eo pipefail

if [[ "$(basename $(pwd))" != "dotfiles" ]]
then
    echo 'Please, run this script from the root (dotfiles) directory'
    exit 1
fi

# Common shell init. If the script is re-run, it should not add stuff to rc
# files again.
if [[ -z "$MCRA_INIT_SHELL" ]]; then
    MCRA_INIT_SHELL="$HOME/.rc"
    MCRA_LOCAL_SHELL="$HOME/.rc.local"

    # The init shell contain common shell stuff. The local one has things that
    # we don't need/want to commit, like system or installation specific
    # configuration.
    MCRA_TO_SOURCE="

# -----------------------------------------------------------------------------
# My shell settings.
# ------------------
# To add local stuff, DO NOT add here, but in the local shell file (use the
# alias rcl to open it to edit directly.
# -----------------------------------------------------------------------------
export MCRA_INIT_SHELL=$MCRA_INIT_SHELL
export MCRA_LOCAL_SHELL=$MCRA_LOCAL_SHELL
export MCRA_TMP_PLAYGROUND="/tmp/mcra-tmp-playground"

# Local should be first, as the other one checks for some expected MCRA_* env
# variables.
source \$MCRA_LOCAL_SHELL
source \$MCRA_INIT_SHELL
# -----------------------------------------------------------------------------


"
    echo "$MCRA_TO_SOURCE" >> ~/.zshrc
    echo "$MCRA_TO_SOURCE" >> ~/.bashrc
fi

main() {
    # dotfiles.
    local symlink_cmd="ln -s"

    symlink_cmd $(pwd)/.gitconfig ~/.gitconfig
    symlink_cmd $(pwd)/.tmux.conf ~/.tmux.conf

    if [[ ! -d ~/.clojure ]]; then
        mkdir ~/.clojure
        symlink_cmd $(pwd)/deps.edn ~/.clojure/deps.edn
    else
        if [[ ! -f ~/.clojure/deps.edn ]]; then
            symlink_cmd $(pwd)/deps.edn ~/.clojure/deps.edn
        fi
    fi

    if [[ ! -d ~/.config/nvim ]]; then
        mkdir ~/.config/nvim
        symlink_cmd $(pwd)/vim/vimrc ~/.config/nvim/init.vim
    else
        if [[ ! -f ~/.config/nvim/init.vim ]]; then
            symlink_cmd $(pwd)/vim/vimrc ~/.config/nvim/init.vim
        fi
    fi

    symlink_cmd $(pwd)/.rc ~/.rc

    # VSCode.
    local vscode_config_path="$HOME/.config/Code/User"
    if [[ `uname` == "Darwin" ]]; then
        vscode_config_path="$HOME/Library/Application Support/Code/User"
    fi

    if [[ -d "$vscode_config_path" ]]; then
        symlink_cmd $(pwd)/vscode/keybindings.jsonc $vscode_config_path/keybindings.json
        symlink_cmd $(pwd)/vscode/settings.jsonc $vscode_config_path/settings.json
        symlink_cmd $(pwd)/vscode/tasks.jsonc $vscode_config_path/tasks.json

        symlink_cmd $(pwd)/vscode/snippets $vscode_config_path/snippets
    fi
}
