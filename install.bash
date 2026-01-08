#!/usr/bin/env bash
# Shortcut for VM setup. Equivalent to: ./setup/install.bash --vm "$@"
#
# For editor configurations, run separately:
#   ./apps/vscode-like/install.bash [--code|--cursor|...]

exec "$(dirname "$0")/setup/install.bash" --vm "$@"
