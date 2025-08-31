#!/usr/bin/env bash

# -e: exit on error
# -u: exit on undefined variable
# -o pipefail: exits on command pipe failures
set -euo pipefail

# get most recent package:
MCRA_TODOIST_LATEST="$(ls -t ~/bin/binaries/todoist/ | head -n1)"

# run it
$MCRA_PACKAGES/todoist/$MCRA_TODOIST_LATEST
