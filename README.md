# Personal Dotfiles

A modernized collection of configuration files for development environments, supporting both host machines (Linux/Windows WSL) and development containers.

## 🚨 Important Notice

This project has undergone **major refactoring**. Most configuration files have been moved to the `deprecated/` directory while a new, consolidated system has been implemented.

### Current Status:

- **Active Configuration**: `shell/main.sh` (Google Shell Style Guide compliant)
- **Deprecated Files**: All old files moved to `deprecated/` directory for reference
- **Migration Period**: Deprecated files will be removed after 30+ days of stable operation

## Quick Start

1. **Clone the repository:**

   ```bash
   git clone https://github.com/marcelocra/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Source the main configuration:**

   ```bash
   source ~/dotfiles/shell/main.sh
   ```

3. **Add to your shell profile:**
   ```bash
   # Add to ~/.bashrc, ~/.zshrc, etc.
   source "$HOME/dotfiles/shell/main.sh"
   ```

## Configuration Overview

### New System (Active)

**Primary Shell Configuration:**

- `shell/main.sh` - Main shell configuration with multi-platform support
- `shell/amuse-datetime.zsh-theme` - Custom zsh theme

**Core Editors:**

- `nvim/` - LazyVim-based Neovim configuration
- `vscode/` - VSCode settings, keybindings, and extensions
- `zed/` - Zed editor configuration

**System Configuration:**

- `git/.gitconfig` - Enhanced Git configuration
- `tmux/.tmux.config` - Tmux configuration

### Deprecated System (Reference Only)

⚠️ **DO NOT USE** - Files in `deprecated/` directory are for reference only:

- Old `init.sh` and `common.sh` → Merged into `shell/main.sh`
- Legacy configurations → Use new system equivalents
- Application configs → Most moved to deprecated, core ones updated

## Features

### Multi-Platform Support

- **Ubuntu**: Full support for containers and host systems
- **Alpine**: Lightweight container support with doas handling
- **openSUSE**: Tumbleweed distribution support
- **WSL**: Windows Subsystem for Linux detection and adaptation
- **Container Detection**: Automatic environment detection and adaptation

### Enhanced Shell Configuration

- **Environment Detection**: Automatically detects and adapts to runtime environment
- **50+ Git Aliases**: Comprehensive Git workflow shortcuts
- **Development Tools**: pnpm, Node.js, Python utilities
- **System Utilities**: Navigation, file operations, search tools
- **Smart Editor Selection**: Automatic nvim > vim > vi > nano detection

### Google Shell Style Guide Compliance

- Proper error handling with `set -euo pipefail`
- Consistent function naming with underscores
- Clear section organization and documentation
- Modular configuration structure

## Installation Guide

### Prerequisites

- Git
- Bash or Zsh shell
- Terminal emulator (recommended: Kitty, Alacritty, or built-in)

### Platform-Specific Setup

#### Linux (Host or WSL)

```bash
# Clone dotfiles
git clone https://github.com/marcelocra/dotfiles.git ~/dotfiles

# Add to shell profile
echo 'source "$HOME/dotfiles/shell/main.sh"' >> ~/.bashrc
# or for zsh:
echo 'source "$HOME/dotfiles/shell/main.sh"' >> ~/.zshrc

# Reload shell
source ~/.bashrc  # or ~/.zshrc
```

#### Development Containers

The configuration automatically detects container environments and adapts accordingly. No special setup required.

### Editor Setup

#### Neovim

```bash
# LazyVim configuration
ln -sf ~/dotfiles/nvim ~/.config/nvim
```

#### VSCode

```bash
# Link configurations (Linux/WSL paths)
ln -sf ~/dotfiles/vscode/settings.jsonc ~/.config/Code/User/settings.json
ln -sf ~/dotfiles/vscode/keybindings.jsonc ~/.config/Code/User/keybindings.json
```

## Available Commands & Aliases

### System Navigation

- `l` - Enhanced file listing with timestamps
- `ll` - List all files including hidden
- `cls` - Clear screen
- `b` - Go back (popd)

### Git Shortcuts (50+ aliases)

- `gs` - git status
- `ga` - git add
- `gaa` - git add --all
- `gc` - git commit -v
- `gco` - git checkout
- `gl` - git log (last 10)
- `gps` - git push
- `gpl` - git pull

### Development Tools

- `p` - pnpm
- `r` - pnpm run
- `n` - editor (nvim/vim/vi/nano)
- `t` - tmux session manager
- `va` - activate Python virtual environment

### Utilities

- `t5`, `t15`, `t30`, `t60` - Timer functions (5, 15, 30, 60 minutes)
- `colines` - Show terminal dimensions
- `path_print` - Display PATH variable formatted

## Migration from Old System

If you were using the previous system:

1. **Your aliases still work** - Most functionality has been preserved
2. **Check new location** - Features may be reorganized but available
3. **Temporary fallback** - Reference `deprecated/` files if needed
4. **Migrate custom changes** - Move any personal modifications to new system

### Finding Migrated Features

1. **Check `shell/main.sh`** - Main location for all shell configuration
2. **Look in sections** - Functions organized by category (Git, Development, System, etc.)
3. **Search by name** - Use grep to find specific aliases or functions
4. **Check TODO section** - Some functions marked for review

## Troubleshooting

### Common Issues

**Problem**: Old aliases not working
**Solution**: Source the new configuration:

```bash
source ~/dotfiles/shell/main.sh
```

**Problem**: Missing functionality from old system
**Solution**:

1. Check if it exists in `shell/main.sh`
2. Look in the TODO section
3. Temporarily reference `deprecated/` files
4. Always migrate to new system

**Problem**: Environment-specific issues
**Solution**: Enable debug mode:

```bash
export DOTFILES_DEBUG=1
source ~/dotfiles/shell/main.sh
```

### Debug Information

The system provides debug information about:

- Detected environment (container, WSL, distribution)
- Platform-specific configurations applied
- Editor selection process

### Getting Help

1. Check `CLAUDE.md` for detailed technical information
2. Review `deprecated/README.md` for migration guidance
3. Examine `shell/main.sh` sections for specific functionality
4. Open an issue for bugs or missing features

## Contributing

1. Fork the repository
2. Create a feature branch
3. Test across different environments (host, container, WSL)
4. Update documentation as needed
5. Submit a pull request

## License

See the LICENSE file for details.

## Acknowledgments

- Google Shell Style Guide for coding standards
- LazyVim for excellent Neovim configuration framework
- The dotfiles community for inspiration and best practices
- Claude Code for great AI assistance in refactoring
