# Configuration steps after a fresh Linux Mint 21 install

Steps should be executed in order for best results.

## Figure out a way to remap Caps Lock to Control and mouse buttons

### Caps Lock

Linux Mint has a keyboard manager in Keyboard > Layouts > Options, that allows
customizations like this one.

[input-mapper](https://github.com/sezanzeb/input-remapper/) is an alternative,
but I haven't used it.

### Mouse

Right now I'm using a Evoluent Vertical Mouse 4. Perhaps the `input-mapper`
mentioned above will work for this, but until then I'm using a
[script](https://github.com/marcelocra/dev/blob/main/config-files/init_system_linux.sh)
that I created in the past. Works fine.

## Install essential software from Ubuntu repos

```sh
sudo apt install -y \
  wget curl unzip git neovim tmux ripgrep zsh copyq
```

DON'T install `curl` from `snap`. It simply doesn't work as expected and end up
giving you a "failed to install the correct version of ruby" type of error.

## Install Google Chrome

Download Google Chrome `.deb` file and double click it to install. Alternatively
You can also `sudo dpgk -i ./path-to-deb` if you prefer.

## Install Homebrew

Run the install script from their website (requires the essentials mentioned
above).

## Install something that will improve your shell experience

- Oh my zsh: https://ohmyz.sh/#install
- Great Oh my zsh plugin: https://github.com/romkatv/powerlevel10k

## Improve Cinnamon date and time widget format

Use this:

`•%n%a%n%d%n%b%n•%n%H%n%M%n%S%n•`

You might need to add some spaces around stuff for it to appear correctly, like so:

`  •%n%a%n %d%n%b%n  •%n %H%n %M%n %S%n  •`

Notice that there's a number of `%n` in the format, which behaves like `\n`
(adding new lines), as I use the menu bar vertically to the left. If you prefer
it to be at the top or bottom of the screen, replace the `%n`s with spaces.

The result will be like this:

![Cinnamon date and time widget format output](./cinnamon-date-time.png)

## Add appropriate keyboard layout

I use the following layouts:

- English (US): to type in english.
- English (US, intl., with dead keys): to type in brazilian portuguese with an
  en-US keyboard.

## Update keyboard to accept cedilla (necessary for pt-BR speakers)

First, follow the third step mentioned below
([reference](https://superuser.com/a/1235405/295116)):

> It's because the cedilla module isn't loaded by default when the locale is set
> to _en_, so you have to change the configuration files for gtk to add them:
>
> **1. Edit configuration files:**
>
>     sudo vim /usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache
>
>     sudo vim /usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/immodules.cache
>
> On both, find the lines starting with `"cedilla" "Cedilla" ` and add :en to
> the line. Something like this:
>
> `"cedilla" "Cedilla" "gtk30" "/usr/share/locale" "az:ca:co:fr:gv:oc:pt:sq:tr:wa:en"`
>
> **2. Change the Compose file:**
>
>     sudo sed -i /usr/share/X11/locale/en_US.UTF-8/Compose -e 's/ć/ç/g' -e 's/Ć/Ç/g'
>
> **3. Instruct the system to load the _cedilla_ module:**
>
> Add those lines to `/etc/environment`:
>
>     GTK_IM_MODULE=cedilla
>     QT_IM_MODULE=cedilla
>
> Reboot and you are done.

I didn't need the other steps. If this one doesn't work for you, try the others
too.

## Install config files

Clone https://github.com/marcelocra/dev/ and symlink the following essential
files from the `config-files` folder:

- .gitconfig
- .gitconfig.personal.gitconfig
- .gitconfig.work.gitconfig (optional: only if working on this machine)
- .gitconfig.unix.gitconfig
- .gitconfig.linux.gitconfig
- init_shell.sh
- vscode-settings.jsonc
- vscode-keybindings.jsonc
- vscode-snippets.code-snippets
- vim/
- .tmux.conf

This one needs to be installed using the "Startup Applications" app (just search
for it in the menu):

- init_system_linux.sh

## Install Git Credential Manager

Don't even think about using Linuxbrew for this one. Won't work ("--cask only
works on MacOS" sort of issue).

Go straight to the
[Linux installation section](https://github.com/GitCredentialManager/git-credential-manager#linux),
download the `.deb` and install with `sudo dpkg -i ...`.

It asks you to run `git-credential-manager-core configure`, but I don't think
that's necessary when you already have that setting in your `.gitconfig` like I
do, so I'll add a TODO here, to double check it.

TODO: describe how the actual configuration goes.

## Install Git Large File Support

Go to [their website](https://git-lfs.github.com/), download the binary and
extract it to some folder in your path (I use `${HOME}/bin`).

## Install `fzf`

Simply follow the installation instructions in
[the project site](https://github.com/junegunn/fzf#installation). Notice that
there's a Vim plugin that is also interesting.

## Install `vim-plug`

Simply follow the installation instructions in
[the project site](https://github.com/junegunn/vim-plug#installation).

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

Most likely the first time you run Telegram it will setup a `telegram.desktop`
file for you, so that it appears correctly when searching for the program
through gnome-shell or in the dock.

If that doesn't happen, theres a
[`telegram.desktop`](../config-files/telegram.desktop) file that you can use.
Take a look at the
[`telegram.desktop_install.sh` ](../config-files/telegram.desktop_install.sh)
file for details on how to install it.

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

## Install Obsidian

The recommended Linux install from [their website](https://obsidian.md) is the
AppImage.

For it to run, after downloading it, right click > properties > permissions >
enable "allow executing file as a program". After that, double clicking should
launch the program.

Note: while these instructions will make Obisidian work, they won't provide a
nice icon in search (gnome-shell) or in the menus (and alt-tab). For that you'll
need to configure a `obsidian.desktop`. You can find
[that file](../config-files/obsidian.desktop) along with
[instructions](../config-files/obsidian.desktop_install.sh) and icons in this
repo.

## Install Brave Browser

Follow the instructions from their website:

https://brave.com/linux/#debian-ubuntu-mint

## Install programming languages runtimes

### Deno (need review)

```sh
curl -fsSL https://deno.land/install.sh | sh
# Add to `.rc` file:
export DENO_INSTALL="${HOME}/.deno"
export PATH="${DENO_INSTALL}/bin:${PATH}"
```

### .NET

Follow the manual installation instructions
[in Microsoft's website](https://learn.microsoft.com/en-us/dotnet/core/install/linux-scripted-manual#manual-install):

Basically, download the binary file from
[their download page](https://dotnet.microsoft.com/en-us/download/dotnet/7.0)
and extract it to some folder that is present in your PATH.

### Golang (need review)

```sh
wget https://go.dev/dl/go1.19.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
export PATH="${PATH}:/usr/local/go/bin"
```
