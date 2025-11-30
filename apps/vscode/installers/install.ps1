#!/usr/bin/env pwsh
# Symlinks VSCode settings from dotfiles to the VSCode User directory.
# Supports both VSCode and VSCode Insiders. Backs up existing files.
# Requires Administrator privileges on Windows for symlinks.

param(
    [switch]$Insiders = $false,
    [string]$DotfilesPath = "$HOME\prj\dotfiles\apps\vscode\User",
    [switch]$Help = $false
)

if ($Help) {
    Write-Host @"
Usage: .\install.ps1 [OPTIONS]

Options:
  -Insiders        Setup for VSCode Insiders
  -DotfilesPath    Path to dotfiles User directory (default: $HOME\prj\dotfiles\apps\vscode\User)
  -Help            Show this help
"@
    exit 0
}

# Determine VSCode User directory
$vscodeUserPath = if ($Insiders) {
    "$env:APPDATA\Code - Insiders\User"
} else {
    "$env:APPDATA\Code\User"
}
$edition = if ($Insiders) { "VSCode Insiders" } else { "VSCode" }

Write-Host "Setting up $edition configurations..." -ForegroundColor Cyan
Write-Host "Source: $DotfilesPath" -ForegroundColor Gray
Write-Host "Target: $vscodeUserPath`n" -ForegroundColor Gray

# Files and folders to symlink
$items = @("settings.json", "keybindings.json", "tasks.json", "mcp.json", "snippets")
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Ensure target directory exists
if (-not (Test-Path $vscodeUserPath)) {
    New-Item -ItemType Directory -Path $vscodeUserPath -Force | Out-Null
}

foreach ($item in $items) {
    $source = Join-Path $DotfilesPath $item
    $target = Join-Path $vscodeUserPath $item

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
