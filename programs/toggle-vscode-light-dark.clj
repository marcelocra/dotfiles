#!/usr/bin/env bb

(require 
  '[clojure.string :as str]
  '[clojure.java.io :as io]
  '[babashka.fs :as fs]
  '[clojure.pprint :as pp]
  '[clojure.reflect :as reflect]
  )

(def settings-path (-> (System/getenv "HOME")
                       (io/file ".config" "Code" "User" "settings.json")
                       (fs/canonicalize)
                       (.toString)))

(def from-theme-to-theme
  {:github-dark-dimmed-to-solarized-light
   {:dark "\"GitHub Dark Dimmed\""
    :light "\"Solarized Light\""}})

(defn get-theme [theme]
  (let [current (-> from-theme-to-theme
                    theme)]
    [(:light current) (:dark current)]))

(let [settings-content (slurp settings-path)
      [light-theme dark-theme] (get-theme :github-dark-dimmed-to-solarized-light)
      light-theme-str-in-settings? (not (nil? (re-find (re-pattern (str "colorTheme.*" light-theme)) settings-content)))]
  (if light-theme-str-in-settings?
    ;; go to dark
    (do
      (println (format "Go to dark: from '%s' to '%s'"
                           light-theme
                           dark-theme))
      (spit settings-path
            (str/replace
              settings-content
              (re-pattern light-theme)
              dark-theme))) 
    ;; go to light
    (do
      (println (format "Go to light: from '%s' to '%s'"
                           dark-theme
                           light-theme))
      (spit settings-path
            (str/replace
              settings-content
              (re-pattern dark-theme)
              light-theme)))))

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

