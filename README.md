# My Dotfiles

A modernized collection of configuration files for development environments, supporting both host machines (Linux/Windows WSL) and development containers.

## 🚀 Quick Start - DevMagic Development Environment

**For new projects**, get a complete development environment with optional AI, databases, and services:

```bash
# One-line DevMagic setup (interactive).
curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/devmagic.sh | bash

# Or manual setup.
mkdir -p .devcontainer && curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/.devcontainer/devcontainer.json -o .devcontainer/devcontainer.json

# Choose your services and open in VS Code.
MCRA_COMPOSE_PROFILES=minimal,ai,postgres code myproject
```

**Available services:** `minimal` (default), `ai` (Ollama), `postgres`, `redis`, `mongodb`, `minio`

## Host Machine Setup

For setting up dotfiles directly on your host machine:

1. **Clone the repository:**

   ```sh
   git clone https://github.com/marcelocra/dotfiles.git ~/.config/marcelocra/dotfiles
   ```

2. **Source shell configuration:**
   ```sh
   # Add to your .bashrc or .zshrc, but keep in mind that it will override a
   # bunch of stuff (in zsh, oh-my-zsh themes, plugins, etc).
   source ~/.config/marcelocra/dotfiles/shell/init.sh
   ```

## Project Status

- **🚀 DevMagic**: Modern Docker Compose development environment (recommended)
- **🐚 Shell**: Consolidated `shell/init.sh` (Google Shell Style Guide compliant)
- **⚙️ Legacy**: Old files in `deprecated/` directory for reference
