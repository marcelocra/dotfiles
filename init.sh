#!/usr/bin/env bash
# Main shell configuration script.
# Enhanced with environment detection and better error handling.

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# ------------------------------------------------------------------------------
# Environment Detection and Variables
# ------------------------------------------------------------------------------

# Detect platform
DOTFILES_PLATFORM="unknown"
DOTFILES_IN_CONTAINER="false"
DOTFILES_IN_WSL="false"

# Platform detection
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if grep -q Microsoft /proc/version 2>/dev/null; then
        DOTFILES_PLATFORM="wsl"
        DOTFILES_IN_WSL="true"
    else
        DOTFILES_PLATFORM="linux"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    DOTFILES_PLATFORM="macos"
else
    DOTFILES_PLATFORM="unknown"
fi

# Container detection
if [[ -f /.dockerenv ]] || [[ -n "${CONTAINER:-}" ]]; then
    DOTFILES_IN_CONTAINER="true"
fi

# Export environment variables for use in other scripts
export DOTFILES_PLATFORM DOTFILES_IN_CONTAINER DOTFILES_IN_WSL

# ------------------------------------------------------------------------------
# Environment Variable Validation
# ------------------------------------------------------------------------------

REQUIRED_ENVS=''

verify_defined() {
    local env_name="$1"
    local env_value
    eval env_value=\$$1

    if [[ -z "$env_value" ]]; then
        REQUIRED_ENVS="${REQUIRED_ENVS}'$env_name' must be defined with the $2.\n\n"
    fi
}

verify_defined "MCRA_INIT_SHELL" 'path to your shell init. I use the `.rc` file in this repo'
verify_defined "MCRA_LOCAL_SHELL" 'path to your local shell init, with stuff that you do not want tracked in a public repo'
verify_defined "MCRA_TMP_PLAYGROUND" 'path to a folder that you can use as a playground. I use /tmp/playground or something like this'

if [[ ! -z "$REQUIRED_ENVS" ]]; then
    echo -e "❌ Missing required environment variables:\n$REQUIRED_ENVS"
    echo "Run 'check-dependencies.sh' for setup instructions."
    return 1
fi

# ------------------------------------------------------------------------------
# Platform-Specific Configuration Loading
# ------------------------------------------------------------------------------

# Load common utilities (if available)
if [[ -f "$HOME/lib/.rc.common" ]]; then
    . "$HOME/lib/.rc.common"
elif [[ -f "$(dirname "$MCRA_INIT_SHELL")/common.sh" ]]; then
    . "$(dirname "$MCRA_INIT_SHELL")/common.sh"
fi

# Utility function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create mm_is_command function if not available from common
if ! declare -f mm_is_command >/dev/null 2>&1; then
    mm_is_command() {
        command_exists "$1"
    }
fi

# Debug output (can be enabled with DOTFILES_DEBUG=1)
if [[ "${DOTFILES_DEBUG:-0}" == "1" ]]; then
    echo "🔍 Dotfiles Environment Detection:"
    echo "  Platform: $DOTFILES_PLATFORM"
    echo "  Container: $DOTFILES_IN_CONTAINER"
    echo "  WSL: $DOTFILES_IN_WSL"
    echo ""
fi

# ------------------------------------------------------------------------------
# Exports and Editor Configuration
# ------------------------------------------------------------------------------

# Smart editor selection with platform considerations
if mm_is_command nvim; then
    export EDITOR='nvim'
    # Use Neovim's built-in pager support as the man pager
    export MANPAGER='nvim +Man!'
elif mm_is_command vim; then
    export EDITOR='vim'
    export MANPAGER='vim +Man!'
elif mm_is_command vi; then
    export EDITOR='vi'
else
    if [[ "${DOTFILES_DEBUG:-0}" == "1" ]]; then
        echo "⚠️  Didn't find Neovim, Vim or Vi. Using nano as the default editor."
    fi
    export EDITOR='nano'
fi

# Hopefully, Neovim (hence, 'n'). Works for Nano too, I guess...
alias n="$EDITOR"

