# 10. Standard Config Directory Location

Date: 2025-01-02

## Status

Accepted

## Context

Dotfiles scripts need to store user preferences and configuration data (e.g., editor preferences, tool settings). Previously, some scripts used paths like `~/.config/dotfiles-editor-preference` or referenced the dotfiles repository location (`~/x/dotfiles`).

This creates several issues:
- **Coupling to repository location**: Scripts that reference `~/x/dotfiles` break if the repository is cloned elsewhere
- **Inconsistent locations**: Different scripts use different config file paths
- **Non-standard**: Not following XDG Base Directory Specification conventions

The XDG Base Directory Specification defines `~/.config` as the standard location for user configuration files. Applications should create subdirectories under `~/.config/` for their specific config files.

## Decision

We will use `~/.config/dotfiles/` as the standard directory for all dotfiles-related configuration and preference files.

### Structure

```
~/.config/dotfiles/
├── editor-preference    # Preferred editor (cursor, code, etc.)
└── [future config files] # Other preferences as needed
```

### Implementation

- All scripts that need to store user preferences will use `~/.config/dotfiles/`
- The directory will be created automatically when needed
- Individual config files use descriptive names (e.g., `editor-preference`, not `editor`)
- Scripts should not reference `$DOTFILES_DIR` or `~/x/dotfiles` for config storage

### Rationale

| Aspect | `~/.config/dotfiles/` | `~/x/dotfiles/` or custom paths |
|--------|----------------------|--------------------------------|
| **Portability** | ✅ Works regardless of repo location | ❌ Breaks if repo moved |
| **Standard compliance** | ✅ Follows XDG spec | ❌ Custom location |
| **Consistency** | ✅ Single location for all configs | ❌ Scattered across locations |
| **Separation of concerns** | ✅ Config separate from code | ❌ Mixes config with source |
| **Backup** | ✅ Easy to backup entire `.config/` | ❌ Need to find custom paths |

## Alternatives Considered

### 1. Use `$DOTFILES_DIR/.config/`
- **Pros**: Keeps config with repository
- **Cons**: Breaks if repository is moved or renamed; couples config to repo location

### 2. Use `~/.dotfiles/` (hidden directory in home)
- **Pros**: Simple, visible in home directory
- **Cons**: Not following XDG spec; clutters home directory

### 3. Use `$XDG_CONFIG_HOME/dotfiles/` (respect XDG env var)
- **Pros**: Fully XDG-compliant
- **Cons**: More complex (need to check env var, fallback to `~/.config`)
- **Decision**: We use `~/.config/dotfiles/` directly, which is the default XDG location. If users have `XDG_CONFIG_HOME` set, they can symlink or adjust as needed.

### 4. Use individual files in `~/.config/` (e.g., `~/.config/dotfiles-editor-preference`)
- **Pros**: Flat structure, no directory needed
- **Cons**: Clutters `~/.config/` root; harder to organize multiple config files

## Consequences

### Positive
- ✅ Config location is independent of repository location
- ✅ Follows standard XDG conventions
- ✅ Easy to find and backup all dotfiles configs
- ✅ Consistent location across all scripts
- ✅ Can add more config files without cluttering `~/.config/`

### Negative
- ⚠️ Need to migrate existing config files (if any) from old locations
- ⚠️ Slightly more verbose path (`~/.config/dotfiles/editor-preference` vs `~/.config/dotfiles-editor-preference`)

### Migration

Scripts should create the directory automatically when needed:
```bash
mkdir -p "$(dirname "$CONFIG_FILE")"
```

No manual migration needed for new installations. Existing users with old config locations will need to migrate manually if they have preferences set.


