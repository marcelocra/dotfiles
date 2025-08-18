# Sublime Text settings

The `User` folder contains Sublime Text 4's `User` directory, usually found at:

- Linux: `~/config/sublime-text/Packages/User`
- Windows: `~/AppData/Roaming/Sublime Text/Packages/User`

Usually I symlink my configs, but it seems that Sublime Text doesn't like that. When you do, editing the symlinked settings won't apply instantaneously until you restart Sublime.

If you don't care about that, go for it. If you do, try a backup cronjob.

## How to use

Copy these files to the appropriate location, backing up any existing content.

```sh
cp ./sublime-text/User/* ~/.config/sublime-text/Packages/User/*
```

Create a cronjob to backup stuff back here.

```sh
$ crontab -e

# Add this to the crontab file.
*/60 * * * * cp -r $HOME/.config/sublime-text/Packages/User/* `$(pwd)`/sublime-text/
```

## Custom Plugin Features

This setup includes a comprehensive custom plugin that adds VSCode-like functionality and productivity features.

### Status Bar Enhancements
- Real-time date/time display (format: `15jul25 13:34`)
- Dynamic word/character count for current document

### Smart Selection System (VSCode-like)
- `Alt+Shift+Up`: Expand selection with history tracking
- `Alt+Shift+Down`: Shrink selection using expansion history stack
- Maintains selection history to enable proper "undo" of expansions

### Multi-Cursor Navigation
- `Ctrl+N/P`: Move focus through multiple selections
- Maintains multi-cursor state while changing focused selection
- Similar to VSCode's moveSelectionToNext/PreviousFindMatch

### Markdown Features
- `Alt+Enter`: Creates timestamped headings (`## 14h33 - `)
- Special behavior in `tasks.md`: Creates `## \n_Added: 2025-08-15 17:44_`
- `Ctrl+Enter`: Toggles task states: `- text` → `- [ ] text` → `- [x] text`
- `Alt+L`: Cycles current line position (top/middle/bottom of screen)

### Text Insertion Chords
- `Alt+T` + `F`: Full timestamp (`2025-08-15 14:33:22`)
- `Alt+T` + `D`: Date in double brackets (`[[2025-08-15]]`)
- `Alt+T` + `T`: Time only (`14h33`)

### Technical Architecture
- **StatusBarManager**: Threading-based real-time updates
- **SelectionHistoryManager**: Tracks expansion states for proper shrinking
- **Event Listeners**: Automatic updates and selection tracking
- Context-aware commands with VSCode-inspired behavior patterns
