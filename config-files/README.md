# My config files

This repo contains many configuration files that I use.

## Symlink

For this to work, commands should be run from the config files directory.

### Windows (PowerShell)

Notice the `-Force` option, that WILL OVERRIDE your destination file. Only use
it if you know what you are doing.

```powershell
# Sublime.
New-Item `
-Path "C:\Users\$env:USERNAME\AppData\Roaming\Sublime Text 3\Packages\User\Preferences.sublime-settings" `
-ItemType SymbolicLink `
-Value "Preferences.sublime-settings" `
-Force

# Powershell.
New-Item `
-Path "C:\Users\$env:USERNAME\OneDrive\Documentos\PowerShell\Microsoft.PowerShell_profile.ps1" `
-ItemType SymbolicLink `
-Value "Microsoft.PowerShell_profile.ps1" `
-Force

# VSCode settings.
New-Item `
-Path "C:\Users\$env:USERNAME\AppData\Roaming\Code\User\settings.json" `
-ItemType SymbolicLink `
-Value "vscode-settings.json" `
-Force

# VSCode keybindings.
New-Item `
-Path "C:\Users\$env:USERNAME\AppData\Roaming\Code\User\keybindings.json" `
-ItemType SymbolicLink `
-Value "vscode-keybindings.json" `
-Force

# Gitconfig.
New-Item `
-Path "C:\Users\$env:USERNAME\.gitconfig" `
-ItemType SymbolicLink `
-Value ".gitconfig" `
-Force

# Windows Terminal.
# As bizarre as this seems, Windows Terminal consistently saves the
# settings.json file to a directory in the following location (yes, with the
# 8wekyb3d8bbwe as part of the path! See here:
#
# https://stackoverflow.com/q/63101571/1814970
New-Item `
-Path "C:\Users\$env:USERNAME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" `
-ItemType SymbolicLink `
-Value "windows-terminal-settings.json" `
-Force

```

### Unix (Bash)

```bash
# Gitconfig.
ln -s $(pwd)/.gitconfig ${HOME}/.gitconfig

# TODO: fill with the other paths, as I use them on unix.
```
