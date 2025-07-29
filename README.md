# Personal Dotfiles

A comprehensive collection of configuration files for development environments, supporting both host machines (Linux/Windows WSL) and development containers.

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Set up environment variables:**
   ```bash
   export MCRA_INIT_SHELL="$HOME/dotfiles/init.sh"
   export MCRA_LOCAL_SHELL="$HOME/.local-shell"  # Create this file for local configs
   export MCRA_TMP_PLAYGROUND="/tmp/playground"
   ```

3. **Source the main configuration:**
   ```bash
   source ~/dotfiles/init.sh
   ```

## Configuration Overview

### Core Editors
- **Neovim**: LazyVim configuration with Clojure support
- **VSCode**: Settings, keybindings, snippets, and extensions
- **Zed**: Modern editor configuration
- **Sublime Text**: Complete settings and keymaps

### Terminal Emulators
- **Kitty**: Feature-rich terminal with themes
- **Alacritty**: GPU-accelerated terminal

### Development Tools
- **Git**: Enhanced configuration with aliases and modern features
- **Shell**: Bash/Zsh configuration with aliases and functions
- **Development Containers**: Ready-to-use devcontainer configuration

## Installation Guide

### Prerequisites

**Required Tools:**
- Git
- A terminal emulator (Kitty/Alacritty recommended)
- Text editor (Neovim/VSCode/Zed)

**Optional Tools:**
- Node.js (for some VSCode extensions)
- Python 3 (for some scripts)
- Docker (for development containers)

### Platform-Specific Setup

#### Linux (Host)
```bash
# Install dependencies
sudo apt update
sudo apt install git curl wget build-essential

# Clone and setup
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Add to your shell profile (.bashrc, .zshrc, etc.)
echo 'export MCRA_INIT_SHELL="$HOME/dotfiles/init.sh"' >> ~/.bashrc
echo 'export MCRA_LOCAL_SHELL="$HOME/.local-shell"' >> ~/.bashrc
echo 'export MCRA_TMP_PLAYGROUND="/tmp/playground"' >> ~/.bashrc
echo 'source "$MCRA_INIT_SHELL"' >> ~/.bashrc
```

#### Windows WSL
```bash
# Same as Linux, but ensure WSL-specific configs are used
# The configuration automatically detects WSL environment
```

#### Development Containers
```bash
# The devcontainer configuration in devcontainers/ directory
# automatically sets up the environment when using VS Code Dev Containers
```

### Editor-Specific Setup

#### Neovim
```bash
# LazyVim configuration is in neovim/LazyVim/
# Symlink or copy to your neovim config directory
ln -sf ~/dotfiles/neovim/LazyVim ~/.config/nvim
```

#### VSCode
```bash
# Install extensions
~/dotfiles/vscode/extensions-installed.sh

# Symlink configurations (adjust paths for your OS)
ln -sf ~/dotfiles/vscode/settings.jsonc ~/.config/Code/User/settings.json
ln -sf ~/dotfiles/vscode/keybindings.jsonc ~/.config/Code/User/keybindings.json
```

#### Kitty Terminal
```bash
# Symlink kitty configuration
ln -sf ~/dotfiles/kitty ~/.config/kitty
```

## Configuration Structure

```
~/dotfiles/
├── neovim/           # Neovim configurations
│   ├── LazyVim/      # Main LazyVim setup
│   └── nvim/         # Alternative config
├── vscode/           # VSCode settings and extensions
├── kitty/            # Kitty terminal configuration
├── alacritty/        # Alacritty terminal configuration
├── apps/             # Desktop application configs
├── windows/          # Windows-specific configurations
├── devcontainers/    # Development container setup
├── legacy/           # Archived configurations
├── .gitconfig        # Git configuration
└── init.sh           # Main shell configuration (self-contained)
```

## Features

### Shell Configuration
- **Smart editor detection**: Automatically uses nvim > vim > vi > nano
- **Environment detection**: Automatically adapts to host vs container
- **Modular design**: Easy to extend and customize
- **Cross-platform**: Works on Linux and Windows WSL

### Git Configuration
- **Modern aliases**: Shortcuts for common operations
- **Better defaults**: Improved merge and diff settings
- **Credential helpers**: Secure credential management
- **Multi-environment**: Separate configs for work/personal

### Editor Integration
- **Consistent themes**: Coordinated color schemes across editors
- **Shared keybindings**: Similar shortcuts across different editors
- **Plugin management**: Automated plugin installation and updates

## Customization

### Local Overrides
Create `~/.local-shell` for local configurations that shouldn't be tracked:
```bash
# ~/.local-shell
export CUSTOM_VAR="value"
alias myalias="command"
```

### Environment Variables
Key environment variables for customization:
- `MCRA_INIT_SHELL`: Path to main init script
- `MCRA_LOCAL_SHELL`: Path to local shell configuration
- `MCRA_TMP_PLAYGROUND`: Path to temporary workspace

### Adding New Configurations
1. Create configuration files in appropriate directories
2. Update `init.sh` if shell integration is needed
3. Add installation instructions to this README

## Troubleshooting

### Common Issues

**Problem**: `init.sh` reports missing environment variables
**Solution**: Ensure all required environment variables are set:
```bash
export MCRA_INIT_SHELL="$HOME/dotfiles/init.sh"
export MCRA_LOCAL_SHELL="$HOME/.local-shell"
export MCRA_TMP_PLAYGROUND="/tmp/playground"
```

**Problem**: VSCode extensions not working
**Solution**: Run the extension installation script:
```bash
~/dotfiles/vscode/extensions-installed.sh
```

**Problem**: Neovim plugins not loading
**Solution**: Ensure LazyVim is properly linked and run `:Lazy sync` in Neovim

**Problem**: Git credentials not working
**Solution**: Check git credential helper configuration in `.gitconfig`

### Getting Help
- Check the configuration files for inline documentation
- Review the `legacy/` directory for historical configurations
- Open an issue if you find bugs or have suggestions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on different environments
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- LazyVim for the excellent Neovim configuration framework
- The dotfiles community for inspiration and best practices
- Contributors to the various tools and configurations used