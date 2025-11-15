# Shell History Configuration Verification

This document traces the complete flow of shell history configuration across the dotfiles setup to verify everything works correctly.

## ✅ Complete Flow Verification

### 1. **Container Starts** (devcontainer.json)

```jsonc
containerEnv: {
  "MCRA_HISTORY_DIR": "/home/node/.shell_histories",  ✅
  "WORKSPACE_FOLDER": "${containerWorkspaceFolder}"   ✅
}
mounts: [
  "OneDrive/shell_histories → /home/node/.shell_histories"  ✅
]
```

**What happens:**

- VS Code mounts your OneDrive history folder into the container
- Sets environment variables for the init script to use
- Workspace folder is automatically set by VS Code

### 2. **Shell Initializes** (init.sh sourced from .zshrc/.bashrc)

```bash
main() calls:
  1. detect_environment()     # Sets DOTFILES_IN_WSL, DOTFILES_IN_CONTAINER
  2. configure_history()      # Uses MCRA_HISTORY_DIR, WORKSPACE_FOLDER
  3. configure_zsh()          # Uses MCRA_HISTORY_BASE_DIR, MCRA_HISTORY_ID
  4. configure_bash()         # Uses MCRA_HISTORY_BASE_DIR, MCRA_HISTORY_ID
```

**What happens:**

- Shell sources `init.sh` on startup
- Functions run in order to set up the environment
- History is configured before shell-specific settings

### 3. **configure_history() Logic** ✅

```bash
Priority:
1. MCRA_HISTORY_DIR="/home/node/.shell_histories" (from container) ✅
2. OneDrive auto-detect (WSL only, when MCRA_HISTORY_DIR not set)
3. Fallback: $HOME/.shell_histories (if nothing else works)

Result:
- MCRA_HISTORY_BASE_DIR="/home/node/.shell_histories"
- MCRA_HISTORY_ID="dotfiles_automaton"
```

**What happens:**

- Checks for explicit `MCRA_HISTORY_DIR` first (set by devcontainer)
- In WSL, tries to auto-detect OneDrive location
- Falls back to local directory if nothing found
- Creates unique ID from workspace name + hostname
- Exports variables for shell-specific functions

### 4. **configure_zsh() Sets HISTFILE** ✅

```bash
if MCRA_HISTORY_BASE_DIR and MCRA_HISTORY_ID are set:
  HISTFILE="/home/node/.shell_histories/.zsh_history_dotfiles_automaton" ✅
else:
  HISTFILE="$HOME/.zsh_history" (backwards compatible)

HISTSIZE=1000000  ✅ (unlimited for practical purposes)
SAVEHIST=1000000  ✅

History options:
- SHARE_HISTORY          # Share between all sessions
- INC_APPEND_HISTORY     # Write immediately
- HIST_IGNORE_DUPS       # No consecutive duplicates
- HIST_IGNORE_ALL_DUPS   # Delete old duplicates
- HIST_FIND_NO_DUPS      # No duplicates in search
- HIST_IGNORE_SPACE      # Commands starting with space ignored
- HIST_SAVE_NO_DUPS      # No duplicates in file
- HIST_REDUCE_BLANKS     # Remove extra whitespace
```

**What happens:**

- If history variables are set, uses the synced location
- Otherwise falls back to default `~/.zsh_history`
- Sets generous history limits
- Enables advanced deduplication and sharing

### 5. **configure_bash() Sets HISTFILE** ✅

```bash
if MCRA_HISTORY_BASE_DIR and MCRA_HISTORY_ID are set:
  HISTFILE="/home/node/.shell_histories/.bash_history_dotfiles_automaton" ✅
# (Note: bash doesn't have an explicit else - keeps default HISTFILE if not set)

HISTSIZE=1000000      ✅ (unlimited for practical purposes)
HISTFILESIZE=1000000  ✅

History options:
- histappend                      # Append, don't overwrite
- HISTCONTROL=ignoredups:erasedups # No duplicates
- HISTTIMEFORMAT                  # Timestamps in history
```

**What happens:**

- If history variables are set, uses the synced location
- Sets generous history limits
- Enables deduplication

## ✅ Result: Everything is Correct!

**No issues found.** The complete chain works:

1. ✅ **Mount syncs OneDrive to container** - Files sync via cloud
2. ✅ **Environment variables set correctly** - Container gets proper config
3. ✅ **History directory detected properly** - Priority system works
4. ✅ **Unique ID includes workspace name** - Each project isolated: `dotfiles_automaton`, `my-app_automaton`
5. ✅ **Both shells use the shared location** - Zsh and bash both configured
6. ✅ **Unlimited history size (1M entries)** - Won't lose commands
7. ✅ **Falls back gracefully if mount missing** - Uses `~/.shell_histories` locally

## Expected History Files

Based on this configuration, you should see files like:

```
OneDrive/shell_histories/
├── .zsh_history_dotfiles_automaton
├── .zsh_history_my-app_automaton
├── .zsh_history_another-project_automaton
├── .bash_history_dotfiles_automaton
└── .zsh_history_LAPTOP-ABC123  (from WSL without workspace)
```

## Testing the Setup

Run these commands in a container to verify:

```bash
# Check environment variables
echo "MCRA_HISTORY_DIR: $MCRA_HISTORY_DIR"
echo "WORKSPACE_FOLDER: $WORKSPACE_FOLDER"
echo "MCRA_HISTORY_BASE_DIR: $MCRA_HISTORY_BASE_DIR"
echo "MCRA_HISTORY_ID: $MCRA_HISTORY_ID"
echo "HISTFILE: $HISTFILE"

# Check if mount is working
ls -la ~/.shell_histories

# Verify history is being written
history | tail -5
```

Expected output:

```
MCRA_HISTORY_DIR: /home/node/.shell_histories
WORKSPACE_FOLDER: /workspaces/dotfiles
MCRA_HISTORY_BASE_DIR: /home/node/.shell_histories
MCRA_HISTORY_ID: dotfiles_automaton
HISTFILE: /home/node/.shell_histories/.zsh_history_dotfiles_automaton
```

## Troubleshooting

If something doesn't work, check:

1. **Mount exists?** `ls -la ~/.shell_histories`
2. **Environment set?** `env | grep MCRA`
3. **File created?** `ls -la $HISTFILE`
4. **Commands saving?** Run a command, then `cat $HISTFILE | tail`

If OneDrive mount fails, it will fall back to `~/.shell_histories` (local only).
