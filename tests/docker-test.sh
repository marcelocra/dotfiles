#!/usr/bin/env bash
set -euo pipefail

# Tests the dotfiles installation script in a clean Docker container.
# Usage: ./tests/docker-test.sh [setup/install.bash]

SCRIPT_TO_TEST="${1:-setup/install.bash}"
ABS_SCRIPT_PATH=$(realpath "$SCRIPT_TO_TEST")
DOTFILES_ROOT=$(dirname "$(dirname "$ABS_SCRIPT_PATH")")

echo "🚀 Testing script: $SCRIPT_TO_TEST"
echo "BS Root: $DOTFILES_ROOT"

# Run in Docker
# We mount the dotfiles repo to /workspace
echo "🐳 Building and running test container..."
docker run --rm \
    -v "$DOTFILES_ROOT:/workspace" \
    -w /workspace \
    ubuntu:24.04 \
    bash -c "apt-get update && apt-get install -y sudo curl git zip unzip && ./tests/runner.sh $SCRIPT_TO_TEST"

EXIT_CODE=$?

exit $EXIT_CODE
