#!/usr/bin/env bash
# Main shell configuration script for Linux environments
# Supports Ubuntu containers, Alpine containers, and openSUSE Tumbleweed
# Assumes zsh and oh-my-zsh are installed
#
# Follows Google Shell Style Guide:
#   https://google.github.io/styleguide/shellguide.html

# =============================================================================
# ENVIRONMENT DETECTION
# =============================================================================

detect_environment() {
    # Container detection (works for both Docker and Podman)
    if [[ -f /.dockerenv ]] || [[ -n "${CONTAINER:-}" ]] || [[ -f /run/.containerenv ]]; then
        export DOTFILES_IN_CONTAINER="true"
    else
        export DOTFILES_IN_CONTAINER="false"
    fi

    if grep -q Microsoft /proc/version 2>/dev/null || \
       grep -q WSL2 /proc/version 2>/dev/null; then
        export DOTFILES_IN_WSL="true"
    else
        export DOTFILES_IN_WSL="false"
    fi

    # Distribution detection
    if [[ -f /etc/alpine-release ]]; then
        export DOTFILES_DISTRO="alpine"
    elif [[ -f /etc/os-release ]]; then
        if grep -q "Ubuntu" /etc/os-release; then
            export DOTFILES_DISTRO="ubuntu"
        elif grep -q "openSUSE" /etc/os-release; then
            export DOTFILES_DISTRO="opensuse"
        else
            export DOTFILES_DISTRO="linux"
        fi
    else
        export DOTFILES_DISTRO="unknown"
    fi
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Add directory to PATH only if it exists and isn't already in PATH.
add_to_path() {
    local dir="$1"
    [[ ! -d "$dir" ]] && return 1
    case ":$PATH:" in
        *":$dir:"*) return 0 ;;
        *) export PATH="$dir:$PATH" ;;
    esac
}

log_debug() {
    if [[ "${DOTFILES_DEBUG:-0}" == "1" ]]; then
        echo "🔍 $*" >&2
    fi
}

# =============================================================================
# EDITOR CONFIGURATION
# =============================================================================

configure_editor() {
    if command_exists nvim; then
        export EDITOR='nvim'
        export MANPAGER='nvim +Man!'
    elif command_exists vim; then
        export EDITOR='vim'
    elif command_exists vi; then
        export EDITOR='vi'
    else
        log_debug "No vi-compatible editor found, using nano"
        export EDITOR='nano'
    fi

    # Hopefully Neovim (hence 'n'). Works for Nano too.
    alias n="$EDITOR"
}

# =============================================================================
# EXPORTS
# =============================================================================

configure_exports() {
    # User bin directories.
    add_to_path "$HOME/bin"
    add_to_path "$HOME/.local/bin"
    
    # Pnpm global store (only if pnpm is installed or likely to be used).
    if command_exists pnpm || [[ -d "$HOME/.local/share/pnpm" ]]; then
        export PNPM_HOME="$HOME/.local/share/pnpm"
        add_to_path "$PNPM_HOME"
    fi
    
    # Add more PATH entries here using: add_to_path "/path/to/dir"
}

# Next export marker.

# =============================================================================
# PLATFORM-SPECIFIC CONFIGURATION
# =============================================================================

configure_platform() {
    case "$DOTFILES_DISTRO" in
        "ubuntu"|"opensuse")
            # Swap Caps Lock and Ctrl when using X11
            if [[ "$DOTFILES_IN_CONTAINER" != "true" ]]; then
                export XKB_DEFAULT_OPTIONS="ctrl:swapcaps"
            fi
            ;;
        "alpine")
            # Alpine uses doas instead of sudo
            if command_exists doas && ! command_exists sudo; then
                alias sudo="doas"
            fi
            ;;
    esac

    # Container-specific configurations
    if [[ "$DOTFILES_IN_CONTAINER" == "true" ]]; then
        export DEBIAN_FRONTEND=noninteractive
        unset XKB_DEFAULT_OPTIONS 2>/dev/null || true
    fi
}

