#!/usr/bin/env python3

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
#
# For more details, take a look at: https://askubuntu.com/a/708043/121101.
#
# After setting that up, reboot the system and you should be good to go!

# -- [ Configure hardware ] ----------------------------------------------------

import datetime
import os
import re
import shutil
import subprocess
import sys

DEBUG = False

# Use the same sensitivity in all pointing devices. This is a good value that I
# found by testing different ones. It is also the minimum (values can be float,
# and -1.1 gives error. I believe the maximum is 1).
DEVICE_SENSITIVITY = -1

HOME = os.path.expanduser("~")
LOGFILE = os.path.join(
    HOME, f".mcra.linux-startup-config.{datetime.datetime.now().strftime('%F_%T')}.log"
)


def prefix(level, *args):
    """Generate a log prefix with a timestamp and level."""
    timestamp = datetime.datetime.now().strftime("%F %T")
    return f"[{timestamp}] [{level}] " + " ".join(map(str, args))


def write_log(msg):
    """Write a message to stdout and append it to LOGFILE."""
    print(msg)
    with open(LOGFILE, "a") as f:
        f.write(msg + "\n")


def error(*args):
    msg = prefix("error", *args)
    write_log(msg)


def debug(*args):
    if not DEBUG:
        return
    msg = prefix("debug", *args)
    write_log(msg)


def log(*args):
    msg = prefix("log", *args)
    write_log(msg)


def run_command(cmd):
    """
    Run a shell command and return (success, output) tuple.
    The command is executed with shell=True; adjust if you want more safety.
    """
    try:
        output = subprocess.check_output(
            cmd, stderr=subprocess.STDOUT, shell=True, universal_newlines=True
        )
        return True, output.strip()
    except subprocess.CalledProcessError as e:
        return False, e.output.strip()


def usage():
    print("Usage: ./linux-startup-config.py [option]")
    print("Options:")
    print("  expert:   setup expert mouse")
    print("  evoluent: setup evoluent mouse")
    print("  logitech: reduce speed of logitech mouse")
    print("  multilaser: reduce speed of multilaser mouse")
    print("  razer:    reduce speed of razer mouse")
    print("  todoist:  symlink todoist again after update")
    print("  all:      run all setups (default if no option provided)")


def get_device_id(pattern):
    """
    Run xinput list and return the first captured device id found using pattern.
    The pattern should have a capturing group that matches the id.
    """
    success, out = run_command("xinput list")
    if not success:
        error("xinput list failed")
        return None
    m = re.search(pattern, out, re.IGNORECASE)
    if not m:
        return None
    return m.group(1)


def get_prop_id(device_id, pattern):
    """
    Run xinput list-props for a given device and return the first captured property id.
    The pattern should have a capturing group.
    """
    cmd = f"xinput list-props {device_id}"
    success, out = run_command(cmd)
    if not success:
        error("Failed to get properties for device", device_id)
        return None
    m = re.search(pattern, out, re.IGNORECASE)
    if not m:
        return None
    return m.group(1)


def configure_mouse(
    device_pattern, button_map=None, prop_pattern=None, prop_value=None, use_float=False
):
    """
    Generic function to configure a mouse device.
      - device_pattern: regex pattern (with one capturing group for device id) used on xinput list.
      - button_map: if provided, a list of integers for xinput set-button-map.
      - prop_pattern: a regex (with one capturing group) to locate a property id from xinput list-props.
      - prop_value: the new value to set for the property.
      - use_float: if True, use xinput set-float-prop, else use xinput set-prop.
    Returns True on success, False otherwise.
    """
    device_id = get_device_id(device_pattern)
    if not device_id:
        debug("Device not found for pattern:", device_pattern)
        return False
    log("Found device id", device_id, "for pattern", device_pattern)
    if button_map:
        cmd = f"xinput set-button-map {device_id} " + " ".join(map(str, button_map))
        success, output = run_command(cmd)
        if not success:
            error("Failed to set button map for device", device_id)
            return False
        log("Set button map for device", device_id, "to", button_map)
    if prop_pattern and (prop_value is not None):
        prop_id = get_prop_id(device_id, prop_pattern)
        if not prop_id:
            debug("Property not found using pattern:", prop_pattern)
            return False
        cmd_name = "xinput set-float-prop" if use_float else "xinput set-prop"
        cmd = f"{cmd_name} {device_id} {prop_id} {prop_value}"
        success, output = run_command(cmd)
        if not success:
            error("Failed to set property for device", device_id)
            return False
        log("Set property for device", device_id, "to", prop_value)
    return True


def setup_expert_mouse():
    """Setup the expert mouse.

    In this device, buttons are originally as follows:

     / 2 | 8 \
    |----O----|
     \ 1 | 3 /

    With the following functions:

    1 = left click
    2 = middle click
    3 = right click
    8 = navigation back

    We want to remap it so that:

    1 = right click
    2 = navigation back
    3 = navigation forward
    8 = left click

    And avoid changing the others.

    Remapping works like this: the argument position is the physical
    mouse numbers and the original numbers map to that physical button's
    function. E.g.: the first argument represents the physical 1 in the
    drawing above. When we place the number 3 there, we are "moving its
    function" (right click) to be in the physical button number 1. At
    this point, physical buttons and functions won't match anymore, but
    that's ok.

        xinput set-button-map $device_id 3 8 9 4 5 6 7 1
    """
    # Kensington Expert Mouse: remap buttons
    pattern = r"Kensington\s+Expert\s+Mouse.*id\s*=\s*([0-9]+)"
    # Remap so that: physical 1 becomes 3, 2 becomes 8, 3 becomes 9 and 8 becomes 1.
    button_map = [3, 8, 9, 4, 5, 6, 7, 1]
    return configure_mouse(pattern, button_map=button_map)


