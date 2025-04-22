#!/usr/bin/env bash
# vim:tw=80:ts=4:sw=4:ai:et:ff=unix:fenc=utf-8:et:fixeol:eol:fdm=marker:fdl=0:fen:ft=sh

readonly TMP_LOGFILE='/tmp/mcra.custom.terminal.log'

PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

log() {
    echo "[$(date '+%F_%T')] $@" >>$TMP_LOGFILE
}

run() {
    local cmd_with_args="$@"
    log "run: cmd_with_args = [$cmd_with_args]"

    bash -c "$cmd_with_args" >>$TMP_LOGFILE 2>&1
}

has_prefix() {
    if [ $# -ne 2 ]; then
        error 'Usage: has_prefix "original string" "prefix to check".'
    fi

    if [ "${1#$2}" != "$1" ]; then
        # The `${1#$2}` substitution replaces $2 at the beginning of $1, making it different from
        # itself, hence entering this branch and confirming that $2 is a prefix on $1.
        return 0 # true
    else
        return 1 # false
    fi
}

use_gnome_terminal() {
    # Get the default profile ID.
    local profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
    log "profile_id: $profile_id"

    # Get the font setting for the default terminal profile.
    local font="$(dconf read /org/gnome/terminal/legacy/profiles:/:$profile_id/font)"
    log "font: $font"

    # Extract the font family and its size.
    local font_family=$(echo $font | sed -E -e "s/'([^0-9]+) [0-9]+'/\1/g")
    local font_size=$(echo $font | grep -o '[0-9]\+')
    log "font_family: $font_family | font_size: $font_size"

    # Default values.
    local columns=150
    local rows=60
    log "default columns: $columns | rows: $rows"

    # TODO: eventually I can play with this to figure the char width and height dynamically. Then
    # the rest of the commented stuff might help.
    # char_width=8
    # char_height=12

    if has_prefix "$font_family" 'Geist'; then
        if [ $font_size -eq 10 ]; then
            columns=157
            rows=81
        elif [ $font_size -eq 11 ]; then
            columns=139 # widescreen. In normal: ?
            rows=54
        elif [ $font_size -eq 8 ]; then
            columns=209 # widescreen. In normal: ?
            rows=84
        fi
    elif has_prefix "$font_family" 'Meslo'; then
        if [ $font_size -eq 13 ]; then
            columns=91
            rows=45
        elif [ $font_size -eq 11 ]; then
            columns=103
            rows=55
        elif [ $font_size -eq 10 ]; then
            columns=155 # widescreen. In normal: 115
            rows=60
        elif [ $font_size -eq 9 ]; then
            columns=131
            rows=65
        elif [ $font_size -eq 8 ]; then
            columns=209 # widescreen. In normal: ?
            rows=84
        fi
    elif has_prefix "$font_family" 'JetBrains'; then
        if [ $font_size -eq 10 ]; then
            columns=157 # widescreen. In normal: ?
            rows=60
        elif [ $font_size -eq 13 ]; then
            columns=125
            rows=60
        elif [ $font_size -eq 11 ]; then
            columns=139 # wide
            rows=55
        elif [ $font_size -eq 9 ]; then
            columns=179 # widescreen. In normal: ?
            rows=61
        elif [ $font_size -eq 8 ]; then
            columns=209 # widescreen. In normal: ?
            rows=84
        fi
    elif has_prefix "$font_family" 'Cascadia Code NF'; then
        # Widescreen. Normal?
        if [ $font_size -eq 10 ]; then
            columns=156
            rows=62
        elif [ $font_size -eq 11 ]; then
            columns=104 # Notebook
            rows=57
        elif [ $font_size -eq 9 ]; then
            columns=179
            rows=70
        elif [ $font_size -eq 8 ]; then
            columns=209
            rows=84
        fi
    elif has_prefix "$font_family" 'Monaspace Neon Var'; then
        if [ $font_size -eq 9 ]; then
            columns=179
            rows=69
        fi
    elif has_prefix "$font_family" 'Rec Mono'; then
        if [ $font_size -eq 13 ]; then
            columns=125
            rows=100
        elif [ $font_size -eq 9 ]; then
            columns=179
            rows=100
        elif [ $font_size -eq 11 ]; then
            columns=139
            rows=100
        fi
    fi

    # # Get the current screen resolution.
    local resolution=$(xrandr | grep '*' | awk '{print $1}')
    local screen_width=$(echo $resolution | cut -d'x' -f1)
    # screen_height=$(echo $resolution | cut -d'x' -f2)
    log "screen_width: $screen_width"

    # Calculate half the screen width. `gnome-terminal` prioritizes the number of columns and rows
    # over starting point. Therefore, we can push the window all the way to the right and still have
    # it loading where we want if we get the correct values for rows and columns.
    local half_width=$((screen_width))

    # # Convert pixel dimensions to terminal columns and rows using the estimated character dimensions.
    # columns=$((half_width / char_width))
    # rows=$((screen_height / char_height))

    log "column:$columns | rows:$rows | width:$half_width"

    local cmd="gnome-terminal --title 'scratchpad' --hide-menubar"
    cmd="$cmd --geometry \"${columns}x${rows}+${half_width}+0\""
    cmd="$cmd --working-directory=$HOME -- "

    echo "$cmd"
}

use_wezterm() {
    # local resolution=$(xrandr | grep '*' | awk '{print $1}')
    # local screen_width=$(echo $resolution | cut -d'x' -f1)
    # local half_width=$((screen_width / 2))

    # log "$half_width"

    echo "/home/linuxbrew/.linuxbrew/bin/wezterm start --position '1303,0' -- "
}

use_alacritty() {
    echo "~/.cargo/bin/alacritty -e "
}

use_term() {
    local cmd="$1"
    local term=''
    log "chosen terminal: $cmd"

    case "$1" in
    gnome) term="$(use_gnome_terminal)" ;;
    wezterm) term="$(use_wezterm)" ;;
    alacritty) term="$(use_alacritty)" ;;
    *) term="$(use_alacritty)" ;;
    esac

    echo $term
}

main() {
    local term="$1"
    local name="$1"

    local command="$(use_term "$1")"
    local sub_command=''

    # TODO: check if tmux is installed.

    # If session exists, connect to it. Otherwise, create it.
    if run tmux has -t $name; then
        log "has session '$name'"

        # Need quotes because of the pipe.
        if run "tmux lsc | grep ' $name '"; then
            sub_command="tmux detach -s $name"
            log "should detach from '$name'"
        else
            sub_command="tmux attach -t $name"
            log "should reattach to '$name' by running:"
        fi
    else
        sub_command="tmux new -s $name"
        log "no session '$name', creating one with:"
    fi

    log "name: $name"
    log "cmd:"
    log "  $command"
    log "with args:"
    log "  $sub_command"

    # Works.
    run $command $sub_command

    # Alternatives to try:
    # /home/linuxbrew/.linuxbrew/bin/wezterm start --position '1303,0' --
    # eval "$command $sub_command"
}

echo '' >>$TMP_LOGFILE
echo '--------------------------------------------------------------------------' >>$TMP_LOGFILE
log 'running .scratch again...'

main "$@"
