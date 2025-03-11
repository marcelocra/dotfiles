#!/usr/bin/env bash

#
# From `man pm-action`:
#
#   /etc/pm/sleep.d, /usr/lib/pm-utils/sleep.d: Programs in these directories
#   (called hooks) are combined and executed in C sort order before suspend and
#   hibernate with as argument suspend or hibernate. Afterwards, they are called
#   in reverse order with argument resume and thaw respectively. If both
#   directories contain a similar named file, the one in /etc/pm/sleep.d will
#   get preference. It is possible to disable a hook in the distribution
#   directory by putting a non-executable file in /etc/pm/sleep.d, or by adding
#   it to the HOOK_BLACKLIST configuration variable
#
# Reference: https://stackoverflow.com/a/58411207/1814970
#

set -e

action="$1"
this_file_name=$(basename $0)
log_file="$HOME/.${USER}.${this_file_name}.log"

debug_logfile=/tmp/pm-action.log

echo "Action: $action
File: $this_file_name
Logfile: $log_file" >> $debug_logfile

log() {
    echo "[`date`] $@" | tee -a $log_file
}

log "---------------------------------------------------------------------"

if [[ "$action" == "install-this-script" ]]; then
    install_path="/etc/pm/sleep.d/99_linux_after_sleep"

    if [[ -f $install_path ]]; then
        log "The file '$install_path' already exists. Exiting..."
        exit 1
    fi

    this_script_path=$(realpath $0)

    log ""
    log "Will symlink this script:"
    log ""
    log "  $this_script_path"
    log ""
    log "to:"
    log ""
    log "  $install_path"
    log ""
    log "To uninstall it, just remove the file. Continue? [y/n]"
    echo -n "> "

    read -r answer
    log "Your answer: $answer"
    if [[ "$answer" != "y" ]]; then
        log "Exiting..."
        exit 1
    fi

    all_installed_scripts_log="$HOME/.$USER.all-installed-scripts.log"

    sudo ln -s $this_script_path /etc/pm/sleep.d/99_linux_after_sleep \
        && (log "Done!" && log "Installed '$this_script_path' to '$install_path'" >> $all_installed_scripts_log) \
        || (log "Failed to copy the file. Exiting..." && exit 1)

    exit 0
fi

echo 'after if' >> $debug_logfile

# We only want to blow up when not running in the context of pm-action.
set +e

echo "---------------------------------------------------------------------" >> $log_file
log $action
echo "---------------------------------------------------------------------" >> $log_file

echo 'before case' >> $debug_logfile

case "$action" in
   suspend)
        # List programs to run before, the system suspends
        # to ram; some folks call this "sleep"
        echo 'inside suspend' >> $debug_logfile
   ;;
   resume)
        # List of programs to when the systems "resumes"
        # after being suspended
        echo 'inside resume' >> $debug_logfile

        log "Resuming the system..."
        $HOME/projects/dotfiles/linux-startup-config.sh >> $log_file 2>&1 \
            && log "Done!" \
            || log "Failed to run the startup script. Exiting..."
   ;;
   hibernate)
        # List of programs to run before the system hibernates
        # to disk; includes power-off, looks like shutdown
        echo 'inside hibernate' >> $debug_logfile
   ;;
   thaw)
        # List of programs to run when the system wakes
        # up from hibernation
        echo 'inside thaw' >> $debug_logfile
   ;;
esac

echo 'the end!' >> $debug_logfile