def setup_evoluent_mouse():
    """Reconfigure Evoluent vertical mouse to swap back/forward button.

    Originally, they are assigned to the bottom/top buttons respectively, but I
    prefer top/bottom. Also reduce the device speed.
    """
    pattern = r"Evoluent\s+VerticalMouse.*id\s*=\s*([0-9]+)"
    button_map = [1, 2, 3, 4, 5, 6, 7, 8, 10, 9]
    # The property pattern searches for: "Accel Speed (some_number)"
    prop_pattern = r"Accel\s+Speed\s+\(([0-9]+)\)"
    return configure_mouse(
        pattern,
        button_map=button_map,
        prop_pattern=prop_pattern,
        prop_value=DEVICE_SENSITIVITY,
    )


def reduce_speed_of_logitech_mouse():
    pattern = r"Logitech.*Mouse.*id\s*=\s*([0-9]+)"
    prop_pattern = r"Accel\s+Speed\s+\(([0-9]+)\)"
    return configure_mouse(
        pattern, prop_pattern=prop_pattern, prop_value=DEVICE_SENSITIVITY
    )


def reduce_speed_of_multilaser_mouse():
    pattern = r"YICHIP.*Mouse.*id\s*=\s*([0-9]+)"
    prop_pattern = r"Accel\s+Speed\s+\(([0-9]+)\)"
    return configure_mouse(
        pattern,
        prop_pattern=prop_pattern,
        prop_value=DEVICE_SENSITIVITY,
        use_float=True,
    )


def reduce_speed_of_razer_mouse():
    pattern = r"Razer.*DeathAdder.*id\s*=\s*([0-9]+)"
    # For DeathAdder, the property is identified via libinput Accel Speed.
    prop_pattern = r"libinput\s+Accel\s+Speed\s+\(([0-9]+)\)"
    return configure_mouse(
        pattern, prop_pattern=prop_pattern, prop_value=-0.8, use_float=True
    )


def symlink_todoist_again():
    """
    Todoist has an auto update feature that replaces the AppImage binary with a
    new one, meaning that the reference used in the .desktop file end up
    invalid.  But that only happens after a system restart, so this is meant to
    update the reference, keeping the .desktop valid.

    It also replaces the ~/.local/share/applications/todoist.desktop, it seems,
    as I also symlink it to my own, but after updates the symlink seems to be
    gone, but I need to double check this. In any case, if the binary link is
    ok, I guess the .desktop won't be an issue.  Configure expert mouse, if
    available.
    """
    my_packages_dir = os.path.join(os.environ["HOME"], "bin", "binaries")
    if not os.path.isdir(my_packages_dir):
        my_packages_dir = os.path.join(os.environ["HOME"], "bin", "packages")
    if not os.path.isdir(my_packages_dir):
        log("Packages directory not found:", my_packages_dir)
        return False
    todoist_dir = os.path.join(my_packages_dir, "todoist")
    if not os.path.isdir(todoist_dir):
        log("Todoist directory not found:", todoist_dir)
        return False
    # Find Todoist AppImage candidates.
    candidates = [
        f for f in os.listdir(todoist_dir) if re.match(r"^Todoist.+AppImage$", f)
    ]
    if not candidates:
        log("No Todoist AppImage found in", todoist_dir)
        return False
    # Use a natural sort based on numbers.
    candidates.sort(
        key=lambda s: [
            int(text) if text.isdigit() else text for text in re.split("([0-9]+)", s)
        ],
        reverse=True,
    )
    todoist_latest = candidates[0]
    src = os.path.join(todoist_dir, todoist_latest)
    dest = os.path.join(os.environ["HOME"], "bin", "todoist")
    try:
        if os.path.exists(dest):
            os.remove(dest)
        os.symlink(src, dest)
        log("Symlinked", src, "to", dest)
        return True
    except Exception as e:
        error("Failed to symlink todoist:", e)
        return False


def main(args):
    if len(args) == 0:
        arg = "all"
    else:
        arg = args[0]
    valid_args = [
        "all",
        "expert",
        "evoluent",
        "logitech",
        "multilaser",
        "razer",
        "todoist",
    ]
    if arg not in valid_args:
        error("Invalid option!")
        usage()
        sys.exit(1)
    log("Provided argument:", arg)

    # Check that xinput is available.
    if not shutil.which("xinput"):
        error("xinput not available. Please install xinput.")
        sys.exit(1)

    if arg in ("expert", "all"):
        log("Running 'expert'...")
        setup_expert_mouse()
        log("Done with 'expert'.")
    if arg in ("evoluent", "all"):
        log("Running 'evoluent'...")
        setup_evoluent_mouse()
        log("Done with 'evoluent'.")
    if arg in ("logitech", "all"):
        log("Running 'logitech'...")
        reduce_speed_of_logitech_mouse()
        log("Done with 'logitech'.")
    if arg in ("multilaser", "all"):
        log("Running 'multilaser'...")
        reduce_speed_of_multilaser_mouse()
        log("Done with 'multilaser'.")
    if arg in ("razer", "all"):
        log("Running 'razer'...")
        reduce_speed_of_razer_mouse()
        log("Done with 'razer'.")
    if arg in ("todoist", "all"):
        log("Running 'todoist'...")
        symlink_todoist_again()
        log("Done with 'todoist'.")


if __name__ == "__main__":
    main(sys.argv[1:])
