# PowerShell 7 profile script.

# Use bash-like command line editing. To work more like bash, some adaptations
# are necessary. I documented them below, along with the defaults.
Set-PSReadLineOption -EditMode Emacs
# Default Emacs key bindings that works as expected:
#   - ctrl+a       move to beginning of line
#   - ctrl+e       move to end of line
#   - ctrl+u       delete from cursor to beginning of line
#   - ctrl+k       delete from cursor to end of line
#   - ctrl+p       previous command
#   - ctrl+n       next command
#   - ctrl/alt+f   move forward one character/word
#   - ctrl/alt+b   move backward one character/word
#   - alt+d        delete word to right of cursor
#   - ctrl+d       delete character under cursor
#   - ctrl+d       [nothing to delete] exit shell
#   - ctrl+c       [no selection] cancel current command
#   - ctrl+c       [with selection] copy selected text
#   - ctrl+v       paste text from clipboard
# Key bindings I changed to work more like bash:
# Delete word to the left of the cursor.
Set-PSReadLineKeyHandler -Key Ctrl+Backspace -Function BackwardKillWord
# Delete word to the right of the cursor.
Set-PSReadLineKeyHandler -Key Ctrl+Delete -Function DeleteWord
# Move backwards one word.
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
# Move forwards one word.
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
# Undo last change.
Set-PSReadLineKeyHandler -Key Ctrl+/ -Function Undo

# Launch the "Universal" Linux image.
# podman run -it --rm --name universal mcr.microsoft.com/devcontainers/universal:3-noble zsh

function Invoke-TimestampArchiver {
    <#
    .SYNOPSIS
        Compresses all files and folders (except .zip and "Archived_*") in a given path
        into individual zip archives, logs size details, and moves originals to
        a timestamped folder.

    .DESCRIPTION
        - Skips existing .zip files in the source directory.
        - Skips any items whose name starts with "Archived_".
        - Creates one .zip per file/folder with the same base name.
        - Outputs a table with original and compressed sizes.
        - Moves originals to a timestamped folder only after successful compression.
        - Defaults to WhatIf mode for safety unless -WhatIf:$false is specified.

    .PARAMETER SourcePath
        The directory containing the files/folders to process.

    .EXAMPLE
        Invoke-TimestampArchiver -SourcePath "C:\Data"
        Invoke-TimestampArchiver -SourcePath "C:\Data" -WhatIf:$false
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory)]
        [string]$SourcePath
    )

    if (-not (Test-Path -Path $SourcePath -PathType Container)) {
        Write-Error "Source path '$SourcePath' does not exist or is not a directory."
        return
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    function Get-ReadableSize {
        param ([long]$Bytes)
        switch ($Bytes) {
            {$_ -ge 1GB} { "{0:N2} GB" -f ($_ / 1GB); break }
            {$_ -ge 1MB} { "{0:N2} MB" -f ($_ / 1MB); break }
            {$_ -ge 1KB} { "{0:N2} KB" -f ($_ / 1KB); break }
            default      { "$_ Bytes" }
        }
    }

    $timestamp     = Get-Date -Format "yyyyMMdd_HHmmss"
    $archiveFolder = Join-Path -Path $SourcePath -ChildPath "Archived_$timestamp"
    New-Item -Path $archiveFolder -ItemType Directory -Force | Out-Null

    # Prepare items: skip .zip files and anything with Archived_* name
    $items = @()
    $items += Get-ChildItem -Path $SourcePath -File |
              Where-Object { $_.Extension -ne ".zip" -and $_.Name -notlike "Archived_*" }
    $items += Get-ChildItem -Path $SourcePath -Directory |
              Where-Object { $_.Name -notlike "Archived_*" }

    $results = @()

    foreach ($item in $items) {
        # Safety: skip if path is or starts with our archive folder
        if ($item.FullName -like "$archiveFolder*") { continue }

        try {
            $originalSize = if ($item.PSIsContainer) {
                (Get-ChildItem -Path $item.FullName -Recurse -Force -ErrorAction SilentlyContinue |
                    Measure-Object -Property Length -Sum).Sum
            } else {
                $item.Length
            }

            $zipPath = Join-Path -Path $SourcePath -ChildPath ("{0}.zip" -f $item.BaseName)

            if (Test-Path $zipPath) {
                Write-Warning "Skipping '$($item.Name)' because zip already exists."
                continue
            }

            if ($item.PSIsContainer) {
                [System.IO.Compression.ZipFile]::CreateFromDirectory($item.FullName, $zipPath, 'Optimal', $false)
            } else {
                $tempDir = Join-Path $env:TEMP ([guid]::NewGuid())
                New-Item -Path $tempDir -ItemType Directory | Out-Null
                Copy-Item -Path $item.FullName -Destination $tempDir
                [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipPath, 'Optimal', $false)
                Remove-Item $tempDir -Recurse -Force
            }

            $compressedSize = (Get-Item $zipPath).Length

            $results += [PSCustomObject]@{
                Name         = $item.Name
                OriginalSize = Get-ReadableSize $originalSize
                ZippedSize   = Get-ReadableSize $compressedSize
            }

            if ($PSCmdlet.ShouldProcess($item.FullName, "Move to archive folder '$archiveFolder'")) {
                Move-Item -Path $item.FullName -Destination $archiveFolder -Force
            }
        } catch {
            Write-Error "Failed to process '$($item.Name)': $_"
        }
    }

    if ($results) {
        $results | Format-Table -AutoSize
    } else {
        Write-Host "No items found to process." -ForegroundColor Yellow
    }

    if ($WhatIf) {
        Write-Host "✅ Dry run complete. Use -WhatIf:`$false to perform actual moves." -ForegroundColor Green
    }
}
