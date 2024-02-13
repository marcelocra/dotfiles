#!/usr/bin/env bb

(require '[clojure.java.shell :refer [sh]])

(def debug? true)

(if debug?
  (println "RUNNING IN DEBUG MODE!")
  nil)

(def scratch-session-name "scratch")

(defn shell [cmd]
  (apply sh (str/split cmd #" ")))

(defn tmux [cmd]
  (format
    cmd
    scratch-session-name))

(def terminal-font
  (:out (shell "gsettings get org.gnome.desktop.interface monospace-font-name")))

(def terminal-font-size
  (Integer/parseInt (str/replace terminal-font #"[^0-9]*" "")))

;; TODO: do this per font face. Current values are for meslo font
(def terminal-geometry
  (get-in
    {9 "131x65"
     10 "115x60"
     11 "103x55"
     13 "91x45"}
    [terminal-font-size]
    "131x65"))

(defn terminal-cmd [cmd]
  (format
    "gnome-terminal --geometry %s--26+4 -- sh -c \"%s\""
    terminal-geometry
    cmd))


(def tmux-session-exists?
  (= 0 (:exit
         (shell
           (tmux "tmux has -t %s")))))

(def tmux-connected?
  (if tmux-session-exists?
    (str/includes? (shell "tmux lsc")
                   scratch-session-name)
    false))

(def shell-cmd
  (if debug?
    println
    shell))

(cond
  (and tmux-session-exists? tmux-connected?)
  (shell-cmd (tmux "tmux detach -s %s"))

  (and tmux-session-exists? (not tmux-connected?))
  (shell-cmd (terminal-cmd (tmux "tmux attach -t %s")))

  (and (not tmux-session-exists?) (not tmux-connected?))
  (shell-cmd (terminal-cmd (tmux "tmux new -s %s")))

  :else (println "something went wrong"))

