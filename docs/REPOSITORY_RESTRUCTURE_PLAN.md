# Dotfiles Repository Restructure Plan

**Created:** January 2026  
**Status:** Draft (v2 - refined based on feedback)  
**Author:** AI Analysis

## Executive Summary

This document outlines a plan to restructure the dotfiles repository to align with modern best practices (Jan 2026), improve maintainability, and provide clearer organization while maintaining backward compatibility.

## Current State Analysis

### Directory Overview

| Directory | Current Purpose | Issues |
|-----------|-----------------|--------|
| `setup/` | Installation scripts | ✅ Well organized |
| `shell/` | Shell config + AI tools + SSH + misc | ⚠️ Overloaded with unrelated files |
| `cli/` | nvim/wezterm configs + AI dev scripts | ⚠️ Mixed concerns |
| `git/` | .gitconfig only | ⚠️ Isolated, could consolidate |
| `pwsh/` | PowerShell scripts | ⚠️ Platform-specific, unclear grouping |
| `apps/` | Application configs | ✅ Well organized |
| `tests/` | Docker tests | ⚠️ Minimal, needs expansion |
| `docs/adr/` | Architecture decisions | ✅ Well maintained |
| `deprecated/` | Legacy files | ⚠️ Needs cleanup |

### Key Problems

1. **`shell/` is overloaded** - Contains:
   - Shell initialization (`init.sh`, `marcelocra.zsh-theme`)
   - AI tool configs (`aider.conf.yml`, `opencode.json`, `.continue.config.yaml`)
   - SSH configs (`ssh_config`, `ssh-1password.config`)
   - Misc tools (`e`, `.curlrc`, `tmux.conf`)
   - Archive (`x-archives.bash`)

2. **`cli/` has mixed concerns**:
   - App configs (`nvim/`, `wezterm/`) - should be with other apps
   - Dev scripts (`to-review/`) - likely deprecated, needs review

3. **Platform configs scattered**:
   - `pwsh/` for Windows
   - `shell/` for Linux
   - No clear cross-platform organization

4. **XDG compliance incomplete** - ADR-0010 established `~/.config/dotfiles/` but config files don't mirror XDG structure.

---

## Naming Philosophy

A dotfiles repository is almost entirely configs. Using `config/` as a directory name is too generic and creates confusion with `apps/` (which also contains configs).

**Chosen approach:**
- **`apps/`** - Application-specific configs (editors, terminals, desktop apps)
- **`xdg/`** - Simple tool configs that symlink to `~/.config/` (XDG Base Directory)
- **`shell/`** - Shell initialization only (not tool configs)
- **`home/`** - Files that symlink directly to `~/` (`.gitconfig`, `.curlrc`, etc.)

This creates clear intent: `apps/` has complex app setups, `xdg/` mirrors `~/.config/`, `home/` mirrors `~/`.

---

## Proposed Structure (Recommended)

```
dotfiles/
├── apps/                         # Application configs (complex, with installers)
│   ├── alacritty/
│   ├── ghostty/
│   ├── kitty/
│   ├── nvim/                     # ← Moved from cli/
│   ├── sublime-text/
│   ├── vscode-like/              # Keep structure (shared/, cursor/, vscode/)
│   │   ├── shared/               # Snippets, tasks shared between editors
│   │   ├── cursor/
│   │   ├── vscode/
│   │   └── install.bash
│   ├── wezterm/                  # ← Moved from cli/
│   ├── zed/
│   └── [desktop apps with .desktop files...]
│
├── xdg/                          # Tool configs → ~/.config/
│   ├── aider/
│   │   └── aider.conf.yml        # ← From shell/
│   ├── continue/
│   │   └── config.yaml           # ← From shell/.continue.config.yaml
│   ├── git/
│   │   ├── config                # ← From git/.gitconfig (renamed)
│   │   └── hooks/
│   │       └── pre-commit        # ← From git/hooks/
│   ├── opencode/
│   │   └── opencode.json         # ← From shell/
│   ├── ssh/
│   │   ├── config                # ← From shell/ssh_config
│   │   └── config.d/
│   │       └── 1password         # ← From shell/ssh-1password.config
│   └── tmux/
│       └── tmux.conf             # ← From shell/tmux.conf
│
├── home/                         # Files → ~/ (dotfiles in home dir)
│   └── .curlrc                   # ← From shell/.curlrc
│
├── shell/                        # Shell initialization ONLY
│   ├── init.sh                   # Main shell init (sourced by .zshrc/.bashrc)
│   ├── x-functions.sh            # Extra functions
│   ├── marcelocra.zsh-theme      # Custom prompt theme
│   └── e                         # Editor launcher command
│
├── setup/                        # Installation & symlink wiring
│   ├── install.bash              # Main installer (includes symlink creation)
│   ├── devcontainer-setup.sh
│   └── common.bash               # Shared utilities (if needed)
│
├── platform/                     # Platform-specific configs
│   └── windows/
│       ├── pwsh/                 # ← Moved from root pwsh/
│       │   └── Microsoft.PowerShell_profile.ps1
│       └── toggle-mic/           # ← Moved from root pwsh/
│
├── tests/                        # Testing
│   ├── docker-test.bash
│   ├── runner.bash
│   └── shellcheck.bash           # Lint all scripts
│
├── docs/
│   ├── adr/
│   └── to-review/
│
├── deprecated/                   # Legacy (review & clean)
│   └── cli-to-review/            # ← Move cli/to-review/ here if deprecated
│
├── AGENTS.md
├── CHANGELOG.md
├── LICENSE
├── PLAN.md
└── README.md
```

