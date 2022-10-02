# Configuration steps after a fresh Ubuntu 22.04.1 LTS install

I did it mostly in this order.

## Install Google Chrome

Download Google Chrome `.deb` file and install it using
`sudo dpgk -i ./path-to-deb`

## Figure out a way to remap Caps Lock to Control

Currently I'm using a terrible one:

```shell
setxkbmap -option caps:ctrl_modifier
```

It needs me to restart the terminal every now and then.

Perhaps [input-mapper](https://github.com/sezanzeb/input-remapper/) will work
better, but I still need to research it a bit more.

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

[So it seems](https://itsfoss.com/cant-run-appimage-ubuntu/) like this version
is missing `libfuse2`, which is required for running AppImages. Simply install
that with `sudo apt install libfuse2`, enable running AppImage files (from the
file properties) and voila: double click for it to open.

## Install Git Credential Manager

Don't even think in using Linuxbrew for this one. Won't work ("--cask only works
on MacOS" sort of issue).

Go straight to the
[Linux installation section](https://github.com/GitCredentialManager/git-credential-manager#linux),
download the `.deb` and install with `sudo dpkg -i ...`.

It asks you to run `git-credential-manager-core configure`, but I don't think
that's necessary when you already have that setting in your `.gitconfig` like I
do, so I'll add a TODO here, to double check it.

TODO: describe how the actual configuration goes.

## Install something that will improve your shell experience

Options:

- Oh my zsh
- https://github.com/romkatv/powerlevel10k
- https://ohmyposh.dev/docs/installation/linux

I've used `oh-my-zsh` for a long time, but now I'm trying
[`oh-my-posh`](https://ohmyposh.dev/docs/installation/linux). It is terribly
slow on Windows' PowerShell, but I wanted to check it in a Linux terminal too.

Let's see.

ps: it is terribly ugly with `bash`. Will check with `zsh`. ps2: it is also ugly
with `zsh`. Going back to `powerlevel10k`

## Install essential software from ubuntu repos

```sh
sudo apt install -y \
  wget curl unzip git neovim tmux ripgrep
```

## Install my `.tmux.conf`

```sh
wget https://raw.githubusercontent.com/marcelocra/.dotfiles/master/unix/.tmux.conf -P ~
```

## Install VSCode

```sh
VSCODE_FILENAME=vscode.deb

wget https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 -O $VSCODE_FILENAME
dpkg -i $VSCODE_FILENAME
rm $VSCODE_FILENAME
```

## Install Telegram

```sh
TELEGRAM_FILENAME=tsetup.4.2.0.tar.xz

wget https://updates.tdesktop.com/tlinux/${TELEGRAM_FILENAME}
tar -xvf $TELEGRAM_FILENAME
```

## Install programming languages runtimes

### Deno

```sh
curl -fsSL https://deno.land/install.sh | sh
# Add to `.rc` file:
export DENO_INSTALL="${HOME}/.deno"
export PATH="${DENO_INSTALL}/bin:${PATH}"
```

### DotNet

```sh
wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update
sudo apt install -y apt-transport-https
sudo apt update
sudo apt install -y dotnet-sdk-6.0
export DOTNET_CLI_TELEMETRY_OPTOUT=1
```

### Golang

```sh
wget https://go.dev/dl/go1.19.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
export PATH="${PATH}:/usr/local/go/bin"
```

## Install correct Nvidia drivers

After the initial installation, I was able to use the computer normally for a
small while.

BUT then, all of a sudden one of my monitors stopped working. When trying to
change/update the drivers, I got a greyed out options, like this:

![greyed out nvidia driver options](./nvidia-drivers-greyed-out.png)

To fix that, there's a number of references pointing out to the following
command:

```
sudo ubuntu-drivers autoinstall
```

I ran it, rebooted the computer and it worked.

References:

- https://askubuntu.com/a/1237598/121101
- https://askubuntu.com/a/1264804/121101

## Install Signal

Going to signal.org, I found the following instructions:

```shell
# NOTE: These instructions only work for 64 bit Debian-based
# Linux distributions such as Ubuntu, Mint etc.

# 1. Install our official public software signing key
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

# 2. Add our repository to your list of repositories
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
  sudo tee -a /etc/apt/sources.list.d/signal-xenial.list

# 3. Update your package database and install signal
sudo apt update && sudo apt install signal-desktop

```

They worked successfully.

## Install Docker

Go to https://www.docker.com/ and follow the instructions for your OS. Should be
straightforward.