# Platform-specific exports
case "$DOTFILES_PLATFORM" in
    "linux"|"wsl")
        # Swap Caps Lock and Ctrl keys when using X11 (Linux/WSL)
        export XKB_DEFAULT_OPTIONS="ctrl:swapcaps"
        ;;
    "macos")
        # macOS-specific exports can go here
        ;;
    *)
        if [[ "${DOTFILES_DEBUG:-0}" == "1" ]]; then
            echo "⚠️  Unknown platform: $DOTFILES_PLATFORM"
        fi
        ;;
esac

# Container-specific configurations
if [[ "$DOTFILES_IN_CONTAINER" == "true" ]]; then
    # In containers, we might want different defaults
    export DEBIAN_FRONTEND=noninteractive
    # Don't use X11 features in containers
    unset XKB_DEFAULT_OPTIONS
fi

# Next export above.
# ------------------------------------------------------------------------------
# Functions.
# ------------------------------------------------------------------------------
# #region {{{

# Simplifies working with tmux. Tries to create
# a new session and if it already exists, just
# jump to it.
tmx() {
    local session_name
    session_name="$1"

    # If no session name was given, use a default one.
    if [ -z "$session_name" ]; then
        session_name="default"
    fi

    # Try to create a new session.
    tmux new -s $session_name >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 0
    fi

    echo "Trying to reuse session $session_name..."
    sleep 0.5
    # Try to load existing session.
    tmux attach-session -t $session_name >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 0
    fi

    # Something else happened.
    echo "An error happened. Couldn't load $session_name"
    return 1
}
alias t=tmx

# Desktop notification to help me change tasks.
function timer_notification() {
    local summary="$1"
    local default_summary='TEMPO ACABOU!'
    local content="$2"
    local default_content="Pronto! Hora de ir para a próxima tarefa!\n\nSe controla e faz isso, pra realmente conseguir avançar e não se sentir mal mais.\n\n\n----- IGNORE BELOW -----\n\n\nAgora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco. Agora vai um monte de texto, só pra isso ocupar bastante da tela e encher o saco."

    if [ -z "$summary" ]; then
        summary=$default_summary
    else
        summary="$(echo $summary | tr '[:lower:]' '[:upper:]')"
        summary="$summary - $default_summary"
    fi

    if [ -z "$content" ]; then
        content="$default_content"
    fi

    notify-send -u critical "$summary" "$content"
}

function timer() {
    local time="$1"
    local default_time="30m"

    if [[ -z "$time" ]]; then
        echo "No time provided, using default ($default_time). You can either provide a value (format: 1s, 20m, 2h, 1h20m) or use an existing template (currently: t1, t5, t15, t30, t60) all in minutes."
        time="$default_time"
    fi

    sleep "$time" && timer_notification
}
alias t5="sleep 5m && timer_notification"
alias t15="sleep 15m && timer_notification"
alias t30="sleep 30m && timer_notification"
alias t60="sleep 1h && timer_notification"

mm_today() {
    echo "$(date +%F)"

    return 0
}

mm_time() {
    echo "$(date +%Hh%M)"

    return 0
}

zip-dir-usage() {
    echo "Usage: zip-dir <folder-to-zip> <zip-name=folder-to-zip>

Error: $1
"
}

zip-dir() {
    local folder_to_zip
    local zip_name

    folder_to_zip="$1"
    zip_name="$2"

    if [ -z "$folder_to_zip" ]; then
        zip-dir-usage 'The first argument is the directory to zip. The second
argument is optional: if not provided, the first is used in its place.'
        return 1
    fi

    if [ ! -d "$folder_to_zip" ]; then
        zip-dir-usage "'$folder_to_zip' is not a directory."
        return 1
    fi

    if [ -z "$zip_name" ]; then
        zip_name=$(basename "$folder_to_zip")
    fi

    if ! command -v zip &>/dev/null; then
        echo 'zip is not installed or not in the path'
        return 1
    fi

    (
        cd $(dirname $folder_to_zip)
        zip -r "$zip_name" "$zip_name"
    )
    return 0
}

regexfind() {
    local dir="$1"
    local regex="$2"

    if [ ! -d "$dir" ]; then
        echo "ERROR: '$dir' is not a directory"
        return 1
    fi

    find "$dir" -regextype egrep -regex "$regex"
}
alias rfind=regexfind

