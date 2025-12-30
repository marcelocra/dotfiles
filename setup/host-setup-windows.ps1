# host-setup-windows.ps1
# Host machine setup script for Windows
# This script configures editors and host-specific tools that should NOT run in containers




# SEE THE HOST-SETUP-LINUX.SH FOR THE REASON WHY THIS SCRIPT IS COMMENTED.







# param(
#     [string]$GitHubHandle = ($env:MCRA_GITHUB_HANDLE -or "marcelocra"),
#     [string]$ConfigDir = ($env:MCRA_CONFIG -or "$env:USERPROFILE\.config\marcelocra"),
#     [switch]$SetupVSCode = ($env:MCRA_SETUP_VSCODE -ne "false"),
#     [switch]$SetupSublime = ($env:MCRA_SETUP_SUBLIME -ne "false"),
#     [switch]$SetupZed = ($env:MCRA_SETUP_ZED -ne "false")
# )

# $DotfilesDir = Join-Path $ConfigDir "dotfiles" "apps"

# Write-Host "🚀 Starting Windows host setup" -ForegroundColor Magenta
# Write-Host "👤 User: $env:USERNAME"
# Write-Host "🏠 Home: $env:USERPROFILE"
# Write-Host "📋 GitHub Handle: $GitHubHandle"
# Write-Host "📦 Dotfiles Dir: $DotfilesDir"

# # Function to log with timestamps
# function Write-Log {
#     param([string]$Message)
#     $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
#     Write-Host "[$timestamp] $Message"
# }

# # Check if dotfiles are available
# if (-not (Test-Path $DotfilesDir)) {
#     Write-Log "❌ Dotfiles not found at $DotfilesDir"
#     Write-Log "💡 Clone dotfiles manually first: git clone https://github.com/$GitHubHandle/dotfiles.git `"$DotfilesDir`""
#     exit 1
# }

# # VS Code configuration (Windows)
# if ($SetupVSCode -and (Get-Command code -ErrorAction SilentlyContinue)) {
#     $VSCodeConfigDir = "$env:APPDATA\Code\User"
#     $VSCodeSourceDir = Join-Path $DotfilesDir "vscode"
    
#     if (Test-Path $VSCodeSourceDir) {
#         Write-Log "🔗 Setting up VS Code configuration..."
#         if (-not (Test-Path $VSCodeConfigDir)) {
#             New-Item -ItemType Directory -Path $VSCodeConfigDir -Force
#         }
        
#         # Create symlinks for VS Code config files
#         $configFiles = @(
#             @{Source = "settings.json"; Target = "settings.json"},
#             @{Source = "keybindings.json"; Target = "keybindings.json"},
#             @{Source = "snippets"; Target = "snippets"}
#         )
        
#         foreach ($file in $configFiles) {
#             $sourcePath = Join-Path $VSCodeSourceDir $file.Source
#             $targetPath = Join-Path $VSCodeConfigDir $file.Target
            
#             if (Test-Path $sourcePath) {
#                 # Remove existing file/directory
#                 if (Test-Path $targetPath) {
#                     Remove-Item $targetPath -Force -Recurse
#                 }
                
#                 # Create symlink (requires admin privileges)
#                 try {
#                     if (Test-Path $sourcePath -PathType Container) {
#                         New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force
#                     } else {
#                         New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force
#                     }
#                 } catch {
#                     Write-Warning "Failed to create symlink for $($file.Source). Try running as Administrator."
#                     # Fallback: copy files instead of symlinking
#                     Copy-Item $sourcePath $targetPath -Recurse -Force
#                 }
#             }
#         }
        
#         Write-Log "✅ VS Code configuration linked"
#     } else {
#         Write-Log "ℹ️  Skipping VS Code (no config found)"
#     }
# } else {
#     Write-Log "ℹ️  Skipping VS Code (not installed or disabled)"
# }

# # Sublime Text configuration (Windows)
# if ($SetupSublime) {
#     $SublimeConfigDir = "$env:APPDATA\Sublime Text 3\Packages\User"
#     $SublimeSourceDir = Join-Path $DotfilesDir "sublime"
    
