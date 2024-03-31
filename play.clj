#!/usr/bin/env bb
(ns play
  (:require
    [babashka.http-client :as http]
    [clojure.pprint :as pp :refer [pprint] :rename {pprint p}]
    [clojure.string :as s]
    [clojure.tools.cli :refer [parse-opts]]
    [clojure.java.io :as io]))

(def debug false)
(and debug
     (do (println "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
         (println "!!!!!!!!!!!!!!!!!! RUNNING IN DEBUG MODE !!!!!!!!!!!!!!!!!!!!!!")
         (println "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
         (println)))

(def cli-options
  [[nil "--obsidian" "Download the latest Obsidian AppImage from their release GitHub repo"]
   ["-h" "--help"]])

(def parsed-opts (parse-opts *command-line-args* cli-options))

(defn usage
  []
  (->> ["Usage: ./play.clj [options]"
        ""
        "Options:"
        (:summary parsed-opts)]
       (s/join \newline)))

(defn get-latest-obsidian-amd64-appimage-url
  []
  (let [base-url "https://github.com"
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
        obsidian-release-page 
        (http/get "https://github.com/obsidianmd/obsidian-releases/releases")]
    (->> obsidian-release-page
         (:body)
         (re-find #"href=\"(.+Obsidian-\d+\.\d+\.\d+\.AppImage)\"")
         (second)
         (str base-url))))

(defn get-latest-obsidian-amd64-appimage
  []
  (let [base-url "https://github.com"
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
        obsidian-release-page 
        (http/get "https://github.com/obsidianmd/obsidian-releases/releases")

        obsidian-appimage-url (->> obsidian-release-page
                                   (:body)
                                   (re-find #"href=\"(.+Obsidian-\d+\.\d+\.\d+\.AppImage)\"")
                                   (second)
                                   (str base-url))
        obsidian-appimage-version (->> obsidian-appimage-url
                                       (re-find #".*download/([^/]*)/Obsidian")
                                       (second))]
    (io/copy
      (:body (http/get obsidian-appimage-url {:as :stream}))
      (io/file (str "Obsidian-" obsidian-appimage-version ".AppImage")))))

(defn exit [msg]
  (println msg)
  (or debug (System/exit 1)))

(defn main []
  (cond
    (not (nil? (:errors parsed-opts)))
    (exit (str 
            (s/join \newline (:errors parsed-opts))
            "\n"
            (usage)))

    (or
      (not (nil? (get-in parsed-opts [:options :help])))
      (empty? (:options parsed-opts)))
    (exit (usage))

    ;; No problems, keep going!
    :else
    (cond
      (get-in parsed-opts [:options :obsidian])
      (println (get-latest-obsidian-amd64-appimage-url))
      
      :else
      (exit "Command not available"))))

(main)

(comment
  ;; trying to download binary file as stream, to show download progress
  (def iostream (:body (http/get "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.11/Obsidian-1.5.11.AppImage" {:as :stream})))

  (-> iostream
      (io/file "output"))

  (type iostream)
  (.close iostream)
  (.read iostream)

  (with-open [o (io/output-stream "test.txt")]
    (loop [part (.read iostream)
           safe 0]
      (if (and (> part -1) (< safe 100))
        (do
          (println "byte: " safe)
          (.write o part)
          (recur (.read iostream) (inc safe)))
        safe)))


  (let [play (io/input-stream ".npmrc")]
   (with-open [o (io/output-stream "test.txt")]
    (loop [part (.read play)
           safe 0]
      (if (and (> part -1) (< safe 1000))
        (do
          (println "count: " part)
          (.write o part)
          (recur (.read play) (inc safe)))
        safe))))
  (vec (.getMethods (.getClass play)))
  (.size play)
  )
