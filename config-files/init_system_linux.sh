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

reduce_speed_of_evoluent_mouse() {
    local device_id
    device_id=$(xinput \
        | sed -nre 's/.*Evoluent\ VerticalMouse.*id\=([0-9]+).*/\1/p' \
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
reduce_speed_of_evoluent_mouse

