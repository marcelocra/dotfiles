# Dotfiles Repository Restructure Plan

**Created:** January 2026  
**Status:** Draft  
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
   - Dev scripts (`to-review/`) - utility scripts, not CLI apps

3. **Platform configs scattered**:
   - `pwsh/` for Windows
   - `shell/` for Linux
   - No clear cross-platform organization

4. **XDG compliance incomplete** - ADR-0010 established `~/.config/dotfiles/` but config files don't mirror XDG structure.

---

## Proposed Structure

### Option A: XDG-Centric Structure (Recommended)

Organize configs to mirror `~/.config/` structure, making symlinks straightforward.

```
dotfiles/
├── config/                      # XDG-style configs (symlink to ~/.config/)
│   ├── aider/
│   │   └── aider.conf.yml
│   ├── continue/
│   │   └── config.yaml
│   ├── curl/
│   │   └── .curlrc
│   ├── git/
│   │   ├── config                # Main .gitconfig
│   │   └── hooks/
│   │       └── pre-commit
│   ├── kitty/
│   │   └── kitty.conf
│   ├── nvim/                     # Moved from cli/
│   │   ├── init.lua
│   │   └── lua/...
│   ├── opencode/
│   │   └── opencode.json
│   ├── ssh/                      # SSH configs
│   │   ├── config
│   │   └── config.d/
│   │       └── 1password.config
│   ├── tmux/
│   │   └── tmux.conf
│   ├── wezterm/                  # Moved from cli/
│   │   └── wezterm.lua
│   └── zsh/                      # Shell theme/plugins
│       └── marcelocra.zsh-theme
│
├── shell/                        # Shell initialization (keep)
│   ├── init.sh                   # Main shell init
│   ├── x-functions.sh            # Extra functions
│   └── e                         # Editor launcher
│
├── setup/                        # Installation scripts (keep)
│   ├── install.bash              # Main installer
│   ├── devcontainer-setup.sh
│   └── common.bash               # Shared utilities
│
├── apps/                         # Desktop app configs (keep, add GUI apps)
│   ├── alacritty/
│   ├── cursor/                   # Move from vscode-like/
│   ├── vscode/                   # Move from vscode-like/
│   ├── kitty/                    # Keep (or move to config/)
│   └── zed/
│
├── scripts/                      # Utility scripts (new)
│   ├── ai-dev.sh                 # From cli/to-review/
│   ├── ai-dev.ps1
│   └── setup-*.sh
│
├── platform/                     # Platform-specific (new)
│   └── windows/
│       ├── pwsh/                 # Moved from root
│       │   └── Microsoft.PowerShell_profile.ps1
│       └── toggle-mic/
│
├── tests/                        # Testing (expand)
│   ├── docker-test.bash
│   ├── runner.bash
│   └── unit/                     # Add unit tests
│
├── docs/
│   ├── adr/
│   └── to-review/
│
├── AGENTS.md
├── CHANGELOG.md
├── install.bash                  # Root wrapper
├── LICENSE
├── PLAN.md
└── README.md                     # Add comprehensive README
```

### Option B: Minimal Restructure

Keep most structure, only fix obvious issues:

```
dotfiles/
├── apps/                         # Consolidate app configs
│   ├── git/                      # Moved from root git/
│   ├── nvim/                     # Moved from cli/
│   ├── wezterm/                  # Moved from cli/
│   └── ... (existing)
│
├── shell/                        # Clean up
│   ├── init.sh
│   ├── theme/
│   │   └── marcelocra.zsh-theme
│   └── e
│
├── config/                       # NEW: Tool configs
│   ├── aider.conf.yml
│   ├── opencode.json
│   ├── continue.config.yaml
│   ├── curlrc
│   ├── ssh/
│   │   ├── config
│   │   └── 1password.config
│   └── tmux.conf
│
├── scripts/                      # NEW: Utility scripts
│   └── (from cli/to-review/)
│
├── platform/
│   └── windows/                  # Moved from pwsh/
│
└── ... (rest stays same)
```

---

## Recommended Changes (Phased)

### Phase 1: Quick Wins (Low Risk)

1. **Move `cli/nvim/` → `apps/nvim/`**
   - Neovim is an app, should be with other apps
   - Update any references

2. **Move `cli/wezterm/` → `apps/wezterm/`**
   - Same reasoning

3. **Move `git/` → `apps/git/`**
   - Consistent with other app configs
   - Update `setup/install.bash` symlink path

4. **Move `cli/to-review/` → `scripts/`**
   - AI dev scripts are utility scripts, not CLI configs
   - Rename to more descriptive names

5. **Create `README.md`**
   - Comprehensive getting started guide
   - Link to AGENTS.md for AI context

### Phase 2: Shell Cleanup (Medium Risk)

