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

# Detects the current execution environment and sets global environment variables.
#
# Exports:
#   DOTFILES_IN_CONTAINER - "true" if running in a container (Docker/Podman), "false" otherwise
#   DOTFILES_IN_WSL       - "true" if running in WSL/WSL2, "false" otherwise
#   DOTFILES_DISTRO       - Distribution name: "alpine", "ubuntu", "opensuse", "linux", or "unknown"
#
# Detection methods:
#   - Container: Checks for /.dockerenv, CONTAINER env var, or /run/.containerenv
#   - WSL: Searches for "Microsoft" or "WSL2" in /proc/version
#   - Distro: Reads /etc/alpine-release and /etc/os-release
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

# Checks if a command exists in the current PATH.
#
# Returns:
#   0 if command exists, non-zero otherwise
#
# Example:
#   if command_exists nvim; then
#     echo "Neovim is installed"
#   fi
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Adds a directory to PATH if it exists and isn't already present.
# Prepends the directory to ensure it takes precedence over existing entries.
#
# Arguments:
#   $1 - Directory path to add to PATH
#
# Returns:
#   1 if directory doesn't exist, 0 otherwise
#
# Example:
#   add_to_path "$HOME/.local/bin"
add_to_path() {
    local dir="$1"
    [[ ! -d "$dir" ]] && return 1
    case ":$PATH:" in
        *":$dir:"*) return 0 ;;
        *) export PATH="$dir:$PATH" ;;
    esac
}

# Outputs debug messages to stderr when DOTFILES_DEBUG is set to 1.
#
# Arguments:
#   $* - Message to log
#
# Example:
#   DOTFILES_DEBUG=1 source init.sh  # Enable debug mode
#   log_debug "Initializing configuration"
log_debug() {
    if [[ "${DOTFILES_DEBUG:-0}" == "1" ]]; then
        echo "🔍 $*" >&2
    fi
}

# =============================================================================
# EDITOR CONFIGURATION
# =============================================================================

# Configures the default editor based on available tools.
# Preference order: nvim > vim > vi > nano
#
# Exports:
#   EDITOR    - Path to preferred editor
#   MANPAGER  - Sets nvim as man page viewer if nvim is available
#
# Aliases:
#   n - Shortcut to the configured editor
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

