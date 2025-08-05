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

**Shell Configuration Architecture:**

- Cross-shell compatibility (bash and zsh support)
- Conditional shell-specific features (oh-my-zsh integration for zsh)
- Interactive shell configuration (no strict error handling for compatibility)
- Function naming with underscores and clear section organization

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

## Shell Configuration Migration (Updated 2025-08-03)

**RECENT MIGRATION: Centralized Configuration + Oh-My-Zsh Integration**

✅ **Completed Migration:**

- **Centralized Configuration**: Moved from scattered Dockerfile shell setup to unified `main.sh`
- **Oh-my-zsh Integration**: Added oh-my-zsh support with Microsoft security-vetted installation
- **Symlink Architecture**: `main.sh` serves as both `.bashrc` and `.zshrc` via symlinks
- **Custom Theme Support**: `amuse-datetime.zsh-theme` integration with fallback
- **Interactive Shell Compatibility**: Removed strict error handling for oh-my-zsh compatibility

**Current Shell Architecture:**

- **Single Configuration**: `shell/main.sh` replaces scattered shell configuration
- **Cross-Shell Support**: Conditional bash and zsh feature configuration
- **Oh-My-Zsh Integration**: Custom theme symlinking with minimal security-focused plugins
- **Container Integration**: Works with Microsoft devcontainer Alpine base with pre-installed oh-my-zsh
- **Variable Compatibility**: Proper initialization for oh-my-zsh and VS Code shell integration

**Key Technical Decisions:**

- Removed `set -euo pipefail` for interactive shell compatibility with oh-my-zsh
- Maintained Google Shell Style Guide principles where compatible with interactive use
- Leveraged Microsoft's security-vetted oh-my-zsh installation rather than custom setup

**Container Usage:**
The centralized configuration now seamlessly integrates with devcontainer environments, providing consistent shell experience across both bash and zsh while leveraging Microsoft's pre-installed and security-reviewed oh-my-zsh.

## VS Code Git Credential Management (Updated 2025-08-05)

**Issue**: VS Code automatically adds container-specific credential helper lines to `.gitconfig` that are unsafe to commit to public repositories.

**Solution Implemented**: Three-layer prevention strategy:

1. **Global Credential Helper Configuration**:

   ```properties
   [credential]
       helper =
       helper = !/usr/bin/gh auth git-credential
   ```

   - Takes precedence over VS Code's automatic credential helper
   - Uses GitHub CLI for all authentication

2. **VS Code Settings** (`vscode/settings.jsonc`):

   ```jsonc
   "git.useIntegratedAskPass": false,
   "git.terminalAuthentication": false,
   ```

   - Tells VS Code not to manage git authentication
   - Lets git handle credentials with configured helpers

3. **Pre-commit Hook** (`git/hooks/pre-commit`):
   - Python script that detects VS Code credential helper lines
   - Fails commits with clear error message if detected
   - Prevents accidental commits of container-specific credentials
   - Symlinked to `.git/hooks/pre-commit` for git to find it

**Why This Matters**:

- VS Code credential helpers contain session-specific paths and IDs
- These lines change between containers/sessions and are not portable
- Committing them to public repositories exposes internal system information
- GitHub CLI provides secure, portable authentication

**Files Modified**:

- `git/.gitconfig` - Added global credential configuration
- `vscode/settings.jsonc` - Disabled VS Code git credential management
- `git/hooks/pre-commit` - Added safety check (executable Python script, symlinked to `.git/hooks/`)
