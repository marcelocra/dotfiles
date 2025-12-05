# Setup Scripts Architecture

## Overview

The AI development container scripts have been refactored to eliminate code duplication by consolidating all installation logic into a single, unified setup script.

## Architecture (v2.0.0 - Unified Approach)

```
Main Scripts (Container Runners)     Setup Script (Unified Installation Logic)
├── ai-dev [MULTI-MODE]      ──→  ai-dev-setup.bash --mode=full|quick|minimal
└── ai-dev.ps1 [MULTI-MODE]     ──→
```

## Unified Setup Script

### `ai-dev-setup.bash` - Unified Environment Setup

**Single script handling all three modes with shared components:**

#### Mode: `full`
- **Target**: Full development with all tools
- **Dependencies**: tmux, fzf, zsh, fish, ripgrep, fd-find, bat, exa, jq, build-essential, python3-pip, vim, nano, htop, tree
- **Configuration**: Enhanced functions in `~/.bashrc` + `~/.zshrc`
- **Features**:
  - Comprehensive aliases (ll, cat, grep, find, gs, ga, gc, gp, gl, h)
  - AI helper functions (ask, gemini, analyze, codehelp)
  - Project analysis tools
  - Multi-shell support (bash + zsh)

#### Mode: `quick`  
- **Target**: Essential development tools
- **Dependencies**: curl, git, ripgrep, bat, exa, jq, python3-pip
- **Configuration**: Functions in `~/.bashrc` + executables in `/usr/local/bin/`
- **Features**:
  - Essential aliases (ll, cat, grep, gs, ga, gc)
  - AI functions as both shell functions and executables
  - Quick setup optimized for speed

#### Mode: `minimal`
- **Target**: Alpine-based minimal footprint  
- **Dependencies**: curl, git, ripgrep, bat, exa, jq, python3, py3-pip (Alpine packages)
- **Configuration**: Simple functions in `~/.profile`
- **Features**:
  - Basic aliases (ll, cat, grep)
  - Simple AI functions in shell profile
  - Minimal setup for quick questions

#### Shared Features (All Modes)
- **Unified History**: All modes use `~/.shell-history` with timestamps and persistence
- **AI Tools**: Claude Code CLI + Gemini CLI (with fallback installation methods)
- **Consistent Interface**: Same command patterns across all modes
- **Error Handling**: Robust command existence checking and graceful fallbacks

## Container Scripts (Multi-mode)

### Bash Script

```bash
# ai-dev - Multi-mode script
case "$MODE" in
    minimal)
        SETUP_CMD="bash /workspace/ai-dev-setup.bash --mode=minimal; exec sh"
        ;;
    quick)
        SETUP_CMD="bash /workspace/ai-dev-setup.bash --mode=quick; exec bash"
        ;;
    full)
        SETUP_CMD="bash /workspace/ai-dev-setup.bash --mode=full; exec bash"
        ;;
esac
```

### PowerShell Script

```powershell
# ai-dev.ps1 - Multi-mode script
$SetupCommands = @{
    "minimal" = "bash /workspace/ai-dev-setup.bash --mode=minimal; exec sh"
    "quick"   = "bash /workspace/ai-dev-setup.bash --mode=quick; exec bash"
    "full"    = "bash /workspace/ai-dev-setup.bash --mode=full; exec bash"
}
```

## Benefits of Unified Architecture

1. **No Code Duplication**: Installation logic exists only once for all environment types
2. **Single Point of Maintenance**: Update one script, affects all modes and platforms  
3. **Consistent Behavior**: Identical setup logic across bash and PowerShell versions
4. **Simplified Architecture**: Reduced from 5 files to 3 files total
5. **Testable**: Single setup script can be tested independently with different modes
6. **Better Parameter Handling**: Proper argument parsing with mode validation
7. **Shared Configuration**: Unified history and configuration management across all modes

## Usage Examples

```bash
# Multi-mode bash script
./ai-dev              # quick mode (default)
./ai-dev quick        # quick mode (explicit)
./ai-dev full         # full development environment
./ai-dev minimal      # minimal Alpine environment

# Multi-mode PowerShell script
.\ai-dev.ps1              # quick mode (default)
.\ai-dev.ps1 -Mode quick  # quick mode (explicit)
.\ai-dev.ps1 -Mode full   # full mode
.\ai-dev.ps1 -Mode minimal # minimal mode
```

## File Structure (v2.0.0)

```
cli/
├── ai-dev               # Multi-mode bash runner
├── ai-dev.ps1              # Multi-mode PowerShell runner  
├── ai-dev-setup.bash         # Unified installation logic (NEW)
├── README-AI-SCRIPTS.md    # User documentation
└── SETUP-SCRIPTS.md        # Architecture documentation
```

**Migration Summary:**
- ❌ Removed: `setup-full.sh`, `setup-quick.sh`, `setup-minimal.sh` (3 files)
- ✅ Added: `ai-dev-setup.bash` (1 file)  
- **Net change**: -2 files, significantly reduced complexity

All scripts now follow the DRY principle with a single, well-tested setup script handling all environment configurations.
