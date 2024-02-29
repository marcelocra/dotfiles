#!/usr/bin/env bb

(require 
  '[clojure.string :as str]
  '[clojure.java.io :as io]
  '[babashka.fs :as fs]
  '[clojure.pprint :as pp]
  '[clojure.reflect :as reflect])

(def settings-content (slurp settings-path))

;; This works on Linux, but might not work on other systems.
(def settings-path (-> (System/getenv "HOME")
                       (io/file ".config" "Code" "User" "settings.json")
                       (fs/canonicalize)  ;; Necessary to follow symlinks (`slurp` doesn't).
                       (.toString)))

;; TODO: add more options and allow choosing from cmd line.
(def theme-mapper
  {:github-dark-dimmed-to-solarized-light
   {:dark "\"GitHub Dark Dimmed\""
    :light "\"Solarized Light\""}})

(defn get-theme [theme]
  (let [current (-> theme-mapper
                    theme)]
    [(:light current) (:dark current)]))

(defn from-theme-to-theme [from to]
  (do
    (println 
      (format "from '%s' to '%s'" from to))
    (spit settings-path
          (str/replace
            settings-content 
            (re-pattern from)
            to))))


(defn toggle
  "If light mode is enabled, toggle dark mode (and vice-versa)."
  []
  (let [[light-theme dark-theme] (get-theme :github-dark-dimmed-to-solarized-light)
        light-theme-str-in-settings? (not (nil? (re-find (re-pattern (str "colorTheme.*" light-theme)) settings-content)))]
    (if light-theme-str-in-settings?
      (from-theme-to-theme light-theme dark-theme)
      (from-theme-to-theme dark-theme light-theme))))

(toggle)


;; playground below! :)

(comment
  (re-find #"colorTheme.*Dark" settings-content)

  (->>
    (reflect/reflect java.io.InputStream)
    :members
    (sort-by :name)
    (pp/print-table))

  (pp/pprint (set (map #(.getName %) (vec (.getMethods (.getClass settings-path))))))
  (-> settings-path
      (.getClass)
      (.getFields))

  (type settings-path)
  (ancestors (type settings-path))

  (pprint (map #(.getName %) (-> settings-path class .getMethods)))
  
  ;; rcf
  )

