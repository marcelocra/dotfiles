#!/usr/bin/env bash
# vim: ai:et:ts=4:sw=4
#
# Get my Clojure Babashka working, so I can get shit done without ever having
# to touch bash again.


# -e: exit on error
# -o pipefail: exits on command pipe failures
set -eo pipefail


# ----------------------------------------------------------
# Install babashka
# ----------------------------------------------------------

if [[ "$(which bb)" != "$HOME/bin/bb" ]]; then

    MCRA_BB_INSTALL_DIR="$HOME/bin/packages/babashka"
    #  version | static     | checksum
    #  -------------------------------
    #  0.4.1   |   ?        | ab70fb39fdbb5206c0a2faab178ffb54dd9597991a4bc13c65df2564e8f174f6
    #  1.3.188 | non-static | 535357fa38e81f9a3c5e739988983083b6c5f126590d982e022e062e4f1df519
    #          | static     | 89431b0659e84a468da05ad78daf2982cbc8ea9e17f315fa2e51fecc78af7cc0
    MCRA_BB_VERSION="1.3.188"
    MCRA_BB_CHECKSUM="89431b0659e84a468da05ad78daf2982cbc8ea9e17f315fa2e51fecc78af7cc0"

    mkdir -p "${MCRA_BB_INSTALL_DIR}/versions"
    cd "$MCRA_BB_INSTALL_DIR"

    curl -sLO https://raw.githubusercontent.com/babashka/babashka/master/install
    chmod +x install
    ./install --dir "${MCRA_BB_INSTALL_DIR}/versions" \
      --download-dir "${MCRA_BB_INSTALL_DIR}/versions" \
      --version "$MCRA_BB_VERSION" \
      --checksum "$MCRA_BB_CHECKSUM" \
      --static

    mv "${MCRA_BB_INSTALL_DIR}/versions/bb" \
       "${MCRA_BB_INSTALL_DIR}/versions/bb-v${MCRA_BB_VERSION}"

    ln -s "${MCRA_BB_INSTALL_DIR}/versions/bb-v${MCRA_BB_VERSION}" \
          "${HOME}/bin/bb"

else
    echo 'Babashka already installed!'
fi


# ----------------------------------------------------------
# Install Neovim, Vim Plug and configurations
# ----------------------------------------------------------

if [[ "$(which nvim)" != "$HOME/bin/nvim" ]]; then
                         
    # Proper command like clipboard.
    sudo apt-get install -y xsel
                 
    # Download latest version of Neovim.
    curl -L -O https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
    curl -L -O https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz.sha256sum

    RESULT="$(sha256sum nvim-linux64.tar.gz)"
    EXPECTED="$(cat nvim-linux64.tar.gz.sha256sum)"

    if [[ $RESULT != $EXPECTED ]]; then
        echo 'Incorrect files. Delete them and try to download again.'
        exit 1
    fi

    # Uncompress to the appropriate location and symlink to my binaries.
    tar xzvf nvim-linux64.tar.gz
    mv nvim-linux64 ~/bin/packages/nvim
    ln -s ~/bin/packages/nvim/nvim-linux64/bin/nvim ~/bin/nvim

    # Download the main Vim Plug plugin, to load other essential stuff.
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

else
    echo 'NeoVim already installed!'
fi

# ----------------------------------------------------------
# Install vim configs and plugins.
# ----------------------------------------------------------

mkdir -p ~/vim && ln -f -s $(pwd)/vim/vimrc ~/.config/nvim/init.vim


#mkdir ~/.clojure/ && ln -s $(pwd)/deps.edn ~/.clojure/deps.edn
#
#ln -s $(pwd)/.gitconfig ~/.gitconfig
#ln -s $(pwd)/.tmux.conf ~/.tmux.conf
#ln -s $(pwd)/.rc ~/.rc

