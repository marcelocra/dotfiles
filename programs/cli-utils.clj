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


;; CLI helper ------------------------------------------------------------------

(def cli-options
  {:example-cli-flag {:default "the default value"}})

;; Do not change code below here -----------------------------------------------

(defn help []
  (println
    (str "Choose one of the commands below: \n\n"
         (str/join "\n"
                   (map #(format "%s\t%s" (:name %) (:doc %))
                        [(meta #'free-ram)])))))

(def parsed-cli-args
  (cli/parse-opts *command-line-args* {:spec cli-options}))

(def cmd-str (first *command-line-args*))

;; Run the selected command.
(if (nil? cmd-str)
  (help)
  (let [fn-to-run (resolve (symbol cmd-str))]
    (if (nil? fn-to-run)
      (help)
      (fn-to-run))))

