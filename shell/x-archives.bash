#!/usr/bin/env bash

# =============================================================================
# BASH/ZSH SCRIPTING CHEAT SHEET
# =============================================================================
#
# VARIABLES & PARAMETERS
#   $0                  - Script name
#   $1, $2, $3...       - Positional arguments
#   $#                  - Number of arguments
#   $@                  - All arguments as separate words (use "$@" with quotes)
#   $*                  - All arguments as single word
#   $?                  - Exit status of last command
#   $$                  - Current process ID
#   $!                  - PID of last background process
#   ${var:-default}     - Use default if var unset/null
#   ${var:=default}     - Assign default if var unset/null
#   ${var:?error}       - Error if var unset/null
#   ${var:+value}       - Use value if var is set
#   ${#var}             - Length of string
#   ${var#pattern}      - Remove shortest match from start
#   ${var##pattern}     - Remove longest match from start
#   ${var%pattern}      - Remove shortest match from end
#   ${var%%pattern}     - Remove longest match from end
#   ${var/pat/rep}      - Replace first match
#   ${var//pat/rep}     - Replace all matches
#
# CONDITIONALS
#   [[ ]] for bash      - Preferred (supports &&, ||, <, >, ==, !=, =~)
#   [ ] for POSIX       - Portable (requires -a, -o, escaped operators)
#   Always quote: [[ "$var" == "value" ]]
#
#   File tests:      -e exists, -f file, -d dir, -L symlink, -r readable
#                    -w writable, -x executable, -s non-empty
#   String tests:    -z empty, -n non-empty, == equal, != not equal
#   Numeric tests:   -eq, -ne, -lt, -le, -gt, -ge
#   Regex match:     [[ "$str" =~ ^[0-9]+$ ]]
#   Pattern match:   [[ "$str" == *.txt ]]
#
# LOOPS
#   for i in {1..10}; do echo $i; done
#   for file in *.txt; do echo "$file"; done
#   for ((i=0; i<10; i++)); do echo $i; done
#   while read line; do echo "$line"; done < file.txt
#   while [[ condition ]]; do ...; done
#   until [[ condition ]]; do ...; done
#
# FUNCTIONS
#   func() { local var="$1"; echo "$var"; }
#   func() { local var="$1"; return 0; }  # return 0-255
#   Always use 'local' for function variables
#
# REDIRECTIONS & PIPES
#   cmd > file            - Redirect stdout (overwrite)
#   cmd >> file           - Redirect stdout (append)
#   cmd 2> file           - Redirect stderr
#   cmd &> file           - Redirect both (bash only)
#   cmd > /dev/null 2>&1  - Discard all output (portable)
#   cmd1 | cmd2           - Pipe stdout to next command
#   cmd1 |& cmd2          - Pipe stdout and stderr (bash 4+)
#   cmd < file            - Read stdin from file
#   cmd <<< "text"        - Here string
#   cmd << EOF            - Here document
#
# COMMAND EXECUTION
#   $(cmd)                - Command substitution (preferred)
#   `cmd`                 - Command substitution (old style)
#   cmd1 && cmd2          - Run cmd2 only if cmd1 succeeds
#   cmd1 || cmd2          - Run cmd2 only if cmd1 fails
#   cmd1; cmd2            - Run sequentially
#   cmd &                 - Run in background
#   (cmd)                 - Run in subshell
#   { cmd; }              - Run in current shell (note spaces and semicolon)
#
# STRING MANIPULATION
#   "${arr[@]}"           - Expand array elements
#   "${!arr[@]}"          - Array indices/keys
#   str="hello world"
#   echo "${str^^}"       - HELLO WORLD (uppercase)
#   echo "${str,,}"       - hello world (lowercase)
#   echo "${str:0:5}"     - hello (substring)
#
# ARRAYS (bash/zsh)
#   arr=(one two three)
#   echo "${arr[0]}"      - First element
#   echo "${arr[@]}"      - All elements
#   echo "${#arr[@]}"     - Array length
#   arr+=(four)           - Append element
#
# ERROR HANDLING
#   set -e                 - Exit on error
#   set -u                 - Exit on undefined variable
#   set -o pipefail        - Exit if any pipe command fails
#   set -x                 - Print commands before executing (debug)
#   trap 'cleanup' EXIT    - Run cleanup on exit
#   trap 'handler' ERR     - Run handler on error
#
# USEFUL PATTERNS
#   command -v cmd >/dev/null 2>&1   - Check if command exists
#   [[ -n "${VAR:-}" ]]              - Safely check if var is set
#   cd "${0%/*}" || exit             - cd to script directory
#   readonly VAR="value"             - Make variable immutable
#   export VAR="value"               - Make available to child processes
#
# ARITHMETIC
#   $((expression))        - Arithmetic expansion
#   ((i++))                - Arithmetic command
#   let "i = i + 1"        - Let command
#   Example: sum=$((5 + 3))  # sum=8
#
# =============================================================================
# ZSH VS BASH: KEY DIFFERENCES
# =============================================================================
#
# ZSH-ONLY FEATURES (won't work in bash):
# ---------------------------------------
#
# 1. OPTION SYSTEM
#    setopt OPTION_NAME    - Enable option (bash uses 'shopt' or 'set')
#    unsetopt OPTION_NAME  - Disable option
#    Examples: setopt AUTO_CD, setopt CORRECT, setopt HIST_IGNORE_DUPS
#
# 2. AUTOLOADING
#    autoload -Uz func     - Load function on first use
#    Example: autoload -Uz compinit; compinit
#
# 3. ZSTYLE (configuration system)
#    zstyle ':completion:*' matcher-list 'm:{a-z}-{A-Z}'
#    Used for completions, prompts, and module configuration
#
# 4. PROMPT EXPANSION (different syntax)
#    %F{color}...%f        - Color text (bash uses \[\033[...m\])
#    %n                    - Username (bash: \u)
#    %m                    - Hostname (bash: \h)
#    %~                    - Current dir with ~ (bash: \w)
#    %#                    - # for root, % for user (bash: \$)
#
# 5. ARRAY INDEXING
#    Arrays start at 1 in zsh, 0 in bash!
#    zsh:  arr-(a b c); echo $arr[1]    # prints "a"
#    bash: arr-(a b c); echo ${arr[0]}  # prints "a"
#
# 6. PARAMETER EXPANSION FLAGS
#    ${(U)var}             - Uppercase (bash: ${var^^})
#    ${(L)var}             - Lowercase (bash: ${var,,})
#    ${(j:,:)arr}          - Join array with delimiter
#
# 7. EXTENDED GLOBBING (more powerful than bash)
#    **/*.txt              - Recursive glob (bash needs: shopt -s globstar)
#    *(.)                  - Only files
#    *(/)                  - Only directories
#    *(om)                 - Order by modification time
#    *(L0)                 - Empty files
#
# 8. HISTORY SHARING
#    setopt SHARE_HISTORY  - Share history between all shells immediately
#    (bash shares only on exit/startup)
#
# 9. SPELLING CORRECTION
#    setopt CORRECT        - Suggests corrections for commands
#    setopt CORRECT_ALL    - Suggests corrections for all arguments
#
# 10. COMPLETION SYSTEM
#     compinit             - Initialize zsh completions
#     (bash uses 'complete' command with different syntax)
#
# BASH-ONLY FEATURES (won't work in zsh):
# ---------------------------------------
#
# 1. shopt                - Bash shell options (zsh uses setopt)
#    Example: shopt -s histappend
#
# 2. HISTCONTROL          - Bash history control variable
#    (zsh uses setopt HIST_IGNORE_DUPS, etc.)
#
# 3. PROMPT_COMMAND       - Executed before each prompt (bash only)
#    (zsh uses precmd() function)
#
# 4. declare/typeset      - Different behavior between shells
#
# PORTABLE CODE TIPS:
# -------------------
#
#   - Check shell: [[ -n "${ZSH_VERSION:-}" ]] or [[ -n "${BASH_VERSION:-}" ]]
#   - Avoid array indexing differences - use loops instead
#   - Use [[ ]] for conditionals (works in both modern versions)
#   - Stick to common parameter expansion: ${var:-default}
#   - Test scripts in both shells if portability matters

