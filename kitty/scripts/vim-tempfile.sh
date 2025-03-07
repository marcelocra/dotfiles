#!/usr/bin/env bash

# Bail on error.
set -e

# Create a temporary file.
tmpfile=$(mktemp /tmp/kitty-nvim-tempfile.XXXXXX)

# Save standard input to the temporary file.
cat > "$tmpfile"

# Cleanup control sequences and open nvim.
file_to_run="$(mktemp)" && cat <<EOF > "$file_to_run" && python3 "$file_to_run"

import re
import sys

with open('$tmpfile', 'r') as f:
    input_text = f.read()

if not input_text:
    print("No input provided")
    sys.exit(1)

ansi_escape = re.compile(
    r"""
    \x1B                # ESC
    (?:                 # Start non-capturing group for the rest
        [@-Z\\-_]      # 7-bit C1 control codes
      | \[             # CSI sequences:
          [0-?]*      # Parameter bytes
          [ -/]*      # Intermediate bytes
          [@-~]       # Final byte
      | \]             # OSC sequences:
          [^\x1B\x07]*  # Any characters except ESC and BEL
          (?:\x1B\\\|\x07|\x1B)  # Terminated by ESC\ or BEL or a lone ESC
    )
    """,
    re.VERBOSE,
)

cleaned_text = ansi_escape.sub("", input_text)

with open('$tmpfile', 'w') as f:
    f.write(cleaned_text)

sys.exit(0)

EOF

# Remove the temporary Python file, as it already ran.
rm "$file_to_run"

# Open editor.
nvim "$tmpfile"

# Remove the temporary file after nvim exits.
rm "$tmpfile"
