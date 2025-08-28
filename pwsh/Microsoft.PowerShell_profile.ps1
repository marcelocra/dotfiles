# PowerShell 7 profile script.

# Use bash-like command line editing. To work more like bash, some adaptations
# are necessary. I documented them below, along with the defaults.
Set-PSReadLineOption -EditMode Emacs
# Default Emacs key bindings that works as expected:
#   - ctrl+a       move to beginning of line
#   - ctrl+e       move to end of line
#   - ctrl+u       delete from cursor to beginning of line
#   - ctrl+k       delete from cursor to end of line
#   - ctrl+p       previous command
#   - ctrl+n       next command
#   - ctrl/alt+f   move forward one character/word
#   - ctrl/alt+b   move backward one character/word
#   - alt+d        delete word to right of cursor
#   - ctrl+d       delete character under cursor
#   - ctrl+d       [nothing to delete] exit shell
#   - ctrl+c       [no selection] cancel current command
#   - ctrl+c       [with selection] copy selected text
#   - ctrl+v       paste text from clipboard
# Key bindings I changed to work more like bash:
# Delete word to the left of the cursor.
Set-PSReadLineKeyHandler -Key Ctrl+Backspace -Function BackwardKillWord
# Delete word to the right of the cursor.
Set-PSReadLineKeyHandler -Key Ctrl+Delete -Function DeleteWord
# Move backwards one word.
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
# Move forwards one word.
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
# Undo last change.
Set-PSReadLineKeyHandler -Key Ctrl+/ -Function Undo

# Launch the "Universal" Linux image.
# podman run -it --rm --name universal mcr.microsoft.com/devcontainers/universal:3-noble zsh