# =============================================================================
# =============================== ARCHIVED CODE ===============================
# =============================================================================

# =============================================================================
# FUNCTIONS - MEDIA PROCESSING
# =============================================================================

# Compresses a video file using H.265 (HEVC) codec for better compression.
# Requires ffmpeg to be installed.
#
# Arguments:
#   $1 - Input video file (default: input.mp4)
#   $2 - Output video file (default: output.mp4)
#
# Returns:
#   1 if ffmpeg is not installed, 0 otherwise
#
# Example:
#   x-video-compress movie.mp4 movie_compressed.mp4
#   x-video-compress large_file.mp4  # Creates output.mp4
x-video-compress() {
    local input="${1:-input.mp4}"
    local output="${2:-output.mp4}"

    if ! command_exists ffmpeg; then
        echo "ERROR: ffmpeg is not installed"
        return 1
    fi

    ffmpeg -i "$input" -vcodec libx265 -crf 28 "$output"
}

# Extracts audio from MP4 video and saves as MP3.
# Requires ffmpeg to be installed.
#
# Arguments:
#   $1 - Input MP4 file (default: input.mp4)
#   $2 - Output MP3 file (default: output.mp3)
#
# Returns:
#   1 if ffmpeg is not installed, 0 otherwise
#
# Example:
#   x-mp3-from-mp4 video.mp4 audio.mp3
#   x-mp3-from-mp4 lecture.mp4  # Creates output.mp3
x-mp3-from-mp4() {
    local input="${1:-input.mp4}"
    local output="${2:-output.mp3}"

    if ! command_exists ffmpeg; then
        echo "ERROR: ffmpeg is not installed"
        return 1
    fi

    ffmpeg -i "$input" "$output"
}