# =============================================================================
# ALIASES - SYSTEM & NAVIGATION
# =============================================================================

configure_system_aliases() {
    # Navigation
    alias b="popd"
    alias cls="clear"

    # File listing with distribution-specific options
    case "$DOTFILES_DISTRO" in
        "alpine")
            # Alpine's ls has limited options
            alias l='ls -lFh -t'
            ;;
        *)
            # GNU ls with enhanced features
            alias l='ls -F --group-directories-first --color=always --time-style="+%d%b%y-%Hh%M" -ltho'
            ;;
    esac

    alias ll='l -A'

    # File operations
    alias untar="tar -xf"

    # Search tools (prefer ripgrep > egrep > grep)
    if command_exists rg; then
        alias g='rg'
    elif command_exists egrep; then
        alias g='egrep'
    elif command_exists grep; then
        alias g='grep'
    fi

    # Less configuration (Alpine doesn't support --use-color)
    case "$DOTFILES_DISTRO" in
        "alpine")
            export LESS='-R'
            ;;
        *)
            export LESS='-R --use-color'
            ;;
    esac

    # Package management shortcuts
    if command_exists batcat; then
        alias bat='batcat'  # Ubuntu's naming
    fi
}

# =============================================================================
# ALIASES - DEVELOPMENT
# =============================================================================

configure_dev_aliases() {
    # Package managers
    alias p="pnpm"
    alias pf="pnpm --filter"
    alias r="pnpm run"
    alias rf="pnpm run --filter"

    # Babashka
    alias bbg="bb --config ~/.config/babashka/bb.edn"
    alias bbge='$EDITOR ~/.config/babashka/bb.edn'

    # Node.js utilities
    alias tsx='pnpx tsx'

    # Python
    alias initpy='uv init && uv venv && uv add pip && venv_activate'

    # System info
    alias colines='echo "Columns: $COLUMNS, Lines: $LINES"'
    alias path_print='echo $PATH | tr ":" "\n"'
    alias ppath='path_print'
    alias path_print_unique='path_print | sort | uniq'
    alias ppathu='path_print_unique'

    # Tree shortcuts
    alias t1="tree -L 1"
    alias t2="tree -L 2"
    alias t3="tree -L 3"
    alias t4="tree -L 4"
    alias t5="tree -L 5"

    # VS Code
    if command_exists code; then
        alias diffc="code -d"
        if ! command_exists codene; then
            alias codene='code --disable-extensions'
        fi
    fi

    # Neovim
    if [[ "$EDITOR" == "nvim" ]]; then
        alias vimdiff="nvim -d"
        alias nvim_none='nvim -u NONE'
        alias nvim_norc='nvim -u NORC'
        alias nvim_noplugin='nvim --noplugin'
    fi

    # Better command defaults
    alias sed='sed -E'  # Always use extended regex
}

# =============================================================================
# ALIASES - PNPM UTILITIES
# =============================================================================

configure_pnpm_aliases() {
    # Frontend frameworks and utilities
    alias pnpm_add_tailwind="pnpm add -D @tailwindcss/typography daisyui@latest tailwindcss postcss autoprefixer tailwind-merge react-markdown && npx tailwindcss init -p"
    alias pnpm_add_tailwind_utils="pnpm add -D tailwind-merge @popperjs/core @tailwindcss/typography daisyui@latest tailwind-merge react-markdown"
    alias pnpm_add_flowbite_svelte="pnpm add -D flowbite-svelte flowbite flowbite-svelte-icons"
    alias pnpm_add_mui='pnpm add @mui/material @emotion/react @emotion/styled @mui/icons-material'
    alias pnpm_add_mui2='echo "Add this to your index.html:\n\n\n<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\" />
<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin />
<link
  rel=\"stylesheet\"
  href=\"https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap\"
/>"'

    # Utility libraries
    alias pnpm_add_lodash="pnpm add -D lodash @types/lodash"
    alias pnpm_add_immer="pnpm add immer use-immer"

    # Package management
    alias pnpm_clean="rm ./pnpm-lock.yaml && rm -rf ./node_modules && pnpm install"
}