**Key decisions:**
- **No root `install.bash`** - `./setup/install.bash` is clear enough
- **No `scripts/` folder** - Setup scripts stay in `setup/`, deprecated scripts go to `deprecated/`
- **`vscode-like/` stays intact** - The shared/ structure works well
- **`git/` moves to `xdg/git/`** - Follows XDG pattern, `.gitconfig` → `~/.config/git/config`

---

## Symlink Management

**Location: `setup/install.bash`** (not `shell/init.sh`)

Symlinks are a one-time operation and belong in the installation script:

| Concern | `setup/install.bash` | `shell/init.sh` |
|---------|---------------------|-----------------|
| Runs | Once per machine | Every shell session |
| Purpose | Install, configure, create symlinks | Set env vars, aliases, PATH |
| Symlinks | ✅ Create here | ❌ Never here |

### Symlink Strategy

The installer will create symlinks in a dedicated function:

```bash
# In setup/install.bash
link_configs() {
    log_info "🔗 Creating configuration symlinks..."
    
    # XDG configs → ~/.config/
    safe_symlink "$DOTFILES_DIR/xdg/git/config" "$HOME/.config/git/config"
    safe_symlink "$DOTFILES_DIR/xdg/aider" "$HOME/.config/aider"
    safe_symlink "$DOTFILES_DIR/xdg/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
    safe_symlink "$DOTFILES_DIR/xdg/ssh/config" "$HOME/.ssh/config"
    # ...
    
    # Home directory dotfiles
    safe_symlink "$DOTFILES_DIR/home/.curlrc" "$HOME/.curlrc"
    
    # Legacy compatibility (optional)
    safe_symlink "$DOTFILES_DIR/xdg/git/config" "$HOME/.gitconfig"
}
```

**Note:** The existing `safe_symlink` function already handles backups and idempotency.

---

## Recommended Changes (Phased)

### Phase 1: Directory Restructure (Medium Risk)

Do this all at once to avoid multiple symlink rewiring:

1. **Create new directories:**
   ```bash
   mkdir -p xdg/{aider,continue,git/hooks,opencode,ssh/config.d,tmux}
   mkdir -p home
   mkdir -p platform/windows
   ```

2. **Move files:**
   ```bash
   # App configs
   mv cli/nvim apps/nvim
   mv cli/wezterm apps/wezterm
   
   # XDG configs (tool configs → ~/.config/)
   mv git/.gitconfig xdg/git/config
   mv git/hooks/pre-commit xdg/git/hooks/pre-commit
   mv shell/aider.conf.yml xdg/aider/aider.conf.yml
   mv shell/.continue.config.yaml xdg/continue/config.yaml
   mv shell/opencode.json xdg/opencode/opencode.json
   mv shell/ssh_config xdg/ssh/config
   mv shell/ssh-1password.config xdg/ssh/config.d/1password
   mv shell/tmux.conf xdg/tmux/tmux.conf
   
   # Home directory files
   mv shell/.curlrc home/.curlrc
   
   # Platform-specific
   mv pwsh platform/windows/pwsh
   
   # Deprecated
   mv cli/to-review deprecated/cli-to-review
   mv shell/x-archives.bash deprecated/x-archives.bash
   ```

3. **Clean up empty directories:**
   ```bash
   rmdir cli  # After moving nvim, wezterm, to-review
   rmdir git  # After moving .gitconfig and hooks
   ```

4. **Delete root install.bash wrapper:**
   ```bash
   rm install.bash
   ```

### Phase 2: Update Symlink Wiring (Medium Risk)

Update `setup/install.bash` to use new paths:

1. **Update `link_shell_configs()` function:**
   - Change git symlink: `$DOTFILES_DIR/xdg/git/config` → `$HOME/.gitconfig`
   - Or use XDG path: `$DOTFILES_DIR/xdg/git/config` → `$HOME/.config/git/config`

2. **Add new symlinks for XDG configs:**
   - aider, opencode, tmux, ssh configs

3. **Test on fresh container:**
   ```bash
   ./tests/docker-test.bash
   ```

### Phase 3: Testing & CI (Low Risk)

1. **Add shellcheck test:**
   ```bash
   # tests/shellcheck.bash
   find . -name "*.bash" -o -name "*.sh" | xargs shellcheck
   ```

