# Recommended Dotfiles Directory Structure

This structure ensures only configuration files are tracked, avoiding temporary/generated files.

```
dotfiles/
├── devcontainer-setup.sh       # Setup script for devcontainers
├── shell/
│   ├── init.sh                 # Main shell configuration
│   ├── marcelocra.zsh-theme    # Custom zsh theme
│   └── ssh_config              # SSH configuration
├── tmux/
│   └── .tmux.conf              # tmux configuration
├── vscode/                     # VS Code configuration
│   ├── settings.json           # User settings (TRACKED)
│   ├── keybindings.json        # Key bindings (TRACKED)
│   └── snippets/               # Code snippets folder (TRACKED)
│       ├── javascript.json
│       ├── python.json
│       └── ...
├── sublime/                    # Sublime Text configuration
│   ├── Preferences.sublime-settings     # Main settings (TRACKED)
│   ├── Default.sublime-keymap           # Key bindings (TRACKED)
│   ├── Package Control.sublime-settings # Package list (TRACKED)
│   └── snippets/                        # Snippets folder (TRACKED)
│       ├── javascript.sublime-snippet
│       └── ...
└── zed/                        # Zed configuration
    ├── settings.json           # Main settings (TRACKED)
    ├── keymap.json            # Key bindings (TRACKED)
    └── themes/                 # Custom themes (TRACKED)
        └── custom-theme.json
```

## What Gets Symlinked vs What Doesn't

### ✅ Symlinked (Configuration Files)

- `settings.json` - Your editor preferences
- `keybindings.json` - Custom keyboard shortcuts
- `snippets/` - Code snippets you've created
- Theme and syntax files
- Package/extension lists

### ❌ NOT Symlinked (Generated/Temporary Files)

- `workspaceStorage/` - VS Code workspace state
- `logs/` - Application logs
- `CachedExtensions/` - Extension cache
- `User/workspaceStorage/` - Workspace-specific data
- `*.log` files - Debug and error logs
- Session files and recent file lists

## Benefits of Selective Symlinking

1. **Clean dotfiles repo** - Only track what you actually configure
2. **No conflicts** - Editor-generated files won't overwrite your configs
3. **Better performance** - No unnecessary file watching on temp files
4. **Portability** - Configs work across different environments
5. **Version control friendly** - Meaningful diffs, no noise

## Adding New Editor Configs

When adding a new editor configuration:

1. **Research what files are user-configurable** (usually in docs)
2. **Test which files contain your settings** vs generated data
3. **Add specific file symlinks** to the setup script
4. **Avoid directory-level symlinks** that might include temp files
