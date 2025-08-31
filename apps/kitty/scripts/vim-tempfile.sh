#!/usr/bin/env bash

# Bail on error.
set -e

# Create a temporary file.
tmpfile=$(mktemp /tmp/kitty-nvim-tempfile.XXXXXX)

# Save standard input to the temporary file.
cat > "$tmpfile"

# Cleanup control sequences and open nvim.
file_to_run="$(mktemp)" && cat <<'EOF' > "$file_to_run"

import re
import sys

input_text = sys.stdin.read()

if not input_text:
    print("No input provided")
    sys.exit(1)

ansi_escape = re.compile(
    r"""
    \x1B                        # ESC
    (?:                         # Start non-capturing group for the rest
        [@-Z\-_]               # 7-bit C1 control codes
      | \[                      # CSI sequences:
          [0-?]*                # Parameter bytes
          [ -/]*                # Intermediate bytes
          [@-~]                 # Final byte
      | \]                      # OSC sequences:
          [^\x1B\x07]*          # Any characters except ESC and BEL
          (?:\x1B\\|\x07|\x1B)  # Terminated by ESC\ or BEL or a lone ESC
    )
    """,
    re.VERBOSE,
)

cleaned_text = ansi_escape.sub("", input_text)
sys.stdout.write(cleaned_text)
sys.exit(0)

EOF

cat "$tmpfile" | python3 "$file_to_run" | nvim -R -

# Remove the temporary Python file, as it already ran.
rm "$file_to_run"

# Remove the temporary file after nvim exits.
rm "$tmpfile"
