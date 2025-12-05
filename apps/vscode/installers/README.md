# VSCode-based Editor Config Installers

Symlinks settings from this dotfiles repo to the editor's User directory.

## Supported Editors

| Editor          | Linux/macOS                      | Windows                          |
| --------------- | -------------------------------- | -------------------------------- |
| VSCode          | `~/.config/Code/User`            | `%APPDATA%\Code\User`            |
| VSCode Insiders | `~/.config/Code - Insiders/User` | `%APPDATA%\Code - Insiders\User` |
| Cursor          | `~/.config/Cursor/User`          | `%APPDATA%\Cursor\User`          |
| Kiro            | `~/.config/Kiro/User`            | `%APPDATA%\Kiro\User`            |

## What gets linked

- `settings.json` — Editor settings
- `keybindings.json` — Keyboard shortcuts
- `tasks.json` — Task definitions
- `mcp.json` — MCP configuration
- `snippets/` — Code snippets

## Usage

### Linux / macOS

```bash
./install.bash              # VSCode (default)
./install.bash --insiders   # VSCode Insiders
./install.bash --cursor     # Cursor
./install.bash --kiro       # Kiro

# Custom dotfiles path
./install.bash --cursor --dotfiles-path /path/to/dotfiles/apps/vscode/User
```

### Windows (PowerShell as Administrator)

```powershell
.\install.ps1                  # VSCode (default)
.\install.ps1 -Insiders        # VSCode Insiders
.\install.ps1 -Cursor          # Cursor
.\install.ps1 -Kiro            # Kiro

# Or use -Editor parameter
.\install.ps1 -Editor cursor

# Custom dotfiles path
.\install.ps1 -Cursor -DotfilesPath "C:\path\to\dotfiles\apps\vscode\User"
```

> **Note**: Windows requires Administrator privileges to create symlinks.

## Features

- ✅ Backs up existing files with timestamp before replacing
- ✅ Skips if already symlinked
- ✅ Supports VSCode, VSCode Insiders, Cursor, and Kiro
- ✅ Continues if a file is missing from source
