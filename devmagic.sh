#!/bin/bash
# DevMagic v1.0.0 - One-line development environment setup
# Usage: curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/devmagic.sh | bash

set -e

# Colors for output.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# DevMagic header.
echo -e "${PURPLE}"
echo "🚀 DevMagic v1.0.0"
echo "━━━━━━━━━━━━━━━━━━━"
echo "One-line development environment setup"
echo -e "${NC}"

# Check if we're in a project directory.
if [ ! -f "package.json" ] && [ ! -f "Cargo.toml" ] && [ ! -f "go.mod" ] && [ ! -f "pyproject.toml" ] && [ ! -f ".git/config" ]; then
    echo -e "${YELLOW}⚠️  No project files detected. Creating example project structure...${NC}"
    mkdir -p src
    echo "# $(basename "$PWD")" > README.md
    echo -e "${GREEN}✅ Basic project structure created${NC}"
fi

# Create .devcontainer directory if it doesn't exist.
if [ ! -d ".devcontainer" ]; then
    echo -e "${BLUE}📁 Creating .devcontainer directory...${NC}"
    mkdir -p .devcontainer
else
    echo -e "${BLUE}📁 .devcontainer directory already exists${NC}"
fi

# Download devcontainer.json.
echo -e "${BLUE}📥 Downloading DevMagic configuration...${NC}"
curl -fsSL https://raw.githubusercontent.com/marcelocra/dotfiles/main/.devcontainer/devcontainer.json -o .devcontainer/devcontainer.json

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ DevMagic configuration downloaded${NC}"
else
    echo -e "${RED}❌ Failed to download configuration${NC}"
    exit 1
fi

# Show available service profiles.
echo -e "${PURPLE}"
echo "🎛️  Available Service Profiles:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"
echo -e "${GREEN}minimal${NC}    • Development container only (default)"
echo -e "${BLUE}ai${NC}          • + Ollama GPU               (port 11434)"
echo -e "${BLUE}ai-cpu${NC}      • + Ollama CPU               (port 11435)"
echo -e "${YELLOW}postgres${NC}  • + PostgreSQL database      (port 5432)"
echo -e "${YELLOW}redis${NC}     • + Redis cache              (port 6379)"
echo -e "${YELLOW}mongodb${NC}   • + MongoDB database         (port 27017)"
echo -e "${YELLOW}minio${NC}     • + MinIO S3 storage         (ports 9000/9001)"
echo

# Environment variable setup.
echo -e "${PURPLE}🔧 Environment Configuration:${NC}"
echo "Set MCRA_COMPOSE_PROFILES to choose services:"
echo -e "${GREEN}export MCRA_COMPOSE_PROFILES=\"minimal,ai,postgres\"${NC}"
echo
echo "Optional database password:"
echo -e "${GREEN}export MCRA_DEV_DB_PASSWORD=\"YourSecurePassword\"${NC}"
echo

# VS Code detection and instructions.
if command -v code >/dev/null 2>&1; then
    echo -e "${PURPLE}🚀 Ready to launch!${NC}"
    echo "Run one of these commands:"
    echo
    echo -e "${GREEN}# Basic development${NC}"
    echo "MCRA_COMPOSE_PROFILES=minimal code ."
    echo
    echo -e "${GREEN}# AI development with database${NC}"
    echo "MCRA_COMPOSE_PROFILES=minimal,ai,postgres code ."
    echo
    echo -e "${GREEN}# Full stack development${NC}"
    echo "MCRA_COMPOSE_PROFILES=minimal,ai,postgres,redis code ."
else
    echo -e "${YELLOW}💡 VS Code not detected${NC}"
    echo "Install VS Code, then run:"
    echo -e "${GREEN}MCRA_COMPOSE_PROFILES=minimal code .${NC}"
fi

echo
echo -e "${PURPLE}🎯 DevMagic Setup Complete!${NC}"
echo -e "${GREEN}✨ Your development environment is ready${NC}"
echo
echo "Learn more: https://github.com/marcelocra/dotfiles"