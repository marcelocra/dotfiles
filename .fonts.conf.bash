#!/usr/bin/env bash
[[ -f $HOME/lib/utils.sh ]] && $HOME/lib/utils.sh $0

utils_ensure_pwd_dirname_is "dotfiles"
# utils_ensure_binaries "curl unzip"

confd_dir="$HOME/.config/fontconfig/conf.d"

if [[ ! -d $confd_dir ]]; then
    mkdir -p $confd_dir
fi

ln -s \
    `pwd`/.fonts.conf \
    $confd_dir/99-custom-rendering.conf

