# My Dotfiles

A modernized collection of configuration files for development environments, supporting both host machines (Linux/Windows WSL) and development containers.

## 🚨 Important Notice

This project has undergone **major refactoring**. Most configuration files have been moved to the `deprecated/` directory while a new, consolidated system has been implemented.

### Current Status:

- **Active Configuration**: `shell/init.sh` (Google Shell Style Guide compliant)
- **Deprecated Files**: All old files moved to `deprecated/` directory for reference
- **Migration Period**: Deprecated files will be removed after 30+ days of stable operation

## Quick Start

1. **Clone the repository:**

   ```sh
   DOTFILES="$HOME/dotfiles"

   git clone https://github.com/marcelocra/dotfiles.git $DOTFILES
   cd $DOTFILES
   ```

2. **Run the install script:**

   > [!IMPORTANT]
   > By default, it will install a bunch of things (.gitconfig, .tmux.conf, sublime/vscode configs, etc). Take a look at the script to customize.

   ```sh
   ./install.sh  
   ```
