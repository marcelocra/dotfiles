#!/bin/bash
# DevMagic v2.0.0 - Submodule-based development environment setup
# Usage: curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/setup/devmagic.sh | bash

set -e

# --- Configuration ---
# The URL of the repository containing your devcontainer.json and docker-compose.yml.
DEVCONTAINER_REPO_URL="git@github.com:marcelocra/devmagic.run.git"

# --- Colors for output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# --- Header ---
echo -e "${PURPLE}"
echo "🚀 DevMagic v2.0.0"
echo "━━━━━━━━━━━━━━━━━━━"
echo "Submodule-based development environment setup"
echo -e "${NC}"

# --- Prerequisite Checks ---
# 1. Check if Git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed. Please install Git to continue.${NC}"
    exit 1
fi

# 2. Check if inside a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo -e "${YELLOW}⚠️ This directory is not a Git repository.${NC}"
    read -p "Do you want to initialize a new Git repository here? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git init
        echo -e "${GREEN}✅ Git repository initialized.${NC}"
    else
        echo -e "${RED}Aborting. Please run this script inside a Git repository.${NC}"
        exit 1
    fi
fi

# 3. Check for existing .devcontainer directory
if [ -d ".devcontainer" ]; then
    echo -e "${RED}❌ A '.devcontainer' directory already exists.${NC}"
    echo -e "${YELLOW}Please remove or rename it, then run the script again.${NC}"
    exit 1
fi

# --- Main Logic ---
echo -e "${BLUE}⚙️ Adding DevMagic environment as a Git submodule...${NC}"

# Add the submodule to the .devcontainer directory
git submodule add "${DEVCONTAINER_REPO_URL}" .devcontainer

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to add the Git submodule.${NC}"
    echo -e "${YELLOW}Please check the repository URL and your permissions.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ DevMagic submodule added successfully to '.devcontainer'.${NC}"
echo

# --- Next Steps ---
echo -e "${PURPLE}🚀 Your DevMagic environment is ready!${NC}"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Commit the new submodule to your repository:"
echo -e "   ${GREEN}git add .gitmodules .devcontainer${NC}"
echo -e "   ${GREEN}git commit -m \"feat: Add DevMagic development environment\""
echo

# Note: The original prompt had an issue with the escaped quotes for the commit message. 
# The corrected version below ensures the commit message is properly quoted.
# Original: git commit -m "feat: Add DevMagic development environment"
# Corrected: git commit -m "feat: Add DevMagic development environment"

echo "2. Open this project in VS Code with the Dev Containers extension."
echo "   It will automatically prompt you to reopen in the container."

echo "3. To update the environment in the future, run:"
echo -e "   ${GREEN}git submodule update --remote --merge${NC}"
echo


echo "Learn more: https://github.com/marcelocra/dotfiles"