# =============================================================================
# FUNCTIONS - CODE ANALYSIS
# =============================================================================

# Counts lines of code in git-tracked files matching specified patterns.
# Only counts files tracked by git, excluding specified patterns.
#
# Arguments:
#   --count, -c <pattern>    - File extensions to count (regex, default: js/ts/elm/sh)
#   --ignore, -i <pattern>   - Patterns to ignore (regex, default: compiled/vendored/etc)
#   --md-wrap, -w <lang>     - Wrap output in markdown code block (default: sh)
#   --no-md-wrap, -no-w      - Don't wrap output in markdown
#
# Alias: loc
#
# Example:
#   x-count-lines-of-code
#   loc --count '(py|rb)$' --ignore 'test'
#   loc -c 'rs$' -i 'target' --no-md-wrap
x-count-lines-of-code() {
    local to_count='(js|cjs|mjs|jsx|ts|cts|mts|tsx|elm|sh)$'
    local to_ignore='(compiled|vendored|cypress|e2e|bundle|config|example|[Ii]cons)'
    local md_wrap='sh'

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --count | -c)
            to_count="$2"
            shift 2
            ;;
        --ignore | -i)
            to_ignore="$2"
            shift 2
            ;;
        --md-wrap | -w)
            md_wrap="$2"
            shift 2
            ;;
        --no-md-wrap | -no-w)
            md_wrap=''
            shift
            ;;
        *)
            break
            ;;
        esac
    done

    # Only look at files tracked by git
    local cmd="git ls-files \
        | egrep \"$to_count\" \
        | egrep -v \"$to_ignore\" \
        | xargs wc -l"

    if [[ -n "$md_wrap" ]]; then
        echo '```'"$md_wrap"
    fi

    echo "looking at: $to_count"
    echo "ignoring: $to_ignore"
    echo -e "running command:\n  $cmd" | sed -E -e 's/\s{9}/\n    /g'
    echo "result:"

    bash -c "$cmd"

    if [[ -n "$md_wrap" ]]; then
        echo '```'
    fi
}


# =============================================================================
# FUNCTIONS - NEOVIM UTILITIES
# =============================================================================

