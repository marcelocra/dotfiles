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
;; Check command line options and behave accordingly. Options:
;; 
;; gnome-terminal
;; ==============
;; 
;; Run gnome-terminal with the appropriate geometry.
;; 
;; 
;; scratch
;; =======
;; 
;; Check if a tmux scratch session exists. If so, attaches.
;; If not, create and attach.
;;


(ns scratch
  (:require [clojure.java.shell :refer [sh]]
            [clojure.string :as str]
            [babashka.cli :as cli]))

(defn usage []
  (println "Options: help, cmd (scratch, gnome-terminal)"))

(defn shell [cmd]
  (apply sh (str/split cmd #" ")))

(def cli-options 
  {:help {:coerce :boolean}
   :cmd {:default :scratch :coerce :keyword}})

(def parsed-cli-options 
  (cli/parse-opts *command-line-args* 
                  {:spec cli-options}))

(def cmd (:cmd parsed-cli-options))

(defn scratch []
  (let [scratch-session-name "scratch"
        tmux-session-exists? (= (:exit (shell (format "tmux has -t %s"
                                                      scratch-session-name)))
                                0)] 
    (if tmux-session-exists?
      (let [is-connected? (str/includes? (shell "tmux lsc")
                                         scratch-session-name)]
        (if is-connected?
          (shell (format "tmux detach -s %s" scratch-session-name))

          ;; TODO: need to change to run the terminal command instead of the actual
          ;; tmux command. But this is still not working. See error below.
          (sh "gnome-terminal" "--" "sh" "-c" (format "\"tmux attach -t %s\"" scratch-session-name))))
      (shell (format "tmux new -s %s" scratch-session-name)))))

(comment
  
  (str/includes? "blabla" "abl") ; true
  (str/includes? "blabla" "aa") ; false

  ;; when connected, the output is the following
  (scratch) ; {:exit 0, :out "", :err ""}

  ;; when not connected:
  (scratch) ; {:exit 1, :out "", :err "open terminal failed: not a terminal\n"}

  ;; when using gnome-terminal:
  (scratch) ; {:exit 0, :out "", :err "# Failed to use specified server: GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name :1.1047 was not provided by any .service files\n# Falling back to default server.\n"}

  ;; rcf
  )

(defn gnome-terminal []
  (println "gnome-terminal"))

(cond
  (= cmd :scratch) (scratch)
  (= cmd :gnome-terminal) (gnome-terminal)
  :else (usage))

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


(comment
  (require '[clojure.java.shell :as shell])

  (shell/sh "tmux" "has" "-t" scratch-session-name)

  (clojure.string.join  " " ["tmux" "has" "-t" scratch-session-name])
  (clojure.string.split (format "tmux has -t %s" scratch-session-name) #" ")


  (def scratch-session-name "scratch")
  (def tmux-check-session-exists-cmd (join ))



  (if (= (:exit ())))

  (let [scratch-session-exists? (shell/sh
                                  (format "tmux has -t %s > /dev/null 2>&1"
                                          scratch-session-name))])

  ;; rcf
  )

