#!/usr/bin/env bash
# vim:tw=80:ts=4:sw=4:ai:et:ff=unix:fenc=utf-8:et:fixeol:eol:fdm=marker:fdl=1:fen:ft=sh
#
# Main shell configuration script. {{{
#
# File docs and posix shell how-to. {{{
#
# TODO: ideas
# -----------
#
#
# - [ ] add documentation on how this file works?
# - [ ] split files per sections?
# - [ ] use a different programming language for some stuff?
#
#
#
# Shell HOW-TO
# ------------
#
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
#
#
# To learn
# --------
#
#
# Move stuff from here to the section above after learning!
#
# - more posix stuff!
#
# }}}
#
# }}}

REQUIRED_ENVS=''

verify_defined() {
    local env_name="$1"
    local env_value
    eval env_value=\$$1

    if [ -z "$env_value" ]; then
        REQUIRED_ENVS="${REQUIRED_ENVS}'$env_name' must be defined with the $2.\n\n"
    fi
}

verify_defined "MCRA_PROJECTS_FOLDER" 'path to the folder where you put all your programming projects'
verify_defined "MCRA_INIT_SHELL" 'path to your shell init. I use the `.rc` file in this repo'
verify_defined "MCRA_LOCAL_SHELL" 'path to your local shell init, with stuff that you do not want tracked in a public repo'
verify_defined "MCRA_TMP_PLAYGROUND" 'path to a folder that you can use as a playground. I use /tmp/playground or something like this'

if [ ! -z "$REQUIRED_ENVS" ]; then
    echo $REQUIRED_ENVS
    return 1
fi

# Load commons.
if [ ! -f $HOME/bin/.rc.common ]; then
    ln -s $MCRA_PROJECTS_FOLDER/dotfiles/.rc.common $HOME/bin/.rc.common
fi
. $HOME/bin/.rc.common

# functions{{{

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

easy_jump_to_project() {
    if [[ ! -z "${MCRA_PROJECTS_FOLDER}" ]]; then
        if [[ ! -z "$1" ]]; then
            pushd ${MCRA_PROJECTS_FOLDER}/$1
        else
            popd
        fi
    else
        echo '${MCRA_PROJECTS_FOLDER} not defined'
    fi
}
alias j="easy_jump_to_project"

# Setup the default text editor based on what is installed.
if mm_is_command nvim; then
    export EDITOR=nvim

    # alias vim="$EDITOR"
    # alias vi=vim
    # alias v=vim
    # alias n=vim
    alias n=$EDITOR
elif mm_is_command vim; then
    export EDITOR=vim

    alias vim="$EDITOR"
    alias vi=vim
    alias v=vim
    alias n=vim
    alias n=$EDITOR
elif mm_is_command vi; then
    export EDITOR=vi
elif mm_is_command nano; then
    export EDITOR=nano
else
    echo "You don't have 'neovim' (nvim), 'vim', 'vi' or 'nano' installed."
    echo "No idea what the EDITOR env will be haha. Actually, take a look:"
    echo "$EDITOR"
fi

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
        echo "Not time provided, using default ($default_time). You can either provide a value (format: 1s, 20m, 2h, 1h20m) or use an existing template (currently: t1, t5, t15, t30, t60) all in minutes."
        time="$default_time"
    fi

    sleep "$time" && timer_notification
}
alias t5="sleep 5m && timer_notification"
alias t15="sleep 15m && timer_notification"
alias t30="sleep 30m && timer_notification"
alias t60="sleep 1h && timer_notification"

