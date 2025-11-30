# Example commands used to symlink VSCode settings

> [!FYI]
>
> This was used to create the installation scripts in `apps/vscode/installers/README.md`.

## Windows

### Install files separately (RECOMMENDED)

Example session, to be made into a script:

```powershell
PS <C:\prj> dir "~\AppData\Roaming\Code\User"

PS <C:\prj> cmd /c mklink /D "~\AppData\Roaming\Code\User\snippets" "\\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\snippets"
symbolic link created for ~\AppData\Roaming\Code\User\snippets <<===>> \\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\snippets

PS <C:\prj> cmd /c mklink "~\AppData\Roaming\Code\User\settings.json" "\\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\settings.json"
symbolic link created for ~\AppData\Roaming\Code\User\settings.json <<===>> \\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\settings.json

PS <C:\prj> cmd /c mklink "~\AppData\Roaming\Code\User\keybindings.json" "\\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\keybindings.json"
symbolic link created for ~\AppData\Roaming\Code\User\keybindings.json <<===>> \\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\keybindings.json

PS <C:\prj> cmd /c mklink "~\AppData\Roaming\Code\User\tasks.json" "\\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\tasks.json"
symbolic link created for ~\AppData\Roaming\Code\User\tasks.json <<===>> \\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\tasks.json

PS <C:\prj> cmd /c mklink "~\AppData\Roaming\Code\User\mcp.json" "\\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\mcp.json"
symbolic link created for ~\AppData\Roaming\Code\User\mcp.json <<===>> \\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\mcp.json

PS <C:\prj> dir "~\AppData\Roaming\Code\User"

    Directory: ~\AppData\Roaming\Code\User

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
l----            30/11/25    12:02                snippets -> \\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\snippets
la---            30/11/25    12:03              0 keybindings.json -> \\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\keybindings.json
la---            30/11/25    12:03              0 mcp.json -> \\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\mcp.json
la---            30/11/25    12:03              0 settings.json -> \\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\settings.json
la---            30/11/25    12:03              0 tasks.json -> \\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User\tasks.json

```

### Install full `User` folder (SEE IMPORTANT SECURITY NOTE)

> [!WARNING]
> SECURITY NOTE
>
> If you do this, **all your VSCode data** will be synced to the other folder. If it is a **public repo**, it means that most likely you **WILL BE EXPOSING SOMETHING YOU DON'T WANT**.
>
> **ONLY USE THIS METHOD** if you are syncing to a **private folder/repo**.

```powershell
# Backup existing User settings folder
$codeInsidersUserPath = "~\AppData\Roaming\Code - Insiders\User"
Rename-Item "$codeInsidersUserPath\User" "$codeInsidersUserPath\User.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"

# Create symlink to dotfiles
cmd /c mklink /D "~\AppData\Roaming\Code\User" "\\wsl$\openSUSE-Tumbleweed\home\username\prj\dotfiles\apps\vscode\User"
```

## Linux

```bash
# Backup existing User settings folder
CODE_INSIDERS_USER_PATH="$HOME/.config/Code - Insiders/User"
mv "$CODE_INSIDERS_USER_PATH" "$CODE_INSIDERS_USER_PATH.backup.$(date +%Y%m%d%H%M%S)"

# Create symlink to dotfiles
ln -s "$HOME/prj/dotfiles/apps/vscode/User" "$CODE_INSIDERS_USER_PATH"
```

## Prompt

[persona]
you are a world class software developer and expert in configuring development environments. You have extensive experience with Visual Studio Code and managing its settings across different operating systems.

[context]
I want to create a simple, portable, script to symlink my VSCode settings from my dotfiles repository to the appropriate VSCode User settings directory on both Windows and Linux/MacOS systems. The goal is to ensure that my VSCode configurations are consistent across different machines.

I want to backup any existing settings before creating the symlink, so I don't lose my previous configurations.

Initially, I wanted to symlink the whole VSCode user configuration directory, but I realized that it might lead to issues if there are version-specific settings (VSCode vs VSCode Insiders - I use both) or machine-specific settings and extensions.

Now my plan is to only symlink specific files that really are cross-platform, like the `settings.json`, `keybindings.json`, `tasks.json`, `snippets` folder, and maybe others that I'm not remembering right now.

