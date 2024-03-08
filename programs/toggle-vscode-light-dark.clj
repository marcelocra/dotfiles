#!/usr/bin/env bb

(require 
  '[clojure.string :as s]
  '[clojure.java.io :as io]
  '[babashka.fs :as fs]
  '[clojure.pprint :as pp :refer [pprint]]
  '[clojure.reflect :as reflect]
  '[clojure.edn :as edn])

;; This works on Linux, but might not work on other systems.
(def settings-path (-> (System/getenv "HOME")
                       (io/file ".config" "Code" "User" "settings.json")
                       (fs/canonicalize)  ;; Necessary to follow symlinks (`slurp` doesn't).
                       (.toString)))

(def settings-content (slurp settings-path))

;; Check some settings lines.
(comment
  (map
    #(pprint (edn/read-string (get % 1)))
    (re-seq #".*(\{:dark.*)" settings-content))

  ;; rcf - rich comment form
  )

;; TODO: add more options and allow choosing from cmd line.
(def theme-mapper
  {:github-dark-dimmed-to-solarized-light
   {:dark "\"GitHub Dark Dimmed\""
    :light "\"Solarized Light\""}})

(defn get-theme [theme]
  (let [current (-> theme-mapper
                    theme)]
    [(:light current) (:dark current)]))

(defn update-colors [settings-content]
  (let [matches (re-seq #"(.*)//(\{:dark.*)" settings-content)] 
    (loop [not-processed matches
           current-content settings-content
           abort-counter 1]
      (if (or 
            (> abort-counter 1000) 
            (<= (count not-processed) 0))
        current-content
        (let [currently-processing (first not-processed)
              opts (edn/read-string (get currently-processing 2))
              line-content-to-replace (get currently-processing 1)
              is-light? (not (nil? (re-find (re-pattern (:light opts)) line-content-to-replace)))
              replace-with (s/replace line-content-to-replace 
                                      (re-pattern (if is-light? (:light opts) (:dark opts))) 
                                      (if is-light? (:dark opts) (:light opts)))
              replaced-content (s/replace current-content
                                          line-content-to-replace
                                          replace-with)] 
          (recur (next not-processed) 
                 replaced-content
                 (inc abort-counter)))))))

(defn from-theme-to-theme [from to]
  (do
    (println 
      (format "from '%s' to '%s'" from to))
    (spit settings-path
          (s/replace
            (update-colors settings-content) 
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


;; ---------------------------------------------------------------------------------------------------------------------
;; ----------- PLAYGROUND ARCHIVES :) ----------------------------------------------------------------------------------
;; ---------------------------------------------------------------------------------------------------------------------

;; changing the color scheme from light/dark/light
(comment
  (re-find #"colorTheme.*Dark" settings-content)

  (->>
    (reflect/reflect java.io.InputStream)
    :members
    (sort-by :name)
    (pp/print-table))

  (pprint (set (map #(.getName %) (vec (.getMethods (.getClass settings-path))))))
  (-> settings-path
      (.getClass)
      (.getFields))

  (type settings-path)
  (ancestors (type settings-path))

  (pprint (map #(.getName %) (-> settings-path class .getMethods)))
  
  ;; rcf
  )

;; changing settings colors based on an edn comment
(comment
  ;; read file if necessary
  #_(def settings-content (slurp settings-path))

  ;; to allow playing without actually nuking the file content
  (defonce backup-settings-content settings-content)
  (defn reset-settings []
    (s/split settings-path backup-settings-content))

  ;; if this line matches, potentially that there are colors to be changed
  (def matches (re-seq #"(.*)//(\{:dark.*)" settings-content))
  (map #(pprint (edn/read-string (get % 2))) 
       (re-seq #"(.*)//(\{:dark.*)" settings-content))
  (count matches)
  (first matches)
  (rest matches)
  (type matches)
  (count (next matches))
  (type (next matches))
  (type (rest matches))

  (defn p [stuff]
    (pprint stuff))

  #_(spit settings-path backup-settings-content)
  #_(spit settings-path (get @new-contents (- (count @new-contents) 1)))
  (spit settings-path (new-file-content (slurp settings-path)))


  ;; checking file contents

  (def atom-content {:id 1})
  (defonce new-contents (atom atom-content))
  (reset! new-contents atom-content)
  (do 
    (swap! new-contents update :id inc)
    (swap! new-contents assoc (:id @new-contents) (new-file-content)))
  @new-contents
  (count @new-contents)

  ;; rcf - rich comment form
  )

