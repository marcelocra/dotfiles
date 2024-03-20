#!/usr/bin/env bb

(ns projects-manager
  (:require
    [babashka.fs :as fs]
    [clojure.string :as s]
    [clojure.pprint :refer [pprint] :rename {pprint p}]
    [clojure.java.shell :refer [sh]]
    [clojure.java.io :as io]))

(defonce projects-dir (System/getenv "MCRA_PROJECTS_FOLDER"))
(defonce files (fs/list-dir projects-dir))

(def folder-categories {:backed-up #{}
                        :to-review #{} 
                        :no-git #{}})

(def init-db (merge folder-categories 
                    {:total-files (count files) 
                     :total-files-touched 0}))

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
          (let [{:keys [out err]} (sh "git" "status" :dir (.toString file))
                to-update (cond
                            (not (empty? err))
                            (if (re-find #"fatal: not a git repository" err)
                              :no-git
                              :unknown-error)

                            (and (re-find #"Your branch is up to date with" out)
                                 (re-find #"nothing to commit, working tree clean" out))
                            :backed-up

                            :else
                            :to-review)]
            (swap! db update to-update conj file))))))
  (swap! db update :total-files-touched 
         (fn [initial-value] 
           (reduce + initial-value 
                   (map 
                     #(count (% @db)) 
                     (keys folder-categories)))))
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
