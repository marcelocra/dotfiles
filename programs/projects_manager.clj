#!/usr/bin/env bb

;; idea: symlink this as mng (for manager).

(ns projects-manager
  (:require
    [babashka.fs :as fs]
    [clojure.string :as s]
    [clojure.pprint :as pp :refer [pprint] :rename {pprint p}]
    [clojure.java.shell :refer [sh]]
    [clojure.java.io :as io]))

(def projects-dir (System/getenv "MCRA_PROJECTS_FOLDER"))
(def folders (->> (fs/list-dir projects-dir)
                  (filter #(fs/directory? %))))

(defn sorted-set-by-modified-time-desc []
  (sorted-set-by 
    (fn [a b] 
      (.compareTo (fs/last-modified-time b) 
                  (fs/last-modified-time a)))))

(def folder-categories {:backed-up (sorted-set-by-modified-time-desc)
                        :to-review (sorted-set-by-modified-time-desc)
                        :no-git (sorted-set-by-modified-time-desc)})

(def init-db (merge folder-categories 
                    {:number-of-folders (count folders)}))

(def db (atom init-db))

(do
  (doseq [folder folders]
    (let [visited? (some #(contains? (% @db) folder) (keys folder-categories))] 
      (if visited?
        nil  ;; File already processed, nothing to do.
        (let [{:keys [out err]} (sh "git" "status" :dir (.toString folder))
              to-update 
              (cond
                (not (empty? err))
                (if (re-find #"fatal: not a git repository" err)
                  :no-git
                  :unknown-error)

                (and (re-find #"Your branch is up to date with" out)
                     (re-find #"nothing to commit, working tree clean" out))
                :backed-up

                :else
                :to-review)]
          (swap! db update to-update conj folder)))))
  (p @db))


;; learning the api

(comment
  (def dir (fs/list-dir "."))
  (def first-el (first dir))
  (def last-el (last dir))

  (.compareTo (fs/last-modified-time first-el) (fs/last-modified-time last-el))
  (.toString (fs/last-modified-time first-el))

  (-> (fs/last-modified-time first-el)
      (.getClass)
      (.getMethods)
      (->> (map #(.getName %)))
      (p))


  (fs/list-dir dir)
  (sh "git" "status" "--porcelain" :dir (.toString dir))
  (sh "git" "status" :dir (.toString dir))
  (sh "git" "add" "." :dir (.toString dir))
  (sh "git" "d" :dir (.toString dir))
  (sh "git" "restore" "--staged" "." :dir (.toString dir))
  (sh "git" "commit" "-m" "'remove comment (using clojure)'" "--dry-run" :dir (.toString dir))

  ;; rcf - rich comment form 
  )
