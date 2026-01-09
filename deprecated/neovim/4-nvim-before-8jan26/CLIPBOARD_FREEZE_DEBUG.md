# Debugging Report: Neovim Freeze & Tmux Clipboard Issues

**Date:** January 8, 2026
**Project:** Dotfiles (Neovim/Tmux)
**System:** Linux VM, accessed via SSH

## Issue Description

1.  **Neovim Hang:** Neovim was freezing indefinitely (or flickering in a loop) on startup.
2.  **Clipboard Failure:** Copying text in Tmux or Neovim did not sync to the user's local machine clipboard reliably.
3.  **Terminal:** User is using **Ptyxis** (Fedora default) locally.

## Root Cause Analysis

1.  **Freeze (Primary Cause): Session Restoration Loop.**
    *   The user observed a "flickering grep modal" when interrupting the freeze.
    *   This indicates `persistence.nvim` (LazyVim's session manager) was attempting to restore a previous session that had an active interactive window (like Telescope or Snacks Picker) open.
    *   Restoring such a state, especially over SSH/Headless connections, caused a UI render loop/hang.
    *   **Fix:** Deleted the corrupt session file (`rm ~/.local/state/nvim/sessions/...`).

2.  **Freeze (Secondary Cause): Clipboard Probing.**
    *   Neovim's startup checks for `xclip` availability on Linux if `clipboard="unnamedplus"` is set before the provider is configured.
    *   **Fix:** Hardcoded OSC 52 provider in `options.lua` to prevent `xclip` detection.

3.  **Clipboard Sync (Ptyxis Quirk):**
    *   OSC 52 works, but `Ctrl+Shift+V` in Ptyxis pastes the *internal* selection, not the system clipboard updated by the remote session. `Ctrl+V` works correctly.

## Actions Taken

### 1. Neovim Configuration (`lua/config/options.lua`)
-   Hardcoded OSC 52 provider to bypass `xclip` detection.

### 2. Tmux Configuration (`~/.tmux.conf`)
-   Cleaned up `xclip`/Windows bindings.
-   Enabled `set-clipboard on` and `allow-passthrough on`.

### 3. Session Cleanup
-   **Deleted:** `~/.local/state/nvim/sessions/%home%$USER%.config%dotfiles.vim` to break the restoration loop.

## Conclusion & Recommendations

1.  **Terminal Recommendation:**
    *   **Ghostty:** Highly recommended for a "world-class," stable, modern experience with native OSC 52 support.
    *   **WezTerm:** Excellent alternative for power users.
    *   **Alacritty:** Best for raw speed/minimalism.

2.  **Ptyxis Note:** While it works, its clipboard handling (`Ctrl+V` vs `Ctrl+Shift+V`) is confusing for this workflow. Switching to Ghostty is recommended.

## Verification
1.  **Restart Neovim:** It should launch cleanly (no "restoring session" loop).
2.  **Test Clipboard:** Yank in Neovim -> Paste with `Ctrl+V` locally.