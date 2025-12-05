# Shell History Sync Setup

This setup shares shell history across Windows, WSL, and all devcontainers using OneDrive/Google Drive.

## How It Works

1. **OneDrive/Google Drive** syncs the history folder across devices
2. **init.bash** automatically detects and uses the synced folder
3. **Each environment** gets its own history file (prevents corruption)
4. **Files are named by workspace + hostname** (e.g., `dotfiles_automaton`)
5. **All histories** are in one place for easy searching
6. **Unlimited history** - 1 million entries (practically unlimited)

## Setup Instructions

### 1. Create History Folder on Windows

Choose **one** of these options:

#### Option A: OneDrive (Recommended)

```powershell
# Create the folder
mkdir "$env:USERPROFILE\OneDrive\shell_histories"
```

#### Option B: Google Drive

```powershell
# Create the folder (adjust path if needed)
mkdir "$env:USERPROFILE\Google Drive\shell_histories"
```

### 2. Configure for Google Drive (if using)

If you're using Google Drive instead of OneDrive, update `.devcontainer/devcontainer.json`:

```jsonc
// Change this line:
"source=${localEnv:HOME}${localEnv:USERPROFILE}/OneDrive/shell_histories,target=/home/node/.shell_histories,type=bind,consistency=cached"

// To this:
"source=${localEnv:HOME}${localEnv:USERPROFILE}/Google Drive/shell_histories,target=/home/node/.shell_histories,type=bind,consistency=cached"
```

No changes needed to `init.bash` - it will automatically use the mounted directory.

### 3. Configure WSL (Optional but Recommended)

Add to your `~/.zshrc` or `~/.bashrc` in WSL:

```bash
# Point to synced history folder
export MCRA_HISTORY_DIR="/mnt/c/Users/YourWindowsUsername/OneDrive/shell_histories"
```

Replace `YourWindowsUsername` with your actual Windows username.

### 4. Test It

1. **In WSL**: Open a terminal, run some commands
2. **In a container**: Rebuild your devcontainer, run some commands
3. **Check the folder**: You should see files like:
   - `.zsh_history_YOUR-HOSTNAME` (from WSL/local machine)
   - `.zsh_history_dotfiles_automaton` (from dotfiles container)
   - `.zsh_history_my-app_automaton` (from my-app container)

## File Structure

```
OneDrive/
└── shell_histories/
    ├── .zsh_history_DESKTOP-ABC123           # Your Windows/WSL machine
    ├── .zsh_history_dotfiles_automaton       # dotfiles devcontainer
    ├── .zsh_history_my-app_automaton         # my-app devcontainer
    ├── .bash_history_project-x_automaton     # Another project using bash
    └── ...
```

**Naming pattern**: `.{shell}_history_{workspace}_{hostname}`

- `{shell}`: `zsh` or `bash`
- `{workspace}`: Name of the project/workspace (only in containers with `WORKSPACE_FOLDER`)
- `{hostname}`: Machine hostname (e.g., `automaton`, `LAPTOP-XYZ`)

## Searching Across All Histories

```bash
# Search all zsh histories
grep -h "docker" ~/OneDrive/shell_histories/.zsh_history_* | sort -u

# Count unique commands across all shells
cat ~/OneDrive/shell_histories/.zsh_history_* | sort -u | wc -l

# Most used commands across all environments
cat ~/OneDrive/shell_histories/.zsh_history_* | cut -d';' -f2 | sort | uniq -c | sort -rn | head -20
```

## How It Actually Works

### Priority Order

The system checks for history directory in this order:

1. **`MCRA_HISTORY_DIR` environment variable** (highest priority)

   - Set in devcontainer: `/home/node/.shell_histories` (mounted from OneDrive)
   - Can be manually set in WSL: `export MCRA_HISTORY_DIR="/mnt/c/Users/YourUser/OneDrive/shell_histories"`

2. **OneDrive auto-detection** (WSL only, when `MCRA_HISTORY_DIR` not set)

   - Looks for: `/mnt/c/Users/{username}/OneDrive/shell_histories`
   - Or: `/mnt/c/Users/{username}/OneDrive - Personal/shell_histories`

3. **Local fallback**: `~/.shell_histories`

### Unique Identifiers

Each shell instance gets a unique ID:

- **With workspace**: `{workspace-name}_{hostname}`
- **Without workspace**: `{hostname}`

Example: In dotfiles container on automaton → `dotfiles_automaton`

## Troubleshooting

### History not syncing in containers

Check if the mount is working:

```bash
ls -la ~/.shell_histories
echo $MCRA_HISTORY_DIR
echo $MCRA_HISTORY_BASE_DIR
echo $MCRA_HISTORY_ID
echo $HISTFILE
```

### OneDrive path different

Your OneDrive might be at a different location. Check with:

```powershell
# On Windows
echo $env:OneDrive

# On WSL
ls -la /mnt/c/Users/$USER/OneDrive*
```

Update the mount path in `devcontainer.json` accordingly.

### Want to use a different folder

Set `MCRA_HISTORY_DIR` environment variable to any path:

```bash
# In ~/.zshrc or ~/.bashrc
export MCRA_HISTORY_DIR="$HOME/my-custom-history-folder"
```

## Configuration Details

### History Size

- **1,000,000 entries** (practically unlimited)
- Same for all environments (zsh and bash)
- No difference between synced and local

### Shell-Specific Settings

**Zsh options:**

- `SHARE_HISTORY` - Share between all sessions
- `INC_APPEND_HISTORY` - Write immediately
- `HIST_IGNORE_DUPS` - No consecutive duplicates
- `HIST_IGNORE_ALL_DUPS` - Delete old duplicates
- `HIST_FIND_NO_DUPS` - No duplicates in search
- `HIST_IGNORE_SPACE` - Commands starting with space ignored
- `HIST_SAVE_NO_DUPS` - No duplicates in file
- `HIST_REDUCE_BLANKS` - Remove extra whitespace

**Bash options:**

- `histappend` - Append, don't overwrite
- `HISTCONTROL=ignoredups:erasedups` - No duplicates
- `HISTTIMEFORMAT` - Timestamps in history

## Security Notes

✅ **Safe for public repo**: The configuration code
❌ **Keep private**: The actual history files (add to `.gitignore`)

Add to your global `.gitignore`:

```
.zsh_history*
.bash_history*
.shell_histories/
```

## Advanced: Merge Histories

To merge all histories into one file:

```bash
# Backup first!
cp -r ~/OneDrive/shell_histories ~/shell_histories_backup

# Merge all zsh histories
cat ~/OneDrive/shell_histories/.zsh_history_* | sort -u > ~/.zsh_history_merged
```