2. **Enable GitHub Actions** (`.github/workflows/test.yml`)

### Phase 4: Documentation (Low Risk)

1. **Create comprehensive `README.md`**
2. **Update `AGENTS.md`** with new structure
3. **Create ADR-0012** documenting this restructure decision

### Phase 5: Cleanup (Low Risk)

1. **Review `deprecated/`** - delete confirmed obsolete files
2. **Review `apps/` desktop files** - are .desktop installers still needed?

---

## Complete File Movement Reference

| Current Location | New Location | Symlink Target |
|------------------|--------------|----------------|
| `git/.gitconfig` | `xdg/git/config` | `~/.gitconfig` or `~/.config/git/config` |
| `git/hooks/pre-commit` | `xdg/git/hooks/pre-commit` | (template, not symlinked) |
| `cli/nvim/` | `apps/nvim/` | `~/.config/nvim/` |
| `cli/wezterm/` | `apps/wezterm/` | `~/.config/wezterm/` |
| `cli/to-review/` | `deprecated/cli-to-review/` | (none - deprecated) |
| `shell/aider.conf.yml` | `xdg/aider/aider.conf.yml` | `~/.config/aider/` |
| `shell/.continue.config.yaml` | `xdg/continue/config.yaml` | `~/.config/continue/` |
| `shell/opencode.json` | `xdg/opencode/opencode.json` | `~/.config/opencode/` |
| `shell/ssh_config` | `xdg/ssh/config` | `~/.ssh/config` |
| `shell/ssh-1password.config` | `xdg/ssh/config.d/1password` | (included from ssh/config) |
| `shell/tmux.conf` | `xdg/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` or `~/.tmux.conf` |
| `shell/.curlrc` | `home/.curlrc` | `~/.curlrc` |
| `shell/x-archives.bash` | `deprecated/x-archives.bash` | (none - archive) |
| `pwsh/` | `platform/windows/pwsh/` | (Windows only) |
| `install.bash` (root) | (deleted) | - |

**Files that stay in `shell/`:**
- `init.sh` - Shell initialization
- `marcelocra.zsh-theme` - Prompt theme
- `e` - Editor launcher
- `x-functions.sh` - Extra shell functions (if exists)
- `install.sh` - Keep as stub/warning

---

## Migration Path

### For Existing Users

The restructure will be handled by re-running `setup/install.bash`:

1. **Pull latest changes**
2. **Run installer:** `./setup/install.bash`
3. **Installer will:**
   - Detect old symlinks (via `safe_symlink` backup mechanism)
   - Create new symlinks to new locations
   - Old symlinks get `.bak.TIMESTAMP` suffix

**No separate migration script needed** - the installer is already idempotent.

### For New Users

Just run `./setup/install.bash` - new structure is transparent.

---

## Backward Compatibility

### Preserve
- `./setup/install.bash` main installer
- `source ~/x/dotfiles/shell/init.sh` pattern (critical)
- `$DOTFILES_DIR` convention

### Remove
- `./install.bash` root wrapper (unnecessary indirection)

### Deprecate (with warnings)
- `./shell/install.sh` (already a stub)
- Old paths like `git/.gitconfig` (will be moved)

---

## Decision Matrix

| Change | Impact | Risk | Priority | Notes |
|--------|--------|------|----------|-------|
| Move nvim/wezterm to apps | Low | Low | High | Clear win |
| Move git to xdg/git | Low | Low | High | Clear win |
| Create xdg/ structure | Medium | Medium | High | Main change |
| Create home/ | Low | Low | High | Simple |
| Platform organization | Low | Low | Medium | Nice to have |
| Delete root install.bash | Low | Low | Medium | Cleanup |
| Deprecated cleanup | Low | Low | Low | Can do later |

---

## Open Questions (Resolved)

| Question | Decision |
|----------|----------|
| Stow vs Manual Symlinks? | **Manual** - avoid new dependency, current approach works |
| Keep `apps/` or merge with `config/`? | **Keep separate** - `apps/` for complex app configs, `xdg/` for simple tool configs |
| XDG Strict Compliance? | **Use `~/.config/` directly** - per ADR-0010 |
| Windows Support Priority? | **Low** - organize into `platform/windows/` but don't invest heavily |
| Symlink wiring location? | **`setup/install.bash`** - one-time operation, not shell init |

---

## Next Steps

1. ✅ **Review this plan** - confirm structure makes sense
2. **Create ADR-0012** for repository structure decision
3. **Execute Phase 1** - all file movements at once
4. **Execute Phase 2** - update symlink wiring in install.bash
5. **Test** on fresh container: `./tests/docker-test.bash`
6. **Document** changes in CHANGELOG.md

---

## References

- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [dotfiles.github.io](https://dotfiles.github.io/) - Community best practices
- Existing ADRs: 0001, 0002, 0010
