#!/usr/bin/env zsh
#
# TODO: Figure out why this doesn't work as expected. Gives the same error as
# when using the bash version. Perhaps it is a matter of misunderstanding the
# `source` command?

function WIP_improved_ls() {
    source $MCRA_CONSOLE_TOOLS/libs/getopt_utils.zsh
    parse_options "p:l:h" "path:,level:,help" "$@"

    [[ -z "$path" ]] && path='.'

    myls $path $@ | myls_display

    [[ -n "$level" ]] \
        && tree $path -L $level \
        || true
}

function WIP_register() {
    if [[ `uname` == "Darwin" ]]; then
        # Mac doesn't support the --time-style flag.
        alias l='ls -lFh -t'
    else
        alias l='improved_ls'
    fi

    alias ll='improved_ls -A'
}
