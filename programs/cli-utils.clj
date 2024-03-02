#!/usr/bin/env bb

(require
  '[clojure.java.shell :refer [sh]]
  '[clojure.string :as str]
  '[babashka.fs :as fs]
  '[babashka.cli :as cli]
  '[clojure.java.io :as io])

(def
  prettierrc-content
  "{
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
}")

(defn free-ram
  "Prints the amount of free ram memory."
  []
  (println 
    (->>
      (:out (sh "cat" "/proc/meminfo"))
      (re-find #"MemFree.*")
      (re-find #"[0-9]+.*"))))

(defn js-pretty
  "Creates a base JavaScript prettierrc file with markdown override."
  []
  (spit
    (-> (fs/cwd) 
        (.toString)
        (io/file ".prettierrc")
        (.toString))
    prettierrc-content))


;; CLI helper ------------------------------------------------------------------

(def cli-options
  {:example-cli-flag {:default "the default value"}})

;; Do not change code below here -----------------------------------------------

(defn help []
  (println
    (str "Choose one of the commands below: \n\n"
         (str/join "\n"
                   (map #(format "%-25s%s" (:name %) (:doc %))
                        [(meta #'free-ram)
                         (meta #'js-pretty)])))))

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

