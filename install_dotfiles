#!/usr/bin/env bb
(ns install-dotfiles
  (:require
    [babashka.fs :as fs]))

(def content-to-append-to-rc-files 
  (format  "

# -----------------------------------------------------------------------------
# My shell settings.
# ------------------
# To add local stuff, DO NOT add here, but in the local shell file (use the
# alias rcl to open it to edit directly.
# -----------------------------------------------------------------------------
export MCRA_INIT_SHELL=$MCRA_INIT_SHELL
export MCRA_LOCAL_SHELL=$MCRA_LOCAL_SHELL
export MCRA_TMP_PLAYGROUND="/tmp/mcra-tmp-playground"

# Local should be first, as the other one checks for some expected MCRA_* env
# variables.
source \$MCRA_LOCAL_SHELL
source \$MCRA_INIT_SHELL
# -----------------------------------------------------------------------------


"))



;; vim: fdm=marker:fmr={{{,}}}:fdl=1:fen:ai:et:ts=4:sw=4:filetype=clojure

