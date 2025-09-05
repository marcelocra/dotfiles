# Changelog

## [1.1.0] - 2025-09-03 - AI Development Scripts Creation

### Added

- 🤖 **AI Functions in Host Shell**: Added `ask`, `gemini`, `analyze`, and `codehelp` functions to `shell/init.sh`
- **Unified Setup Script**: Created `ai-dev-setup.sh` consolidating all environment setup logic
- **Shared History Configuration**: All AI dev environments now use persistent `~/.shell-history` with timestamps
- **Enhanced Error Handling**: Improved error handling and command existence checking in setup scripts

### Changed

- **Improved**: Consolidated `setup-full.sh`, `setup-quick.sh`, and `setup-minimal.sh` (initially separated) into single `ai-dev-setup.sh`
- **AI Dev Architecture**: Simplified from 5 files to 3 files (ai-dev.sh, ai-dev.ps1, ai-dev-setup.sh)
- **Container Scripts**: Updated both Bash and PowerShell runners to use unified setup script
- **Documentation**: Updated AI context and architecture descriptions

### Removed

- **Legacy Setup Files**: Removed redundant `setup-*.sh` files in favor of unified approach

### Benefits

- **No Code Duplication**: Setup logic exists only once for all modes
- **Easier Maintenance**: Single script to update for environment changes
- **Better Shell Integration**: AI functions now available on host systems
- **Consistent History**: Shared shell history across all development environments

## [1.0.0] - 2025-08-26 - DevMagic Docker Compose Environment

### Added

- 🚀 **DevMagic**: Complete Docker Compose-based development environment
- Profile-based service selection (`minimal`, `ai`, `postgres`, `redis`, `mongodb`, `minio`)
- One-line project setup with curl command
- Cross-platform path handling (`${HOME}${USERPROFILE}`)
- Container network isolation for security
- Named volumes for data persistence
- Remote docker-compose.yml for easy updates
- Blog outlines for future technical articles

### Changed

- **BREAKING**: Replaced single devcontainer approach with Docker Compose
- Transitioned from `mounts` in devcontainer.json to `volumes` in docker-compose.yml
- Updated user management to use container defaults (`codespace`)
- Environment variables now use `MCRA_` prefix for consistency
- Streamlined documentation and removed outdated files

### Technical Details

- Services communicate via container network names (e.g., `http://ollama:11434`)
- GPU (port 11434) and CPU (port 11435) Ollama alternatives
- Database password management via `MCRA_DEV_DB_PASSWORD` environment variable
- Profile system allows running only needed services per project

## [0.3.0] - 2025-08-05 - VS Code Git Credential Management

### Added

- Three-layer VS Code git credential prevention system (Edit: Didn't work.)
- Global credential helper configuration using GitHub CLI
- Pre-commit hook to prevent accidental credential commits (Edit: Disabled. Not necessary anymore.)

### Changed

- VS Code settings to disable integrated git authentication
- Git configuration to use GitHub CLI for all authentication

### Security

- Prevents container-specific credential helpers from being committed
- Eliminates exposure of internal system information in public repositories

## [0.2.0] - 2025-08-03 - Shell Configuration Consolidation

### Added

- Consolidated `shell/init.sh` replacing scattered shell configurations
- Oh-my-zsh integration with security-vetted installation
- Custom theme support with fallback strategies
- Interactive shell compatibility

### Changed

- **BREAKING**: Moved from scattered configs to `shell/init.sh`
- Centralized configuration replacing Dockerfile shell setup
- Removed strict error handling for oh-my-zsh compatibility

### Technical

- Symlink architecture: `init.sh` serves as both `.bashrc` and `.zshrc`
- Container integration with Microsoft devcontainer environments
- Variable compatibility for oh-my-zsh and VS Code shell integration

## [0.1.0] - 2025-07-29 - Major Refactoring Foundation

### Added

- Google Shell Style Guide compliant implementation
- Multi-platform support (Ubuntu, Alpine, openSUSE)
- WSL and container environment detection
- Modular function organization with clear naming
- Enhanced error handling and safety checks

### Changed

- **BREAKING**: Complete restructuring of dotfiles project
- Shell configuration consolidated to `shell/main.sh`
- All old files moved to `deprecated/` directory
- New structure with `shell/`, `nvim/`, `git/`, `tmux/` directories

### Migration

- Users need to source `shell/main.sh` instead of old scattered files
- Deprecated files preserved for reference during transition period
- 30+ day migration window for stability testing

## Legacy System (Pre-0.1.0)

### Previous Architecture

- Scattered configuration files with inconsistent naming
- Mixed shell setup across multiple files
- Single devcontainer approach with service installation via setup scripts
- Platform-specific handling without proper detection

### Issues That Led to Refactoring

- Hard to maintain scattered configurations
- Platform compatibility problems
- Service mixing with development environment
- Complex debugging of monolithic containers
- Inconsistent file organization and naming
