#!/usr/bin/env bash
#
# lesstmp - A script to open less with a temporary file if there's standard
# input being piped in.

# Exit on error, unset variables, or if any command returns a non-zero exit
# status.
set -euo pipefail

export EDITOR=nvim

LESS_BIN="less -R"

# Check if there's standard input being piped in. If there is, create a
# temporary file for it and go from there. If there isn't, just call less with
# the arguments passed to this script.
if [ -p /dev/stdin ]; then

    # Create a temporary file
    tmpfile=$(mktemp /tmp/kitty-less-tempfile.XXXXXX)

    # Save standard input to the temporary file.
    cat > "$tmpfile"

    # Open less with the temporary file, using kitty default behaviors:
    # - starting at the end of the file (+G)
    # - preserving ANSI colors (-R)
    $LESS_BIN "$tmpfile"

    # Remove the temporary file when less exits.
    rm "$tmpfile"
else
    $LESS_BIN "$@"
fi