count_lines_of_code() {
    local to_count='(js|cjs|mjs|jsx|ts|cts|mts|tsx|elm|sh)$'
    local to_ignore='(compiled|vendored|cypress|e2e|bundle|config|example|[Ii]cons)'
    local md_wrap='sh'

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --count | -c)
            to_count="$2"

            shift
            shift
            ;;

        --ignore | -i)
            to_ignore="$2"

            shift
            shift
            ;;

        --md-wrap | -w)
            md_wrap="$2"

            shift
            shift
            ;;

        --no-md-wrap | -no-w)
            md_wrap=''

            shift
            ;;
        esac
    done

    # Only look at files tracked by git, i.e., ignore what is in `.gitignore`.
    local cmd="git ls-files \
        | egrep \"$to_count\" \
        | egrep -v \"$to_ignore\" \
        | xargs wc -l"

    if [ -n "$md_wrap" ]; then
        echo '```'"$md_wrap"
    fi

    echo "looking at: $to_count"
    echo "ignoring: $to_ignore"
    echo "running command:\n  $cmd" | sed -E -e 's/\s{9}/\n    /g'
    echo "result:"

    bash -c "$cmd"

    if [ -n "$md_wrap" ]; then
        echo '```'
    fi

}
alias loc=count_lines_of_code

x() {
    # Execute stuff depending on what is in the folder.
    #
    # - If there's an `nx.json` file in the current directory
    #   - If no arguments are given, list all `nx` tasks
    #   - Else, run `nx` with the given arguments.
    # - If there's a `package.json` file in the current directory
    #   - If no arguments are given, list all `pnpm` scripts
    #   - Else, run `pnpm run` with the given arguments.

    local nx_json='nx.json'
    local package_json='package.json'

    if [ -f "$nx_json" ]; then
        if [ $# -eq 0 ]; then
            echo "No arguments given. Listing all 'nx' tasks."
            echo
            pnpx nx show projects | sort
        else
            echo "Running 'nx' with the given arguments."
            echo
            pnpx nx "$@"
        fi
    elif [ -f "$package_json" ]; then
        if [ $# -eq 0 ]; then
            echo "No arguments given. Listing all 'pnpm' scripts."
            echo
            cat package.json | jq -r '.scripts|to_entries[]| .key + " -> " + .value'
        else
            echo "Running 'pnpm run' with the given arguments."
            echo
            pnpm run "$@"
        fi
    else
        echo "No 'nx.json' or 'package.json' found in the current directory and you didn't configured any other behavior. Exiting."
    fi

    return 0
}

# StackOverflow: https://unix.stackexchange.com/a/38380/140493
#
# tl;dr:
#
#   Update 2020: This answer was written in 2009. Since 2013 a video format much
#   better than H.264 is widely available, namely H.265 (better in that it
#   compresses more for the same quality, or gives higher quality for the same
#   size). To use it, replace the libx264 codec with libx265, and push the
#   compression lever further by increasing the CRF value — add, say, 4 or 6,
#   since a reasonable range for H.265 may be 24 to 30. Note that lower CRF
#   values correspond to higher bitrates, and hence produce higher quality
#   videos.
#
function video_compress() {
    local input="${1:-input.mp4}"
    local output="${2:-output.mp4}"

    ffmpeg -i $input -vcodec libx265 -crf 28 $output
}

# AskUbuntu: https://askubuntu.com/a/539886/121101
#
# Extract mp3 from mp4.
function mp3_from_mp4() {
    local input="${1:-input.mp4}"
    local output="${2:-output.mp3}"

    ffmpeg -i $input $output
}

# List broken symlinks in folder.
function broken_symlinks() {
    find "${1:-.}" -type l ! -exec test -e {} \; -exec ls -lah --color {} \;
}

# Backup/disable Neovim installed packages and cache.
function neovim_backup_state() {
    local now=$(date +%F_%T | sed -e 's/:/-/g')
    mv ~/.local/share/nvim{,.$now.bak}
    mv ~/.local/state/nvim{,.$now.bak}
    mv ~/.cache/nvim{,.$now.bak}
}

# Backup Neovim installed packages, cache and lazy-lock to a tmp dir.
# WARN: Remember that it will be removed on reboot.
function neovim_backup_state_to_tmp() {
    # Make a tmp folder with the current date.
    local tmp_dir=$(mktemp -d -t nvim_$(date +%F_%T | sed -e 's/:/-/g')_XXXXXX)

    mv ~/.local/share/nvim $tmp_dir/local-share-nvim
    mv ~/.local/state/nvim $tmp_dir/local-state-nvim
    mv ~/.cache/nvim $tmp_dir/cache-nvim
    mv ~/.config/nvim/lazy-lock.json $tmp_dir
}

if ! command -v codene &>/dev/null; then
    alias codene='code --disable-extensions'
fi

# Next function above.
# #endregion Functions. }}}

# ------------------------------------------------------------------------------
# Aliases.
# ------------------------------------------------------------------------------
# #region {{{

# ------------------------------------------------------------------------------
# Reserved aliases with one lettered.
# ------------------------------------------------------------------------------

# Used in the following sections:
# b=popd
# l=ls ...
# n=$EDITOR (hopefully, Neovim)
# r=js run
# s=reserved
# t=easy tmux
# g=some type of grep

# ------------------------------------------------------------------------------
# Show diffs between files.
# ------------------------------------------------------------------------------

if mm_is_command code; then
    # VSCode diff is great!
    alias diffc="code -d"
fi

if [[ "$EDITOR" = "nvim" ]]; then
    # Neovim diff is good too.
    alias vimdiff="nvim -d"
fi

# ------------------------------------------------------------------------------
# Set my preferred defaults for ls.
# ------------------------------------------------------------------------------
# NOTE:
# -l: print as a list.
# -F: classify (folder vs files).
# -h: print human readable sizes (using K, M, G instead of bytes).
# -t: sort by time, most recently updated first.
# -o: omit group name
# --time-style: how to show time. Currently, 30mar23-22h10.
# --hyperlink=auto: stuff becomes clickable. For example, it is possbile to
#   open images in kitty term.

# My daily driver `ls` with platform-specific options
case "$DOTFILES_PLATFORM" in
    "macos")
        # Mac doesn't support the --time-style flag and some other GNU ls options
        alias l='ls -lFh -t'
        ;;
    "linux"|"wsl"|*)
        # GNU ls with enhanced features
        alias l='ls -F --group-directories-first --color=always --time-style="+%d%b%y-%Hh%M" -ltho'
        ;;