I also want to backup other things, like chat sessions that occur in VSCode, which are stored in `User/workspaceStorage/<workspace-id>/{chatSessions,chatEditSessions}`, but since it might contain private data, I will symlink them separately, to a different (private) repository.

[task]
Please, use the commands at the beginning of this file as a reference and create a complete script that accomplishes the above goals for both Windows and Linux/MacOS systems. The script should handle backing up existing settings, creating the necessary symlinks, and ensuring that it works seamlessly across different operating systems.

[rules]

- Add your answer below this section.

---

## Answer

### Cross-Platform Setup Script

I've created two scripts below - one for Windows (PowerShell) and one for Linux/MacOS (Bash). Both scripts:

1. Back up existing settings with timestamps
2. Symlink only cross-platform configuration files (`settings.json`, `keybindings.json`, `tasks.json`, and the `snippets` folder)
3. Support both VSCode and VSCode Insiders
4. Provide clear feedback about what's being done

#### Windows (PowerShell)

Save as `setup-vscode-configs.ps1`:

```powershell
#!/usr/bin/env pwsh
# Script to symlink VSCode settings from dotfiles

param(
    [switch]$Insiders = $false,
    [string]$DotfilesPath = "$HOME\prj\dotfiles\apps\vscode\User"
)

# Determine VSCode User directory based on edition
$vscodeUserPath = if ($Insiders) {
    "$env:APPDATA\Code - Insiders\User"
} else {
    "$env:APPDATA\Code\User"
}

$edition = if ($Insiders) { "VSCode Insiders" } else { "VSCode" }
Write-Host "Setting up $edition configurations..." -ForegroundColor Cyan

# Files and folders to symlink
$itemsToLink = @(
    "settings.json",
    "keybindings.json",
    "tasks.json",
    "snippets"
)

# Create timestamp for backup
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Ensure VSCode User directory exists
if (-not (Test-Path $vscodeUserPath)) {
    Write-Host "Creating VSCode User directory: $vscodeUserPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $vscodeUserPath -Force | Out-Null
}

# Process each item
foreach ($item in $itemsToLink) {
    $sourcePath = Join-Path $DotfilesPath $item
    $targetPath = Join-Path $vscodeUserPath $item

    # Check if source exists in dotfiles
    if (-not (Test-Path $sourcePath)) {
        Write-Host "⚠️  Source not found: $sourcePath (skipping)" -ForegroundColor Yellow
        continue
    }

    # Backup existing item if it exists and is not already a symlink
    if (Test-Path $targetPath) {
        $isSymlink = (Get-Item $targetPath).Attributes -band [System.IO.FileAttributes]::ReparsePoint

        if ($isSymlink) {
            Write-Host "ℹ️  $item is already a symlink (skipping backup)" -ForegroundColor Gray
            continue
        }

        $backupPath = "$targetPath.backup.$timestamp"
        Write-Host "📦 Backing up existing $item to: $backupPath" -ForegroundColor Yellow
        Move-Item -Path $targetPath -Destination $backupPath -Force
    }

    # Create symlink
    $isDirectory = Test-Path $sourcePath -PathType Container
    $linkType = if ($isDirectory) { "/D" } else { "" }

    Write-Host "🔗 Creating symlink: $item" -ForegroundColor Green

    if ($isDirectory) {
        cmd /c mklink /D "$targetPath" "$sourcePath" 2>&1 | Out-Null
    } else {
        cmd /c mklink "$targetPath" "$sourcePath" 2>&1 | Out-Null
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Success" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Failed to create symlink" -ForegroundColor Red
    }
}

Write-Host "`n✅ Setup complete for $edition!" -ForegroundColor Green
```

**Usage:**

```powershell
# For regular VSCode
.\setup-vscode-configs.ps1

# For VSCode Insiders
.\setup-vscode-configs.ps1 -Insiders

# Custom dotfiles path
.\setup-vscode-configs.ps1 -DotfilesPath "C:\path\to\dotfiles\apps\vscode\User"
```

#### Linux/MacOS (Bash)

Save as `setup-vscode-configs.sh`:

```bash
#!/usr/bin/env bash
# Script to symlink VSCode settings from dotfiles

set -euo pipefail

