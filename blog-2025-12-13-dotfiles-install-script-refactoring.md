# Blog: Refactoring Dotfiles Install Scripts - From Scattered Scripts to Unified Setup

## Outline

### The Problem: Script Proliferation

- **The situation**: Multiple standalone scripts doing similar things
  - `shell/install.sh` - main installation script
  - `git/setup-shims.sh` - 1Password SSH signing shim setup
  - `shell/ssh-1password-config-install.sh` - SSH config for 1Password
  - Platform-specific gitconfig files (`.gitconfig.wsl2.gitconfig`, `.gitconfig.windows.gitconfig`)
- **The pain**: Running multiple scripts, remembering which to run where
- **Goal**: Single idempotent script that handles everything

### Integration Strategy

- **Analyze existing structure**: Understand patterns already in use
- **Identify common operations**: Symlink creation, backup logic, environment detection
- **Preserve skip flags**: Maintain granular control via environment variables
- **Eliminate platform-specific files**: Use shims instead of hardcoded paths

### Key Refactoring: The `safe_symlink()` Helper

- **Problem**: Same backup-and-symlink logic repeated in 6+ places
- **Pattern recognized**:
  1. Check if source exists
  2. Ensure target directory exists
  3. If symlink already pointing to correct source, skip
  4. If file exists, back it up with timestamp
  5. Create new symlink
- **Solution**: Extract to reusable function used everywhere
- **Usage**: tmux.conf, VS Code settings/keybindings/snippets, editor launcher, git shims, SSH config

```bash
# Creates a symlink, backing up any existing file with a timestamp.
# Returns 0 if symlink was created or already correct, 1 if source doesn't exist.
safe_symlink() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        log_warning "⚠️  Source not found: $source"
        return 1
    fi

    mkdir -p "$(dirname "$target")"

    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
            log_debug "Symlink already correct: $target -> $source"
            return 0
        fi
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local backup="${target}.bak.${timestamp}"
        log_info "📦 Backing up existing file to: $backup"
        mv "$target" "$backup"
    fi

    ln -s "$source" "$target"
    return 0
}
```

### Applying `safe_symlink()` Consistently

After extraction, we applied it to all symlink operations:

```bash
# Before: Inconsistent patterns, some with backup, some without
ln -sf "$settings_file" "$vscode_dir/settings.json"
ln -sf "$DOTFILES_DIR/shell/.tmux.conf" "$HOME/.tmux.conf"

# After: Consistent, safe, with automatic backup
safe_symlink "$DOTFILES_DIR/apps/vscode/User/settings.json" "$vscode_dir/settings.json"
safe_symlink "$DOTFILES_DIR/shell/.tmux.conf" "$HOME/.tmux.conf"
safe_symlink "$source_binary" "$shim_path"
```

### Eliminating Platform-Specific Git Configs

- **Before**: Separate `.gitconfig.wsl2.gitconfig` and `.gitconfig.windows.gitconfig` with hardcoded paths
- **Problem**: Hardcoded usernames (`/mnt/c/Users/marce/...`) break on different machines
- **Solution**: Use a shim (`op-signer`) that the install script creates dynamically

```bash
# In .gitconfig - works everywhere
[gpg "ssh"]
    program = op-signer

# The install script creates ~/bin/op-signer -> actual 1Password binary
# dynamically detecting the platform and username
```

### Environment Detection Patterns

- **Container detection**: `/.dockerenv`, `$CONTAINER`, `/run/.containerenv`
- **WSL detection**: `grep Microsoft /proc/version`
- **Platform detection**: `uname -s` with case matching

```bash
detect_platform() {
    local kernel=$(uname -s)
    case "$kernel" in
        Linux*)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        Darwin*) echo "macos" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}
```

### Dynamic Binary Resolution

- **Challenge**: 1Password installs to different paths on each platform
- **Solution**: Function that resolves path based on detected platform

| Platform | Path                                                                               |
| -------- | ---------------------------------------------------------------------------------- |
| Linux    | `/opt/1Password/op-ssh-sign`                                                       |
| macOS    | `/Applications/1Password.app/Contents/MacOS/op-ssh-sign`                           |
| WSL      | `/mnt/c/Users/${win_user}/AppData/Local/Microsoft/WindowsApps/op-ssh-sign-wsl.exe` |
| Windows  | `${USERPROFILE}/AppData/Local/Microsoft/WindowsApps/op-ssh-sign.exe`               |

### Skip Flags for Granular Control

- Each feature can be independently disabled
- Useful for containers (skip 1Password), CI/CD, or partial setups

```bash
DOTFILES_SKIP_HOMEBREW=true         # Skip Homebrew installation
DOTFILES_SKIP_CLI_TOOLS=true        # Skip CLI tools
DOTFILES_SKIP_ZSH_PLUGINS=true      # Skip zsh plugins
DOTFILES_SKIP_VSCODE=true           # Skip VS Code config
DOTFILES_SKIP_EDITOR_LAUNCHER=true  # Skip 'e' command
DOTFILES_SKIP_GIT_SHIMS=true        # Skip 1Password git shims
DOTFILES_SKIP_SSH_CONFIG=true       # Skip SSH config
```

### Automatic Context-Aware Skipping

- Some features should never run in certain environments
- Git shims and SSH config auto-skip in containers
- SSH config auto-skips in WSL (uses Windows 1Password agent)

```bash
# Skip in containers - 1Password isn't typically available
if [[ "$DOTFILES_IN_CONTAINER" == "true" ]]; then
    log_info "⏭️  Skipping git shims setup (running in container)"
    return 0
fi
```

## Key Technical Patterns

### Idempotency Through Symlink Checking

```bash
# Check if already correctly configured before doing work
if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
    log_info "✅ Already set up correctly"
    return 0
fi
```

### Timestamp-Based Backups

```bash
# Never lose existing configuration
local timestamp=$(date +"%Y%m%d_%H%M%S")
local backup="${target}.bak.${timestamp}"
mv "$target" "$backup"
```

### WSL Username Detection

```bash
# Dynamically get Windows username in WSL
local win_user=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
```

## Lessons Learned

1. **Extract common patterns**: When you see the same logic 3+ times, make it a function
2. **Shims beat hardcoded paths**: Platform-specific symlinks eliminate config file sprawl
3. **Dynamic detection over static config**: Detect platform at runtime, not config time
4. **Idempotency is essential**: Scripts should be safe to run multiple times
5. **Graceful degradation**: Missing dependencies should warn, not fail
6. **Context-aware defaults**: Auto-skip features that don't make sense in current environment

## Files Eliminated

After refactoring, these files became redundant:

- `git/setup-shims.sh` → integrated into install.sh
- `shell/ssh-1password-config-install.sh` → integrated into install.sh
- `git/.gitconfig.windows.gitconfig` → replaced by op-signer shim
- `git/.gitconfig.wsl2.gitconfig` → replaced by op-signer shim
- `git/.gitconfig.linux.gitconfig` → no longer needed
- `git/.gitconfig.unix.gitconfig` → no longer needed

## Target Audience

- Developers managing dotfiles across multiple platforms
- Anyone using 1Password for SSH/Git signing
- DevOps engineers building portable development environments
- Teams standardizing development setups across Windows, macOS, and Linux
