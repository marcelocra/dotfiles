#!/bin/sh

# Commands to run during system startup.
#
# To set them up, use Ubuntu's Startup Application app (also present in Linux
# Mint). Open the app and add a new command, pasting the path to this file.
#
# BE AWARE that simply doing that might not be enough, as sometimes the
# configurations only work if the desktop is fully loaded before they are
# applied.
#
# In those cases, add a delay to the command. Linux Mint provide a 'delay'
# option directly in the UI. If that's not the case for the distro you are
# using, do something like this:
#
#   /bin/sh -c "sleep 3 && /path-to-this-file/init_system_linux.sh"
#
# For more details, take a look at: https://askubuntu.com/a/708043/121101.
#
# After setting that up, reboot the system and you should be good to go!

# -- [ Configure hardware ] ----------------------------------------------------

set -e

# TODO: move this and the following ideas to `.rc.common`.
now() {
    echo "$(date '+%F_%T')"
}

logfile="$HOME/.log.linux-startup-config.$(now).txt"

prefix() {
    echo -n "[$(now | sed -E -e 's/_/ /')] [$@]"
}

error() {
    echo -n "$(prefix error) $@\n" | tee -a $logfile
}

debug() {
    echo -n "$(prefix debug) $@\n" | tee -a $logfile
}

usage() {
  echo 'Usage: ./linux-startup-config.sh [options = all (if no arg is provided)]

options:
  - expert: setup expert mouse to have more intuitive usage settings
  - evoluent: setup evoluent mouse to have more intuitive usage settings
  - logitech: reduce speed of logitech mouse
  - todoist: symlink todoist again after an update
  - all: do everything'
}


if [ $# -eq 0 ]; then
  arg='all'
else
  arg="$@"

  found=0

  for valid_arg in "all expert evoluent logitech todoist"; do
    if [ "$arg" = "$valid_arg" ]; then
      found=1
      break
    fi
  done

  if [ $found -eq 0 ]; then
    error 'Invalid option!'
    usage
    return 1
  fi
fi

# Commands need xinput, so check that first.
if [ -f "${HOME}/.no-xinput-found" ]; then
  error 'xinput not available. install that first'
  return 1
fi

if ! command -v xinput >/dev/null 2>&1; then
  local no_xinput
  no_xinput="${HOME}/.no-xinput-found"

  echo >&2 "I require xinput but it's not installed.  Aborting."
  echo >&2 "I will create ${no_xinput} and won't try again. If you"
  echo >&2 "want this to run again, delete that file."
  touch "${no_xinput}" && echo >&2 "Created!" || echo >&2 "Failed :("
  return 1
fi


# Configure expert mouse, if available.
setup_expert_mouse() {
    local device_id

    device_id=$(xinput list \
        | sed -nre 's/.*Kensington\ Expert\ Mouse.*id\=([0-9]+).*/\1/p' \
        | head -n1)
    if [ ! -z "$device_id" ]; then
        # In this device, buttons are originally as follows:
        #
        #  / 2 | 8 \
        # |----O----|
        #  \ 1 | 3 /
        #
        # With the following functions:
        #
        # 1 = left click
        # 2 = middle click
        # 3 = right click
        # 8 = navigation back
        #
        # We want to remap it so that:
        #
        # 1 = right click
        # 2 = navigation back
        # 3 = navigation forward
        # 8 = left click
        #
        # And avoid changing the others.
        #
        # Remapping works like this: the argument position is the physical
        # mouse numbers and the original numbers map to that physical button's
        # function. E.g.: the first argument represents the physical 1 in the
        # drawing above. When we place the number 3 there, we are "moving its
        # function" (right click) to be in the physical button number 1. At
        # this point, physical buttons and functions won't match anymore, but
        # that's ok.
        xinput set-button-map $device_id 3 8 9 4 5 6 7 1
    fi
}

# Reconfigure Evoluent vertical mouse to swap back/forward button. Originally,
# they are assigned to the bottom/top buttons respectively, but I prefer
# top/bottom. Also reduce the device speed.
setup_evoluent_mouse() {
    # Swap back/forward buttons.
    local device_id

    device_id=$(xinput \
        | sed -nre 's/.*Evoluent\ VerticalMouse.*id\=([0-9]+).*/\1/p' \
        | head -n1)
    if [ -z "$device_id" ]; then
      return
    fi

    xinput set-button-map $device_id 1 2 3 4 5 6 7 8 10 9

    # Reduce the device acceleration speed.
    local prop_id
    prop_id=$(xinput list-props $device_id \
        | sed -nre 's/.*Accel\ Speed\ \(([0-9]+)\).*/\1/p' \
        | head -n1)
    if [ -z "$prop_id" ]; then
        return
    fi

    # This is a good value that I found by testing different ones.
    xinput set-prop $device_id $prop_id -0.75
}

reduce_speed_of_logitech_mouse() {
    local device_id
    device_id=$(xinput \
        | sed -nre 's/.*Logitech.*Mouse.*id\=([0-9]+).*/\1/p' \
        | head -n1)
    if [ -z "$device_id" ]; then
        return
    fi

    local prop_id
    prop_id=$(xinput list-props $device_id \
        | sed -nre 's/.*Accel\ Speed\ \(([0-9]+)\).*/\1/p' \
        | head -n1)
    if [ -z "$prop_id" ]; then
        return
    fi

    # This is a good value that I found by testing different ones.
    xinput set-prop $device_id $prop_id -0.75
}

# Todoist has an auto update feature that replaces the AppImage binary with
# a new one, meaning that the reference used in the .desktop file end up
# invalid. But that only happens after a system restart, so this is meant to
# update the reference, keeping the .desktop valid.
#
# It also replaces the ~/.local/share/applications/todoist.desktop, it seems,
# as I also symlink it to my own, but after updates the symlink seems to be
# gone, but I need to double check this. In any case, if the binary link is ok,
# I guess the .desktop won't be an issue.
symlink_todoist_again() {
    local my_packages_dir="$HOME/bin/binaries"

    if [ ! -d $my_packages_dir ]; then
        my_packages_dir="$HOME/bin/packages"
    fi

    if [ ! -d $my_packages_dir ]; then
        # No packages found. Nothing to do.
        return
    fi

    local todoist_dir="$my_packages_dir/todoist"
    if [ ! -d $todoist_dir ]; then
        # todoist_dir not found. Nothing to do.
        return
    fi

    local todoist_latest_bin="$(ls $todoist_dir | sort -V -r | head -n1 | grep -E '^Todoist.+AppImage$')"

    if [ -z $todoist_latest_bin ]; then
        # No binary available. Nothing to do.
        return
    fi

    ln -f -s $todoist_dir/$todoist_latest_bin $HOME/bin/todoist
}

debug "Provided argument: '$arg'\n"

if [ "$arg" = "expert" ] || [ "$arg" = "all" ]; then


  debug "Running 'expert'..."
  setup_expert_mouse
  debug 'Done!'

fi

if [ "$arg" = "evoluent" ] || [ "$arg" = "all" ]; then

  debug "Running 'evoluent'..."
  setup_evoluent_mouse
  debug 'Done!'

fi

if [ "$arg" = "logitech" ] || [ "$arg" = "all" ]; then

  debug "Running 'logitech'..."
  reduce_speed_of_logitech_mouse
  debug 'Done!'

fi

if [ "$arg" = "todoist" ] || [ "$arg" = "all" ]; then

  debug "Running 'todoist'..."
  symlink_todoist_again
  debug 'Done!'

fi

return 0
