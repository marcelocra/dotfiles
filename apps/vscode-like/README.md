# VS Code-like Editor Configurations

This directory contains configurations for VS Code-compatible editors (VS Code, Cursor, Kiro, Antigravity).

## Structure

```
vscode-like/
├── shared/              # Files shared across all editors
│   ├── snippets/        # Code snippets (same for all editors)
│   ├── tasks.json       # Task definitions (same for all editors)
│   └── mcp.json         # MCP configuration (same for all editors)
├── vscode/              # VS Code-specific files
│   ├── settings.json    # VS Code settings
│   └── keybindings.json # VS Code keybindings
├── cursor/              # Cursor-specific files
│   ├── README.md        # Cursor configuration documentation
│   ├── settings.json    # Cursor settings (if different)
│   └── keybindings.json # Cursor keybindings
└── install.bash         # Installation script for all editors
```

## Installation

### Linux / macOS

```bash
./install.bash              # VSCode (default)
./install.bash --insiders   # VSCode Insiders
./install.bash --cursor     # Cursor
./install.bash --kiro       # Kiro
./install.bash --antigravity # Antigravity
```

### Remote VS Code (SSH/Containers)

The script automatically detects remote VS Code installations (`.vscode-server`, `.vscode-remote`) when running in SSH sessions or containers. You can also manually specify the path:

```bash
./install.bash --code --user-path "$HOME/.vscode-server/data/User"
```

### What Gets Installed

-   **Shared files**: `snippets/`, `tasks.json`, `mcp.json` (symlinked from `shared/`)
-   **Editor-specific files**: `settings.json`, `keybindings.json` (symlinked from editor folder)

## Editor-Specific Notes

### VS Code

-   Uses VS Code-specific extensions (GitHub Copilot, roo-cline, amp.\*)
-   Settings include VS Code chat/AI features

### Cursor

-   Uses Cursor's built-in AI (no extension checks needed)
-   Keybindings use `workbench.action.chat.openagent` directly
-   Settings exclude VS Code-only extensions
-   See [`cursor/README.md`](cursor/README.md) for detailed documentation on Cursor-specific configurations and removed VS Code settings

## Migration from `apps/vscode/`

If you're migrating from the old `apps/vscode/User/` structure:

1. The new structure separates shared vs editor-specific files
2. Each editor gets its own folder for `settings.json` and `keybindings.json`
3. Shared files (snippets, tasks, mcp) are in one place
4. No conditional logic needed in install scripts