esac

alias ll='l -A'

# ------------------------------------------------------------------------------
# Easily edit and reload shell configs.
# ------------------------------------------------------------------------------
alias rc.='echo "Reloading configs at $(date +%F_%T)... " \
    && source $HOME/init_all.sh \
    && echo '\''done!'\'' \
    || echo '\''failed :('\'''
# # Changed in the last 10 minutes.
# alias rc_changed='find $MCRA_INIT_SHELL $MCRA_LOCAL_SHELL -mmin -10'
alias rc='($EDITOR $MCRA_INIT_SHELL); rc.'
alias rcl='($EDITOR $MCRA_LOCAL_SHELL); rc.'
alias rcz='($EDITOR ~/.zshrc); rc.'
alias rcb='($EDITOR ~/.bashrc); rc.'

# ------------------------------------------------------------------------------
# Untar (extract) files.
# ------------------------------------------------------------------------------
# I never remember how to extract tar files. Now I discovered that it
# automatically detect the compression format, so I only need to provide the -x
# (extract) and the -f (point to file) options (f has to be the last one if
# they are provided together).
alias untar="tar -xf"

# ------------------------------------------------------------------------------
# Always use the same tmp and make it easy to go there.
# ------------------------------------------------------------------------------
if [[ ! -d "$MCRA_TMP_PLAYGROUND" ]]; then
    mkdir $MCRA_TMP_PLAYGROUND
fi
alias tmp="pushd $MCRA_TMP_PLAYGROUND"
alias temp=tmp

# As in 'back'.
alias b="popd"

alias p="pnpm"
alias pf="pnpm --filter"
alias r="pnpm run"
# For use in workspaces.
alias rf="pnpm run --filter"

alias bbg="bb --config ~/.config/babashka/bb.edn"
alias bbge='$EDITOR ~/.config/babashka/bb.edn'

alias colines='echo "Columns: $COLUMNS, Lines: $LINES"'

alias path_print='echo $PATH | tr ":" "\n"'
alias ppath=path_print
alias path_print_unique='path_print | sort | uniq'
alias ppathu=path_print_unique

alias t1="tree -L 1"
alias t2="tree -L 2"
alias t3="tree -L 3"
alias t4="tree -L 4"
alias t5="tree -L 5"

# alias is_venv='which deactivate >/dev/null 2>&1 && true || false'
# function check_python_venv() {
#     local in_venv
#     if is_venv; then
#         in_venv="IN"
#     else
#         in_venv="NOT IN"
#     fi
#
#     printf "\n!!! %s A VIRTUAL ENVIRONMENT... !!!\n\n\n" $in_venv
# }
# alias python3='check_python_venv && python3'
# alias python=python3
# alias py='python'

if mm_is_command rg; then
    alias g=rg
elif mm_is_command egrep; then
    alias g=egrep
elif mm_is_command grep; then
    alias g=grep
fi

# ------------------------------------------------------------------------------
# My preffered less options.
# ------------------------------------------------------------------------------
# ALWAYS use `-R`, otherwise terminals probably will keep printing ESC chars.
export LESS='-R --use-color'
# If `lesspipe` is available, we can use the following instead of the
# `LESSOPEN` env.
# eval "$(lesspipe)"
# export LESSOPEN='|~/.lessfilter %s'

# Alternatively, using a custom command allows us to keep the default less
# less in case we don't need anything else.
# alias lesc='LESSOPEN="|pygmentize -g %s" lesstmp'

# Less with vim support as the editor (pressing v in less).
alias lesv='lesstmp'

# ------------------------------------------------------------------------------
# Font-related aliases and functions.
# ------------------------------------------------------------------------------
fonts_install_packages_to_improve_rendering() {
    # Great fonts with good rendering.
    sudo apt install fonts-noto
    sudo apt install ttf-mscorefonts-installer

    # Packages that enhance font rendering.
    sudo apt install fontconfig fontconfig-config
    sudo apt install libfreetype6
}

alias fonts_update_cache="fc-cache -fv"
alias fonts_rebuild_cache="sudo fc-cache -r -v"
alias fonts_list="ll ~/.local/share/fonts"

# List monospaced fonts.
alias list_mono_fonts='fc-list : family spacing outline scalable | grep -e spacing=100 -e spacing=90 | grep -e outline=True | grep -e scalable=True'

# ------------------------------------------------------------------------------
# Pnpm stuff.
# ------------------------------------------------------------------------------

alias pnpm_add_tailwind="pnpm add -D @tailwindcss/typography daisyui@latest tailwindcss postcss autoprefixer tailwind-merge react-markdown && npx tailwindcss init -p"
alias pnpm_add_tailwind_utils="pnpm add -D tailwind-merge @popperjs/core @tailwindcss/typography daisyui@latest tailwind-merge react-markdown"
alias pnpm_add_flowbite_svelte="pnpm add -D flowbite-svelte flowbite flowbite-svelte-icons"
alias pnpm_clean="rm ./pnpm-lock.yaml && rm -rf ./node_modules && pnpm install"
alias pnpm_add_mui='pnpm add @mui/material @emotion/react @emotion/styled @mui/icons-material'
alias pnpm_add_mui2='echo "Add this to your index.html:\n\n\n<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\" />
<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin />
<link
  rel=\"stylesheet\"
  href=\"https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap\"
/>"'
alias pnpm_add_lodash="pnpm add -D lodash @types/lodash"
alias pnpm_add_immer="pnpm add immer use-immer"

# ------------------------------------------------------------------------------
# Python stuff.
# ------------------------------------------------------------------------------
function venv_activate() {
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
alias va=venv_activate

# Init local python environment and install pip.
alias initpy='uv init && uv venv && uv add pip && venv_activate'

# ------------------------------------------------------------------------------
# Neovim stuff.
# ------------------------------------------------------------------------------
# Open nvim without plugins and/or configs. From the docs (:help noplugin):
#
# --noplugin  Skip loading plugins.  Resets the 'loadplugins' option.
#             Note that the |-u| argument may also disable loading plugins:
#                 argument    load vimrc files    load plugins ~
#                 (nothing)       yes         yes
#                 -u NONE         no          no
#                 -u NORC         no          yes
#                 --noplugin      yes         no
alias neovim_none='nvim -u NONE'
alias neovim_norc='nvim -u NORC'
alias neovim_noplugin='nvim --noplugin'

# Next multiline alias (section) above.
# ------------------------------------------------------------------------------
# Misc.
# ------------------------------------------------------------------------------
# Speech synthesizer.
alias say="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"
alias fala="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"
alias falar="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"

# Always use sed with extended regexes. Mac supports `-E` but not `-r`.
alias sed='sed -E'

# List processes bound to all ports.
alias list_process_to_port_all="netstat -lnp"
# Same, but for TCP only. This is usually what I want, e.g. when a server hold
# it even after ctrl+c.
alias list_process_to_port_tcp="netstat -lnpt"

# Monitor.
alias monitor_show_dpi="xdpyinfo | grep dots"

# Last time a user logged into the system.
alias last_login="last -10"

# Print the size of the files in the current directory.
alias files_cwd_size_in_mb='ls -la | awk '\''{sum += $5} END {print sum/1024/1024 " MB"}'\'''
alias files_size_in_mb='awk '\''{sum += $5} END {print sum/1024/1024 " MB"}'\'''

# Get os version, name and details.
alias system_info='cat /etc/os-release && lsb_release -a && hostnamectl && uname -r'

# Start Chrome using other language.
alias chrome_br='LANGUAGE=pt_BR google-chrome-stable'

# List processes using the most memory. Fix header using sed (gambiarra).
alias list_process_by_mem_gambs='ps -eo pid,comm,rss --sort=-rss \
    | awk '\''{ printf "%-10s %-20s %-10s\n", $1, $2, $3/1024 }'\'' \
    | column -t \
    | sed -E "s/^(PID.*)0/\1MEM/"'

# Same as above, but use awk to print the original header.
alias list_process_by_mem='ps -eo pid,comm,rss --sort=-rss \
    | awk '\''NR == 1 { printf "%-10s %-20s %-10s\n", $1, $2, $3 } \
              NR  > 1 { printf "%-10s %-20s %-10s\n", $1, $2, $3/1024 }'\'' \
    | column -t'
alias mem='list_process_by_mem | less'

# Bat, a cat clone with wings.
alias bat=batcat

# List installed packages.
alias list_installed_packages='dpkg --get-selections | grep -v deinstall'

# Clear the screen with the same alias used in Windows.
alias cls="clear"

# Show folder differences.
# Usage: folder_diff dir1 dir2
alias folder_diff='diff --brief --recursive --new-file'

# Time ago in millis.
alias time_ago="date -d '10 hours ago' +%s%3N"

# Change user and group owners of a folder and all of its files and folders
# recursively.
alias change_owners='sudo chown -R $USER:$USER'

# Check shasum easily.
alias shasum_easy='echo "b87366b62eddfbecb60e681ba83299c61884a0d97569abe797695c8861f5dea4 *ubuntu-25.04-desktop-amd64.iso" | shasum -a 256 --check'

# Diff using kitty.
alias d='kitten diff'

# Print the PATH without values added by init scripts.
# NOTE: It MUST be written with the single quotes as it is not, otherwise it
# will be expanded in the current shell and not in the new one.
alias path_clean='env -i sh -c '\''echo $PATH'\'''

# List all block devices.
alias list_devices='lsblk -o NAME,SIZE,FSTYPE,MODEL'

# Regenerate grup entries.
alias grub_update='sudo update-grub'

# Run programs without installing them.
alias tsx='pnpx tsx'

# Better Copilot CLI aliases. Requires gh cli copilot extensions to be
# installed.
alias copilot="ghcs"
alias cpl="copilot"

# Always start lua using rlwrap, as the default repl is quite limited.
alias lua='rlwrap lua'

# Next alias above, unless they fit in one of the other sections.
# #endregion Aliases. }}}

# #region .git-frequent. {{{

alias gs='git status'
# simple and resumed, no branches
alias gss='git status -s'
# simple and resumed, with branches
alias gsb='git status -sb'

alias ga='git add'
alias gaa='git add --all'

alias gb='git branch'
alias gbd='git branch -d'

alias gco='git checkout'
# Go back to previous branch.
alias gco-='git checkout -'

alias gc='git commit -v'
alias gcm='git commit -m'

alias gac='gaa && gc'
alias gacm='gaa && gcm'

alias gd='git d'
alias gdk='git dk'

alias gpl="git pull"
alias gps="git push"
alias gpss="git push --set-upstream"
alias gpd='git push --dry-run'

alias gld="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
alias gl="gld -10"
alias gla="gld"
# git log graph
alias glg='git log --oneline --decorate --graph --all'
# git log simple
alias glsa="git log --oneline --no-decorate"
alias gls="glsa -5"
# git log messages
alias glm='git log --pretty=format:"* %s"'

alias grs='git restore'
alias grss='git restore --staged'
alias grssa='git restore --staged .'

alias gst='git stash'
alias gsta='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash push -m'
# TODO: test this when stashing
alias gsts='git stash show --text'
alias gstall='git stash --all'

alias gsh='git show'
alias gsps='git show --pretty=short --show-signature'

alias gt='git tag'
alias gta='git tag -a'
alias gts='git tag -s'
alias gtv='git tag | sort -V'

# TODO: test this
alias gchanges='git whatchanged -p --abbrev-commit --pretty=medium'

alias git-undo-last='git reset HEAD~'

alias gr='git remote'
alias grc='gr set-url'
alias grco='grc origin'

alias gcct="echo 'git conventional commit types (gcct): fix, feat, build, chore, ci, docs, style, refactor, perf, test'"

# Next git frequent alias above.

# git lfs
alias glfsdry="git lfs push origin main --dry-run --all"
alias glfss="git lfs status"

# #endregion .git-frequent. }}}

# #region .docker. {{{

alias pod=podman
alias docker=podman

alias dc="docker compose"
alias docker-prune-month-old-images='docker image prune -a --filter "until=720h"'
alias docker-prune-two-week-old-images='docker image prune -a --filter "until=336h"'

# # TODO: figure out what does this really do and whether or not I need it here. Formatting was all
# # weird and it seemed to be broken.
# docker_images_sorted() {
#   docker images --format "table {{.ID}}\t{{.Size}}\t{{.Repository}}:{{.Tag}}" \
#     | head -n1
#
#   docker images --format "{{.ID}}\t{{.Size}}\t{{.Repository}}:{{.Tag}}" \
#     | awk '{match($2, /([0-9.]+)([KMG]?B)/, a); size = a[1]; unit = a[2]; if (unit == "GB") size *= 1024; else if (unit == "KB") size /= 1024; printf "%s\t%09.2f MB\t%s \n", $1, size, $3}' \
#     | (sed -u 1q; sort -k 2 -h)
# }
# alias di='docker_images_sorted'

# Next docker/podman alias above.
# #endregion .docker. }}}

# ------------------------------------------------------------------------------
# THE END!
# ------------------------------------------------------------------------------

# Must be last, otherwise any failure above could cause the script to return non
# zero, which could have weird consequences.
return 0

# ------------------------------------------------------------------------------
# Documentation.
# ------------------------------------------------------------------------------
#
# #region .Shell HOW-TO. {{{
#
# - Discard commands outputs
#   - stdout: > /dev/null
#   - stderr: 2> /dev/null
#   - both
#     - more portable: > /dev/null 2>&1
#     - less portable (but good enough), shorter: &> /dev/null
# - Scripts and functions arguments
#   - each argument get a number: $1, $2, $3 ...
#   - for all arguments:
#     - $* => $1 $2 ... ${N}
#     - $@ => $1 $2 ... ${N}
#     - "$*" => "$1c$2c ... ${N}"
#     - "$@" => "$1" "$2" ... "${N}"
# - Difference between [[ and [
#   - [ is posix
#   - [[ is bash, inspired by the korn shell
#   - there are a lot of differences, described in more details in the answer below
#     - https://stackoverflow.com/a/47576482/1814970
#   - the recommendation is to always use [], as it is more portable and it has equivalents for
#     everything from [[]]
# - Function variables are not scoped to the function unless they are defined with `local`
#
# #endregion .Shell HOW-TO. }}}
