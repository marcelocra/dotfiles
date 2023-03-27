#!/usr/bin/env bash

install_desktop_and_image_files() {
  # Obsidian.
  ln -s -f "$src_dir/obsidian.desktop" \
    ${HOME}/.local/share/applications/obsidian.desktop
  # Credits to the creator of the icons here: https://forum.obsidian.md/t/big-sur-icon/8121
  ln -s -f "$src_dir/obsidian.png" \
    ${HOME}/.local/share/icons/obsidian.png 


  # Portacle.
  ln -s -f "$src_dir/portacle.desktop" \
    ${HOME}/.local/share/applications/portacle.desktop
  ln -s -f "$src_dir/portacle.svg" \
    ${HOME}/.local/share/icons/portacle.svg 

  
  # Telegram.
  ln -s -f "$src_dir/telegram.desktop" \
    ${HOME}/.local/share/applications/telegram.desktop
  ln -s -f "$src_dir/telegram.png" \
    ${HOME}/.local/share/icons/telegram.png 


  # Todoist.
  ln -s -f "$src_dir/todoist.desktop" \
    ${HOME}/.local/share/applications/todoist.desktop
  ln -s -f "$src_dir/todoist.png" \
    ${HOME}/.local/share/icons/todoist.png 


  # Necessary to refresh the desktop database and actually show stuff on search,
  # during alt tab, in the taskbar, etc.
  update-desktop-database ~/.local/share/applications
}

main() {
  local src_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/config-files"

  # Vim.
  ln -s -f "$src_dir/vim/vimrc" "$HOME/.config/nvim/init.vim"


  # Git.
  ln -s -f "$src_dir/.gitconfig" "$HOME/.gitconfig"
  ln -s -f "$src_dir/.gitconfig.unix.gitconfig" "$HOME/.gitconfig.unix.gitconfig"
  ln -s -f "$src_dir/.gitconfig.personal.gitconfig" "$HOME/.gitconfig.personal.gitconfig"
  if [[ ! `uname` == "Darwin" ]]; then
    ln -s -f "$src_dir/.gitconfig.linux.gitconfig" "$HOME/.gitconfig.linux.gitconfig"
  fi


  # Tmux.
  ln -s -f "$src_dir/.tmux.conf" "$HOME/.tmux.conf"


  # VSCode.
  local config_path
  
  if [[ `uname` == "Darwin" ]]; then
    config_path="$HOME/Library/Application Support/Code/User"
  else
    config_path="$HOME/.config/Code/User"
  fi

  ln -s -f "$src_dir/vscode-keybindings.jsonc" "${config_path}/keybindings.json"
  ln -s -f "$src_dir/vscode-settings.jsonc" "${config_path}/settings.json"
  ln -s -f "$src_dir/vscode-snippets.code-snippets" "${config_path}/snippets/snippets.code-snippets"


  # Install some desktop and image files, as described in the function. Disabled
  # by default because won't be useful for everyone.

  # install_apps_desktop_and_image_files
}


# Note: this script REPLACES everything (note the -f option in ln).
# If you want to keep your existing config files, save them before running this.
# Uncomment the line below to run the script.

#main