#     if (Test-Path $SublimeSourceDir) {
#         Write-Log "🔗 Setting up Sublime Text configuration..."
#         if (-not (Test-Path $SublimeConfigDir)) {
#             New-Item -ItemType Directory -Path $SublimeConfigDir -Force
#         }
        
#         # Create symlinks for Sublime config files
#         $configFiles = @(
#             "Preferences.sublime-settings",
#             "Default.sublime-keymap",
#             "Package Control.sublime-settings"
#         )
        
#         foreach ($fileName in $configFiles) {
#             $sourcePath = Join-Path $SublimeSourceDir $fileName
#             $targetPath = Join-Path $SublimeConfigDir $fileName
            
#             if (Test-Path $sourcePath) {
#                 if (Test-Path $targetPath) {
#                     Remove-Item $targetPath -Force
#                 }
                
#                 try {
#                     New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force
#                 } catch {
#                     Write-Warning "Failed to create symlink for $fileName. Try running as Administrator."
#                     Copy-Item $sourcePath $targetPath -Force
#                 }
#             }
#         }
        
#         # Handle snippets directory
#         $snippetsSource = Join-Path $SublimeSourceDir "snippets"
#         $snippetsTarget = Join-Path $SublimeConfigDir "snippets"
#         if (Test-Path $snippetsSource) {
#             if (Test-Path $snippetsTarget) {
#                 Remove-Item $snippetsTarget -Force -Recurse
#             }
#             try {
#                 New-Item -ItemType SymbolicLink -Path $snippetsTarget -Target $snippetsSource -Force
#             } catch {
#                 Copy-Item $snippetsSource $snippetsTarget -Recurse -Force
#             }
#         }
        
#         Write-Log "✅ Sublime Text configuration linked"
#     } else {
#         Write-Log "ℹ️  Skipping Sublime Text (no config found)"
#     }
# } else {
#     Write-Log "ℹ️  Skipping Sublime Text (disabled)"
# }

# # Zed configuration (Windows - coming soon)
# if ($SetupZed) {
#     $ZedConfigDir = "$env:APPDATA\Zed"
#     $ZedSourceDir = Join-Path $DotfilesDir "zed"
    
#     if (Test-Path $ZedSourceDir) {
#         Write-Log "🔗 Setting up Zed configuration..."
#         if (-not (Test-Path $ZedConfigDir)) {
#             New-Item -ItemType Directory -Path $ZedConfigDir -Force
#         }
        
#         # Create symlinks for Zed config files
#         $configFiles = @(
#             @{Source = "settings.json"; Target = "settings.json"},
#             @{Source = "keymap.json"; Target = "keymap.json"},
#             @{Source = "themes"; Target = "themes"}
#         )
        
#         foreach ($file in $configFiles) {
#             $sourcePath = Join-Path $ZedSourceDir $file.Source
#             $targetPath = Join-Path $ZedConfigDir $file.Target
            
#             if (Test-Path $sourcePath) {
#                 # Remove existing file/directory
#                 if (Test-Path $targetPath) {
#                     Remove-Item $targetPath -Force -Recurse
#                 }
                
#                 # Create symlink (requires admin privileges)
#                 try {
#                     if (Test-Path $sourcePath -PathType Container) {
#                         New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force
#                     } else {
#                         New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force
#                     }
#                 } catch {
#                     Write-Warning "Failed to create symlink for $($file.Source). Try running as Administrator."
#                     # Fallback: copy files instead of symlinking
#                     Copy-Item $sourcePath $targetPath -Recurse -Force
#                 }
#             }
#         }
        
#         Write-Log "✅ Zed configuration linked"
#     } else {
#         Write-Log "ℹ️  Skipping Zed (no config found)"
#     }
# } else {
#     Write-Log "ℹ️  Skipping Zed (disabled)"
# }

# Write-Log "🎉 Windows host setup complete!"
# Write-Log "💡 Editor configurations are now linked from your dotfiles"
# Write-Log "🔧 To customize this setup, edit the PowerShell script"

# # Note about admin privileges
# Write-Host ""
# Write-Host "📝 Note: If symlink creation failed, run this script as Administrator" -ForegroundColor Yellow
# Write-Host "   Alternatively, files were copied instead of symlinked" -ForegroundColor Yellow