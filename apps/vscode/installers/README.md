# VSCode Config Installers

Symlinks VSCode settings from this dotfiles repo to the VSCode User directory.

## What gets linked

- `settings.json` — Editor settings
- `keybindings.json` — Keyboard shortcuts
- `tasks.json` — Task definitions
- `mcp.json` — MCP configuration
- `snippets/` — Code snippets

## Usage

### Linux / macOS

```bash
# VSCode
./install.sh

# VSCode Insiders
./install.sh --insiders

# Custom dotfiles path
./install.sh --dotfiles-path /path/to/dotfiles/apps/vscode/User
```

### Windows (PowerShell as Administrator)

```powershell
# VSCode
.\install.ps1

# VSCode Insiders
.\install.ps1 -Insiders

# Custom dotfiles path
.\install.ps1 -DotfilesPath "C:\path\to\dotfiles\apps\vscode\User"
```

> **Note**: Windows requires Administrator privileges to create symlinks.

## Features

- ✅ Backs up existing files with timestamp before replacing
- ✅ Skips if already symlinked
- ✅ Supports both VSCode and VSCode Insiders
- ✅ Continues if a file is missing from source
