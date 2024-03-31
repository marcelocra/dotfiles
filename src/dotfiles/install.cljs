#!/usr/bin/env nbb
(ns dotfiles.install
  (:require
   ["node:fs" :as fs]
   ["node:path" :as path]
   ["shelljs$default" :as sh]
   [clojure.pprint :as pp :refer [pprint] :rename {pprint p}]
   [clojure.string :as s]
   [clojure.tools.cli :refer [parse-opts]]
   [nbb.core :refer [await]]
   [promesa.core :as p]))

(if (not= (path/basename (.cwd js/process)) "dotfiles")
  (do
    (println "Please, run this script from the root (dotfiles) directory")
    (js/process.exit 1))
  nil)

(def debug true)
(def home js/process.env.HOME)
(def pwd (.cwd js/process))
(def zshrc (path/join home ".zshrc"))


(def cli-options
  [["-a" "--all" "Symlink all configuration files available"]
   [nil "--yes" "Required if symlinking all configuration files with the --all option"]
   [nil "--git" "Symlink .gitconfig"]
   [nil "--tmux" "Symlink .tmux.conf"]
   [nil "--vim" "Symlink .vimrc"]
   [nil "--clojure" "Symlink deps.edn"]
   [nil "--shell" "Symlink .rc (main shell init file)"]
   [nil "--vscode" "Symlink vscode settings"]
   [nil "--obsidian" "Download the latest Obsidian AppImage from their release GitHub repo"]
   ["-h" "--help"]])

(def parsed-opts (parse-opts *command-line-args* cli-options))

(defn usage
  []
  (->> ["Usage: ./play.clj [options]"
        ""
        "Options:"
        (:summary parsed-opts)]
       (s/join \newline)))

(defn exit [msg]
  (println msg)
  (or debug (js/process.exit 1)))

(def append-to-rc
  (->> ["# -----------------------------------------------------------------------------",
        "# My shell settings.",
        "# ------------------",
        "# To add local stuff, DO NOT add here, but in the local shell file (use the",
        "# alias rcl to open it to edit directly.",
        "# -----------------------------------------------------------------------------",
        (str "export MCRA_INIT_SHELL=" (path/join home ".rc")),
        (str "export MCRA_LOCAL_SHELL=" (path/join home ".rc.local")),
        "",
        "# Local should be first, as the other one checks for some expected MCRA_* env",
        "# variables.",
        "source $MCRA_LOCAL_SHELL",
        "source $MCRA_INIT_SHELL",
        "# -----------------------------------------------------------------------------",
        ""]
       (s/join \newline)))

(if (nil? js/process.env.MCRA_INIT_SHELL)
  (fs/appendFileSync zshrc append-to-rc)
  nil)

;; shell init 

;; .gitconfig
(and
 (let [in-path [:options :git]]
   (get-in (if debug
             (assoc-in parsed-opts in-path true)
             parsed-opts)
           in-path))
 (let [filename ".gitconfig"
       result (sh/ln "-s" (path/join pwd filename) (path/join home filename))]
   (or (.-stderr result) (.-stdout result))))

;; .tmux.conf
(and
 (let [in-path [:options :tmux]]
   (get-in (if debug
             (assoc-in parsed-opts in-path true)
             parsed-opts)
           in-path))
 (let [filename ".tmux.conf"
       result (sh/ln "-s" (path/join pwd filename) (path/join home filename))]
   (or (.-stderr result) (.-stdout result))))

;; clojure deps

;; vim

;; vscode

;; obsidian

(comment

  (def home js/process.env.HOME)
  (path/join home ".rc")

  (js->clj (await (fs/readdir ".")))

  (let [something (fs/readdir (path/join "."))]
    (p/then something #(p/then % js/console.log)))

  (await (fs/readdir '.'))

  (js/console.log "hey")

  #_())

;; vim: fdm=marker:fmr={{{,}}}:fdl=1:fen:ai:et:ts=4:sw=4:filetype=clojure
