#!/usr/bin/env bash

export EDITOR=nvim
# export VISUAL=nvim

# Create a temporary file
tmpfile=$(mktemp /tmp/kitty-less-tempfile.XXXXXX)

# Save standard input to the temporary file.
cat > "$tmpfile"

# Open less with the temporary file, using kitty default behaviors:
# - starting at the end of the file (+G)
# - preserving ANSI colors (-R)
less +G -R "$tmpfile"

# Remove the temporary file when less exits.
rm "$tmpfile"
