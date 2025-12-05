# My Dotfiles

A modernized collection of configuration files for development environments, supporting both host machines (Linux/Windows WSL) and development containers.

## Host Machine Setup

For setting up dotfiles directly on your host machine:

1. **Clone the repository:**

   ```sh
   git clone https://github.com/marcelocra/dotfiles.git ~/.config/marcelocra/dotfiles
   ```

2. **Source shell configuration:**
   ```sh
   # Add to your .bashrc or .zshrc
   source ~/.config/marcelocra/dotfiles/shell/init.bash
   ```

## Features

### 🤖 AI Development Scripts (cli/ directory)

Containerized development environments with AI assistants:

- **Multi-mode containers**: `full`, `quick`, `minimal` environments
- **AI Integration**: Claude Code CLI + Gemini CLI pre-installed
- **Cross-platform**: Bash (Linux/macOS/WSL) + PowerShell (Windows)
- **Shared History**: Persistent shell history across environments

**Note:** The `cli` folder and its scripts (`ai-dev`, `ai-dev.ps1`, `ai-dev-setup.bash`) are still maintained in this repository and have not been migrated elsewhere.

Usage:

```bash
# Quick AI-enabled development environment
./cli/ai-dev

# Full development environment with all tools
./cli/ai-dev full

# Minimal Alpine-based environment
./cli/ai-dev minimal
```

### 🐚 Shell Configuration

Consolidated `shell/init.bash` with:

- **AI Helper Functions**: `ask`, `gemini`, `analyze`, `codehelp` (when CLI tools installed)
- **Multi-platform**: Ubuntu, Alpine, openSUSE support
- **Google Shell Style Guide**: Compliant implementation
- **Container Detection**: Automatic environment adaptation

## Project Status

- **🤖 AI Scripts**: v2.0 unified architecture (see `cli/` folder)
- **🐚 Shell**: Consolidated, Google Style Guide compliant
- **🛠️ Host Setup**: Scripts for configuring editors and tools on host machines (see `setup/` folder)
- **⚙️ Legacy**: Old files in `deprecated/` directory for reference
