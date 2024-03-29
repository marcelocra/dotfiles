# My config files

This folder contains many configuration files that I use.

If you would like to use any of these, I recommend symlinking them. That is how
I use and think it is the best option to keep them up-to-date.

## Symlink

### Unix shell

```sh
# VSCode Settings and Keybindings.
ln -f -s $(pwd)/config-files/vscode-settings.jsonc ${HOME}/.config/Code/User/settings.json
ln -f -s $(pwd)/config-files/vscode-keybindings.jsonc ${HOME}/.config/Code/User/keybindings.json


# TODO: fill with the other paths, as I use them on unix.
```

### Windows (PowerShell)

Notice the `-Force` option, that WILL OVERRIDE your destination file. Only use
it if you know what you are doing.

```powershell
# Read all environment variables from a `.env` file. This considers that
# the `.env` file is in the current folder. Adapt for your requirements.
get-content .env | foreach {
    $name, $value = $_.split('=')
    set-content env:\$name $value
}


# Sublime.
New-Item `
-Path "C:\Users\$env:USERNAME\AppData\Roaming\Sublime Text 3\Packages\User\Preferences.sublime-settings" `
-ItemType SymbolicLink `
-Value "$env:MCRA_CONFIG_FILES_DIRECTORY\Preferences.sublime-settings" `
-Force

# Powershell.
New-Item `
-Path "$env:MCRA_POWERSHELL_DIRECTORY\Microsoft.PowerShell_profile.ps1" `
-ItemType SymbolicLink `
-Value "$env:MCRA_CONFIG_FILES_DIRECTORY\Microsoft.PowerShell_profile.ps1" `
-Force

# VSCode settings.
New-Item `
-Path "C:\Users\$env:USERNAME\AppData\Roaming\Code\User\settings.json" `
-ItemType SymbolicLink `
-Value "$env:MCRA_CONFIG_FILES_DIRECTORY\vscode-settings.jsonc" `
-Force

# VSCode keybindings.
New-Item `
-Path "C:\Users\$env:USERNAME\AppData\Roaming\Code\User\keybindings.json" `
-ItemType SymbolicLink `
-Value "$env:MCRA_CONFIG_FILES_DIRECTORY\vscode-keybindings.jsonc" `
-Force

# Gitconfig.
New-Item `
-Path "C:\Users\$env:USERNAME\.gitconfig" `
-ItemType SymbolicLink `
-Value "$env:MCRA_CONFIG_FILES_DIRECTORY\.gitconfig" `
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
-Value "$env:MCRA_CONFIG_FILES_DIRECTORY\windows-terminal-settings.json" `
-Force

# WSL 2 global config (applies for all wsl2 distros).
New-Item `
-Path "C:\Users\$env:USERNAME\.wslconfig" `
-ItemType SymbolicLink `
-Value "$env:MCRA_CONFIG_FILES_DIRECTORY\.wslconfig" `
-Force


```