# =============================================================================
# ALIASES - FONTS
# =============================================================================

configure_font_aliases() {
    alias fonts_update_cache="fc-cache -fv"
    alias fonts_rebuild_cache="sudo fc-cache -r -v"
    alias fonts_list="ll ~/.local/share/fonts"
    alias list_mono_fonts='fc-list : family spacing outline scalable | grep -e spacing=100 -e spacing=90 | grep -e outline=True | grep -e scalable=True'
}

# =============================================================================
# ALIASES - GIT
# =============================================================================

configure_git_aliases() {
    # Status and info
    alias gs='git status'
    alias gss='git status -s'      # Simple and resumed, no branches
    alias gsb='git status -sb'     # Simple and resumed, with branches

    # Adding and committing
    alias ga='git add'
    alias gaa='git add --all'
    alias gc='git commit -v'
    alias gcm='git commit -m'
    alias gac='gaa && gc'
    alias gacm='gaa && gcm'

    # Branching and navigation
    alias gb='git branch'
    alias gbd='git branch -d'
    alias gco='git checkout'
    alias gco-='git checkout -'    # Go back to previous branch

    # Viewing changes
    alias gd='git d'
    alias gdk='git dk'

    # Remote operations
    alias gpl="git pull"
    alias gps="git push"
    alias gpss="git push --set-upstream"
    alias gpd='git push --dry-run'

    # Logging
    alias gld="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
    alias gl="gld -10"
    alias gla="gld"
    alias glg='git log --oneline --decorate --graph --all'  # git log graph
    alias glsa="git log --oneline --no-decorate"            # git log simple all
    alias gls="glsa -5"
    alias glm='git log --pretty=format:"* %s"'              # git log messages

    # Restoring and stashing
    alias grs='git restore'
    alias grss='git restore --staged'
    alias grssa='git restore --staged .'
    alias gst='git stash'
    alias gsta='git stash apply'
    alias gstc='git stash clear'
    alias gstd='git stash drop'
    alias gstl='git stash list'
    alias gstp='git stash push -m'
    alias gsts='git stash show --text'
    alias gstall='git stash --all'

    # Showing and tagging
    alias gsh='git show'
    alias gsps='git show --pretty=short --show-signature'
    alias gt='git tag'
    alias gta='git tag -a'
    alias gts='git tag -s'
    alias gtv='git tag | sort -V'

    # Utilities
    alias gchanges='git whatchanged -p --abbrev-commit --pretty=medium'
    alias git-undo-last='git reset HEAD~'
    alias gr='git remote'
    alias grc='gr set-url'
    alias grco='grc origin'
    alias gcct="echo 'git conventional commit types (gcct): fix, feat, build, chore, ci, docs, style, refactor, perf, test'"

    # Git LFS
    alias glfsdry="git lfs push origin main --dry-run --all"
    alias glfss="git lfs status"
}

# Next git alias marker

# =============================================================================
# ALIASES - DOCKER/PODMAN
# =============================================================================

configure_docker_aliases() {
    # alias pod='podman'
    # alias docker='podman'
    # alias dc="docker compose"
    # alias docker-prune-month-old-images='docker image prune -a --filter "until=720h"'
    # alias docker-prune-two-week-old-images='docker image prune -a --filter "until=336h"'
}

# Next docker alias marker

# =============================================================================
# ALIASES - SYSTEM UTILITIES
# =============================================================================

