#!/usr/bin/env bash

# Repeats '=' 100 times. Change that to any other character that you care about,
# but be careful because not all terminal emulators can render all chars.
printf '=%.0s' {1..100}

# Same as above, but using a dynamic variable (for example, $COLUMN).
printf '=%.0s' $(seq 1 $LIMIT)

# This is another way of doing it, with variables too.
printf "%${COLUMNS}s\n" | tr " " "="

# Seems like the first two options are essentially using loops, while the third
# is not. For more info, check:
#
# https://stackoverflow.com/q/5349718/1814970

# Simple way to convert all EOL characters to LF.
# Be careful if you have folders like `node_modules`, as it
# could take a VERY long time to finish (if it does).
prettier --end-of-line lf --write .
