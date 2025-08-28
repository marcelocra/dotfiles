# My Dotfiles

A modernized collection of configuration files for development environments, supporting both host machines (Linux/Windows WSL) and development containers.

## 🚀 Quick Start - DevMagic Development Environment

**For new projects**, get a complete, version-controlled development environment using a Git submodule. This ensures your environment is reproducible and easy to update.

### One-Line Setup

Run the following command in the root of your Git repository:

```bash
# This script adds the dev environment as a submodule in .devcontainer
curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/setup/devmagic.sh | bash
```

The script will guide you through the next steps, which involve committing the new submodule.

### How It Works

The `devmagic.sh` script automates the setup of a [Git Submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules), which points to a dedicated repository containing the development environment configuration (`devcontainer.json` and `docker-compose.yml`).

This approach allows you to:
- Keep your project's dev environment in sync with upstream changes.
- Pin your project to a specific version of the dev environment.
- Manage project-specific configuration changes cleanly.

### Updating the Environment

To pull the latest updates for the development environment, run this command from your project's root:

```bash
git submodule update --remote --merge
```

Then, commit the updated submodule pointer.

## Host Machine Setup

For setting up dotfiles directly on your host machine:

1. **Clone the repository:**

   ```sh
   git clone https://github.com/marcelocra/dotfiles.git ~/.config/marcelocra/dotfiles
   ```

2. **Source shell configuration:**
   ```sh
   # Add to your .bashrc or .zshrc
   source ~/.config/marcelocra/dotfiles/shell/init.sh
   ```

## Project Status

- **🚀 DevMagic**: Modern Docker Compose development environment (recommended)
- **🐚 Shell**: Consolidated `shell/init.sh` (Google Shell Style Guide compliant)
- **⚙️ Legacy**: Old files in `deprecated/` directory for reference