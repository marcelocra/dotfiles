#!/usr/bin/env sh
#
# Commands run during system startup.
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


# Commands need xinput, so check that first.
if [ -f "${HOME}/.no-xinput-found" ]; then
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
        # In this device, top buttons are 1 and 3, botton are 8 and 9. Thinking
        # of a pizza with 4 pieces, top left is 1 and bottom left is 8.
        # Here we are mapping those buttons to what xinput expects:
        #   1) browser back. Will be mapped to mouse 1
        #   2) left click. Will be mapped to mouse 8
        #   3) right click. Will be mapped to mouse 9
        #   4->5) scroll. Keep as is.
        #   6->7) don't know. Keep as is.
        #   8) browser forward. Will be mapped to mouse 3.
        #   9->10) don't remember, but mapped to 0 for some reason.
        xinput set-button-map $device_id 1 8 9 4 5 6 7 3 0 0
    fi
}

# Configure Evoluent vertical mouse so that back/forward buttons work as
# expected.
setup_evoluent_mouse() {
    local device_id

    device_id=$(xinput \
        | sed -nre 's/.*Evoluent\ VerticalMouse.*id\=([0-9]+).*/\1/p' \
        | head -n1)
    if [ ! -z "$device_id" ]; then
        # This device is different from the one above, but I don't remember
        # exactly how. As I discover, will add here.
        xinput set-button-map $device_id 1 2 3 4 5 6 7 8 10 9
    fi
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

    xinput set-prop $device_id $prop_id -0.75  # I found this value to be good.
}

setup_expert_mouse
setup_evoluent_mouse
reduce_speed_of_logitech_mouse
