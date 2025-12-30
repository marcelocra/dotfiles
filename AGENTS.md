# AI Context - Dotfiles Project

This project contains a collection of configuration files and setup scripts for development environments. Its main features are:

- **AI Development Scripts** (`cli/` directory): Containerized AI-enabled development environments
- **Shell Configuration** (`shell/` directory): Consolidated shell setup with AI helper functions
- **Host Setup Scripts** (`setup/` directory): Scripts for configuring editors and tools on host machines
- **Application Configs** (`apps/` directory): Editor and application configurations (VS Code, Neovim, Kitty, etc.)

## 🛠️ Host Setup Scripts (setup/ directory)

Scripts for configuring host machines (not containers):

- **`host-setup-linux.sh`**: Configures VS Code, Sublime Text, and Zed on Linux hosts
- **`host-setup-windows.ps1`**: Configures editors on Windows hosts

These scripts symlink editor configurations from the `apps/` directory to the appropriate locations on the host machine.

## Podman / Client-side Issues

A lengthy debugging session revealed that some `docker-compose` client binaries (even when used with a `podman` alias and a correct Docker context) can fail to correctly issue a `build` command against a Podman socket.

**Symptoms:**

- `docker-compose build` fails silently with no errors.
- VS Code dev container builds fail with errors about being unable to find a local image, often after an interactive prompt to select a remote registry.

**Solution:**

- The most robust solution is to bypass the incompatible `docker-compose` client and install the native `podman-compose` tool (`pip install podman-compose`).
- A system-level fix that may be required is ensuring the `DOCKER_HOST` environment variable is correctly pointing to the active Podman socket (e.g., `export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"`).

## 🤖 Feature: AI Development Scripts (cli/ directory)

**Primary Approach**: Containerized AI-enabled development environments with Claude Code CLI and Gemini CLI pre-installed.

### Key Components

- **`ai-dev.sh`**: Multi-mode Bash script for Linux/macOS/WSL
- **`ai-dev.ps1`**: Multi-mode PowerShell script for Windows/cross-platform
- **`ai-dev-setup.sh`**: Unified setup script handling all environment configurations

### Architecture (v2.0.0 - DRY Refactoring)

```
Container Runners          Setup Script (Unified Logic)
├── ai-dev.sh         ──→  ai-dev-setup.sh --mode=full|quick|minimal
└── ai-dev.ps1        ──→
```

**Benefits of Unified Architecture:**

- **No Code Duplication**: One setup script for all modes
- **Easy Maintenance**: Single point of updates for all environments
- **Consistent Behavior**: Same logic across Bash and PowerShell
- **Shared History**: All environments use `~/.shell-history` with timestamps

### Usage Pattern

```bash
# Bash (Linux/macOS/WSL)
./ai-dev.sh              # quick mode (default)
./ai-dev.sh full         # full development environment
./ai-dev.sh minimal      # minimal Alpine environment

# PowerShell (Windows/cross-platform)
.\ai-dev.ps1              # quick mode (default)
.\ai-dev.ps1 -Mode full   # full mode
.\ai-dev.ps1 -Mode minimal # minimal mode
```

### AI Integration Features

- **Claude Code CLI**: Primary AI assistant with fallback installation
- **Gemini CLI**: Alternative AI assistant
- **AI Helper Functions**: `ask "question"`, `gemini "question"`, `analyze`, `codehelp <file>`
- **Cross-Platform Consistency**: Same functionality across all platforms
