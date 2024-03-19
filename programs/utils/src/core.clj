#!/usr/bin/env bb
;; vim: autoindent expandtab tabstop=2 shiftwidth=2
;;
;; Command line utils.
(ns core
  (:require
    [clojure.java.shell :refer [sh]]
    [clojure.string :as s]
    [babashka.fs :as fs]
    [babashka.cli :as cli]
    [clojure.java.io :as io]
    [clojure.repl :refer [doc]]))

(def debug false)

(if (nil? (System/getenv "MCRA_CLI_UTILS_PATH"))
  (do
    (println "Please, define MCRA_CLI_UTILS_PATH env variable and try again.")
    (println "It should point to the `utils` script from the `dev` project.")
    (System/exit 1))
  nil)

(def templates-dir
  (-> (System/getenv "MCRA_CLI_UTILS_PATH")
      (fs/parent)
      (fs/file)
      (io/file "templates")
      (.toString)

      ;; When you don't know the api, you end up coding more. For the same
      ;; thing above, initially I wrote the code below (which wasn't working,
      ;; btw).

      ; (io/file)
      ; (fs/components)
      ; (->> (map #(.toString %)))
      ; (drop-last)
      ; (reverse)
      ; (conj "templates")
      ; (reverse)
      ; (->> (apply io/file))
      ; (fs/absolutize)
      ; (.toString))
      ))

(comment
  (-> (fs/list-dir templates-dir)
      (->> (map #(.toString %)))
      (->> (s/join "\n"))
      (println))

  ;; rcf - rich comment form
  )

(defn produce-file-path
  [name]
  (-> templates-dir
      (io/file name)
      (.toString)))

(def file-names
  "IMPORTANT: update the `template-files` too."
  {:bb "bb.edn"
   :prettier ".prettierrc.json"
   :shadow-cljs "shadow-cljs.edn"
   :build "build.clj"})

(def template-files
  {:bb (produce-file-path (:bb file-names))
   :prettier {"js" (produce-file-path (:prettier file-names))}
   :shadow-cljs (produce-file-path (:shadow-cljs file-names))
   :build (produce-file-path (:build file-names))})

(defn file-to-write
  "Prepares a filename for the given name in the current path."
  [name]
  (-> (fs/cwd)
      (.toString)
      (io/file name)
      (.toString)))


;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; CLI helper

(def cli-options
  {:lang {:default "js"}})

;; Made dynamic to simplify testing.
(def ^:dynamic parsed-cli-args
  (cli/parse-opts *command-line-args* {:spec cli-options}))

(def cmd-str (first *command-line-args*))


;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------

(defn free-ram
  "Prints the amount of free ram memory."
  []
  (println 
    (->>
      (:out (sh "cat" "/proc/meminfo"))
      (re-find #"MemFree.*")
      (re-find #"[0-9]+.*"))))


;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------

(defn pretty
  "Creates a prettierrc file for one of the following languages (use the options from the parenthesis): JavaScript (default or :js)."
  []
  (let [file-name (file-to-write (:prettier file-names))] 
    (if (fs/exists? file-name)
      (println (format "File '%s' exists. Aborting." file-name))
      (let [lang (:lang parsed-cli-args)
            content (fs/read-all-bytes (get-in template-files [:prettier lang] (get-in template-files [:prettier "js"])))]
        (if (nil? content)
          (println (str "Option '" lang "' not available. See help."))
          (fs/write-bytes file-name content))))))


;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------

(defn time-in
  "Returns the current time in the given timezone or America/New_York (default)."
  []
  (let [tz (get parsed-cli-args :tz "America/New_York")
        now (java.time.ZonedDateTime/now)
        timezone (java.time.ZoneId/of tz)
        tz-time (.withZoneSameInstant now timezone)
        pattern (java.time.format.DateTimeFormatter/ofPattern "HH:mm")]
    (println (format "[%s] %s" tz (.format tz-time pattern)))))

;; Example on how to create a binding to test functions.
(comment
  (binding [parsed-cli-args {:tz "America/Toronto"}]
    (time-in))

  ;; rcf - rich comment form
  )


;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------

(defn bb
  "Creates a new bb.edn file in the current directory."
  []
  (let [file-name (file-to-write (:bb file-names))] 
    (if (fs/exists? file-name)
      (println (format "File '%s' exists. Aborting." file-name))
      (let [lang (:lang parsed-cli-args)
            content (fs/read-all-bytes (get template-files :bb))]
        (if (nil? content)
          (println (str "Option '" lang "' not available. See help."))
          (fs/write-bytes file-name content))))))


;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------

(defn toggle-notifications
  "Enables/disables desktop notifications in an ubuntu/mint with cinnamon de."
  []
  (let [enabled-status "true\n"
        notifications-enabled?  (= enabled-status (:out (sh "gsettings"
                                                            "get"
                                                            "org.cinnamon.desktop.notifications"
                                                            "display-notifications")))]
    (let [result (sh "gsettings"
                     "set"
                     "org.cinnamon.desktop.notifications"
                     "display-notifications"
                     (str (not notifications-enabled?)))
          current-status (:out (sh "gsettings"
                                   "get"
                                   "org.cinnamon.desktop.notifications"
                                   "display-notifications"))
          user-feedback (if (= current-status enabled-status)
                          "Notifications enabled"
                          "Notifications disabled")]
      (println user-feedback))))


;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
(defn create-file-from-template
  "Creates a file with `file-name` from the `template` in the current directory, if the file doesn't already exists. If it does, shows a message and aborts."
  [file-name template]
  (if (fs/exists? file-name)
    (println (format "File '%s' exists. Aborting." file-name))
    (let [content (fs/read-all-bytes (produce-file-path (or template file-name)))]
      (if debug 
        (println (str "DEBUG mode:\ncreate "
                      file-name
                      "\nwith content:\n\n"
                      (String. content)))
        (fs/write-bytes file-name content)))))

(defn shadow
  "Creates a shadow-cljs.edn file and a .gitignore in the current directory."
  []
  (doseq [{:keys [file-name template]} [{:file-name "shadow-cljs.edn"} 
                                        {:file-name ".gitignore"
                                         :template "shadow-cljs.gitignore"}]]
    (create-file-from-template file-name template)))


;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
(defn build
  "Creates a build.clj file in the current directory, to help running commands."
  []
  (let [template :build
        file-name (file-to-write (template file-names))] 
    (if (fs/exists? file-name)
      (println (format "File '%s' exists. Aborting." file-name))
      (let [content (fs/read-all-bytes (get template-files template))]
        (fs/write-bytes file-name content)))))


;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; Next command here.


;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; NO COMMANDS BELOW HERE.
;;
;; This section is meant for the helper function and code that runs the other
;; commands.

(defn help []
  (println
    (str "Choose one of the commands below: \n\n"
         (s/join "\n"
                   (map #(format "%-25s%s" (:name %) (:doc %))
                        [(meta #'free-ram)
                         (meta #'pretty)
                         (meta #'time-in)
                         (meta #'bb)
                         (meta #'toggle-notifications)
                         (meta #'shadow)])))))


;; Run the selected command.
(if (nil? cmd-str)
  (help)
  (let [fn-to-run (resolve (symbol cmd-str))]
    (if (nil? fn-to-run)
      (help)
      (fn-to-run))))


;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; -----------------------------------------------------------------------------
;; PLAYGROUND!! :)

(comment
  (def templates-dir (-> (fs/cwd)
                         (.toString)
                         (io/file "src" "templates")
                         (.toString)))

  ;; creates one file for each of the templates
  (->
    templates-dir
    (io/file "bb.edn")
    (fs/write-bytes (.getBytes bb-template)))

  (->
    templates-dir
    (io/file ".prettierrc.json")
    (fs/write-bytes (.getBytes (get prettierrc-content "js"))))

  ;; creates a dir for templates if it doesn't exists and/or returns its content
  (->
    templates-dir
    (fs/create-dirs)
    (fs/list-dir))
  


  (-> (fs/cwd) 
      (.toString))

  ;; rcf - rich comment form
  )

