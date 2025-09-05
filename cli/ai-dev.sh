#!/bin/bash

# ai-dev.sh - Multi-mode AI development container for Bash.
# Usage: ./ai-dev.sh [full|quick|minimal]

set -e

# Default mode is quick.
MODE="${1:-quick}"

# Validate mode parameter.
case "$MODE" in
    full|quick|minimal)
        ;;
    *)
        echo "Usage: $0 [full|quick|minimal]"
        echo ""
        echo "Modes:"
        echo "  full     - Complete development environment with all tools"
        echo "  quick    - Essential development tools (default)"
        echo "  minimal  - Minimal Alpine-based environment"
        echo ""
        echo "Examples:"
        echo "  $0           # Uses quick mode"
        echo "  $0 full      # Uses full mode"
        echo "  $0 minimal   # Uses minimal mode"
        exit 1
        ;;
esac

CONTAINER_NAME="ai-dev-$(basename $(pwd))"

# Colors for output.
BLUE='\033[34m'
YELLOW='\033[33m'
GREEN='\033[32m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting AI development container in $MODE mode...${NC}"

# Stop container if already running.
if podman ps -q -f name="$CONTAINER_NAME" | grep -q .; then
    echo -e "${YELLOW}⚠️  Container already exists. Stopping...${NC}"
    podman stop "$CONTAINER_NAME" >/dev/null 2>&1
    podman rm "$CONTAINER_NAME" >/dev/null 2>&1
fi

# Define images and setup commands based on mode.
case "$MODE" in
    minimal)
        IMAGE="node:20-alpine"
        SETUP_CMD="bash /workspace/ai-dev-setup.sh --mode=minimal; exec sh"
        ;;
    quick)
        IMAGE="mcr.microsoft.com/devcontainers/javascript-node:1-20-bullseye"
        SETUP_CMD="bash /workspace/ai-dev-setup.sh --mode=quick; exec bash"
        ;;
    full)
        IMAGE="mcr.microsoft.com/devcontainers/javascript-node:1-20-bullseye"
        SETUP_CMD="bash /workspace/ai-dev-setup.sh --mode=full; exec bash"
        ;;
esac

# Build volume mounts.
VOLUME_MOUNTS=(
    "-v" "$(pwd):/workspace:Z"
    "-v" "$HOME/.claude:/root/.claude:Z"
    "-v" "$HOME/.config:/root/.config:Z"
    "-v" "$HOME/.ssh:/root/.ssh:Z"
)

# Environment variables.
ENV_VARS=(
    "-e" "TZ=America/Sao_Paulo"
    "-e" "LC_ALL=en_US.UTF-8"
    "-e" "LANG=en_US.UTF-8"
)

# Run the container.
echo -e "${GREEN}Starting $MODE mode container...${NC}"

if ! podman run -it --rm \
    --name "$CONTAINER_NAME" \
    --hostname "ai-dev" \
    -w "/workspace" \
    "${VOLUME_MOUNTS[@]}" \
    "${ENV_VARS[@]}" \
    "$IMAGE" \
    bash -c "$SETUP_CMD"; then
    
    echo -e "\n${YELLOW}❌ Failed to start container. Make sure podman is installed and running.${NC}"
    exit 1
fi