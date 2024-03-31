#!/usr/bin/env nbb
(ns dotfiles.install
  (:require
    ["node:fs/promises" :as fs]
    ["node:path" :as path]
    [clojure.pprint :as pp :refer [pprint] :rename {pprint p}]
    [nbb.core :refer [await]]
    [promesa.core :as p]))

(defn usage [])

(comment

    js/process.env.HOME

    (await (fs/readdir "."))

    (let [something (fs/readdir (path/join "."))]
        (p/then something #(p/then % js/console.log))) 



    (await (fs/readdir '.'))

    (js/console.log "hey")
    
    )

(def content-to-append-to-rc-files 
  (str "

# -----------------------------------------------------------------------------
# My shell settings.
# ------------------
# To add local stuff, DO NOT add here, but in the local shell file (use the
# alias rcl to open it to edit directly.
# -----------------------------------------------------------------------------
export MCRA_INIT_SHELL=$MCRA_INIT_SHELL
export MCRA_LOCAL_SHELL=$MCRA_LOCAL_SHELL

# Local should be first, as the other one checks for some expected MCRA_* env
# variables.
source $MCRA_LOCAL_SHELL
source $MCRA_INIT_SHELL
# -----------------------------------------------------------------------------


"))



;; vim: fdm=marker:fmr={{{,}}}:fdl=1:fen:ai:et:ts=4:sw=4:filetype=clojure

