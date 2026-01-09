# Plan: Neovim Freeze & Clipboard Sync Solution

**Date:** January 8, 2026
**Project:** Dotfiles (Neovim/Tmux)
**Author:** AI Assistant

## Problem Summary

Based on the debugging report, there are two primary issues affecting the Neovim/Tmux setup:

1. **Neovim Freeze**: Caused by a session restoration loop in `persistence.nvim` when attempting to restore sessions with active interactive windows (Telescope/Snacks Picker).
2. **Clipboard Sync Issues**: Unreliable clipboard synchronization between Neovim/Tmux and the local machine, particularly with Ptyxis terminal's handling of `Ctrl+V` vs `Ctrl+Shift+V`.

## Approach

### 1. Neovim Session Management Solution

**Root Cause**: `persistence.nvim` attempts to restore sessions with interactive UI elements, causing a render loop when these elements can't be properly initialized in headless/SSH environments.

**Proposed Solution**:
- Modify session saving behavior to detect and exclude interactive windows
- Implement a "clean session" restoration mode for headless connections
- Add safeguards to prevent problematic session restores

**Implementation Steps**:
1. Review `persistence.nvim` configuration options
2. Add pre-session-save hook to close all interactive windows (Telescope, Snacks Pickers, etc.)
3. Implement detection of headless/SSH sessions to use a different restoration strategy
4. Add manual session management commands for safer session handling

### 2. Clipboard Synchronization Solution

**Root Cause**: Inconsistent clipboard handling between Neovim's OSC 52 implementation, Tmux clipboard configuration, and terminal-specific paste behaviors.

**Proposed Solution**:
- Standardize OSC 52 clipboard provider configuration
- Ensure Tmux properly passes clipboard data through
- Document terminal-specific behaviors and workarounds

**Implementation Steps**:
1. Verify OSC 52 provider is correctly hardcoded in Neovim configuration
2. Review and optimize Tmux clipboard settings (`set-clipboard on`, `allow-passthrough on`)
3. Add documentation about terminal compatibility and recommended paste methods
4. Implement fallback clipboard mechanisms for environments where OSC 52 isn't available

## Implementation Plan

### Phase 1: Neovim Session Handling
1. Modify `lua/plugins/persistence.lua` or equivalent configuration
2. Add pre-save hooks to close interactive windows
3. Implement SSH/headless detection for alternative session handling
4. Test session save/restore with various UI states

### Phase 2: Clipboard Configuration
1. Review and standardize `lua/config/options.lua` clipboard settings
2. Optimize `.tmux.conf` for reliable clipboard passthrough
3. Test clipboard functionality across different terminal emulators
4. Document terminal-specific behaviors and recommendations

### Phase 3: Documentation & User Guidance
1. Update README with terminal compatibility information
2. Add troubleshooting guide for clipboard issues
3. Document recommended terminal emulators (Ghostty, WezTerm)
4. Provide clear instructions for paste operations in different terminals

## Verification Steps

### Neovim Session Handling
- [ ] Start Neovim with no existing session (should not freeze)
- [ ] Start Neovim with a clean session (should restore properly)
- [ ] Open interactive windows (Telescope, etc.), then save session and restart (should not freeze)
- [ ] Test session restoration over SSH connection (should use headless mode)
- [ ] Verify manual session management commands work correctly

### Clipboard Synchronization
- [ ] Copy text in Neovim and paste with `Ctrl+V` locally (should work)
- [ ] Copy text in Tmux and paste with `Ctrl+V` locally (should work)
- [ ] Test clipboard functionality in different terminals (Ptyxis, Ghostty, WezTerm)
- [ ] Verify clipboard works over SSH connections
- [ ] Test fallback mechanisms when OSC 52 is not available

## Risk Mitigation

1. **Backup existing configurations** before making changes
2. **Test in isolated environment** first (VM/container)
3. **Implement gradual rollout** with option to revert to previous behavior
4. **Document all changes** for future troubleshooting
5. **Provide clear rollback instructions** if issues occur

## Success Criteria

1. Neovim starts reliably without freezing regardless of session state
2. Clipboard synchronization works consistently between Neovim/Tmux and local machine
3. Solution works across different terminal emulators with documented exceptions
4. No degradation in performance or functionality for normal use cases
5. Clear documentation exists for users to understand and troubleshoot the setup