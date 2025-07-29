#!/usr/bin/env bash
# vim: ai:et:ts=4:sw=4
#
# Must be run from the root directory.

# -e: exit on error
# -o pipefail: exits on command pipe failures
# set -eo pipefail


##### CHECK STUFF FIRST #####


if [[ "$(basename $(pwd))" != "dotfiles" ]]
then
    echo 'Please, run this script from the root (dotfiles) directory'
    exit 1
fi

if [[ "$#" -eq 0 ]]; then
    echo "Usage: ./dotfiles-installer [options]

Options:

--all       Symlink all configuration files available
--git       Symlink .gitconfig
--tmux      Symlink .tmux.conf
--clojure   Symlink deps.edn
--vim       Symlink .vimrc
--shell     Symlink .rc
--vscode    Symlink vscode settings
--obsidian  Install the Obsidian app desktop entry and logo

"
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

# Local should be first, as the other one checks for some expected MCRA_* env
# variables.
source \$MCRA_LOCAL_SHELL
source \$MCRA_INIT_SHELL
# -----------------------------------------------------------------------------


"
    echo "$MCRA_TO_SOURCE" >> ~/.zshrc
    echo "$MCRA_TO_SOURCE" >> ~/.bashrc
fi


##### DEFINE SOME HELPER FUNCTIONS #####


my_date() {
    date "+%F_%T" | tr ':' '-'
}


symlink_cmd_with_saving() {
    echo "Trying to create symlink for: '$2'..."
    # Check if it is a file or symlink.
    if [[ -e "$2" ]]; then
        echo "'$2' exists... backing up to '$2.bak.<now-date>'..."
        mv "$2" "$2.bak.$(my_date)"
        echo 'Done!'
    fi
    ln -s "$1" "$2" && echo 'Done successfully!'
    echo
}

symlink_cmd() {
    echo "Trying to create symlink for: '$2'..."
    ln -f -s "$1" "$2" && echo 'Done!'
    echo
}
    
# dotfiles.

git_dotfiles() {
    symlink_cmd "$(pwd)/.gitconfig" "$HOME/.gitconfig"
}

tmux_dotfiles() {
    symlink_cmd $(pwd)/.tmux.conf ~/.tmux.conf
}

clojure_dotfiles() {
    if [[ ! -d ~/.clojure ]]; then
        mkdir ~/.clojure
    else
        echo '~/.clojure already exists... continuing.'
    fi

    symlink_cmd $(pwd)/deps.edn ~/.clojure/deps.edn
}

vim_dotfiles() {
    if [[ ! -d ~/.config/nvim ]]; then
        mkdir ~/.config/nvim
    else
        echo '~/.config/nvim already exists... continuing.'
    fi
  
    symlink_cmd $(pwd)/vim/vimrc ~/.config/nvim/init.vim
}

shell_dotfiles() {
    symlink_cmd $(pwd)/.rc ~/.rc
}

vscode_dotfiles() {
    local vscode_config_path="$HOME/.config/Code/User"

    if [[ `uname` == "Darwin" ]]; then
        vscode_config_path="$HOME/Library/Application Support/Code/User"
    fi

    if [[ -d "$vscode_config_path" ]]; then
        symlink_cmd $(pwd)/vscode/keybindings.jsonc $vscode_config_path/keybindings.json
        symlink_cmd $(pwd)/vscode/settings.jsonc $vscode_config_path/settings.json
        symlink_cmd $(pwd)/vscode/tasks.jsonc $vscode_config_path/tasks.json

        # Snippets are placed in a directory, and I want all my user snippets to be tracked,
        # so I symlink the whole directory. This part will check if there's an existing snippets
        # dir, back it up, warn you and then symlink the new one.
        local snippets_path="$vscode_config_path/snippets"
        if [[ -d $snippets_path ]]; then
            local old_snippets_path="$vscode_config_path/old-snippets-$(my_date)"
            mv $snippets_path $old_snippets_path
            echo "Existing snippets directory found. Moved it to:"
            echo "$old_snippets_path"
        fi
        symlink_cmd $(pwd)/vscode/snippets $snippets_path
        # Snippets end.
    fi
}

