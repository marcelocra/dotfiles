#!/usr/bin/env pwsh
# Symlinks VSCode settings from dotfiles to the editor's User directory.
# Supports VSCode, VSCode Insiders, Cursor, and Kiro. Backs up existing files.
# Requires Administrator privileges on Windows for symlinks.

param(
    [ValidateSet("code", "insiders", "cursor", "kiro")]
    [string]$Editor = "code",
    [switch]$Insiders = $false,  # Legacy support
    [switch]$Cursor = $false,    # Legacy support
    [switch]$Kiro = $false,      # Legacy support
    [string]$DotfilesPath = "$HOME\prj\dotfiles\apps\vscode\User",
    [switch]$Help = $false
)

if ($Help) {
    Write-Host @"
Usage: .\install.ps1 [OPTIONS]

Options:
  -Editor <name>   Editor to configure: code, insiders, cursor, kiro (default: code)
  -Insiders        Shortcut for -Editor insiders
  -Cursor          Shortcut for -Editor cursor
  -Kiro            Shortcut for -Editor kiro
  -DotfilesPath    Path to dotfiles User directory (default: $HOME\prj\dotfiles\apps\vscode\User)
  -Help            Show this help
"@
    exit 0
}

# Handle legacy switch parameters
if ($Insiders) { $Editor = "insiders" }
if ($Cursor) { $Editor = "cursor" }
if ($Kiro) { $Editor = "kiro" }

# Determine User directory based on editor
$userPath = switch ($Editor) {
    "code"     { "$env:APPDATA\Code\User" }
    "insiders" { "$env:APPDATA\Code - Insiders\User" }
    "cursor"   { "$env:APPDATA\Cursor\User" }
    "kiro"     { "$env:APPDATA\Kiro\User" }
}
$edition = switch ($Editor) {
    "code"     { "VSCode" }
    "insiders" { "VSCode Insiders" }
    "cursor"   { "Cursor" }
    "kiro"     { "Kiro" }
}

Write-Host "Setting up $edition configurations..." -ForegroundColor Cyan
Write-Host "Source: $DotfilesPath" -ForegroundColor Gray
Write-Host "Target: $userPath`n" -ForegroundColor Gray

# Files and folders to symlink
$items = @("settings.json", "keybindings.json", "tasks.json", "mcp.json", "snippets")
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Ensure target directory exists
if (-not (Test-Path $userPath)) {
    New-Item -ItemType Directory -Path $userPath -Force | Out-Null
}

foreach ($item in $items) {
    $source = Join-Path $DotfilesPath $item
    $target = Join-Path $userPath $item

    if (-not (Test-Path $source)) {
        Write-Host "⚠ Skip: $item (source not found)" -ForegroundColor Yellow
        continue
    }

    if (Test-Path $target) {
        $attrs = (Get-Item $target).Attributes
        if ($attrs -band [System.IO.FileAttributes]::ReparsePoint) {
            Write-Host "→ $item already symlinked" -ForegroundColor Gray
            continue
        }
        $backup = "$target.backup.$timestamp"
        Write-Host "📦 Backup: $item → $($backup | Split-Path -Leaf)" -ForegroundColor Yellow
        Move-Item -Path $target -Destination $backup -Force
    }

    $isDir = Test-Path $source -PathType Container
    if ($isDir) {
        cmd /c mklink /D "$target" "$source" 2>&1 | Out-Null
    } else {
        cmd /c mklink "$target" "$source" 2>&1 | Out-Null
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Linked: $item" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed: $item (run as Administrator?)" -ForegroundColor Red
    }
}

Write-Host "`n✅ Done!" -ForegroundColor Green
