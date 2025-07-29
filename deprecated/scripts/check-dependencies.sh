#!/usr/bin/env bash

# Dependency check script for dotfiles setup
# This script checks if required tools are installed and provides installation guidance

set -e

echo "🔍 Checking dotfiles dependencies..."
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track what's missing
MISSING_REQUIRED=()
MISSING_OPTIONAL=()

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check version
check_version() {
    local cmd="$1"
    local version_flag="$2"
    local name="$3"
    
    if command_exists "$cmd"; then
        local version
        version=$($cmd $version_flag 2>/dev/null | head -1)
        printf "  ✅ ${GREEN}%-20s${NC} %s\n" "$name" "$version"
        return 0
    else
        printf "  ❌ ${RED}%-20s${NC} Not found\n" "$name"
        return 1
    fi
}

# Function to check optional tool
check_optional() {
    local cmd="$1"
    local version_flag="$2"
    local name="$3"
    
    if command_exists "$cmd"; then
        local version
        version=$($cmd $version_flag 2>/dev/null | head -1)
        printf "  ✅ ${GREEN}%-20s${NC} %s\n" "$name" "$version"
        return 0
    else
        printf "  ⚠️  ${YELLOW}%-20s${NC} Not found (optional)\n" "$name"
        return 1
    fi
}

echo ""
echo "Required Tools:"
echo "---------------"

# Check required tools
if ! check_version "git" "--version" "Git"; then
    MISSING_REQUIRED+=("git")
fi

if ! check_version "bash" "--version" "Bash"; then
    MISSING_REQUIRED+=("bash")
fi

if ! check_version "curl" "--version" "curl"; then
    MISSING_REQUIRED+=("curl")
fi

echo ""
echo "Editors:"
echo "--------"

# Check editors
if ! check_optional "nvim" "--version" "Neovim"; then
    MISSING_OPTIONAL+=("neovim")
fi

if ! check_optional "code" "--version" "VSCode"; then
    MISSING_OPTIONAL+=("code")
fi

if ! check_optional "zed" "--version" "Zed"; then
    MISSING_OPTIONAL+=("zed")
fi

if ! check_optional "subl" "--version" "Sublime Text"; then
    MISSING_OPTIONAL+=("sublime-text")
fi

echo ""
echo "Terminal Emulators:"
echo "-------------------"

if ! check_optional "kitty" "--version" "Kitty"; then
    MISSING_OPTIONAL+=("kitty")
fi

if ! check_optional "alacritty" "--version" "Alacritty"; then
    MISSING_OPTIONAL+=("alacritty")
fi

echo ""
echo "Development Tools:"
echo "------------------"

if ! check_optional "node" "--version" "Node.js"; then
    MISSING_OPTIONAL+=("nodejs")
fi

if ! check_optional "python3" "--version" "Python 3"; then
    MISSING_OPTIONAL+=("python3")
fi

if ! check_optional "docker" "--version" "Docker"; then
    MISSING_OPTIONAL+=("docker")
fi

echo ""
echo "Environment Check:"
echo "------------------"

# Check environment variables
if [[ -n "$MCRA_INIT_SHELL" ]]; then
    printf "  ✅ ${GREEN}%-20s${NC} %s\n" "MCRA_INIT_SHELL" "$MCRA_INIT_SHELL"
else
    printf "  ❌ ${RED}%-20s${NC} Not set\n" "MCRA_INIT_SHELL"
fi

if [[ -n "$MCRA_LOCAL_SHELL" ]]; then
    printf "  ✅ ${GREEN}%-20s${NC} %s\n" "MCRA_LOCAL_SHELL" "$MCRA_LOCAL_SHELL"
else
    printf "  ❌ ${RED}%-20s${NC} Not set\n" "MCRA_LOCAL_SHELL"
fi

if [[ -n "$MCRA_TMP_PLAYGROUND" ]]; then
    printf "  ✅ ${GREEN}%-20s${NC} %s\n" "MCRA_TMP_PLAYGROUND" "$MCRA_TMP_PLAYGROUND"
else
    printf "  ❌ ${RED}%-20s${NC} Not set\n" "MCRA_TMP_PLAYGROUND"
fi

echo ""
echo "Platform Detection:"
echo "-------------------"

# Detect platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if grep -q Microsoft /proc/version 2>/dev/null; then
        printf "  🐧 ${GREEN}Platform:${NC} Windows WSL\n"
    else
        printf "  🐧 ${GREEN}Platform:${NC} Linux\n"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    printf "  🍎 ${GREEN}Platform:${NC} macOS\n"
else
    printf "  ❓ ${YELLOW}Platform:${NC} Unknown ($OSTYPE)\n"
fi

# Check if running in container
if [[ -f /.dockerenv ]] || [[ -n "$CONTAINER" ]]; then
    printf "  📦 ${GREEN}Container:${NC} Yes\n"
else
    printf "  📦 ${GREEN}Container:${NC} No\n"
fi

echo ""
echo "Summary:"
echo "========"

if [[ ${#MISSING_REQUIRED[@]} -eq 0 ]]; then
    printf "${GREEN}✅ All required tools are installed!${NC}\n"
else
    printf "${RED}❌ Missing required tools: ${MISSING_REQUIRED[*]}${NC}\n"
    echo ""
    echo "Installation commands:"
    echo "---------------------"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Ubuntu/Debian:"
        echo "  sudo apt update"
        echo "  sudo apt install ${MISSING_REQUIRED[*]}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS (with Homebrew):"
        echo "  brew install ${MISSING_REQUIRED[*]}"
    fi
fi

if [[ ${#MISSING_OPTIONAL[@]} -gt 0 ]]; then
    printf "\n${YELLOW}⚠️  Optional tools not found: ${MISSING_OPTIONAL[*]}${NC}\n"
    echo ""
    echo "Optional installation commands:"
    echo "------------------------------"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Ubuntu/Debian:"
        for tool in "${MISSING_OPTIONAL[@]}"; do
            case $tool in
                "neovim")
                    echo "  # Neovim: sudo apt install neovim"
                    ;;
                "code")
                    echo "  # VSCode: Download from https://code.visualstudio.com/"
                    ;;
                "kitty")
                    echo "  # Kitty: sudo apt install kitty"
                    ;;
                "nodejs")
                    echo "  # Node.js: curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt install -y nodejs"
                    ;;
                "docker")
                    echo "  # Docker: curl -fsSL https://get.docker.com | sh"
                    ;;
            esac
        done
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS (with Homebrew):"
        for tool in "${MISSING_OPTIONAL[@]}"; do
            case $tool in
                "neovim")
                    echo "  brew install neovim"
                    ;;
                "code")
                    echo "  brew install --cask visual-studio-code"
                    ;;
                "kitty")
                    echo "  brew install --cask kitty"
                    ;;
                "nodejs")
                    echo "  brew install node"
                    ;;
                "docker")
                    echo "  brew install --cask docker"
                    ;;
            esac
        done
    fi
fi

echo ""
echo "Next Steps:"
echo "----------"
echo "1. Install any missing required tools"
echo "2. Set up environment variables:"
echo "   export MCRA_INIT_SHELL=\"\$HOME/dotfiles/init.sh\""
echo "   export MCRA_LOCAL_SHELL=\"\$HOME/.local-shell\""
echo "   export MCRA_TMP_PLAYGROUND=\"/tmp/playground\""
echo "3. Source the main configuration:"
echo "   source ~/dotfiles/init.sh"
echo "4. Follow the README.md for editor-specific setup"

if [[ ${#MISSING_REQUIRED[@]} -eq 0 ]]; then
    exit 0
else
    exit 1
fi