1. **Create `config/` directory** for XDG-style configs:
   ```
   config/
   ├── aider/aider.conf.yml       # from shell/aider.conf.yml
   ├── continue/config.yaml       # from shell/.continue.config.yaml
   ├── curl/.curlrc               # from shell/.curlrc
   ├── opencode/opencode.json     # from shell/opencode.json
   ├── ssh/config                 # from shell/ssh_config
   ├── ssh/1password.config       # from shell/ssh-1password.config
   └── tmux/tmux.conf             # from shell/tmux.conf
   ```

2. **Update `setup/install.bash`**:
   - Update symlink paths
   - Consider using `stow` for symlink management

3. **Clean `shell/` directory**:
   - Keep only: `init.sh`, `x-functions.sh`, `e`, `marcelocra.zsh-theme`
   - Consider: `shell/themes/marcelocra.zsh-theme`

### Phase 3: Platform Organization (Medium Risk)

1. **Create `platform/windows/`**:
   - Move `pwsh/` → `platform/windows/pwsh/`
   - Keep Windows-specific configs together

2. **Consider `platform/linux/`**:
   - Or keep Linux as default (current implicit behavior)

### Phase 4: Testing & CI (Low Risk)

1. **Expand `tests/`**:
   ```
   tests/
   ├── docker-test.bash
   ├── runner.bash
   ├── test-install.bash          # Test installation
   ├── test-shell-init.bash       # Test shell initialization
   └── shellcheck.bash            # Lint all scripts
   ```

2. **Enable GitHub Actions**:
   - Update `.github/workflows/test.yml`
   - Add shellcheck/shfmt checks
   - Run Docker tests on PR

### Phase 5: Cleanup (Low Risk)

1. **Review `deprecated/`**:
   - Delete confirmed obsolete files
   - Move any still-useful files to active locations
   - Document what was deleted and why

2. **Archive `x-archives.bash`**:
   - Move to `deprecated/` or `docs/archives/`

---

## Symlink Strategy

### Current Approach
Manual symlinks in `setup/install.bash`:
```bash
safe_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
```

### Recommended Approach: GNU Stow Compatible

Organize configs so `stow` can manage symlinks:

```bash
# From dotfiles root:
stow -t ~ config    # Symlinks config/* to ~/.config/*
stow -t ~ shell     # Symlinks shell files to ~
```

This requires:
1. `config/git/config` → symlinks to `~/.config/git/config`
2. Directory structure mirrors target location

**Alternative**: Keep current manual approach but document it well.

---

## Migration Path

### For Existing Users

1. **Run migration script** (to be created):
   ```bash
   ./setup/migrate-v2.bash
   ```

2. **Script will**:
   - Backup existing symlinks
   - Create new symlinks
   - Report any issues

3. **Manual cleanup**:
   - Remove old symlinks if needed
   - Verify everything works

### For New Users

Just run `./setup/install.bash` - new structure is transparent.

---

## Backward Compatibility

### Preserve
- `./install.bash` wrapper at root
- `./setup/install.bash` main installer
- `source ~/x/dotfiles/shell/init.sh` pattern

### Deprecate (with warnings)
- `./shell/install.sh` (already a stub)
- Direct references to old paths

---

## Decision Matrix

| Change | Impact | Risk | Priority |
|--------|--------|------|----------|
| Move nvim/wezterm to apps | Low | Low | High |
| Move git to apps | Low | Low | High |
| Create scripts/ | Low | Low | High |
| Create config/ | Medium | Medium | Medium |
| Platform organization | Low | Low | Medium |
| Stow integration | Medium | Medium | Low |
| Deprecated cleanup | Low | Low | Low |

---

## Open Questions

1. **Stow vs Manual Symlinks?**
   - Stow is cleaner but adds dependency
   - Current manual approach works but is verbose

2. **Keep `apps/` or merge with `config/`?**
   - `apps/` has desktop app configs (VS Code, kitty themes)
   - `config/` would have CLI tool configs
   - Could merge all into `config/`

3. **XDG Strict Compliance?**
   - Should we respect `$XDG_CONFIG_HOME` env var?
   - Current: hardcoded `~/.config/`
   - ADR-0010 says: "users can symlink or adjust as needed"

4. **Windows Support Priority?**
   - How much effort for `pwsh/` organization?
   - Is cross-platform a priority?

---

## Next Steps

1. **Review this plan** and choose preferred option
2. **Create ADR-0012** for repository structure decision
3. **Implement Phase 1** (quick wins)
4. **Test** on fresh VM/container
5. **Document** changes in CHANGELOG.md

---

## References

- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [GNU Stow](https://www.gnu.org/software/stow/)
- [dotfiles.github.io](https://dotfiles.github.io/) - Community best practices
- Existing ADRs: 0001, 0002, 0010
