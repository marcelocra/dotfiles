#!/usr/bin/env bb

(ns projects-manager
  (:require
    [babashka.fs :as fs]
    [clojure.string :as s]
    [clojure.pprint :refer [pprint] :rename {pprint p}]
    [clojure.java.shell :refer [sh]]
    [clojure.java.io :as io]))

(defonce projects-dir (System/getenv "MCRA_PROJECTS_FOLDER"))

;; algo:
;; 
;; 1 - run `git status` in each repo
;; 2 - see if the following string is in the output of `git status`:
;; 
;; :out "On branch main\nYour branch is up to date with 'origin/main'.\n\nnothing to commit, working tree clean\n"
;; 
;; 3 - mark this folder as backed up
;; 4 - any folder without that string is added to a review list
;; 5 - the review list is printed out

(defonce files (fs/list-dir projects-dir))

(def init-db {:backed-up #{}
              :to-review #{} 
              :total-files (count files) 
              :total-files-touched 0
              })
(comment
  (reset! db init-db)
  (swap! db assoc :visited 0)
  
  ;; rcf - rich comment form 
  )

(def db (atom init-db))

(do
  (swap! db assoc :total-files-touched 0)
  (doseq [file files]
    (let [visited? (or 
                     (contains? (:backed-up @db) file) 
                     (contains? (:to-review @db) file))] 
      (if visited?
        nil  ;; File already processed, nothing to do.
        (if (not (fs/directory? file))
          (swap! db update :total-files-touched inc)  ;; Bail, we only care for directories.
          (let [out (:out (sh "git" "status" :dir (.toString file)))
                backed-up (= out (str "On branch main\n"
                                      "Your branch is up to date with 'origin/main'.\n\n"
                                      "nothing to commit, working tree clean\n"))]
            (swap! db update (if backed-up :backed-up :to-review) conj file))))))
  (swap! db update :total-files-touched 
         (fn [initial-value] 
           (reduce + initial-value 
                   (map 
                     #(count (% @db)) 
                     [:backed-up :to-review]))))
  (p @db))



;; learning the api

(comment
  (def dir (fs/list-dir "."))

  (first dir)
  (last dir)

  (fs/list-dir dir)
  (sh "git" "status" "--porcelain" :dir (.toString dir))
  (sh "git" "status" :dir (.toString dir))
  (sh "git" "add" "." :dir (.toString dir))
  (sh "git" "d" :dir (.toString dir))
  (sh "git" "restore" "--staged" "." :dir (.toString dir))
  (sh "git" "commit" "-m" "'remove comment (using clojure)'" "--dry-run" :dir (.toString dir))

  ;; rcf - rich comment form 
  )
