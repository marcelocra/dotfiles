#!/usr/bin/env bash
#
# https://stackoverflow.com/a/58411207/1814970

action="$1"

case "$action" in
   suspend)
        # List programs to run before, the system suspends
        # to ram; some folks call this "sleep"
   ;;
   resume)
        # List of programs to when the systems "resumes"
        # after being suspended
   ;;
   hibernate)
        # List of programs to run before the system hibernates
        # to disk; includes power-off, looks like shutdown
   ;;
   thaw)
        # List of programs to run when the system wakes
        # up from hibernation
   ;;
esac