configure_system_utility_aliases() {
    # Text to speech (Portuguese)
    alias say="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"
    alias fala="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"
    alias falar="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"

    # Process and port monitoring
    alias list_process_to_port_all="netstat -lnp"
    alias list_process_to_port_tcp="netstat -lnpt"
    alias list_process_by_mem='ps -eo pid,comm,rss --sort=-rss \
        | awk '\''NR == 1 { printf "%-10s %-20s %-10s\n", $1, $2, $3 } \
                  NR  > 1 { printf "%-10s %-20s %-10s\n", $1, $2, $3/1024 }'\'' \
        | column -t'
    alias mem='list_process_by_mem | less'

    # System information
    alias monitor_show_dpi="xdpyinfo | grep dots"
    alias last_login="last -10"
    alias system_info='cat /etc/os-release && lsb_release -a && hostnamectl && uname -r'
    alias list_installed_packages='dpkg --get-selections | grep -v deinstall'
    alias list_devices='lsblk -o NAME,SIZE,FSTYPE,MODEL'

    # File operations
    alias files_cwd_size_in_mb='ls -la | awk '\''{sum += $5} END {print sum/1024/1024 " MB"}'\'''
    alias files_size_in_mb='awk '\''{sum += $5} END {print sum/1024/1024 " MB"}'\'''
    alias folder_diff='diff --brief --recursive --new-file'
    alias change_owners='sudo chown -R $USER:$USER'

    # Utilities
    alias chrome_br='LANGUAGE=pt_BR google-chrome-stable'
    alias grub_update='sudo update-grub'
    alias time_ago="date -d '10 hours ago' +%s%3N"
    alias shasum_easy='echo "b87366b62eddfbecb60e681ba83299c61884a0d97569abe797695c8861f5dea4 *ubuntu-25.04-desktop-amd64.iso" | shasum -a 256 --check'
    alias path_clean='env -i sh -c '\''echo $PATH'\'''

    # Better command tools
    if command_exists kitten; then
        alias d='kitten diff'
    fi

    # GitHub Copilot CLI
    if command_exists ghcs; then
        alias copilot="ghcs"
        alias cpl="copilot"
    fi

    # Lua with readline wrapper
    if command_exists rlwrap; then
        alias lua='rlwrap lua'
    fi

    # TODO: make this system specific.
    alias i='sudo dnf install'

    # Next alias marker
}

# =============================================================================
# FUNCTIONS - TMUX
# =============================================================================

tmx() {
    local session_name="${1:-default}"

    # Try to create a new session
    if ! tmux new -s "$session_name" >/dev/null 2>&1; then
        echo "Trying to reuse session $session_name..."
        sleep 0.5
        # Try to load existing session
        if ! tmux attach-session -t "$session_name" >/dev/null 2>&1; then
            echo "An error happened. Couldn't load $session_name"
            return 1
        fi
    fi
}

alias t='tmx'

# =============================================================================
# FUNCTIONS - DATE/TIME
# =============================================================================

today() {
    date +%F
}

time_format() {
    date +%Hh%M
}

# =============================================================================
# FUNCTIONS - ARCHIVE OPERATIONS
# =============================================================================

zip_dir() {
    local folder_to_zip="$1"
    local zip_name="${2:-$(basename "$folder_to_zip")}"

    if [[ -z "$folder_to_zip" ]]; then
        echo "Usage: zip_dir <folder-to-zip> [zip-name]"
        echo "Error: The first argument is required."
        return 1
    fi

    if [[ ! -d "$folder_to_zip" ]]; then
        echo "Usage: zip_dir <folder-to-zip> [zip-name]"
        echo "Error: '$folder_to_zip' is not a directory."
        return 1
    fi

    if ! command_exists zip; then
        echo 'zip is not installed or not in the path'
        return 1
    fi

    (
        cd "$(dirname "$folder_to_zip")" || exit 1
        zip -r "$zip_name" "$(basename "$folder_to_zip")"
    )
}

# =============================================================================
# FUNCTIONS - FILE OPERATIONS
# =============================================================================

regexfind() {
    local dir="$1"
    local regex="$2"

    if [[ ! -d "$dir" ]]; then
        echo "ERROR: '$dir' is not a directory"
        return 1
    fi

    find "$dir" -regextype egrep -regex "$regex"
}

alias rfind='regexfind'

broken_symlinks() {
    find "${1:-.}" -type l ! -exec test -e {} \; -exec ls -lah --color {} \;
}

