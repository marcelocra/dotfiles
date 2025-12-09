#!/bin/bash

# ai-dev-setup.bash - Unified AI development environment setup script.
# This script is called by container runners (ai-dev, ai-dev.ps1).
#
# Usage: ai-dev-setup.bash --mode=full|quick|minimal

set -e

# Utility functions
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

log_debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo "🔍 $*" >&2
    fi
}

# Default mode
MODE="quick"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --mode=*)
            MODE="${1#*=}"
            shift
            ;;
        --mode)
            MODE="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Usage: $0 --mode=full|quick|minimal"
            exit 1
            ;;
    esac
done

# Validate mode
case "$MODE" in
    full|quick|minimal)
        ;;
    *)
        echo "Error: Invalid mode '$MODE'. Must be one of: full, quick, minimal"
        exit 1
        ;;
esac

echo "🔧 Setting up $MODE AI development environment..."

# =============================================================================
# SHARED HISTORY CONFIGURATION
# =============================================================================

configure_shared_history() {
    local shell_config_file="$1"

    cat >> "$shell_config_file" << 'EOF'

# Shared shell history configuration
export HISTFILE="/root/.shell-history"
export HISTSIZE=50000
export HISTFILESIZE=50000
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend 2>/dev/null || true
setopt HIST_IGNORE_DUPS 2>/dev/null || true
setopt HIST_IGNORE_ALL_DUPS 2>/dev/null || true
setopt HIST_SAVE_NO_DUPS 2>/dev/null || true
setopt SHARE_HISTORY 2>/dev/null || true
setopt APPEND_HISTORY 2>/dev/null || true
EOF
}

# =============================================================================
# PACKAGE INSTALLATION
# =============================================================================

install_packages() {
    case "$MODE" in
        minimal)
            echo "📦 Installing minimal packages (Alpine)..."
            apk add --no-cache curl git ripgrep bat exa jq python3 py3-pip 2>/dev/null
            ;;
        quick)
            echo "📦 Installing essential packages..."
            apt-get update -qq > /dev/null 2>&1
            apt-get install -y -qq curl git ripgrep bat exa jq python3-pip > /dev/null 2>&1
            ;;
        full)
            echo "📦 Installing comprehensive packages..."
            apt-get update -q && apt-get install -y -q \
                tmux fzf curl git zsh fish \
                ripgrep fd-find bat exa jq \
                build-essential python3-pip \
                vim nano htop tree
            ;;
    esac
}

# =============================================================================
# AI CLI INSTALLATION
# =============================================================================

install_ai_tools() {
    echo "📦 Installing Claude CLI..."
    npm install -g @anthropic-ai/claude-code 2>/dev/null || echo "⚠️  Claude CLI could not be installed automatically."

    echo "📦 Installing Gemini CLI..."
    npm install -g @google/gemini-cli 2>/dev/null || echo "⚠️  Gemini CLI not installed."
}

# =============================================================================
# COMMON SHELL CONFIGURATION (SHARED ACROSS ALL MODES)
# =============================================================================

get_ai_functions_content() {
    cat << 'EOF'

# AI Helper Functions
ask() {
    if [ -z "$1" ]; then
        echo "Usage: ask \"your question here\""
        echo "Example: ask \"optimize this JavaScript function\""
        return 1
    fi
    echo "🤖 Claude: Processing your request..."
    claude chat --message "$*"
}

gemini() {
    if [ -z "$1" ]; then
        echo "Usage: gemini \"your question here\""
        echo "Example: gemini \"explain this code pattern\""
        return 1
    fi
    echo "✨ Gemini: Processing your request..."
    gemini-cli "$*" 2>/dev/null || {
        echo "Note: Gemini CLI not available. Using fallback..."
        echo "Gemini would respond to: $*"
    }
}

# Project helper functions
analyze() {
    echo "🔍 Project Analysis:"
    echo "Files: $(find . -type f | wc -l)"
    echo "Languages: $(find . -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.html" -o -name "*.css" | sed 's/.*\.//' | sort | uniq -c)"
    echo ""
    ask "analyze this project structure: $(ls -la)"
}

codehelp() {
    if [ -f "$1" ]; then
        echo "📖 Getting help for: $1"
        ask "explain and suggest improvements for this code: $(cat "$1")"
    else
        echo "Usage: codehelp <filename>"
        echo "Example: codehelp index.js"
    fi
}
EOF
}

get_aliases_content() {
    cat << 'EOF'

# Development aliases
alias ll="exa -la"
alias ls="exa"
alias cat="bat"
alias find="fd"
alias grep="rg"
alias vim="vim"
alias tree="exa --tree"

# Git aliases
alias gs="git status"
alias ga="git add"
alias gaa="git add ."
alias gc="git commit"
alias gcm="gc -m"
alias gpl="git pull"
alias gph="git push"
alias gl="git log --oneline -10"

# System aliases
alias h="htop"
alias ..="cd .."
alias ...="cd ../.."
EOF
}

create_ai_functions() {
    local config_file="$1"
    get_ai_functions_content >> "$config_file"
    configure_shared_history "$config_file"
}

create_aliases() {
    local config_file="$1"
    get_aliases_content >> "$config_file"
}

# =============================================================================
# MODE-SPECIFIC CONFIGURATION FUNCTIONS
# =============================================================================

setup_minimal_mode() {
    create_ai_functions ~/.profile
    create_aliases ~/.profile
    source ~/.profile 2>/dev/null || true
    
    echo "💡 Use: ask \"your question\" for Claude"
    echo "💡 Use: gemini \"your question\" for Gemini"
}

setup_quick_mode() {
    create_ai_functions ~/.bashrc
    create_aliases ~/.bashrc
    source ~/.bashrc 2>/dev/null || true
    
    echo "💡 Type: ask \"your question\" to talk with Claude."
    echo "💡 Type: gemini \"your question\" to talk with Gemini."
    echo "💡 Type: claude --help to see more options."
}

setup_full_mode() {
    create_ai_functions ~/.bashrc
    create_aliases ~/.bashrc
    source ~/.bashrc 2>/dev/null || true
    
    echo "🚀 Available Commands:"
    echo "  ask \"question\"     - Talk with Claude"
    echo "  gemini \"question\"  - Talk with Gemini"
    echo "  analyze            - Analyze current project"
    echo "  codehelp <file>    - Get help with specific file"
    echo ""
    echo "📁 Enhanced aliases: ll, cat, grep, find, gs, ga, gc"
    echo "🔧 Development tools: tmux, fzf, zsh, fish, htop"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    # Common setup for all modes
    install_packages
    install_ai_tools
    
    # Mode-specific configuration
    case "$MODE" in
        minimal)
            setup_minimal_mode
            ;;
        quick)
            setup_quick_mode
            ;;
        full)
            setup_full_mode
            ;;
    esac

    echo ""
    echo "✅ $MODE development environment ready!"
    echo "📁 You are in: /workspace (mapped to current directory)"
    echo ""
}

main "$@"