# Backs up Neovim state directories with timestamp.
# Useful before major configuration changes or plugin updates.
#
# Backs up:
#   - ~/.local/share/nvim (data, plugins)
#   - ~/.local/state/nvim (state files)
#   - ~/.cache/nvim (cache files)
#
# Backup naming: original_name.YYYY-MM-DD_HH-MM-SS.bak
#
# Example:
#   x-nvim-backup-state  # Creates timestamped backups
x-nvim-backup-state() {
    local now
    now=$(date +%F_%T | sed -e 's/:/-/g')
    mv ~/.local/share/nvim{,."$now".bak}
    mv ~/.local/state/nvim{,."$now".bak}
    mv ~/.cache/nvim{,."$now".bak}
}

# Backs up Neovim state to a temporary directory.
# Similar to x-nvim-backup-state but uses system temp directory.
#
# Backs up:
#   - ~/.local/share/nvim -> local-share-nvim
#   - ~/.local/state/nvim -> local-state-nvim
#   - ~/.cache/nvim -> cache-nvim
#   - ~/.config/nvim/lazy-lock.json -> lazy-lock.json
#
# Creates temp directory: /tmp/nvim_YYYY-MM-DD_HH-MM-SS_XXXXXX
# Prints the temp directory path after backup.
#
# Example:
#   x-nvim-backup-to-tmp
x-nvim-backup-to-tmp() {
    # Make a tmp folder with the current date
    local tmp_dir
    tmp_dir=$(mktemp -d -t "nvim_$(date +%F_%T | sed -e 's/:/-/g')_XXXXXX")

    mv ~/.local/share/nvim "$tmp_dir/local-share-nvim"
    mv ~/.local/state/nvim "$tmp_dir/local-state-nvim"
    mv ~/.cache/nvim "$tmp_dir/cache-nvim"
    mv ~/.config/nvim/lazy-lock.json "$tmp_dir"

    echo "Neovim state backed up to: $tmp_dir"
}

# =============================================================================
# FUNCTIONS - NOTIFICATION & TIMER
# =============================================================================

# Sends a desktop notification (if notify-send available) or prints to console.
# Used by timer functions to alert when time is up.
#
# Arguments:
#   $1 - Summary/title (default: "TEMPO ACABOU!", uppercased if provided)
#   $2 - Body/content (default: Portuguese message)
#
# Example:
#   x-timer-notification "Break time" "Take a 5 minute break"
#   x-timer-notification  # Uses default messages
x-timer-notification() {
    local summary="${1:-TEMPO ACABOU!}"
    local content="${2:-Pronto! Hora de ir para a próxima tarefa!}"

    if [[ -n "$1" ]]; then
        summary="$(echo "$summary" | tr '[:lower:]' '[:upper:]') - TEMPO ACABOU!"
    fi

    if command_exists notify-send; then
        notify-send -u critical "$summary" "$content"
    else
        echo "TIMER: $summary"
        echo "$content"
    fi
}

# Countdown timer that sends notification when complete.
# Supports various time formats: 30s, 5m, 2h, 1h30m.
#
# Arguments:
#   $1 - Time duration (default: 30m)
#        Formats: Xs (seconds), Xm (minutes), Xh (hours), XhYm (combined)
#
# Convenience aliases:
#   t5, t15, t30, t60 - 5, 15, 30, 60 minute timers
#
# Example:
#   x-timer 25m       # Pomodoro timer
#   x-timer 1h30m     # 90 minute timer
#   t15             # Quick 15 minute timer
x-timer() {
    local time="${1:-30m}"

    if [[ -z "$1" ]]; then
        echo "No time provided, using default ($time)."
        echo "Format: 1s, 20m, 2h, 1h20m or use templates: t5, t15, t30, t60 (minutes)"
    fi

    sleep "$time" && x-timer-notification
}

# # Timer aliases
# alias t5="sleep 5m && x-timer-notification"
# alias t15="sleep 15m && x-timer-notification"
# alias t30="sleep 30m && x-timer-notification"
# alias t60="sleep 1h && x-timer-notification"

