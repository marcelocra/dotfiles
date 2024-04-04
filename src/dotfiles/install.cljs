#!/usr/bin/env nbb
(ns dotfiles.install
  (:require
   ["node:fs" :as fs]
   ["node:path" :as path]
   ["shelljs$default" :as sh]
   [clojure.repl :refer [doc]]
   [clojure.string :as s]
   [clojure.tools.cli :refer [parse-opts]]
   [clojure.pprint :as pp :refer [pprint] :rename {pprint p}]
   [nbb.core :refer [await]]
   [promesa.core :as prom]))

(def debug true)
(def home js/process.env.HOME)
(def config-dir (path/join (.cwd js/process)))
(def zshrc (path/basename home ".zshrc"))

(def locations
    {:shell {:src (path/join config-dir ".rc")
             :dest (path/join home ".rc")}
     :gitconfig {:src (path/join config-dir ".gitconfig")
                 :dest (path/join home ".gitconfig")}
     :tmux {:src (path/join config-dir ".tmux.conf")
            :dest (path/join home ".tmux.conf")}
     :clojure {:src (path/join config-dir "deps.edn")
               :dest (path/join home ".clojure" "deps.edn")}
     :vim {:src (path/join config-dir "vim" "vimrc")
           :dest (path/join home ".config" "nvim" "init.vim")}
     :vscode [{:src (path/join config-dir "vscode" "settings.jsonc")
               :dest (path/join home ".config" "User" "Code" "settings.json")}]})

(defn link-em-all [kvs & {:keys [dry]}]
    (p "Processing key-value pairs for :src and :dest...")
    (doseq [kv kvs]
        (let [src (:src kv)
              dest (:dest kv)]
            (p (str "ln '" src "' -> '" dest "'"))
            (if (fs/existsSync dest)
                (if dry
                    (p (str "cp '" dest "' -> .bak.xxxxx"))
                    (do
                        (fs/cpSync dest (path/join (path/dirname dest) (str ".bak" (path/basename dest))))
                        (fs/rmSync dest)))
                nil)
            (if dry
                nil
                (fs/symlinkSync src dest))))
    (p "Done!"))

