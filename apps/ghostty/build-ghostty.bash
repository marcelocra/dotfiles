#!/usr/bin/env bash

# Usage:
# ./build-ghostty.bash              # Run with Docker (default, saves state)
# ./build-ghostty.bash --no-docker  # Run locally without Docker

set -euo pipefail

# Configuration
# Overridable via environment variables
GHOSTTY_IMAGE_NAME="${GHOSTTY_IMAGE_NAME:-ghostty-build-env}"
GHOSTTY_IMAGE_TAG="${GHOSTTY_IMAGE_TAG:-latest}"
PUB_KEY="${GHOSTTY_PUB_KEY:-RWQlAjJC23149WL2sEpT/l0QKy7hMIFhYdQOFy0Z7z7PbneUgvlsnYcV}"
DOWNLOAD_DIR="${GHOSTTY_DOWNLOAD_DIR:-$HOME/bin/downloads/ghostty}"

# Internal configuration
CUSTOM_IMAGE="${GHOSTTY_IMAGE_NAME}:${GHOSTTY_IMAGE_TAG}"
BASE_IMAGE="docker.io/library/fedora:43"
DEPS="gtk4-devel gtk4-layer-shell-devel zig libadwaita-devel gettext minisign"
BUILD_OPTS="-Doptimize=ReleaseFast -fno-sys=gtk4-layer-shell"

# 1. Download and Preparation
echo "--- Preparing Source Code ---"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

echo "Downloading Ghostty source and signature..."
curl -LO https://github.com/ghostty-org/ghostty/releases/download/tip/ghostty-source.tar.gz
curl -LO https://github.com/ghostty-org/ghostty/releases/download/tip/ghostty-source.tar.gz.minisig

# Check if minisign is installed on host for verification
if ! command -v minisign &> /dev/null; then
    echo "minisign not found. Installing it..."
    sudo dnf install -y minisign
fi

echo "Verifying signature..."
minisign -Vm ghostty-source.tar.gz -P "$PUB_KEY"

echo "Extracting source..."
# Extract and get the directory name
tar -xzf ghostty-source.tar.gz
# The tarball usually extracts to a directory. Let's find it.
# We expect something like ghostty-source or ghostty-<version>
SRC_DIR=$(tar -tf ghostty-source.tar.gz | head -n 1 | cut -f1 -d"/")
cd "$SRC_DIR"

# 2. Build Process
INSTALL_CMD="dnf install -y $DEPS"
BUILD_CMD="zig build $BUILD_OPTS"

if [[ "${1:-}" == "--no-docker" ]]; then
    echo "--- Mode: Local Build (No Docker) ---"

    if ! command -v dnf &> /dev/null; then
        echo "Error: 'dnf' not found. This script is designed for Fedora/RHEL systems."
        exit 1
    fi

    echo "Installing dependencies..."
    sudo $INSTALL_CMD

    echo "Building Ghostty..."
    eval "$BUILD_CMD"
else
    echo "--- Mode: Docker Build ---"

    if ! command -v docker &> /dev/null; then
        echo "Error: Docker not found. Please install Docker or use --no-docker"
        exit 1
    fi

    # Check if the custom image with dependencies already exists
    if ! docker images -q "$CUSTOM_IMAGE" > /dev/null; then
        echo "Custom image '$CUSTOM_IMAGE' not found. Creating it to save state..."

        # Create a temporary container to install dependencies
        TEMP_CONTAINER="ghostty-temp-setup"
        docker run --name "$TEMP_CONTAINER" "$BASE_IMAGE" bash -c "$INSTALL_CMD"

        # Save the container state as a new image
        docker commit "$TEMP_CONTAINER" "$CUSTOM_IMAGE"

        # Cleanup
        docker rm "$TEMP_CONTAINER"
        echo "Image '$CUSTOM_IMAGE' created successfully."
    else
        echo "Using existing image '$CUSTOM_IMAGE' (dependencies already installed)."
    fi

    echo "Starting build in container..."
    docker run \
        --rm \
        -it \
        -v "$(pwd):/workspace:Z" \
        -w /workspace \
        "$CUSTOM_IMAGE" \
        bash -c "$BUILD_CMD"
fi

# 3. Post-build: Symlinks and Installation
echo "--- Post-build: Installing Symlinks ---"

# Binary symlink
mkdir -p "$HOME/bin"
ln -sf "$(pwd)/zig-out/bin/ghostty" "$HOME/bin/ghostty"
echo "Symlinked ghostty binary to $HOME/bin/ghostty"

# Desktop file
mkdir -p "$HOME/.local/share/applications"
cp "$(pwd)/zig-out/share/applications/com.mitchellh.ghostty.desktop" "$HOME/.local/share/applications/"
echo "Copied desktop file to $HOME/.local/share/applications/"

# Icon
mkdir -p "$HOME/.local/share/icons"
cp "$(pwd)/zig-out/share/icons/hicolor/1024x1024/apps/com.mitchellh.ghostty.png" "$HOME/.local/share/icons/"
echo "Copied icon to $HOME/.local/share/icons/"

echo "--- Build and Installation Completed Successfully ---"
