# AI Development Scripts

Multi-mode scripts to run AI-enabled development containers with Claude and Gemini CLI pre-installed.

## Available Scripts

### Bash Script (Linux/macOS/WSL)

#### `./ai-dev` - Multi-mode Development Environment
```bash
# Quick mode (default) - Essential development tools
./ai-dev
./ai-dev quick

# Full mode - Complete development environment  
./ai-dev full

# Minimal mode - Alpine-based minimal footprint
./ai-dev minimal

# Help
./ai-dev help
```

**Environment Details:**
- **Full**: DevContainer JS-Node + tmux, fzf, zsh, fish, ripgrep, bat, exa, jq, build tools
- **Quick**: DevContainer JS-Node + essential tools (git, ripgrep, bat, exa, jq)  
- **Minimal**: Node Alpine + basic tools (git, ripgrep, bat, exa, jq)
- **AI Tools**: Claude Code CLI + Gemini CLI (all modes)

### PowerShell Script (Windows/Cross-platform)

#### `./ai-dev.ps1` - Multi-mode PowerShell Version
```powershell
# Quick mode (default)
.\ai-dev.ps1

# Full mode
.\ai-dev.ps1 -Mode full

# Minimal mode  
.\ai-dev.ps1 -Mode minimal
```

## Usage

### Inside the Container

All scripts provide these functions:

```bash
# Ask Claude
ask "how do I optimize this JavaScript?"

# Ask Gemini
gemini "explain this code structure"

# Direct Claude CLI
claude --help
claude chat "your question"
```

### Mode Comparison

| Feature | Full | Quick | Minimal |
|---------|------|-------|---------|
| **Base Image** | DevContainer JS-Node | DevContainer JS-Node | Node Alpine |
| **Size** | ~2GB | ~1.5GB | ~500MB |
| **Setup Time** | ~60s | ~30s | ~15s |
| **Dev Tools** | tmux, fzf, zsh, fish, build-essential | Essential only | Basic only |
| **Best For** | Complex projects, full dev | Most tasks, balanced | Quick questions, speed |

### Enhanced Features (Full Mode Only)

```bash
# Project analysis
analyze              # Analyze current project structure

# Code help  
codehelp index.js    # Get AI help for specific file

# Advanced aliases
gs, ga, gc, gp, gl   # Git shortcuts
h                    # htop
tree                 # exa --tree
```

### Useful Aliases Available

```bash
ll          # exa -la (better ls)
cat         # bat (syntax highlighting) 
grep        # rg (ripgrep - faster grep)
find        # fd (faster find) [full mode only]
```

### Mounted Directories

- **Current directory** → `/workspace`
- **~/.claude** → Container's Claude config
- **~/.config** → Container's config directory  
- **~/.ssh** → Container's SSH keys (read-only)

## Requirements

- **Podman** (or Docker with script modifications)
- **Internet connection** for package installation
- **Claude CLI credentials** in `~/.claude/` (optional but recommended)

## Examples

```bash
# Start quick environment (most common)
./ai-dev

# Start full development environment
./ai-dev full

# Inside container - ask about current project  
ask "analyze this HTML structure and suggest improvements"

# Use Gemini for alternative perspective
gemini "what are the performance implications of this code?"

# Work with enhanced tools
ll                    # List files with better formatting
cat index.html        # View with syntax highlighting  
grep "function" *.js  # Fast search across JS files

# Full mode extras
analyze               # AI-powered project analysis
codehelp app.js       # Get specific file help
```

## Architecture

The scripts use a unified architecture with consolidated setup logic:

```
Container Runners          Setup Script (Unified Logic)
├── ai-dev         ──→  ai-dev-setup.bash --mode=full|quick|minimal
└── ai-dev.ps1        ──→
```

## Script Features

- **Multi-mode operation** with parameter validation
- **English comments and messages** for international compatibility  
- **Proper error handling** with colored output
- **Claude Code CLI prioritized** over regular Claude CLI
- **Fallback installation methods** for robustness
- **Automatic container cleanup** on restart
- **SELinux-compatible volume mounts** (`:Z` flag)
- **Cross-platform consistency** (bash + PowerShell)

## Customization

Edit the `ai-dev-setup.bash` script to:
- Add/remove development tools
- Modify AI CLI installation methods  
- Change aliases and helper functions
- Adjust package installation logic for different modes

The container runner scripts (`ai-dev`, `ai-dev.ps1`) handle:
- Container configuration
- Volume mounts  
- Environment variables
- Mode selection logic

## Shared Features

All environments include:
- **Shared shell history**: Persistent `~/.shell-history` with timestamps
- **Consistent aliases**: Same command shortcuts across all modes
- **AI integration**: Claude and Gemini CLI tools with helper functions
- **Cross-platform compatibility**: Works on Linux, macOS, Windows (WSL/PowerShell)