(defn main []
    (->> locations
         (keys)
         (map #(% locations))
         (map #(if (vector? %) (let [[elems] %] elems) %))
         #_(reduce  ;; more convoluted way of doing the same thing as above
               (fn [acc curr] 
                   (if (vector? curr) 
                       (let [[elms] curr] (conj  acc elms))
                       (conj acc curr))) 
               [])
         (link-em-all)))

   
(main)


(comment
    (->> locations
         (keys)
         (map #(% locations))
         (partition-by vector?)
         (apply link-em-all))

    (map #(let [{:keys [src dest]} (% locations)] (str src "-" dest)) (keys locations))

    (doseq [k (keys locations)
            v (k locations)]
        (println v))

    (defn t [hey & {:keys [dry]}]
        (p hey)
        (p dry))

    (t "something" :dry)

    ;; rcf - rich comment form 
    )



;; shell init 
; (and
;     (let [in-path [:options :shell]]
;         (get-in (if debug
;                     (assoc-in parsed-opts in-path true)
;                     parsed-opts)
;                 in-path))
;     (let [filename ".rc"
;           result (sh/ln "-s" (path/join config-dir filename) (path/join home filename))]
;         (or (.-stderr result) (.-stdout result))))



; ;; clojure deps
; (and 
;  (and
;   (not (fs/existsSync (path/join home ".clojure"))) 
;   (fs/mkdirSync (path/join home ".clojure")))
;  (fs/symlinkSync (path/join config-dir "deps.edn") (path/join home ".clojure/deps.edn")))

; (if (not= (path/basename (.cwd js/process)) "dotfiles")
;   (do
;     (println "Please, run this script from the root (dotfiles) directory")
;     (js/process.exit 1))
;   nil)

; (def debug true)
; (def home js/process.env.HOME)
; (def config-dir (path/join (.cwd js/process)))
; (def zshrc (path/basename home ".zshrc"))


; (def cli-options
;   [["-a" "--all" "Symlink all configuration files available"]
;    [nil "--yes" "Required if symlinking all configuration files with the --all option"]
;    [nil "--git" "Symlink .gitconfig"]
;    [nil "--tmux" "Symlink .tmux.conf"]
;    [nil "--vim" "Symlink .vimrc"]
;    [nil "--clojure" "Symlink deps.edn"]
;    [nil "--shell" "Symlink .rc (main shell init file)"]
;    [nil "--vscode" "Symlink vscode settings"]
;    [nil "--obsidian" "Download the latest Obsidian AppImage from their release GitHub repo"]
;    ["-h" "--help"]])

; (def parsed-opts (parse-opts *command-line-args* cli-options))

; (defn usage
;   []
;   (->> ["Usage: ./play.clj [options]"
;         ""
;         "Options:"
;         (:summary parsed-opts)]
;        (s/join \newline)))

; (defn exit [msg]
;   (println msg)
;   (or debug (js/process.exit 1)))

; (def append-to-rc
;   (->> ["# -----------------------------------------------------------------------------",
;         "# My shell settings.",
;         "# ------------------",
;         "# To add local stuff, DO NOT add here, but in the local shell file (use the",
;         "# alias rcl to open it to edit directly.",
;         "# -----------------------------------------------------------------------------",
;         (str "export MCRA_INIT_SHELL=" (path/join home ".rc")),
;         (str "export MCRA_LOCAL_SHELL=" (path/join home ".rc.local")),
;         "",
;         "# Local should be first, as the other one checks for some expected MCRA_* env",
;         "# variables.",
;         "source $MCRA_LOCAL_SHELL",
;         "source $MCRA_INIT_SHELL",
;         "# -----------------------------------------------------------------------------",
;         ""]
;        (s/join \newline)))


; ;; Only append the init shell part if it is not already there.
; (if (nil? js/process.env.MCRA_INIT_SHELL)
;   (fs/appendFileSync zshrc append-to-rc)
;   nil)

;   ;; ["-a" "--all" "Symlink all configuration files available"]
;   ;; [nil "--yes" "Required if symlinking all configuration files with the --all option"]
;   ;; [nil "--git" "Symlink .gitconfig"]
;   ;; [nil "--tmux" "Symlink .tmux.conf"]
;   ;; [nil "--vim" "Symlink .vimrc"]
;   ;; [nil "--clojure" "Symlink deps.edn"]
;   ;; [nil "--shell" "Symlink .rc (main shell init file)"]
;   ;; [nil "--vscode" "Symlink vscode settings"]
;   ;; [nil "--obsidian" "Download the latest Obsidian AppImage from their release GitHub repo"]
;   ;; ["-h" "--help"]])

; (def locations
;     {:shell {:src (path/join config-dir ".rc")
;              :dest (path/join home ".rc")}
;      :gitconfig {:src (path/join config-dir ".gitconfig")
;                  :dest (path/join hoje ".gitconfig")}
;      :tmux {:src (path/join config-dir ".tmux.conf")
;             :dest (path/join home ".tmux.conf")}
;      :clojure {:src (path/join config-dir "deps.edn")
;                :dest (path/join home ".clojure" "deps.edn")}
;      :vim {:src (path/join config-dir "vim" "vimrc")
;            :dest (path/join hoje ".config" "nvim" "init.vim")}
;      :vscode [{:src (path/join config-dir "vscode" "settings.jsonc")
;                :dest (path/join home ".config" "User" "Code" "settings.json")}]})

; ;; shell init 
; (and
;  (let [in-path [:options :shell]]
;    (get-in (if debug
;              (assoc-in parsed-opts in-path true)
;              parsed-opts)
;            in-path))
;  (let [filename ".rc"
;        result (sh/ln "-s" (path/join config-dir filename) (path/join home filename))]
;    (or (.-stderr result) (.-stdout result))))



; ;; clojure deps
; (and 
;  (and
;   (not (fs/existsSync (path/join home ".clojure"))) 
;   (fs/mkdirSync (path/join home ".clojure")))
;  (fs/symlinkSync (path/join config-dir "deps.edn") (path/join home ".clojure/deps.edn")))
 

; ;; vim

; ;; vscode

; ;; obsidian

; (comment

;   (def home js/process.env.HOME)
;   (path/join home ".rc")

;   (js->clj (await (fs/readdir ".")))

;   (let [something (fs/readdir (path/join "."))]
;     (p/then something #(p/then % js/console.log)))

;   (await (fs/readdir '.'))

;   (js/console.log "hey")

;   #_())

; ;; vim: fdm=marker:fmr={{{,}}}:fdl=1:fen:ai:et:ts=4:sw=4:filetype=clojure