# Configures environment variables and PATH for various development tools.
# Handles telemetry opt-outs, language runtimes, package managers, and SDK paths.
#
# Configured tools (when available):
#   - Privacy: Disables telemetry for .NET, Next.js, Astro, Turbo, Storybook, Homebrew
#   - Package managers: pnpm, Homebrew
#   - Runtimes: nvm (Node), Bun, Deno, Rust/Cargo, Go, Ruby/rbenv
#   - Languages: Haskell/GHCup, OCaml/opam, .NET SDK
#   - Frameworks: Flutter SDK
#   - CLIs: Fly.io, GitHub Copilot, Angular
#
# Also adds $HOME/bin and $HOME/.local/bin to PATH.
configure_exports() {
    # Locale and timezone configuration.
    # Use C.UTF-8 for predictable scripting behavior (byte-wise sorting, POSIX regex).
    # Use en_GB for LC_TIME to get day/month/year and 24-hour time format.
    # See: docs/adr/0003-locale-and-timezone-configuration.md
    export TZ="${TZ:-America/Sao_Paulo}"
    export LANG="${LANG:-C.UTF-8}"
    export LC_ALL="${LC_ALL:-C.UTF-8}"
    export LC_TIME="${LC_TIME:-en_GB.UTF-8}"

    # Privacy - disable telemetry for various tools.
    export DO_NOT_TRACK=1
    export DOTNET_CLI_TELEMETRY_OPTOUT=true
    export DOTNET_INTERACTIVE_CLI_TELEMETRY_OPTOUT=true
    export NEXT_TELEMETRY_DISABLED=1
    export ASTRO_TELEMETRY_DISABLED=1
    export TURBO_TELEMETRY_DISABLED=1
    export STORYBOOK_DISABLE_TELEMETRY=1
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1

    # User bin directories.
    add_to_path "$HOME/bin"
    add_to_path "$HOME/.local/bin"

    # Pnpm global store.
    local pnpm_home="$HOME/.local/share/pnpm"
    if command_exists pnpm || [[ -d "$pnpm_home" ]]; then
        export PNPM_HOME="$pnpm_home"
        add_to_path "$PNPM_HOME"
    fi

    # Homebrew (Linux).
    local brew_path="/home/linuxbrew/.linuxbrew"
    [[ -d "$brew_path" ]] && eval "$($brew_path/bin/brew shellenv)"

    # Node Version Manager (nvm).
    local nvm_dir="$HOME/.nvm"
    if [[ -d "$nvm_dir" ]]; then
        export NVM_DIR="$nvm_dir"
        [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
        [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
    fi

    # Bun JavaScript runtime.
    local bun_dir="$HOME/.bun"
    if [[ -d "$bun_dir" ]]; then
        export BUN_INSTALL="$bun_dir"
        add_to_path "$BUN_INSTALL/bin"
        [[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
    fi

    # Deno JavaScript runtime.
    local deno_dir="$HOME/.deno"
    if [[ -d "$deno_dir" ]]; then
        export DENO_INSTALL="$deno_dir"
        add_to_path "$DENO_INSTALL/bin"
    fi

    # Rust / Cargo.
    add_to_path "$HOME/.cargo/bin"

    # Go language.
    local go_path="$HOME/go"
    if [[ -d "$go_path/bin" ]]; then
        export GOPATH="$go_path"
        add_to_path "$GOPATH/bin"
    fi

    # Ruby / rbenv.
    local rbenv_bin="$HOME/.rbenv/bin/rbenv"
    if [[ -f "$rbenv_bin" ]]; then
        local gem_home="$HOME/bin/packages/ruby/gems"
        export GEM_HOME="$gem_home"
        [[ ! -d "$GEM_HOME" ]] && mkdir -p "$GEM_HOME"
        add_to_path "$GEM_HOME/bin"
        eval "$(~/.rbenv/bin/rbenv init - zsh)"
    fi

    # Haskell / GHCup.
    [[ -f "$HOME/.ghcup/env" ]] && source "$HOME/.ghcup/env"

    # OCaml / opam.
    local opam_init="$HOME/.opam/opam-init/init.zsh"
    [[ -r "$opam_init" ]] && source "$opam_init" >/dev/null 2>&1

    # .NET SDK.
    if command_exists dotnet; then
        export DOTNET_ROOT="$(dirname $(realpath $(command -v dotnet)))"
        add_to_path "$DOTNET_ROOT"
        add_to_path "$HOME/.dotnet/tools"
        alias d='dotnet'
        alias dp='dotnet paket'
    fi

    # Flutter SDK.
    local flutter_dir="$HOME/bin/flutter"
    if [[ -d "$flutter_dir" ]]; then
        export FLUTTER_SDK="$flutter_dir"
        export FLUTTER_ROOT="$FLUTTER_SDK/bin"
        add_to_path "$FLUTTER_ROOT"
    fi

    # Fly.io CLI.
    local fly_dir="$HOME/.fly"
    if [[ -d "$fly_dir" ]]; then
        export FLYCTL_INSTALL="$fly_dir"
        add_to_path "$FLYCTL_INSTALL/bin"
    fi

    # GitHub Copilot CLI aliases.
    if command_exists gh; then
        eval "$(gh copilot alias -- zsh 2>/dev/null)"
    fi

    # Angular CLI completions.
    if command_exists ng; then
        source <(ng completion script 2>/dev/null)
    fi
}

# Next export marker.

# =============================================================================
# PLATFORM-SPECIFIC CONFIGURATION
# =============================================================================

# Applies platform-specific configurations based on detected environment.
#
# Configurations:
#   - Ubuntu/openSUSE: Sets XKB_DEFAULT_OPTIONS to swap Caps Lock with Ctrl (X11 only)
#   - Alpine: Creates sudo alias for doas if sudo is not available
#   - Containers: Sets DEBIAN_FRONTEND=noninteractive, unsets XKB options
#
# Uses:
#   DOTFILES_DISTRO       - Set by detect_environment()
#   DOTFILES_IN_CONTAINER - Set by detect_environment()
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

# Sets up system-level aliases for navigation, file operations, and search.
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

# Sets up development-related aliases for package managers, editors, and tools.
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
    alias initpy='uv init && uv venv && uv add pip && x-venv-activate'

    # System info
    alias x-colines='echo "Columns: $COLUMNS, Lines: $LINES"'
    alias x-path-print='echo $PATH | tr ":" "\n"'
    alias x-ppath='x-path-print'
    alias x-path-print-unique='x-path-print | sort | uniq'
    alias x-ppathu='x-path-print-unique'

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
        alias x-nvim-none='nvim -u NONE'
        alias x-nvim-norc='nvim -u NORC'
        alias x-nvim-noplugin='nvim --noplugin'
    fi

    # Better command defaults
    alias sed='sed -E'  # Always use extended regex
}

# =============================================================================
# ALIASES - FONTS
# =============================================================================

# Sets up aliases for font management on Linux systems.
configure_font_aliases() {
    alias x-fonts-update-cache="fc-cache -fv"
    alias x-fonts-rebuild-cache="sudo fc-cache -r -v"
    alias x-fonts-list="ll ~/.local/share/fonts"
    alias x-fonts-mono='fc-list : family spacing outline scalable | grep -e spacing=100 -e spacing=90 | grep -e outline=True | grep -e scalable=True'
}

# =============================================================================
# ALIASES - GIT
# =============================================================================

# Creates comprehensive Git workflow aliases.
#
# Status & info:
#   gs, gss, gsb - Various git status formats
#
# Adding & committing:
#   ga, gaa      - git add
#   gc, gcm      - git commit
#   gac, gacm    - add all + commit (with/without message)
#
# Branching:
#   gb, gbd      - branch operations
#   gco, gco-    - checkout (gco- returns to previous branch)
#
# Viewing:
#   gd, gdk      - git diff shortcuts
#   gl, gla, glg - various git log formats
#   gls, glsa    - simple log formats
#   glm          - log messages only (for changelogs)
#
# Remote operations:
#   gpl, gps, gpss, gpd - pull, push variants
#
# Other:
#   grs, grss    - git restore
#   gst*         - git stash operations
#   gt*          - git tag operations
#   gr*          - git remote operations
#   gcct         - Shows conventional commit types
#   glfs*        - Git LFS operations
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

# Placeholder for Docker/Podman aliases.
configure_docker_aliases() {
    alias pod='podman'
    alias docker='podman'
    alias dc="docker compose"
    alias x-docker-prune-month-old-images='docker image prune -a --filter "until=720h"'
    alias x-docker-prune-two-week-old-images='docker image prune -a --filter "until=336h"'

    alias x-podman-universal-devcontainer='podman run -it --rm -v "$(pwd):/workspace:Z" -w /workspace mcr.microsoft.com/devcontainers/universal:2-linux zsh'
    alias x-podman-ts-node-devcontainer='podman run -it --rm -v "$(pwd):/workspace:Z" -w /workspace mcr.microsoft.com/devcontainers/typescript-node:24-bookworm zsh'
}

# Next docker alias marker

# =============================================================================
# ALIASES - SYSTEM UTILITIES
# =============================================================================

# Sets up various system utility aliases and tool wrappers.
configure_system_utility_aliases() {
    # Text to speech (Portuguese)
    alias x-say="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"
    alias x-fala="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"
    alias x-falar="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"

    # Process and port monitoring
    alias x-list-process-to-port-all="netstat -lnp"
    alias x-list-process-to-port-tcp="netstat -lnpt"
    alias x-list-process-by-mem='ps -eo pid,comm,rss --sort=-rss \
        | awk '\''NR == 1 { printf "%-10s %-20s %-10s\n", $1, $2, $3 } \
                  NR  > 1 { printf "%-10s %-20s %-10s\n", $1, $2, $3/1024 }'\'' \
        | column -t'
    alias mem='x-list-process-by-mem | less'

    # System information
    alias x-monitor-show-dpi="xdpyinfo | grep dots"
    alias x-logins-last-10="last -10"
    alias x-system-info='cat /etc/os-release && lsb_release -a && hostnamectl && uname -r'
    alias x-list-installed-packages='dpkg --get-selections | grep -v deinstall'
    alias x-list-devices='lsblk -o NAME,SIZE,FSTYPE,MODEL'

    # File operations
    alias x-files-cwd-size-in-mb='ls -la | awk '\''{sum += $5} END {print sum/1024/1024 " MB"}'\'''
    alias x-files-size-in-mb='awk '\''{sum += $5} END {print sum/1024/1024 " MB"}'\'''
    alias x-folder-diff='diff --brief --recursive --new-file'
    alias x-change-owners='sudo chown -R $USER:$USER'

    # Utilities
    alias x-chrome-br='LANGUAGE=pt_BR google-chrome-stable'
    alias x-grub-update='sudo update-grub'
    alias x-time-ago="date -d '10 hours ago' +%s%3N"
    alias x-shasum-easy='echo "b87366b62eddfbecb60e681ba83299c61884a0d97569abe797695c8861f5dea4 *ubuntu-25.04-desktop-amd64.iso" | shasum -a 256 --check'
    alias x-path-clean='env -i sh -c '\''echo $PATH'\'''

    # Lua with readline wrapper
    if command_exists rlwrap && command_exists lua; then
        alias lua='rlwrap lua'
    fi

    # Better man (falls back to --help)
    alias mann='x-man'
    alias bman=mann

    # Easily edit and source the rc file.
    alias rc='$EDITOR $HOME/.config/dotfiles/shell/init.sh && . ~/.zshrc'

    # Next alias marker
}

# =============================================================================
# FUNCTIONS - TMUX
# =============================================================================

# Creates a new tmux session or attaches to an existing one.
#
# Example:
#   tmx work      # Create or attach to "work" session
#   t             # Create or attach to "default" session
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

# Prints today's date in YYYY-MM-DD format.
#
# Example:
#   x-today  # Output: 2025-12-02
x-today() {
    date +%F
}

# Prints current time in HHhMM format.
#
# Example:
#   x-time-for-text  # Output: 14h30
x-time-for-text() {
    date +%Hh%M
}

# Print the current date/time in a format suitable for filenames (no seconds).
x-datetime-for-filename() {
    date +'%Y%m%d-%H%M'
}

# Print the current date/time in a format suitable for filenames with seconds.
x-datetime-for-filename-with-seconds() {
    date +'%Y%m%d-%H%M%S'
}

# =============================================================================
# FUNCTIONS - FILE OPERATIONS
# =============================================================================

# Searches for files matching a regex pattern using extended regex syntax.
#
# Arguments:
#   $1 - Directory to search
#   $2 - Extended regex pattern
#
# Returns:
#   1 if directory is invalid, 0 otherwise
#
# Example:
#   x-regex-find . '.*\.(js|ts)$'      # Find all .js and .ts files
#   x-regex-find ~/code '.*/test/.*'   # Find files in test directories
x-regex-find() {
    local dir="$1"
    local regex="$2"

    if [[ ! -d "$dir" ]]; then
        echo "ERROR: '$dir' is not a directory"
        return 1
    fi

    find "$dir" -regextype egrep -regex "$regex"
}

# Finds and lists all broken symbolic links in a directory.
# A broken symlink is one that points to a non-existent target.
#
# Arguments:
#   $1 - Directory to search (default: current directory)
#
# Example:
#   x-broken-symlinks              # Search current directory
#   x-broken-symlinks ~/projects   # Search specific directory
x-broken-symlinks() {
    find "${1:-.}" -type l ! -exec test -e {} \; -exec ls -lah --color {} \;
}

# =============================================================================
# FUNCTIONS - PYTHON ENVIRONMENT
# =============================================================================

# Activates Python virtual environment.
# Tries local .venv first, then falls back to global venv.
#
# Search order:
#   1. ./.venv/bin/activate (local project venv)
#   2. ~/.python-global-venv/.venv/bin/activate (global venv)
#
# Returns:
#   0 if venv found and activated, 1 otherwise
#
# Alias: va
#
# Example:
#   x-venv-activate  # or just: va
x-venv-activate() {
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

alias venv='x-venv-activate'
alias ve='x-venv-activate'

# =============================================================================
# FUNCTIONS - MISC
# =============================================================================

# Starts SSH agent and adds the default Ed25519 key.
# Useful for establishing SSH connections after system restart.
#
# Expects key at: ~/.ssh/id_ed25519
#
# Example:
#   load-ssh  # Start agent and load key
# TODO: allow providing a custom key path?
load-ssh() {
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
}

x-help() {
    # TODO: Create this helper command like x-help <function|name|anything> that
    # greps documentation from the ./x-archives.bash file.
    :  # no-op placeholder, necessary to avoid errors on bash shells
}

x-backup-vscode-folders() {
    local vscode_archives="$HOME/.vscode-archives"
    if [[ ! -d "$vscode_archives" ]]; then
        mkdir -p "$vscode_archives"
    fi

    mv ~/.vscode-remote-containers* \
        "$vscode_archives/.vscode-remote-containers.bak.$(x-datetime-for-filename)"
    mv ~/.vscode-server* \
        "$vscode_archives/.vscode-server.bak.$(x-datetime-for-filename)"
}

# Display man page for a command, or --help if man page doesn't exist
x-man() {
    local cmd="$1"

    if [[ -z "$cmd" ]]; then
        echo "Usage: x-man <command>"
        return 1
    fi

    # Check if man page exists
    if man -w "$cmd" >/dev/null 2>&1; then
        man "$cmd"
        return
    fi

    # If no man page, try --help
    if command_exists "$cmd"; then
        echo "ℹ️  No manual entry for '$cmd', showing --help..." >&2
        "$cmd" --help 2>&1 | less
    else
        echo "Command '$cmd' not found"
        return 1
    fi
}

x-omz-reset-rc() {
    mv ~/.zshrc ~/.zshrc.bak.$(x-datetime-for-filename)
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
}

x-git-clone-d1() {
    git clone --depth 1 "$1"
}

# Next function marker

# =============================================================================
# HISTORY CONFIGURATION
# =============================================================================

# Configures shell history location with support for sync across machines.
# Sets up history directory based on environment priority:
#   1. MCRA_HISTORY_DIR (explicit override)
#   2. OneDrive folder in WSL (for cross-machine sync)
#   3. ~/.shell_histories (local fallback)
#
# Exports:
#   MCRA_HISTORY_BASE_DIR - Base directory for history files
#   MCRA_HISTORY_ID       - Unique identifier for this shell instance
#                          (includes workspace name if in devcontainer)
#
# Used by configure_zsh() and configure_bash() to set HISTFILE.
configure_history() {
    # Determine history directory based on environment
    local history_base_dir=""

    # 1. Check for explicit MCRA_HISTORY_DIR (highest priority - can be set in .zshrc/.bashrc or devcontainer)
    if [[ -n "${MCRA_HISTORY_DIR:-}" ]]; then
        history_base_dir="$MCRA_HISTORY_DIR"
    # 2. Check if we're in WSL with OneDrive (sync across machines)
    elif [[ "$DOTFILES_IN_WSL" == "true" ]] && [[ -d "/mnt/c/Users" ]]; then
        # Try to find OneDrive folder (could be OneDrive, OneDrive - Personal, etc.)
        local win_user=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
        if [[ -d "/mnt/c/Users/$win_user/OneDrive" ]]; then
            history_base_dir="/mnt/c/Users/$win_user/OneDrive/shell_histories"
        elif [[ -d "/mnt/c/Users/$win_user/OneDrive - Personal" ]]; then
            history_base_dir="/mnt/c/Users/$win_user/OneDrive - Personal/shell_histories"
        fi
    fi

    # 3. Fallback to local directory
    if [[ -z "$history_base_dir" ]] || [[ ! -d "$(dirname "$history_base_dir")" ]]; then
        history_base_dir="$HOME/.shell_histories"
    fi

    mkdir -p "$history_base_dir"

    # Create unique identifier for this shell instance
    # Use workspace name if available, otherwise hostname
    local history_id="${HOSTNAME:-$(hostname)}"
    if [[ -n "${WORKSPACE_FOLDER:-}" ]]; then
        local workspace_name="$(basename "$WORKSPACE_FOLDER")"
        history_id="${workspace_name}_${history_id}"
    fi

    # Export for use by configure_zsh and configure_bash
    export MCRA_HISTORY_BASE_DIR="$history_base_dir"
    export MCRA_HISTORY_ID="$history_id"

    log_debug "History base dir: $MCRA_HISTORY_BASE_DIR"
    log_debug "History ID: $MCRA_HISTORY_ID"
}

# =============================================================================
# ZSH CONFIGURATION
# =============================================================================

# Configures zsh-specific features including oh-my-zsh integration.
# Only runs when executed in zsh shell.
#
# Sets up:
#   - History file location (uses MCRA_HISTORY_BASE_DIR if configured)
#   - History size (1 million entries)
#   - Oh-my-zsh with custom theme and plugins (if available)
#   - Standalone zsh configuration (if oh-my-zsh not available)
#   - fzf integration for fuzzy finding
#   - Key bindings (Ctrl+U for backward kill line)
#
# Plugins (when oh-my-zsh available):
#   - zsh-autosuggestions
#   - zsh-syntax-highlighting
#
# Custom theme: marcelocra.zsh-theme (from dotfiles repo)
configure_zsh() {
    # Only configure zsh-specific features if we're running in zsh
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        # History configuration
        # Use shared history location if configured, otherwise default
        if [[ -n "${MCRA_HISTORY_BASE_DIR:-}" ]] && [[ -n "${MCRA_HISTORY_ID:-}" ]]; then
            export HISTFILE="$MCRA_HISTORY_BASE_DIR/.zsh_history_${MCRA_HISTORY_ID}"
        else
            export HISTFILE="$HOME/.zsh_history"
        fi
        # Unlimited history (or practically unlimited)
        export HISTSIZE=1000000
        export SAVEHIST=1000000
        export HIST_STAMPS="yyyy-mm-dd"

        if [[ -d "$HOME/.oh-my-zsh" ]]; then
            # Oh-my-zsh setup (handles most configuration automatically)
            export ZSH="$HOME/.oh-my-zsh"
            export ZSH_CUSTOM="$ZSH/custom"

            # Use custom theme from dotfiles
            local ZSH_THEME_PATH="${DOTFILES_DIR:-$HOME/x/dotfiles}/shell/marcelocra.zsh-theme"
            if [[ -f "$ZSH_THEME_PATH" ]]; then
                # Ensure themes directory exists then symlink custom theme
                mkdir -p "$ZSH_CUSTOM/themes"
                ln -sf "$ZSH_THEME_PATH" "$ZSH_CUSTOM/themes/marcelocra.zsh-theme"
                ZSH_THEME="marcelocra"
            else
                # Fallback to a safe default theme
                ZSH_THEME="robbyrussell"
            fi

            # Enable my oh-my-zsh plugins if present in $ZSH_CUSTOM/plugins
            plugins=()
            [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && plugins+=(zsh-autosuggestions)
            [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)

            log_debug "oh-my-zsh plugins: ${plugins[*]}"
            log_debug "ZSH_THEME set to $ZSH_THEME (path: $ZSH_THEME_PATH)"

            # Source oh-my-zsh
            source "$ZSH/oh-my-zsh.sh"
        else
            # Standalone zsh setup (when oh-my-zsh not available)

            # History options
            setopt SHARE_HISTORY          # Share history between all sessions
            setopt INC_APPEND_HISTORY     # Write to history file immediately
            setopt HIST_IGNORE_DUPS       # Don't record duplicates
            setopt HIST_IGNORE_ALL_DUPS   # Delete old duplicate entries
            setopt HIST_FIND_NO_DUPS      # Don't display duplicates when searching
            setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
            setopt HIST_SAVE_NO_DUPS      # Don't write duplicates to history file
            setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks
            setopt APPEND_HISTORY         # Append to history file

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
            PS1='%F{141}%n@%m%f %F{245}›%f %F{blue}%~%f %# '
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

# Configures bash-specific features including history and prompt.
# Only runs when executed in bash shell.
#
# Sets up:
#   - History file location (uses MCRA_HISTORY_BASE_DIR if configured)
#   - History size (1 million entries)
#   - History control (no duplicates, timestamps)
#   - Custom prompt with git branch and timestamp
#   - Terminal title updates (for xterm)
#   - fzf integration for fuzzy finding
#
# Prompt features:
#   - Username (or GITHUB_USER if set)
#   - Exit status indicator (red arrow on error)
#   - Current directory
#   - Git branch (if in repo)
#   - Dirty working tree indicator (if enabled)
#   - Timestamp
configure_bash() {
    # Only configure bash-specific features if we're running in bash
    if [[ -n "${BASH_VERSION:-}" ]]; then
        # History configuration
        # Use shared history location if configured, otherwise default
        if [[ -n "${MCRA_HISTORY_BASE_DIR:-}" ]] && [[ -n "${MCRA_HISTORY_ID:-}" ]]; then
            export HISTFILE="$MCRA_HISTORY_BASE_DIR/.bash_history_${MCRA_HISTORY_ID}"
        fi
        # Unlimited history (or practically unlimited)
        export HISTSIZE=1000000
        export HISTFILESIZE=1000000
        export HISTCONTROL=ignoredups:erasedups
        export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
        shopt -s histappend

        # Custom prompt with git branch and timestamp
        __bash_prompt() {
            local userpart='`[ ! -z "${GITHUB_USER:-}" ] && echo -n "\[\033[38;5;141m\]@${GITHUB_USER:-}@\h " || echo -n "\[\033[38;5;141m\]\u@\h " \
                && echo -n "\[\033[38;5;245m\]›\[\033[0m\]"`'
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
            local exitstatus='`[ "${MCRA_XIT:-0}" -ne "0" ] && echo -n "\[\033[1;31m\]" || echo -n "\[\033[32m\]"`'
            PS1="${userpart} ${lightblue}\w ${gitbranch}${timestamp}${removecolor}\n${exitstatus}\$ ${removecolor}"
            unset -f __bash_prompt
        }
        PROMPT_COMMAND='MCRA_XIT=$?; '"${PROMPT_COMMAND:-}"
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

            PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }precmd"
            trap 'preexec' DEBUG
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

# Activates mise (development environment manager) if enabled.
# Mise manages tool versions per-project (Node, Python, Ruby, etc.).
#
# Requirements:
#   - MCRA_USE_MISE environment variable set to "true"
#   - mise binary available in PATH
#
# Installation should be done via setup script, not here.
#
# See: https://mise.jdx.dev/
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

# Configures fzf (fuzzy finder) default options.
# Shell-specific keybindings are configured in configure_zsh() and configure_bash().
#
# Default options:
#   - 40% screen height
#   - Reverse layout (input at top)
#   - Border around interface
#   - Inline info display
#
# Common keybindings (set by shell integration):
#   Ctrl+R - Search command history
#   Ctrl+T - Search files
#   Alt+C  - cd into directory
#
# See: https://github.com/junegunn/fzf
configure_fzf() {
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'
}

# =============================================================================
# MAIN INITIALIZATION
# =============================================================================

# Main initialization function that orchestrates all configuration steps.
# Called automatically when script is sourced (not executed).
#
# Initialization order:
#   1. detect_environment       - Detect OS, distro, container, WSL
#   2. configure_editor         - Set default editor
#   3. configure_exports        - Set environment variables and PATH
#   4. configure_platform       - Platform-specific settings
#   5. configure_history        - History file location
#   6. configure_zsh            - Zsh-specific config
#   7. configure_bash           - Bash-specific config
#   8. configure_*_aliases      - All alias groups
#   9. configure_mise           - Mise activation
#   10. configure_fzf           - Fuzzy finder options
#
# Debug mode: Set DOTFILES_DEBUG=1 to see initialization messages
main() {
    detect_environment
    configure_editor
    configure_exports
    configure_platform
    configure_history
    configure_zsh
    configure_bash
    configure_system_aliases
    configure_dev_aliases
    configure_font_aliases
    configure_git_aliases
    configure_docker_aliases
    configure_system_utility_aliases
    configure_mise
    configure_fzf

    # Load extra functions from the ./x-functions.sh file if it exists.
    # It should be in the same directory as this script.
    # Get the directory where this script is located.
    # Works in both bash and zsh.
    local script_dir
    if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
        script_dir="$(dirname "${BASH_SOURCE[0]}")"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        # Use zsh's %x parameter expansion to get the current script path
        # Fall back to "." if expansion fails
        local script_path
        script_path="${(%):-%x}" 2>/dev/null || script_path="."
        script_dir="$(dirname -- "$script_path")"
    else
        script_dir="$(dirname "$0")"
    fi

    local extra_functions_file="$script_dir/x-functions.sh"
    if [[ -f "$extra_functions_file" ]]; then
        source "$extra_functions_file"
        log_debug "Loaded extra functions from x-functions.sh"
    fi

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
