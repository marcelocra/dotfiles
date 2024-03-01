#!/usr/bin/env bb

(require
  '[clojure.java.shell :refer [sh]]
  '[clojure.string :as str]
  '[babashka.fs :as fs]
  '[babashka.cli :as cli])

(defn free-ram
  "Prints the amount of free ram memory."
  []
  (println 
    (->>
      (:out (sh "cat" "/proc/meminfo"))
      (re-find #"MemFree.*")
      (re-find #"[0-9]+.*"))))


;; CLI helpers -----------------------------------------------------------------

(defn help []
  (println
    (str "Choose one of the commands below: \n\n"
         (str/join "\n"
                   (map #(format "%s\t%s" (:name %) (:doc %))
                        [(meta #'free-ram)])))))

(def cli-options
  {:cmd {:default "help"}})


;; Do not change code below here -----------------------------------------------

(def parsed-cli-args
  (cli/parse-opts *command-line-args* {:spec cli-options}))

;; Run the selected command.
((resolve (symbol (:cmd parsed-cli-args))))

