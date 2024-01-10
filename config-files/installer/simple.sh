#!/usr/bin/env bash
# vim: foldmethod=marker foldmarker={{{,}}} foldlevel=1 foldenable autoindent expandtab tabstop=4 shiftwidth=4
#
# Run from the config-files directory.

if [[ "$(basename $(pwd))" != "config-files" ]]
then
    echo "please, run from the config-files directory"
    exit 1
fi

# Common shell init. If the script is re-run, it should not add stuff to rc
# files again.
if [[ -z "$MCRA_INIT_SHELL" ]]; then
    MCRA_INIT_SHELL="$(pwd)/init_shell.sh"
    MCRA_TO_SOURCE="export MCRA_INIT_SHELL=$MCRA_INIT_SHELL
    source \$MCRA_INIT_SHELL"
    echo "$MCRA_TO_SOURCE" >> ~/.zshrc
    echo "$MCRA_TO_SOURCE" >> ~/.bashrc
fi

symlink_or_bail() {
    local src="$1"
    local target="$2"

    if [[ -f "$target" ]]; then
        echo "$target exists... not replacing. Back it up then run this again"
        echo
        echo
        return
    fi

    local dirname="$(dirname $target)"
    # Create the parent directory, unless it is the home dir
    # or it already exists.
    if [[ "$dirname" != "$HOME" && ! -d "$dirname" ]]; then
        mkdir "$dirname"
    fi

    echo "symlinking '$src' to '$target'..."
    ln -s $src $target && echo "done!"
    echo
    echo
}

symlink_or_bail $(pwd)/.gitconfig ~/.gitconfig
symlink_or_bail $(pwd)/.tmux.conf ~/.tmux.conf
symlink_or_bail $(pwd)/deps.edn ~/.clojure/deps.edn
symlink_or_bail $(pwd)/vim/vimrc ~/.config/nvim/init.vim

# VSCode.
MCRA_VSCODE_CONFIG_PATH=""
if [[ `uname` == "Darwin" ]]; then
  MCRA_VSCODE_CONFIG_PATH="$HOME/Library/Application Support/Code/User"
else
  MCRA_VSCODE_CONFIG_PATH="$HOME/.config/Code/User"
fi
if [[ ! -z "$MCRA_VSCODE_CONFIG_PATH" ]]; then
    symlink_or_bail "$(pwd)/vscode-keybindings.jsonc" "${MCRA_VSCODE_CONFIG_PATH}/keybindings.json"
    symlink_or_bail "$(pwd)/vscode-settings.jsonc" "${MCRA_VSCODE_CONFIG_PATH}/settings.json"
    symlink_or_bail "$(pwd)/vscode-snippets.code-snippets" "${MCRA_VSCODE_CONFIG_PATH}/snippets/snippets.code-snippets"
fi

