# AI Context - Dotfiles Project

## Project Status (Updated 2025-07-29)

⚠️ **MAJOR REFACTORING COMPLETED** - This project has undergone significant restructuring:

- **OLD SYSTEM**: Files moved to `deprecated/` directory
- **NEW SYSTEM**: Consolidated configuration in `shell/main.sh`
- **MIGRATION**: Google Shell Style Guide compliant implementation

## Current Project Structure

### Active Configuration Files:

1. **Shell System (NEW):**

   - `shell/main.sh` - **PRIMARY** shell configuration (Google Style Guide compliant)
   - `shell/amuse-datetime.zsh-theme` - Custom zsh theme

2. **Core Editors:**

   - `nvim/` - LazyVim-based Neovim configuration
   - `vscode/` - VSCode settings, keybindings, snippets, extensions
   - `zed/` - Zed editor configuration

3. **System Configuration:**

   - `git/.gitconfig` - Git configuration
   - `tmux/.tmux.config` - Tmux configuration

4. **Deprecated/Legacy:**
   - `deprecated/` - **ALL OLD FILES** moved here for reference during migration
   - Contains former `init.sh`, `common.sh`, old configs, and legacy implementations

### Migration Summary:

**COMPLETED REFACTORING:**

- ✅ Shell configuration consolidated to `shell/main.sh`
- ✅ Multi-platform support (Ubuntu, Alpine, openSUSE)
- ✅ Google Shell Style Guide compliance
- ✅ Environment detection (container, WSL, distribution)
- ✅ Modular function organization with clear naming
- ✅ Enhanced error handling and safety checks

**DEPRECATED FILES:**

- `init.sh` → Merged into `shell/main.sh`
- `common.sh` → Functions extracted to `shell/main.sh`
- Old configs → Moved to `deprecated/` for reference

### Current System Features:

**Multi-Platform Support:**

- Ubuntu containers and host systems
- Alpine containers (lightweight, doas support)
- openSUSE Tumbleweed support
- Windows WSL detection and adaptation
- Container vs host environment detection

**Organized Configuration:**

- System aliases (navigation, file operations, package management)
- Development aliases (pnpm, node, python, git)
- Utility functions (tmux, archives, media processing)
- Editor configuration (nvim, code detection and setup)
- Environment-specific adaptations

## How to Use This System

### Primary Configuration File:

```bash
# Source the main shell configuration
source ~/dotfiles/shell/main.sh
```

### Key Features:

**Environment Detection:**

- Automatically detects container vs host environment
- WSL detection and adaptation
- Distribution-specific handling (Ubuntu, Alpine, openSUSE)

**Modular Organization:**

- System aliases (navigation, file operations)
- Development aliases (git, pnpm, node, python)
- Utility functions (tmux, media processing, code analysis)
- Platform-specific adaptations

**Google Shell Style Guide Compliance:**

- Proper error handling with `set -euo pipefail`
- Function naming with underscores
- Clear section organization
- Comprehensive documentation

### Migration Notes:

**If You Need Old Functionality:**

1. Check if it exists in new `shell/main.sh`
2. Look in the TODO section for extracted functions
3. Reference `deprecated/` files temporarily
4. Always migrate to new system instead of using deprecated files

**Deprecated Files Will Be Removed When:**

- All dependencies identified and migrated
- New configuration tested across environments
- No functionality regressions for 30+ days

## Current Usage

**Add to your shell profile (.bashrc, .zshrc):**

```bash
# Add this to your shell configuration
source "$HOME/dotfiles/shell/main.sh"
```

**Available Aliases & Functions:**

- **Git**: 50+ aliases (gs, gaa, gc, gco, gl, etc.)
- **Development**: pnpm shortcuts (p, r, rf), Node utilities
- **System**: Navigation (l, ll, cls), search tools (g for ripgrep/grep)
- **Utilities**: tmux wrapper (t), timer functions (t5, t15, t30, t60)
- **Python**: venv activation (va), project initialization

**Debug Mode:**

```bash
export DOTFILES_DEBUG=1
source ~/dotfiles/shell/main.sh
```

## Recent Git Status Summary

Based on the git status, the project shows extensive refactoring with:

- Most old files moved to `deprecated/` directory (marked with 'R' - renamed/moved)
- New structure with `shell/main.sh`, `nvim/`, `git/`, `tmux/` directories
- Many files deleted (marked with 'D') as part of cleanup
- New files added (marked with 'A') for the refactored system

This represents a complete modernization and consolidation of the dotfiles project into a more maintainable and cross-platform compatible system.

## Important Commit Information

**This commit represents a major refactoring milestone:**

- **Scope**: Complete restructuring of dotfiles project
- **Breaking Changes**: Yes - old file locations have changed
- **Migration Required**: Users need to source `shell/main.sh` instead of `init.sh`
- **Backward Compatibility**: Deprecated files preserved in `deprecated/` directory
- **License**: Added Apache 2.0 license

**Post-commit actions needed:**

1. Update shell profiles to source new `shell/main.sh`
2. Test configuration across different environments
3. Monitor for any missing functionality from old system
4. Schedule removal of `deprecated/` directory after 30+ days of stable operation