function force_rm() {
    local target="$(realpath $1)"

    # Verify that the target is not empty.
    if [[ -z "$target" ]]; then
        echo 'Please, provide the path to a file or folder.'
        return 1
    fi

    echo -n "> Verifying if target is valid for '$target': "

    # Verify that the target is inside the user home dir or the chosen tmp dir,
    # to avoid removing system stuff.
    case $target in
    $HOME/*)
        echo -n 'valid.'
        echo
        ;;
    $MCRA_TMP_PLAYGROUND/*)
        echo -n 'valid.'
        echo
        ;;
    /*)
        echo -n 'invalid.'
        echo
        echo
        echo "All paths should be within '$HOME' or '$MCRA_TMP_PLAYGROUND'. If you want to remove something above it, do manually (and BE SURE to know what you are doing!)"
        return 1
        ;;
    esac

    # Verify that the target is a file/symlink or a directory.
    if [[ ! -e "$target" && ! -d "$target" ]]; then
        echo 'What you are trying to remove is not a file nor a directory:'
        echo
        echo "  $target"
        echo
        echo 'Aborting...'

        return 1
    fi

    echo "> Running 'ls -la $target' ..."
    echo
    ls -la $target
    echo
    # while true; do
    #     read 'Are you sure you wish to permanentely remove it all? [yN] ' yn
    #     case $yn in
    #         [Yy]* ) rm -rf ${target}; break;;
    #         [Nn]* ) return 0;;
    #         * ) return 0;;
    #     esac
    # done
    echo '> Are you sure you wish to permanentely remove it all? [yN]'
    echo
    select yn in "y" "n"; do
        case $yn in
        y)
            echo
            echo "> Running 'rm -rf $target' ..."
            rm -rf $target
            return 0
            ;;
        n | *)
            echo
            echo 'Aborting...'
            return 1
            ;;
        esac
    done

    # Other idea:
    #
    #local valid_prefixes=($HOME $MCRA_TMP_PLAYGROUND)

    #echo "> Target should have one of the valid path prefixes:"
    #echo
    #echo "$target"
    #echo

    #for valid in "${valid_prefixes[@]}"; do
    #    if [[ $target == $valid/* ]]; then
    #        echo "\t[x] valid"
    #        echo "\t[ ] invalid"
    #    else
    #        echo "\t[ ] valid"
    #        echo "\t[x] invalid"
    #        echo
    #        echo "All paths should be within '$HOME' or '$MCRA_TMP_PLAYGROUND'. If you want to remove something above it, do manually (and BE SURE to know what you are doing!)"

    #        return 1
    #    fi
    #done

    return 1
}

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

# help() {
#   local args="$@"
#   local the_cmd="$1"

#   # The first argument MUST be a command.
#   if ! mm_is_command $the_cmd; then
#     echo "It seems like '$the_cmd' is not a command."
#     return 1
#   fi

#   # Already saved the first argument.
#   shift

#   local default_help_opt='help'
#   # Use nvim as pager. Options:
#   #  -R: readonly
#   #  -M: not modifiable or writeable (can't even save)
#   #  - : read from stdin
#   local default_pager='nvim -R -'
#   local default_manpager="nvim '+Man!'"

#   local help_opt="$default_help_opt"
#   if ! $the_cmd $help_opt >/dev/null 2>&1; then
#     help_opt='--help'
#   fi

#   if ! $the_cmd $help >/dev/null 2>&1; then
#     help_opt='-h'
#   fi

#   if ! $the_cmd $help >/dev/null 2>&1; then
#     help_opt=''
#   fi

#   local pager="$default_pager"
#   local use_man=$_FALSE
#   local manpager="$default_manpager"
#   while [ $# -ne 0 ]; do
#     case "$1" in
#       help|--help|-h)
#         help_opt="$2"; shift

#         ;;
#       pager|--pager|-p)
#         if $use_man; then break; fi # Ignore option if using man.
#         pager="$2"; shift
#         ;;
#       manpager|--manpager|-mp)
#         manpager="$2"; shift
#         ;;
#       man|-m)
#         use_man=$_TRUE
#         pager="$manpager"

#         shift
#         ;;
#       *)
#         ;;
#     esac
#     shift
#   done

#   if [ -z "$help_opt" ] || [ -z "$pager" ] || [ -z "$manpager" ]
#   then
#     mm_trim "
#       ERROR:
#           Args: $@
#           help_opt: $help_opt
#           pager: $pager
#           manpager: $manpager

#       Usage: $0 <cmd> [opts]

#       Opts:

#       -h,--help,help <help option/cmd name> (default '$default_help_opt')

#           The function already tests 'help', '--help' and '-h'. If those don't
#           work, provide another one with this option.

#           Example: help some_cmd -h 'info' (some_cmd help command is called 'info')

#       -p,--pager,pager <pager to use> (default '$default_pager')

#           Choose a different pager.

#           Example: help some_cmd -p less

#       -m (default: false)

#           Use a manpager.

#       -mp,--manpager,manpager <manpager to use> (default: '$default_manpager')

#           Chooses a different manpager. When used, the -p option is ignored.
#           Ignored if -m is not provided.

#           Example: help some_cmd -m -mp less
#     " 4
#     return 1
#   fi

#   $the_cmd $help_opt | $pager
# }

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
function compress_video() {
    local input="${1:-input.mp4}"
    local output="${2:-output.mp4}"

    ffmpeg -i $input -vcodec libx265 -crf 28 $output
}

# List broken symlinks in folder.
function broken_symlinks() {
    find "${1:-.}" -type l ! -exec test -e {} \; -exec ls -lah --color {} \;
}

# next function above.
# }}}functions
# aliases{{{
# one lettered{{{

# Used in the following sections:

# b = popd
# l = ls ...
# n = reserved
# r = js run
# s = reserved
# t = go to my temp dir
# v = vim
# g = some type of grep

# }}}one lettered
# general{{{

# Show diffs between files.

if command -v code &>/dev/null; then
    # VSCode diff is great!
    alias diff-code="code -d"
fi

if [ "$EDITOR" = "nvim" ]; then
    # Neovim diff is good too.
    alias vimdiff="nvim -d"
fi

# -l: print as a list.
# -F: classify (folder vs files).
# -h: print human readable sizes (using K, M, G instead of bytes).
# -t: sort by time, most recently updated first.
# --time-style: how to show time. Currently, 30mar23-22h10.
# --hyperlink=auto: stuff becomes clickable. For example, it is possbile to
#   open images in kitty term.
alias myls='ls -lFt --group-directories-first --color=always --time-style="+%d%b%y-%Hh%M"'
alias myls_display_no_group='awk -f <(cat - <<-'\''EOF'\''
    BEGIN {
        print
    }

    {
        # If the line starts with "total", print as is.
        if (index($1, "total") == 1) {
            print $0;
            next;
        }

        total += $5;
        printf "%-10s   %-4.4s%3s   %-13s   %s\n", $1, $5/1024, "KB", $6, substr($0, index($0,$7));
    }

    END {
        total_kb = total/1024;
        total_mb = total_kb/1024;
        printf "\nSize: %s MB (%s KB)\n", total_mb, total_kb;
    }
EOF
)'

alias myls_display_table='awk -f <(cat - <<-'\''EOF'\''
    BEGIN {
        sep = "";
        "tput cols" | getline the_cols;
        for (i=0; i < the_cols ; i++) {
            sep = sep"-";
        }
    }

    NR == 1 {
        printf "%sSize (B) |  Date (Desc)  | Files and Folders\n%s", sep, sep;
    }

    NR > 1 {
        total += $5;
        printf "%-9s| %-14s| %s\n", $5, $6, substr($0, index($0,$7));
    }

    END {
        printf "\nTotal (KB): %s\nTotal (MB): %s\n", total/1024, total/1024/1024;
        printf "%s\n", sep;
    }
EOF
)'

function improved_ls() {
    local path_to_use=${1:-.}
    local tree_level
    local is_next=false

    [[ -n "$1" ]] && shift

    # Try to get `path_to_use` from the --path option in $@.
    for arg in "$@"; do
        if [[ $arg == --path=* ]] || [[ $arg == -p=* ]]; then
            path_to_use="${arg#*=}"
        elif [[ "$arg" == "--path" ]] || [[ "$arg" == "-p" ]]; then
            is_next=true
        elif $is_next; then
            path_to_use="$arg"
            is_next=false
        fi
    done

    for arg in "$@"; do
        if [[ $arg == --level=* ]] || [[ $arg == -l=* ]]; then
            tree_level="${arg#*=}"
        elif [[ "$arg" == "--level" ]] || [[ "$arg" == "-l" ]]; then
            is_next=true
        elif $is_next; then
            tree_level="$arg"
            is_next=false
        fi
    done

    echo "--path=${path_to_use}"
    [[ -n "$tree_level" ]] && echo "--level=${tree_level}"

    # Remove the --path and --level option from the arguments.
    local rest=$(echo "$@" | sed -E -e 's/(--path|-p)[= ][^ ]+//g' -e 's/(--level|-l)[= ][^ ]+//g')

    myls ${path_to_use} ${rest} | myls_display_table
    [[ -n "$tree_level" ]] &&
        tree "${path_to_use}" -L $tree_level ||
        true
}

function improved_ls_no_group() {
    myls $@ | myls_display_no_group
}

if [[ $(uname) == "Darwin" ]]; then
    # Mac doesn't support the --time-style flag.
    alias l='ls -lFh -t'
else
    alias l='improved_ls_no_group'
    alias lt='improved_ls'
fi

function improved_ls_full() {
    local path_to_use=${1:-.}
    [[ -n "$1" ]] && shift
    improved_ls $path_to_use $@ -A
}
alias ll='improved_ls_no_group -A'
alias llt='improved_ls_full'

if [[ ! -z "${MCRA_INIT_SHELL}" && ! -z "${MCRA_LOCAL_SHELL}" ]]; then
    alias rc.='echo -n "Reloading configs at $(date +%F_%T)... " \
        && source $MCRA_LOCAL_SHELL \
        && source $MCRA_INIT_SHELL \
        && echo '\''done!'\'' \
        || echo '\''failed :('\'''
    # # Changed in the last 10 minutes.
    # alias rc_changed='find $MCRA_INIT_SHELL $MCRA_LOCAL_SHELL -mmin -10'
    alias rc='cd $MCRA_PROJECTS_FOLDER/dotfiles; $EDITOR $MCRA_INIT_SHELL; rc.'
    alias rcl='cd $MCRA_PROJECTS_FOLDER/dotfiles; $EDITOR $MCRA_LOCAL_SHELL; rc.'
    alias rcz='cd $MCRA_PROJECTS_FOLDER/dotfiles; $EDITOR ~/.zshrc; rc.'
    alias rcb='cd $MCRA_PROJECTS_FOLDER/dotfiles; $EDITOR ~/.bashrc; rc.'
else
    alias rc="echo 'Define \$MCRA_INIT_SHELL and \$MCRA_LOCAL_SHELL in your rc file'"
    alias rcl=rc
    alias rcz=rc
    alias rcb=rc
    alias rc.=rc
fi

# Speech synthesizer.
alias say="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"
alias fala="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"
alias falar="spd-say -w -l pt-BR -p 100 -r -30 -R 100 -m all"

# # AsciiDoc.
# alias asciidoctor="docker run --rm -it -v $(pwd):/documents/ asciidoctor/docker-asciidoctor"
# alias asciidoctor-gen="docker run --rm -v $(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf index.adoc"

# Always use sed with extended regexes.
if [[ $(uname) == "Darwin" ]]; then
    alias sed='sed -E'
else
    alias sed='sed -r'
fi

# I never remember how to extract tar files. Now I discovered that it
# automatically detect the compression format, so I only need to provide the -x
# (extract) and the -f (point to file) options (f has to be the last one if
# they are provided together).
alias untar="tar -xf"

# Always use the same tmp and make it easy to go there.
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

alias ppath="echo $PATH | tr ':' '\n'"

alias t1="tree -L 1"
alias t2="tree -L 2"
alias t3="tree -L 3"
alias t4="tree -L 4"
alias t5="tree -L 5"

alias is_venv='which deactivate >/dev/null 2>&1 && true || false'
function check_python_venv() {
    local in_venv
    if is_venv; then
        in_venv="IN"
    else
        in_venv="NOT IN"
    fi

    printf "\n!!! %s A VIRTUAL ENVIRONMENT... !!!\n\n\n" $in_venv
}
alias python3='check_python_venv && python3'
alias python=python3
alias py='python'

if mm_is_command rg; then
    alias g=rg
elif mm_is_command egrep; then
    alias g=egrep
elif mm_is_command grep; then
    alias g=grep
fi

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

# List processes bound to all ports.
alias list_process_to_port_all="netstat -lnp"
# Same, but for TCP only. This is usually what I want, e.g. when a server hold
# it even after ctrl+c.
alias list_process_to_port_tcp="netstat -lnpt"

# Fonts
# -----

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

# Monitor
# -------

alias monitor_show_dpi="xdpyinfo | grep dots"

# Last time a user logged into the system.
alias last_login="last -10"

# Print the size of the files in the current directory.
alias files_cwd_size_in_mb='ls -la | awk '\''{sum += $5} END {print sum/1024/1024 " MB"}'\'''
alias files_size_in_mb='awk '\''{sum += $5} END {print sum/1024/1024 " MB"}'\'''

# Get os version, name and details.
alias system_info='cat /etc/os-release && lsb_release -a && hostnamectl && uname -r'

# Pnpm stuff
# ----------

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

# Chrome
# ------

# Start Chrome using other language.
alias chrome_br='LANGUAGE=pt_BR google-chrome-stable'

# Python
# ------

alias venv_activate='source .venv/bin/activate'

# Init local python environment and install pip.
alias initpy='uv init && uv venv && uv add pip && venv_activate'

# List monospaced fonts.
# ---------------------

alias list_mono_fonts='fc-list : family spacing outline scalable | grep -e spacing=100 -e spacing=90 | grep -e outline=True | grep -e scalable=True'

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

# next alias above, unless they fit in one of the other sections.
# }}}general
# git frequent{{{

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

# }}}git frequent
# git lfs{{{

alias glfsdry="git lfs push origin main --dry-run --all"
alias glfss="git lfs status"

# }}}git lfs
# docker{{{

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

# }}}docker
# }}}aliases

# The end.

# Must be last, otherwise any failure above could cause the script to return non zero, which could
# have weird consequences.
return 0