# Install Obsidian desktop entry and icons.
obsidian_prepare_desktop() {
    ln -s $(pwd)/apps/obsidian/obsidian.desktop \
        ${HOME}/.local/share/applications/obsidian.desktop

    # Credits to the creator of the icons here:
    # https://forum.obsidian.md/t/big-sur-icon/8121
    ln -s $(pwd)/apps/obsidian/obsidian.png \
        ${HOME}/.local/share/icons/obsidian.png 

    # Update desktop files database.
    # This is what actually show things in the ui.
    update-desktop-database ~/.local/share/applications
}

# Install Obsidian.
obsidian_install() {
    # Download the latest version of Obsidian to this location.
    local obsidian_dir="$MCRA_PACKAGES/obsidian"
    local obsidian_release_url="$(./play.clj --obsidian)"

    wget --directory-prefix $obsidian_dir $obsidian_release_url

    # -A list all files except . and .. 
    # -r reverse order while sorting
    # -t sort by time, newest first
    local latest_bin="$(ls -Art $MCRA_PACKAGES/obsidian | tail -n 1)"

    if [[ -z "$latest_bin" ]]
    then
        echo "obsidian_dir=$obsidian_dir"
        echo "obsidian_release_url=$obsidian_release_url"
        echo "latest_bin=$latest_bin"
        exit 1
    fi

    # Symlink the latest binary, desktop entry and icon.

    ln -s $latest_bin $MCRA_BINARIES/obsidian

    obsidian_prepare_desktop
}

# Prepare Logseq desktop entry and icons.
logseq_prepare_desktop() {
    ln-s $(pwd)/apps/logseq/logseq.desktop \
        ${HOME}/.local/share/applications/logseq.desktop

    ln -s $(pwd)/apps/logseq/logseq.png \
        ${HOME}/.local/share/icons/logseq.png 

    update-desktop-database ~/.local/share/applications
}

# Prepare Clickup desktop entry and icons.
clickup_prepare_desktop() {
    ln -s $(pwd)/apps/clickup/clickup.desktop \
        ${HOME}/.local/share/applications/clickup.desktop

    ln -s $(pwd)/apps/clickup/icons/desktop-gradient-circle-2x.png \
        ${HOME}/.local/share/icons/clickup.png 

    update-desktop-database ~/.local/share/applications
}

# Prepare Portacle desktop entry and icons.
portacle_prepare_desktop() {
    ln -s $(pwd)/apps/portacle/portacle.desktop \
        ${HOME}/.local/share/applications/portacle.desktop

    ln -s $(pwd)/apps/portacle/portacle.svg \
        ${HOME}/.local/share/icons/portacle.svg 

    update-desktop-database ~/.local/share/applications
}

# Prepare Todoist desktop entry and icons.
todoist_prepare_desktop() {
    ln -s $(pwd)/apps/todoist/todoist.desktop \
        ${HOME}/.local/share/applications/todoist.desktop

    ln -s $(pwd)/apps/todoist/todoist.png \
        ${HOME}/.local/share/icons/todoist.png 

    update-desktop-database ~/.local/share/applications
}

all_dotfiles() {
    git_dotfiles
    tmux_dotfiles
    clojure_dotfiles
    vim_dotfiles
    shell_dotfiles
    vscode_dotfiles
    obsidian_install
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -a|--all) all_dotfiles ;;
        --git) git_dotfiles ;;
        --tmux) tmux_dotfiles ;;
        --clj|--clojure) clojure_dotfiles ;;
        --vim) vim_dotfiles ;;
        --shell) shell_dotfiles ;;
        --vscode) vscode_dotfiles ;;
        --obsidian-install) obsidian_install ;;
        --obsidian-prepare-desktop) obsidian_prepare_desktop ;;
        --logseq-prepare-desktop) logseq_prepare_desktop ;;
        --clickup-prepare-desktop) clickup_prepare_desktop ;;
        --portacle-prepare-desktop) portacle_prepare_desktop ;;
        --todoist-prepare-desktop) todoist_prepare_desktop ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done
