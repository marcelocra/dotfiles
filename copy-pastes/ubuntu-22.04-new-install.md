# Configuration steps after a fresh Ubuntu 22.04.1 LTS install

I did it mostly in this order.

## Install Google Chrome

Download Google Chrome `.deb` file and install it using `sudo dpgk -i ./path-to-deb`

## Figure out a way to remap Caps Lock to Control

Currently I'm using a terrible one:

```shell
setxkbmap -option caps:ctrl_modifier
```

It needs me to restart the terminal every now and then.

Perhaps
[input-mapper](https://github.com/sezanzeb/input-remapper/) will work better,
but I still need to research it a bit more.

## Figure out a way to remap mouse buttons

Right now I'm using a Evoluent Vertical Mouse 4 (left handed, even though I'm
right handed). Perhaps the `input-mapper` mentioned above will work for this,
but until then I'm simply using the defaults (forward/backward buttons are
swapped from what I'm used and forward doesn't work).

## Install Homebrew

I tripped on this many times, particurly with ruby version (and for no reason,
keep reading).

First, it requires you to install `git` and `curl`. DON'T install `curl` from
`snap`. It simply doesn't work as expected and end up giving you a "failed to
install the correct version of ruby" type of error.

Simply `sudo apt install curl` and everything should work fine.

## Install Obsidian

Another weird one.

The recommended Linux install from [their website](https://obsidian.md) is the
AppImage, but this simply doesn't work out of the box in Ubuntu 22.04.

[So it seems](https://github.com/sezanzeb/input-remapper/) like this version
is missing `libfuse2`, which is required for running AppImages. Simply install
that with `sudo apt install libfuse2`, enable running AppImage files (from
the file properties) and voila: double click for it to open.
