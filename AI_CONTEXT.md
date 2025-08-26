# AI Context - Dotfiles Project

## 🚀 DevMagic - Current Setup (v1.0.0 - 2025-08-26)

**Primary Approach**: Docker Compose-based development environment with profile-based services.

### Key Components
- `docker-compose.yml` - Service definitions with profiles
- `.devcontainer/devcontainer.json` - 🚀 DevMagic configuration (points to remote compose file)
- `devmagic.sh` - One-line setup script
- `devcontainer-setup.sh` - Cross-platform container initialization
- `shell/init.sh` - Consolidated shell configuration (Google Shell Style Guide compliant)

### Service Profiles
- `minimal` (default): Just development container
- `ai`: + Ollama GPU (port 11434) | `ai-cpu`: + Ollama CPU (port 11435)
- `postgres`, `redis`, `mongodb`, `minio`: Database and storage services

### Usage Pattern
```bash
# One-line DevMagic setup.
curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/devmagic.sh | bash

# Or manual setup.
mkdir -p .devcontainer && curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/.devcontainer/devcontainer.json -o .devcontainer/devcontainer.json

# Choose services.
MCRA_COMPOSE_PROFILES=minimal,ai,postgres code myproject
```

### Technical Decisions
- **Cross-platform paths**: `${HOME}${USERPROFILE}` for Windows/Linux compatibility
- **Container networks**: Services communicate via service names (security + simplicity)
- **Named volumes**: Data persistence across container rebuilds
- **MCRA_ prefix**: Consistent environment variable naming
- **Remote compose**: Easy updates without copying files

### Architecture Benefits
- **Service isolation**: Easier debugging, independent scaling
- **Profile-based**: Only run needed services per project  
- **Cross-platform**: Works on Windows/Linux/WSL/containers
- **Secure by default**: Container network isolation
- **One-line setup**: Minimal friction for new projects

## Shell Configuration Summary

- **Primary file**: `shell/init.sh` (replaces old scattered configs)
- **Cross-shell**: Works with bash and zsh
- **Multi-platform**: Ubuntu, Alpine, openSUSE, WSL detection
- **Aliases**: 50+ git aliases, pnpm shortcuts, system navigation
- **Functions**: tmux wrapper, timer functions, venv activation

## Environment Variables
```bash
MCRA_COMPOSE_PROFILES="minimal,ai,postgres"  # Which services to start
MCRA_DEV_DB_PASSWORD="YourSecurePassword!"   # Database password
MCRA_DEVCONTAINER_USER="codespace"          # Container user
MCRA_USE_MISE="true"                         # Enable mise tool manager
```

## Current Project Structure
```
dotfiles/
├── .devcontainer/
│   ├── devcontainer.json      # 🚀 DevMagic configuration
│   └── README.md              # Setup instructions
├── docker-compose.yml         # Service definitions
├── devmagic.sh                # One-line setup script
├── devcontainer-setup.sh      # Container initialization
├── shell/
│   └── init.sh               # Primary shell configuration
├── git/.gitconfig            # Git configuration  
├── vscode/                   # VS Code settings
└── CHANGELOG.md              # Version history
```
