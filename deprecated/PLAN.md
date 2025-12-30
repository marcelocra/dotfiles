# Refactoring Plan: Shared Shell Library

## Goal

Consolidate duplicated code between `shell/install.sh` and `shell/init.sh` into a shared library file, eliminating sync issues and following DRY principles.

---

## Current Problems

### 1. Out-of-Sync `detect_environment()` Functions

| Detection                   | `install.sh` | `init.sh` |
| --------------------------- | ------------ | --------- |
| `DOTFILES_IN_CONTAINER`     | ✅           | ✅        |
| `DOTFILES_IN_WSL`           | ✅           | ✅        |
| `DOTFILES_DISTRO`           | ❌           | ✅        |
| `DOTFILES_IN_BUNKER`        | ✅           | ❌        |
| `DOTFILES_IN_REMOTE_VSCODE` | ✅           | ❌        |
| `DOTFILES_IN_SSH`           | ✅           | ❌        |
| `DOTFILES_REMOTE_ENV`       | ✅           | ❌        |

### 2. Duplicated Utility Functions

Both files define identical versions of:

-   `command_exists()`
-   `log_debug()` (slightly different implementations)
-   `add_to_path()` (only in `init.sh`, but useful everywhere)

---

## Proposed Solution

### New File Structure

```
shell/
├── lib.bash           # NEW: Shared library (sourced by both)
├── install.sh         # One-time installation script
├── init.sh            # Shell initialization (sourced on every shell start)
└── ...
```

### What Goes in `lib.bash`

```bash
# shell/lib.bash - Shared utilities for dotfiles scripts
#
# This file is sourced by both install.sh (one-time setup) and
# init.sh (every shell start). Keep it lightweight and fast.

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

command_exists()    # Check if command is available
add_to_path()       # Add directory to PATH if not present
log_debug()         # Debug logging (when DOTFILES_DEBUG=1)

# =============================================================================
# ENVIRONMENT DETECTION
# =============================================================================

detect_environment()
    # Exports:
    #   DOTFILES_IN_CONTAINER   - Docker/Podman container
    #   DOTFILES_IN_WSL         - Windows Subsystem for Linux
    #   DOTFILES_IN_BUNKER      - DevBunker environment
    #   DOTFILES_IN_REMOTE_VSCODE - VS Code remote container
    #   DOTFILES_IN_SSH         - SSH session
    #   DOTFILES_REMOTE_ENV     - Derived: any remote environment
    #   DOTFILES_DISTRO         - alpine, ubuntu, opensuse, linux, unknown
```

---

## Implementation Steps

### Step 1: Fix `install.bash` Syntax Errors

**File:** `install.bash`

**Changes:**

-   Line 8: Add missing `=` after `DOTFILES_SKIP_VSCODE`
-   Line 9: Add missing `=` after `DOTFILES_SKIP_EDITOR_LAUNCHER`

---

### Step 2: Create `shell/lib.bash`

**File:** `shell/lib.bash` (NEW)

**Contents:**

1. **Header comment** explaining purpose and usage
2. **Guard against multiple sourcing** (optional, for safety)
3. **Utility functions:**
    - `command_exists()` - from both files (identical)
    - `add_to_path()` - from `init.sh`
    - `log_debug()` - unified implementation
4. **`detect_environment()` function:**
    - Merge both versions
    - Include all detections from `install.sh`
    - Include `DOTFILES_DISTRO` from `init.sh`
    - Export `DOTFILES_REMOTE_ENV` derived flag

**Important considerations:**

-   Keep this file lightweight (it runs on every shell start)
-   No external command calls that could slow down shell startup
-   Use built-in bash features where possible

---

### Step 3: Update `shell/install.sh`

**File:** `shell/install.sh`

**Changes:**

1. **Add source line near the top** (after configuration section):

    ```bash
    # Source shared library
    source "${DOTFILES_DIR}/shell/lib.bash"
    ```

2. **Remove duplicated functions:**

    - Remove `command_exists()` (now in lib.bash)
    - Remove `log_debug()` (now in lib.bash)
    - Remove `detect_environment()` (now in lib.bash)

3. **Keep install-specific functions:**
    - `log_info()`, `log_success()`, `log_warning()`, `log_error()` - only used during install
    - `format_duration()`, `timed()` - only used during install
    - `safe_symlink()` - only used during install
    - All `install_*` and `setup_*` functions

---

### Step 4: Update `shell/init.sh`

**File:** `shell/init.sh`

**Changes:**

1. **Determine DOTFILES_DIR early** (before sourcing lib.bash):

    ```bash
    # Determine dotfiles location (needed to source lib.bash)
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/x/dotfiles}"
    ```

2. **Add source line near the top:**

    ```bash
    # Source shared library
    source "${DOTFILES_DIR}/shell/lib.bash"
    ```

3. **Remove duplicated functions:**

    - Remove `command_exists()` (now in lib.bash)
    - Remove `add_to_path()` (now in lib.bash)
    - Remove `log_debug()` (now in lib.bash)
    - Remove `detect_environment()` (now in lib.bash)

4. **Keep init-specific functions:**
    - All `configure_*` functions
    - All aliases and shell functions
    - History configuration

---

### Step 5: Test the Changes

**Test scenarios:**

1. **Fresh install simulation:**

    ```bash
    # In a container or SSH session
    export DOTFILES_DEBUG=1
    ./install.bash
    # Verify: all environment flags are correctly detected
    ```

2. **Shell initialization:**

    ```bash
    # Start a new shell
    zsh
    # Verify: environment detection works
    echo $DOTFILES_REMOTE_ENV
    echo $DOTFILES_DISTRO
    ```

3. **Git signing in remote environment:**
    ```bash
    # In SSH session
    git commit -m "test"
    # Verify: uses ssh-keygen shim, not 1Password binary
    ```

---

## File Changes Summary

| File               | Action | Description                                                 |
| ------------------ | ------ | ----------------------------------------------------------- |
| `install.bash`     | MODIFY | Fix syntax errors on lines 8-9                              |
| `shell/lib.bash`   | CREATE | New shared library with utilities and environment detection |
| `shell/install.sh` | MODIFY | Source lib.bash, remove duplicated code                     |
| `shell/init.sh`    | MODIFY | Source lib.bash, remove duplicated code                     |

---

## Benefits

1. **Single source of truth** - Environment detection logic in one place
2. **No sync issues** - Updates to detection automatically apply everywhere
3. **Easier maintenance** - Utility functions consolidated
4. **Extensible** - Easy to add new environment detections later
5. **Testable** - Can source lib.bash independently for testing

---

## Risks and Mitigations

| Risk                   | Mitigation                                     |
| ---------------------- | ---------------------------------------------- |
| Breaking shell startup | Test thoroughly before committing              |
| Slow shell startup     | Keep lib.bash minimal, avoid external commands |
| Circular sourcing      | Add source guard in lib.bash                   |
| Missing DOTFILES_DIR   | Set default before sourcing lib.bash           |
