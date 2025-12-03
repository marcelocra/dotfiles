#!/usr/bin/env pwsh
# Symlinks Zed editor settings from WSL dotfiles to the Windows Zed config directory.
# Backs up existing files with a timestamped suffix.
# Requires Administrator privileges on Windows for symlinks.
#
# NOTE: The created symlinks use \\wsl$\ UNC paths. These work correctly from Windows
# applications (including Zed), but will show "Input/output error" if accessed from
# WSL via /mnt/c/. This is a known WSL limitation and does not affect functionality.

param(
    [string]$WslDistro = "openSUSE-Tumbleweed",
    [string]$WslUsername = $env:USERNAME,
    [string]$DotfilesRelPath = "prj\dotfiles\apps\zed",
    [switch]$Help = $false
)

if ($Help) {
    Write-Host @"
Usage: .\install.ps1 [OPTIONS]

Options:
  -WslDistro       WSL distribution name (default: openSUSE-Tumbleweed)
  -WslUsername     WSL username (default: current Windows username)
  -DotfilesRelPath Relative path to zed config in WSL home (default: prj\dotfiles\apps\zed)
  -Help            Show this help

Example:
  .\install.ps1 -WslDistro "Ubuntu" -WslUsername "marcelo"
"@
    exit 0
}

# Build WSL path for source files (normalize path separators to backslashes)
$normalizedRelPath = $DotfilesRelPath -replace '/', '\'
$wslBasePath = "\\wsl$\$WslDistro\home\$WslUsername\$normalizedRelPath"

# Zed config directory on Windows
$configPath = "$env:APPDATA\Zed"

Write-Host "Setting up Zed configurations..." -ForegroundColor Cyan
Write-Host "Source (WSL): $wslBasePath" -ForegroundColor Gray
Write-Host "Target (Windows): $configPath`n" -ForegroundColor Gray

# Files to symlink
$items = @("settings.json", "keymap.json")
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Ensure target directory exists
if (-not (Test-Path $configPath)) {
    New-Item -ItemType Directory -Path $configPath -Force | Out-Null
}

foreach ($item in $items) {
    $source = "$wslBasePath\$item"
    $target = Join-Path $configPath $item

    # Check if source exists via WSL path
    if (-not (Test-Path $source)) {
        Write-Host "⚠ Skip: $item (source not found at $source)" -ForegroundColor Yellow
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

    # Use cmd mklink for WSL UNC path compatibility
    $result = cmd /c mklink "$target" "$source" 2>&1
    if ($LASTEXITCODE -eq 0 -or $result -match "symbolic link created") {
        Write-Host "✓ Linked: $item" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed: $item (run as Administrator?)" -ForegroundColor Red
        Write-Host "  Error: $result" -ForegroundColor DarkRed
    }
}

Write-Host "`n✅ Done!" -ForegroundColor Green