#!/usr/bin/env bb
;; vim: autoindent expandtab tabstop=2 shiftwidth=2
;;
;; Command line utils.

(require
  '[clojure.java.shell :refer [sh]]
  '[clojure.string :as str]
  '[babashka.fs :as fs]
  '[babashka.cli :as cli]
  '[clojure.java.io :as io])

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

(def
  prettierrc-content
  {"js" "{
  \"arrowParens\": \"always\",
  \"bracketSpacing\": true,
  \"endOfLine\": \"lf\",
  \"htmlWhitespaceSensitivity\": \"css\",
  \"insertPragma\": false,
  \"singleAttributePerLine\": false,
  \"bracketSameLine\": false,
  \"jsxBracketSameLine\": false,
  \"jsxSingleQuote\": false,
  \"printWidth\": 120,
  \"proseWrap\": \"preserve\",
  \"quoteProps\": \"as-needed\",
  \"requirePragma\": false,
  \"semi\": true,
  \"singleQuote\": false,
  \"tabWidth\": 2,
  \"trailingComma\": \"es5\",
  \"useTabs\": false,
  \"embeddedLanguageFormatting\": \"auto\",
  \"vueIndentScriptAndStyle\": false,
  \"overrides\": [
    {
      \"files\": \"*.md\",
      \"options\": {
        \"printWidth\": 80,
        \"proseWrap\": \"always\",
        \"parser\": \"markdown\"
      }
    }
  ]
}"
   })


(defn pretty
  "Creates a prettierrc file for one of the following languages (use the options from the parenthesis): JavaScript (default or :js)."
  []
  (let [lang (:lang parsed-cli-args)
        content (get prettierrc-content lang)]
    (if (nil? content)
      (println (str "Option '" lang "' not available. See help."))
      (spit
        (-> (fs/cwd) 
            (.toString)
            (io/file ".prettierrc")
            (.toString))
        content))))


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

(def bb-template
  "{:min-bb-version \"1.3.188\"

 :tasks
 {:requires ([babashka.fs :as fs]
             [babashka.cli :as cli])
  :init (do 
          (def cli-options
            {:hello {:default \"hello, world!\"}})
          (def parsed-cli-args (cli/parse-opts *command-line-args* {:spec cli-options}))

          (defn now
            \"Creates a date and time string for the current moment.\"
            [& {:keys [format-str]}]
            (let [date (java.util.Date.)]
              (-> (java.text.SimpleDateFormat. (if (nil? format-str)
                                                 \"yyyy-MM-dd HH:mm:ss.SSS\"
                                                 format-str))
                  (.format date))))

          (defn logging
            \"Logs timestamp with task name.\"
            [text-to-log]
            (let [log (Object.)
                  current-task-name (:name (current-task))] 
              (locking log
                (println 
                  (format 
                    \"[ %s | %s ] %s\"
                    (now)
                    (if (nil? current-task-name) \"global\" current-task-name)
                    text-to-log)))))

          (logging parsed-cli-args))
  :enter (logging \"starting\")
  :leave (logging \"done!\")

  dev {:doc \"Run these during development.\"
       :task (run '-dev {:parallel true})}
 
  -dev {:depends [-dev-cmd1 -dev-cmd2]}
  -dev-cmd1 {:task (shell \"bun d\")}
  -dev-cmd2 {:task (shell \"bun t\")}

  ;; Next task above this line.
 }
 
 ;; Next bb setting above this line.
}")

(defn bb
  "Creates a new bb.edn file in the current directory."
  []
  (println bb-template))


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
         (str/join "\n"
                   (map #(format "%-25s%s" (:name %) (:doc %))
                        [(meta #'free-ram)
                         (meta #'pretty)
                         (meta #'time-in)
                         (meta #'bb)])))))


;; Run the selected command.
(if (nil? cmd-str)
  (help)
  (let [fn-to-run (resolve (symbol cmd-str))]
    (if (nil? fn-to-run)
      (help)
      (fn-to-run))))

