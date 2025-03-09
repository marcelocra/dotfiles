# dotfiles

My essential configuration files.

## Fonts

Enable font config with higher priority:

```sh
mkdir -p ~/.config/fontconfig/conf.d

ln -s $(pwd)/.fonts.conf ~/.config/fontconfig/conf.d/99-custom-rendering.conf

```

Tell X how to render fonts:

```sh

ln -s $(pwd)/.Xresources ~/.Xresources

```
