#!/usr/bin/env pwsh

# ai-dev.ps1 - AI-integrated development container for PowerShell.
# Usage: .\ai-dev.ps1 [full|quick|minimal]

param(
    [ValidateSet("full", "quick", "minimal")]
    [string]$Mode = "quick"
)

$ContainerName = "ai-dev-$(Split-Path -Leaf $PWD)"
$WorkspacePath = $PWD

# Colors for output.
$Blue = "`e[34m"
$Yellow = "`e[33m"
$Green = "`e[32m"
$Red = "`e[31m"
$NC = "`e[0m"  # No Color

Write-Host "${Blue}🚀 Starting AI development container...${NC}"

# Stop container if already running.
try {
    $existing = podman ps -q --filter "name=$ContainerName" 2>$null
    if ($existing) {
        Write-Host "${Yellow}⚠️  Container already exists. Stopping...${NC}"
        podman stop $ContainerName 2>$null | Out-Null
        podman rm $ContainerName 2>$null | Out-Null
    }
} catch {
    # Container doesn't exist, continue.
}

# Define setup commands based on mode (now using unified external script).
$SetupCommands = @{
    "minimal" = "bash /workspace/ai-dev-setup.bash --mode=minimal; exec sh"
    "quick"   = "bash /workspace/ai-dev-setup.bash --mode=quick; exec bash"  
    "full"    = "bash /workspace/ai-dev-setup.bash --mode=full; exec bash"
}

# Select image and setup based on mode.
$Image = switch ($Mode) {
    "minimal" { "node:20-alpine" }
    "quick" { "mcr.microsoft.com/devcontainers/javascript-node:1-20-bullseye" }
    "full" { "mcr.microsoft.com/devcontainers/javascript-node:1-20-bullseye" }
}

$SetupCommand = $SetupCommands[$Mode]

# Build volume mounts.
$VolumeMounts = @(
    "-v", "${WorkspacePath}:/workspace:Z"
    "-v", "$HOME/.claude:/root/.claude:Z"
    "-v", "$HOME/.config:/root/.config:Z"
    "-v", "$HOME/.ssh:/root/.ssh:Z"
)

# Environment variables.
$EnvVars = @(
    "-e", "TZ=America/Sao_Paulo"
    "-e", "LC_ALL=en_US.UTF-8"
    "-e", "LANG=en_US.UTF-8"
)

# Run the container.
Write-Host "${Green}Starting $Mode mode container...${NC}"

$PodmanArgs = @(
    "run", "-it", "--rm"
    "--name", $ContainerName
    "--hostname", "ai-dev"
    "-w", "/workspace"
) + $VolumeMounts + $EnvVars + @($Image)

if ($Mode -eq "minimal") {
    $PodmanArgs += @("sh", "-c", $SetupCommand)
} else {
    $PodmanArgs += @("bash", "-c", $SetupCommand)
}

try {
    & podman @PodmanArgs
} catch {
    Write-Host "${Red}❌ Failed to start container. Make sure podman is installed and running.${NC}"
    Write-Host "Error: $_"
    exit 1
}