# Configuration
INSIDERS=false
DOTFILES_PATH="$HOME/prj/dotfiles/apps/vscode/User"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --insiders)
            INSIDERS=true
            shift
            ;;
        --dotfiles-path)
            DOTFILES_PATH="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --insiders         Setup for VSCode Insiders"
            echo "  --dotfiles-path    Path to dotfiles User directory (default: $DOTFILES_PATH)"
            echo "  -h, --help         Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Determine VSCode User directory based on edition
if [ "$INSIDERS" = true ]; then
    VSCODE_USER_PATH="$HOME/.config/Code - Insiders/User"
    EDITION="VSCode Insiders"
else
    VSCODE_USER_PATH="$HOME/.config/Code/User"
    EDITION="VSCode"
fi

echo -e "\033[36mSetting up $EDITION configurations...\033[0m"

# Files and folders to symlink
ITEMS_TO_LINK=(
    "settings.json"
    "keybindings.json"
    "tasks.json"
    "snippets"
)

# Create timestamp for backup
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Ensure VSCode User directory exists
if [ ! -d "$VSCODE_USER_PATH" ]; then
    echo -e "\033[33mCreating VSCode User directory: $VSCODE_USER_PATH\033[0m"
    mkdir -p "$VSCODE_USER_PATH"
fi

# Process each item
for item in "${ITEMS_TO_LINK[@]}"; do
    SOURCE_PATH="$DOTFILES_PATH/$item"
    TARGET_PATH="$VSCODE_USER_PATH/$item"

    # Check if source exists in dotfiles
    if [ ! -e "$SOURCE_PATH" ]; then
        echo -e "\033[33m⚠️  Source not found: $SOURCE_PATH (skipping)\033[0m"
        continue
    fi

    # Backup existing item if it exists and is not already a symlink
    if [ -e "$TARGET_PATH" ]; then
        if [ -L "$TARGET_PATH" ]; then
            echo -e "\033[90mℹ️  $item is already a symlink (skipping backup)\033[0m"
            continue
        fi

        BACKUP_PATH="$TARGET_PATH.backup.$TIMESTAMP"
        echo -e "\033[33m📦 Backing up existing $item to: $BACKUP_PATH\033[0m"
        mv "$TARGET_PATH" "$BACKUP_PATH"
    fi

    # Create symlink
    echo -e "\033[32m🔗 Creating symlink: $item\033[0m"
    ln -s "$SOURCE_PATH" "$TARGET_PATH"

    if [ $? -eq 0 ]; then
        echo -e "\033[32m   ✓ Success\033[0m"
    else
        echo -e "\033[31m   ✗ Failed to create symlink\033[0m"
    fi
done

echo -e "\n\033[32m✅ Setup complete for $EDITION!\033[0m"
```

**Usage:**

```bash
# Make script executable
chmod +x setup-vscode-configs.sh

# For regular VSCode
./setup-vscode-configs.sh

# For VSCode Insiders
./setup-vscode-configs.sh --insiders

# Custom dotfiles path
./setup-vscode-configs.sh --dotfiles-path "/path/to/dotfiles/apps/vscode/User"
```

### Key Features

1. **Selective Syncing**: Only symlinks `settings.json`, `keybindings.json`, `tasks.json`, and the `snippets` folder - avoiding version-specific or machine-specific files.

2. **Safe Backups**: Existing files are backed up with timestamps before symlinking, so you never lose your configurations.

3. **Smart Detection**: Skips backup if the target is already a symlink, preventing unnecessary backup creation.

4. **Dual Edition Support**: Works with both regular VSCode and VSCode Insiders using a simple flag.

5. **Clear Feedback**: Provides colored output showing exactly what's happening at each step.

6. **Error Handling**: Continues processing other files if one fails, with clear error messages.

### Additional Notes

**For chat session backup** (as mentioned in your requirements), you could create a separate script that symlinks the workspace storage to a private repository:

```bash
# Example for backing up chat sessions separately
ln -s "$HOME/.private-dotfiles/vscode-workspace-storage" \
      "$HOME/.config/Code/User/workspaceStorage"
```

**Files NOT symlinked** (intentionally excluded):

- `globalStorage/` - Contains machine-specific data and auth tokens
- `workspaceStorage/` - Contains workspace-specific data (as you noted)
- Extensions - Usually managed separately via extension sync or profiles
- `*.log` files - Machine and session specific
- Machine-specific settings in various JSON files
