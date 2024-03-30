#!/usr/bin/env bb

(ns play
  (:require
    [babashka.http-client :as http]
    [clojure.pprint :as pp :refer [pprint] :rename {pprint p}]
    [clojure.string :as s]))

(defonce base-url "https://github.com")
(defonce obsidian-release-page
  (http/get "https://github.com/obsidianmd/obsidian-releases/releases"))

;; This is what we are looking for as a result of the get request above:
;;
;; <a href="/obsidianmd/obsidian-releases/releases/download/v1.5.11/Obsidian-1.5.11.AppImage"
;;    rel="nofollow"
;;    data-turbo="false"
;;    data-view-component="true"
;;    class="Truncate">
;;      <span data-view-component="true"
;;            class="Truncate-text text-bold">
;;        Obsidian-1.5.11.AppImage
;;      </span>
;;      <span data-view-component="true" class="Truncate-text">
;;      </span>
;; </a>

(def obsidian-release-appimage 
  (second (re-find #"href=\"(.+Obsidian-\d+\.\d+\.\d+\.AppImage)\""
                   obsidian-release-page)))

(str base-url obsidian-release-appimage)

