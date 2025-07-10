(ns installer
  (:require
    [clojure.java.shell :as shell]
    [clojure.string :as s]))

(def home (System/getenv "HOME"))

(defn run [& cmd]
  (apply shell/sh (s/split (s/join " " cmd) #" ")))

(defn vimrc [& args]
  (print
    (:out
      (run "echo" *file* ))))

(defn main [& args]
  (do
    (vimrc)))

(defn stuff [& args]
  (do
    (println 'hey)
    (println *file*)))

