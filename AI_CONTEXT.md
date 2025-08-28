# AI Context - Dotfiles Project

## 🚀 DevMagic - Current Setup (v2.0.0 - 2025-08-26)

**Primary Approach**: Git Submodule-based development environment. A one-line script adds the `devmagic` environment repository as a submodule to a project, allowing for easy updates and version pinning.

### Key Components

- **`devmagic/` directory**: The contents of the submodule, intended to be its own repository.
  - `docker-compose.yml`: Service definitions with profiles (`postgres`, `ollama`, etc.).
  - `devcontainer.json`: The primary Dev Container configuration file.
  - `Dockerfile.dev`: A simple Dockerfile used to work around a Podman/docker-compose bug by forcing a local image build.
- `setup/devmagic.sh`: One-line setup script that automates `git submodule add`.
- `setup/devcontainer-setup.sh`: Script for container initialization (installing tools, etc.).

### Service Profiles

- `minimal` (default): Just the development container.
- `ai`: + Ollama GPU (port 11434) | `ai-cpu`: + Ollama CPU (port 11435).
- `postgres`, `redis`, `mongodb`, `minio`: Database and storage services.

### Usage Pattern

```bash
# One-line DevMagic setup in a new project's git repo.
curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/setup/devmagic.sh | bash

# The script adds the submodule and provides instructions to commit.
git add .gitmodules .devcontainer
git commit -m "feat: Add DevMagic environment"

# To update the environment to the latest version:
git submodule update --remote --merge
```

### Technical Decisions & Workarounds

- **Git Submodule**: Chosen as the primary mechanism for sharing the dev environment across projects to allow for versioning and easy updates.
- **`Dockerfile.dev` Workaround**: A `build` step was added to the `docker-compose.yml` to explicitly build the dev container image. This is necessary to work around a bug in some `docker-compose` client versions that incorrectly try to `pull` a locally-defined image when used with a Podman backend.
- **Container Networks**: Services communicate via service names for security and simplicity.
- **Named Volumes**: Ensure data persistence across container rebuilds.

### Architecture Benefits

- **Version Controlled Environment**: Projects can be pinned to specific versions of the dev environment.
- **Easy Updates**: `git submodule update` provides a standard way to pull in new changes.
- **Service Isolation**: Independent services in Docker Compose allow for easier debugging and scaling.
- **One-line Setup**: Minimal friction for new projects despite the power of submodules.

## Podman / Client-side Issues

A lengthy debugging session revealed that some `docker-compose` client binaries (even when used with a `podman` alias and a correct Docker context) can fail to correctly issue a `build` command against a Podman socket.

**Symptoms:**

- `docker-compose build` fails silently with no errors.
- VS Code dev container builds fail with errors about being unable to find a local image, often after an interactive prompt to select a remote registry.

**Solution:**

- The most robust solution is to bypass the incompatible `docker-compose` client and install the native `podman-compose` tool (`pip install podman-compose`).
- A system-level fix that may be required is ensuring the `DOCKER_HOST` environment variable is correctly pointing to the active Podman socket (e.g., `export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"`).
