(require '[babashka.fs :as fs]
         '[clojure.java.shell :refer [sh]]
         '[babashka.classpath :as cp])

(cp/add-classpath "bb")

(println (sh "bb --help"))

(-> (Runtime/getRuntime)
    (.addShutdownHook (Thread. #(println "bie"))))