# =============================================================================
# FUNCTIONS - CODE ANALYSIS
# =============================================================================

count_lines_of_code() {
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

alias loc='count_lines_of_code'

# =============================================================================
# FUNCTIONS - PROJECT AUTOMATION
# =============================================================================

x() {
    # Execute stuff depending on what is in the folder
    local nx_json='nx.json'
    local package_json='package.json'

    if [[ -f "$nx_json" ]]; then
        if [[ $# -eq 0 ]]; then
            echo "No arguments given. Listing all 'nx' tasks."
            echo
            pnpx nx show projects | sort
        else
            echo "Running 'nx' with the given arguments."
            echo
            pnpx nx "$@"
        fi
    elif [[ -f "$package_json" ]]; then
        if [[ $# -eq 0 ]]; then
            echo "No arguments given. Listing all 'pnpm' scripts."
            echo
            cat package.json | jq -r '.scripts|to_entries[]| .key + " -> " + .value'
        else
            echo "Running 'pnpm run' with the given arguments."
            echo
            pnpm run "$@"
        fi
    else
        echo "No 'nx.json' or 'package.json' found in the current directory. Exiting."
        return 1
    fi
}

# =============================================================================
# FUNCTIONS - MEDIA PROCESSING
# =============================================================================

video_compress() {
    local input="${1:-input.mp4}"
    local output="${2:-output.mp4}"

    if ! command_exists ffmpeg; then
        echo "ERROR: ffmpeg is not installed"
        return 1
    fi

    ffmpeg -i "$input" -vcodec libx265 -crf 28 "$output"
}

mp3_from_mp4() {
    local input="${1:-input.mp4}"
    local output="${2:-output.mp3}"

    if ! command_exists ffmpeg; then
        echo "ERROR: ffmpeg is not installed"
        return 1
    fi

    ffmpeg -i "$input" "$output"
}

# =============================================================================
# FUNCTIONS - PYTHON ENVIRONMENT
# =============================================================================

venv_activate() {
    local the_venv="./.venv/bin/activate"

    if [[ -f "$the_venv" ]]; then
        source "$the_venv"
        return 0
    fi

    the_venv="$HOME/.python-global-venv/.venv/bin/activate"
    if [[ -f "$the_venv" ]]; then
        source "$the_venv"
        return 0
    fi

    echo 'No valid venv found.'
    return 1
}

alias va='venv_activate'

# =============================================================================
# FUNCTIONS - NEOVIM UTILITIES
# =============================================================================

nvim_backup_state() {
    local now
    now=$(date +%F_%T | sed -e 's/:/-/g')
    mv ~/.local/share/nvim{,."$now".bak}
    mv ~/.local/state/nvim{,."$now".bak}
    mv ~/.cache/nvim{,."$now".bak}
}

nvim_backup_to_tmp() {
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

timer_notification() {
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

timer() {
    local time="${1:-30m}"

    if [[ -z "$1" ]]; then
        echo "No time provided, using default ($time)."
        echo "Format: 1s, 20m, 2h, 1h20m or use templates: t5, t15, t30, t60 (minutes)"
    fi

    sleep "$time" && timer_notification
}

# Timer aliases
alias t5="sleep 5m && timer_notification"
alias t15="sleep 15m && timer_notification"
alias t30="sleep 30m && timer_notification"
alias t60="sleep 1h && timer_notification"

# =============================================================================
# FUNCTIONS - AI HELPERS
# =============================================================================

ask_claude() {
    if [ -z "$1" ]; then
        echo "Usage: ask_claude \"your question here\""
        echo "Example: ask_claude \"optimize this JavaScript function\""
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

ask_gemini() {
    if [ -z "$1" ]; then
        echo "Usage: ask_gemini \"your question here\""
        echo "Example: ask_gemini \"explain this code pattern\""
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

analyze() {
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
        ask_claude "analyze this project structure: $(ls -la)"
    else
        echo "💡 Install Claude CLI for AI-powered project analysis"
    fi
}

codehelp() {
    if [ -f "$1" ]; then
        echo "📖 Getting help for: $1"
        if command_exists claude; then
            ask_claude "explain and suggest improvements for this code: $(cat "$1")"
        else
            echo "❌ Claude CLI not installed. Install with: npm install -g @anthropic-ai/claude-code"
        fi
    else
        echo "Usage: codehelp <filename>"
        echo "Example: codehelp index.js"
    fi
}

# =============================================================================
# FUNCTIONS - MISC
# =============================================================================

# Load SSH agent and add key.
load_ssh() {
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
}

# Next function marker

# =============================================================================
# ZSH CONFIGURATION
# =============================================================================

configure_zsh() {
    # Only configure zsh-specific features if we're running in zsh
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        # Common configuration (applies to both oh-my-zsh and standalone)
        export HISTFILE="$HOME/.zsh_history"
        export HISTSIZE=10000
        export SAVEHIST=10000
        export HIST_STAMPS="yyyy-mm-dd"

        if [[ -d "$HOME/.oh-my-zsh" ]]; then
            # Oh-my-zsh setup (handles most configuration automatically)
            export ZSH="$HOME/.oh-my-zsh"
            export ZSH_CUSTOM="$ZSH/custom"

            # Use custom theme from dotfiles
            local ZSH_THEME_PATH="$HOME/prj/dotfiles/shell/marcelocra.zsh-theme"
            if [[ -f "$ZSH_THEME_PATH" ]]; then
                # Symlink custom theme to oh-my-zsh themes directory
                ln -sf "$ZSH_THEME_PATH" "$ZSH_CUSTOM/themes/"
                ZSH_THEME="marcelocra"
            else
                # Fallback to a safe default theme
                ZSH_THEME="robbyrussell"
            fi

            # Enable oh-my-zsh plugins (keep minimal for security)
            if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
                plugins=(zsh-autosuggestions zsh-syntax-highlighting)
            else
                plugins=()
            fi

            # Source oh-my-zsh
            source "$ZSH/oh-my-zsh.sh"
        else
            # Standalone zsh setup (when oh-my-zsh not available)

            # History options
            setopt HIST_IGNORE_DUPS
            setopt HIST_IGNORE_ALL_DUPS
            setopt HIST_SAVE_NO_DUPS
            setopt SHARE_HISTORY
            setopt APPEND_HISTORY

            # Enable completion system
            autoload -Uz compinit
            compinit

            # Completion options
            setopt COMPLETE_IN_WORD     # complete from both ends of word
            setopt ALWAYS_TO_END        # move cursor to end of word on completion
            setopt AUTO_MENU            # show completion menu on successive tab press
            setopt AUTO_LIST            # automatically list choices on ambiguous completion
            setopt AUTO_PARAM_SLASH     # add trailing slash for directory completions

            # Case-insensitive completion
            zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

            # Basic prompt
            setopt PROMPT_SUBST
            PS1='%F{green}%n@%m%f %F{blue}%~%f %# '
        fi

        # Common zsh options (useful for both setups)
        setopt AUTO_CD              # cd by typing directory name if it's not a command
        setopt CORRECT              # command auto-correction
        setopt COMPLETE_ALIASES     # complete aliases

        # Make Ctrl+U behave like bash (kill from cursor to beginning of line)
        # Default zsh behavior kills the entire line
        bindkey '^U' backward-kill-line

        # Configure fzf if installed.
        if command_exists fzf && fzf --zsh >/dev/null 2>&1; then
            eval "$(fzf --zsh)"
        else
            [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
            [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
        fi
    fi
}

# =============================================================================
# BASH CONFIGURATION
# =============================================================================

configure_bash() {
    # Only configure bash-specific features if we're running in bash
    if [[ -n "${BASH_VERSION:-}" ]]; then
        # History configuration
        export HISTSIZE=10000
        export HISTFILESIZE=10000
        export HISTCONTROL=ignoredups:erasedups
        export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
        shopt -s histappend

        # Custom prompt with git branch and timestamp
        __bash_prompt() {
            local userpart='`export XIT=$? \
                && [ ! -z "${GITHUB_USER:-}" ] && echo -n "\[\033[0;32m\]@${GITHUB_USER:-} " || echo -n "\[\033[0;32m\]\u " \
                && [ "$XIT" -ne "0" ] && echo -n "\[\033[1;31m\]➜" || echo -n "\[\033[0m\]➜"`'
            local gitbranch='`\
                if [ "$(git config --get devcontainers-theme.hide-status 2>/dev/null)" != 1 ] && [ "$(git config --get codespaces-theme.hide-status 2>/dev/null)" != 1 ]; then \
                    export BRANCH="$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git --no-optional-locks rev-parse --short HEAD 2>/dev/null)"; \
                    if [ "${BRANCH:-}" != "" ]; then \
                        echo -n "\[\033[0;36m\](\[\033[1;31m\]${BRANCH:-}" \
                        && if [ "$(git config --get devcontainers-theme.show-dirty 2>/dev/null)" = 1 ] && \
                            git --no-optional-locks ls-files --error-unmatch -m --directory --no-empty-directory -o --exclude-standard ":/*" > /dev/null 2>&1; then \
                                echo -n " \[\033[1;33m\]✗"; \
                        fi \
                        && echo -n "\[\033[0;36m\]) "; \
                    fi; \
                fi`'
            local timestamp='`echo -n "\[\033[33m\][$(date "+%Y-%m-%d %H:%M:%S")]\[\033[0m\]"`'
            local lightblue='\[\033[1;34m\]'
            local removecolor='\[\033[0m\]'
            PS1="${userpart} ${lightblue}\w ${gitbranch}${timestamp}${removecolor}\n\$ "
            unset -f __bash_prompt
        }
        __bash_prompt
        export PROMPT_DIRTRIM=4

        # Terminal title configuration for xterm
        if [[ "$TERM" == "xterm" ]]; then
            preexec() {
                local cmd="${BASH_COMMAND}"
                echo -ne "\033]0;${USER}@${HOSTNAME}: ${cmd}\007"
            }

            precmd() {
                echo -ne "\033]0;${USER}@${HOSTNAME}: ${SHELL}\007"
            }

            trap 'preexec' DEBUG
            PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }precmd"
        fi

        # Configure fzf if installed.
        if command_exists fzf && fzf --bash >/dev/null 2>&1; then
            eval "$(fzf --bash)"
        else
            [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
        fi
    fi
}

# =============================================================================
# MISE
# =============================================================================

configure_mise() {
    # Only activate mise if it's enabled and installed.
    # The installation should happen in the one-time setup script.
    if [ "${MCRA_USE_MISE:-}" = "true" ] && command_exists mise; then
        log_debug "Activating mise..."
        eval "$(mise activate zsh)"
        export PATH="$HOME/.local/bin:$PATH"
        log_debug "Done!"
    else
        log_debug "Mise activation skipped (MCRA_USE_MISE not enabled or mise not found)"
    fi
}

# =============================================================================
# FZF
# =============================================================================

configure_fzf() {
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'
}

# =============================================================================
# MAIN INITIALIZATION
# =============================================================================

main() {
    detect_environment
    configure_editor
    configure_exports
    configure_platform
    configure_zsh
    configure_bash
    configure_system_aliases
    configure_dev_aliases
    configure_pnpm_aliases
    configure_font_aliases
    configure_git_aliases
    configure_docker_aliases
    configure_system_utility_aliases
    configure_mise
    configure_fzf

    log_debug "Dotfiles initialized for $DOTFILES_DISTRO"
    log_debug "Container: $DOTFILES_IN_CONTAINER, WSL: $DOTFILES_IN_WSL"
}

# Only run main if script is sourced, not executed.
# Works for bash and zsh (not pure POSIX sh).
if ! (return 0 2>/dev/null); then
    echo "This script should be sourced, not executed directly."
    echo "Use: source $0"
    exit 1
fi

main "$@"

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
