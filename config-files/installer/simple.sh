#!/usr/bin/env bash
#
# Run from the config-files directory.

if [[ "$(basename $(pwd))" != "config-files" ]]
then
	echo "please, run from the config-files directory"
	exit 1
fi

# Git config.
ln -s $(pwd)/.gitconfig ~/.gitconfig

# Clojure deps.
mkdir ~/.config/clojure
ln -s $(pwd)/deps.edn ~/.config/clojure/deps.edn

# Common shell init.
MCRA_INIT_SHELL="$(pwd)/init_shell.sh"
MCRA_TO_SOURCE="export MCRA_INIT_SHELL=$MCRA_INIT_SHELL
source \$MCRA_INIT_SHELL"
echo "$MCRA_TO_SOURCE" >> ~/.zshrc
echo "$MCRA_TO_SOURCE" >> ~/.bashrc

# Vim configs.
mkdir ~/.config/nvim
ln -s $(pwd)/vim/vimrc ~/.config/nvim/init.vim

# Tmux.
ln -s $(pwd)/.tmux.conf ~/.tmux.conf

