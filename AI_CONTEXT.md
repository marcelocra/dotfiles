# AI Context - Dotfiles Project

This project contains a collection of configuration files and setup scripts for development environments. Its flagship feature is the **DevMagic** environment. It also includes the **AI Development Scripts** in the `cli/` directory for containerized AI-enabled development environments.

## 🚀 Feature: DevMagic Environment (v3.0.0 - 2025-09-01)

**Primary Approach**: A hybrid, Git Submodule-based development environment. The core development container is built directly from an image for speed and reliability, while optional auxiliary services (databases, AI models) are managed via `docker-compose` profiles.

### Key Components

- **`devmagic/` directory**: The contents of the submodule.
  - `devcontainer.json`: The primary Dev Container configuration file. It defines the core environment by referencing a pre-built `image`.
  - `docker-compose.yml`: Defines a suite of optional, on-demand services (`postgres`, `ollama`, etc.) using profiles. It is **not** used to build the main container.
  - `README.md`: Instructions on how to use the auxiliary services.
- `setup/devmagic.sh`: One-line setup script that automates `git submodule add`.
- `setup/devcontainer-setup.sh`: Script for container initialization (installing tools like `mise`, etc.), run via `postCreateCommand`.

### Service Profiles

Profiles are used exclusively for managing optional, sidecar services. The main development container always starts.

- `ai`: + Ollama GPU (port 11434) | `ai-cpu`: + Ollama CPU (port 11435).
- `postgres`, `redis`, `mongodb`, `minio`: Database and storage services.

### Usage Pattern

```bash
# One-line DevMagic setup in a new project's git repo.
curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/setup/devmagic.sh | bash

# Commit the new environment
git add .gitmodules .devcontainer
git commit -m "feat: Add DevMagic development environment"

# To update the environment to the latest version:
git submodule update --remote --merge

# --- Using Auxiliary Services (from within the dev container) ---

# Start the Ollama service
docker compose --profile ai up -d

# Stop the Ollama service
docker compose --profile ai down
```

### Technical Decisions & Workarounds

- **Git Submodule**: Chosen as the primary mechanism for sharing the dev environment across projects to allow for versioning and easy updates.
- **Decoupled Architecture**: The core architectural decision is to **separate** the main container's definition from auxiliary services. The `devcontainer.json` uses a direct `image` for reliability, avoiding the fragile and complex `docker-compose` build process that fails within VS Code's orchestration when using Podman.
- **On-Demand Services**: `docker-compose` is used for its primary strength: managing the lifecycle of optional, multi-container services. This avoids the toolchain integration bugs encountered previously.
- **Container Networks**: Services communicate via service names for security and simplicity.
- **Named Volumes**: Ensure data persistence across container rebuilds.

### Architecture Benefits

- **Version Controlled Environment**: Projects can be pinned to specific versions of the dev environment.
- **Reliable & Fast Startup**: Using a pre-built image for the main container is significantly faster and more reliable than a compose build.
- **Flexible & On-Demand**: Auxiliary services can be started and stopped as needed without rebuilding the main container.
- **One-line Setup**: Minimal friction for new projects despite the power of submodules.

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
