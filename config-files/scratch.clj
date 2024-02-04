#!/usr/bin/env bb
;; 
;; This script was meant to be associated to a shortcut key,
;; like F10 or INSERT, for example (from now on, <shortcut>).
;;
;; Then, whenever you press <shortcut> one of three things
;; will happen:
;;
;;   1. The first time you hit <shortcut>, it will open a new
;;      terminal window with tmux attached.
;;
;;   2. If you press <shortcut> again, that tmux session will
;;      be detached and the terminal window will be closed.
;;
;;   3. If you press <shortcut> again, a new terminal window
;;      will be opened, but attached to the same tmux session
;;      created in 1. Unless you kill this tmux session,
;;      whenever you press <shortcut>, it will be used.
;;
;; Gotcha: if you do not press <shortcut> to close the
;; scratch terminal window (e.g. you alt+tab away from it)
;; and then press <shortcut>, it will close the existing (and
;; unfocused) window, which might be confusing. Just press
;; <shortcut> again :).
;;
;; When creating a shortcut for gnome-terminal, use the
;; following command, replacing <path-to-this> with the
;; actual path to this file in your system:
;;
;;   # For MesloLGS NF Regular, size 13:
;;   gnome-terminal --geometry 91x45--26+4 -- sh -c "<path-to-this>"
;;
;;   # For MesloLGS NF Regular, size 10:
;;   gnome-terminal --geometry 115x60--26+4 -- sh -c "<path-to-this>"
;;
;;   # For MesloLGS NF Regular, size 9:
;;   gnome-terminal --geometry 115x60--26+4 -- sh -c "<path-to-this>"
;;

;;
;; if [[ "$1" == "launch-terminal" ]]; then
;;     gnome-terminal --geometry 91x45--26+4 -- sh -c ""
(require '[clojure.java.shell :as shell])

(def scratchpad-session-name "scratch")

(let [scratch-session-exists? (shell
                               (format "tmux has -t %s > /dev/null 2>&1"
                                       scratchpad-session-name))])

; SCRATCHPAD_SESSION_NAME="scratch"

; # If session exists, connect to it. Otherwise, create it.
; if tmux has -t $SCRATCHPAD_SESSION_NAME > /dev/null 2>&1; then
;     if tmux lsc | grep $SCRATCHPAD_SESSION_NAME > /dev/null 2>&1; then
;         tmux detach -s $SCRATCHPAD_SESSION_NAME
;     else
;         tmux attach -t $SCRATCHPAD_SESSION_NAME > /dev/null 2>&1
;     fi
; else
;     tmux new -s $SCRATCHPAD_SESSION_NAME > /dev/null 2>&1
; fi