# =============================================================================
# FUNCTIONS - AI HELPERS
# =============================================================================

# Sends a question to Claude AI via CLI.
# Requires @anthropic-ai/claude-code npm package.
#
# Arguments:
#   $* - Question or prompt for Claude
#
# Returns:
#   1 if Claude CLI not installed, 0 otherwise
#
# Installation:
#   npm install -g @anthropic-ai/claude-code
#
# Example:
#   x-ask-claude "optimize this JavaScript function"
#   x-ask-claude "explain git rebase"
x-ask-claude() {
    if [ -z "$1" ]; then
        echo "Usage: x-ask-claude \"your question here\""
        echo "Example: x-ask-claude \"optimize this JavaScript function\""
        return 1
    fi

    if command_exists claude; then
        echo "🤖 Claude: Processing your request..."
        claude chat --message "$*"
    else
        echo "❌ Claude CLI not installed. Install with: npm install -g @anthropic-ai/claude-code"
        return 1
    fi
}

# Sends a question to Google Gemini AI via CLI.
# Requires @google/gemini-cli npm package.
#
# Arguments:
#   $* - Question or prompt for Gemini
#
# Returns:
#   1 if Gemini CLI not installed, 0 otherwise
#
# Installation:
#   npm install -g @google/gemini-cli
#
# Example:
#   x-ask-gemini "explain this code pattern"
#   x-ask-gemini "best practices for React hooks"
x-ask-gemini() {
    if [ -z "$1" ]; then
        echo "Usage: x-ask-gemini \"your question here\""
        echo "Example: x-ask-gemini \"explain this code pattern\""
        return 1
    fi

    if command_exists gemini; then
        echo "✨ Gemini: Processing your request..."
        gemini "$*"
    else
        echo "❌ Gemini CLI not installed. Install with: npm install -g @google/gemini-cli"
        return 1
    fi
}

# Analyzes current project structure and provides statistics.
# Works best in git repositories. Optionally uses Claude AI for deeper analysis.
#
# Displays:
#   - Total file count
#   - Git tracked files count
#   - Programming languages detected (by extension)
#   - AI-powered analysis (if Claude CLI available)
#
# Returns:
#   1 if not in a git repository, 0 otherwise
#
# Example:
#   cd my_project
#   x-analyze  # Shows project statistics and AI insights
x-analyze() {
    if [[ ! -d .git ]]; then
        echo "❌ This function works best in git repositories"
        return 1
    fi

    echo "🔍 Project Analysis:"
    echo "Files: $(find . -type f | wc -l)"
    echo "Git tracked files: $(git ls-files | wc -l)"
    echo "Languages: $(find . -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.html" -o -name "*.css" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.c" -o -name "*.cpp" | sed 's/.*\.//' | sort | uniq -c)"
    echo ""

    if command_exists claude; then
        x-ask-claude "analyze this project structure: $(ls -la)"
    else
        echo "💡 Install Claude CLI for AI-powered project analysis"
    fi
}

# Gets AI-powered explanation and improvement suggestions for a code file.
# Requires Claude CLI to be installed.
#
# Arguments:
#   $1 - File path to analyze
#
# Example:
#   x-codehelp index.js
#   x-codehelp src/components/Button.tsx
x-codehelp() {
    if [ -f "$1" ]; then
        echo "📖 Getting help for: $1"
        if command_exists claude; then
            x-ask-claude "explain and suggest improvements for this code: $(cat "$1")"
        else
            echo "❌ Claude CLI not installed. Install with: npm install -g @anthropic-ai/claude-code"
        fi
    else
        echo "Usage: x-codehelp <filename>"
        echo "Example: x-codehelp index.js"
    fi
}

# Prints instructions on how to deal with WSL distributions on Windows.
x-wsl-help() {
    echo '
INFO: Set default distro: wsl.exe --set-default <DistroName>
INFO: Run distro: wsl.exe --distribution <DistroName>
INFO: Install distro: wsl.exe --install [Distro] --name <Name> --no-launch
'
}

# Next archive above - keep this comment at the bottom.

