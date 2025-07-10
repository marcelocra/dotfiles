#!/usr/bin/env sh
# vim:sw=4:ts=4:et:ai:fen:fdm=marker:fmr={{{,}}}:fdl=0

run_node() {
    # Compile.
    clj -M -m cljs.main \
        --target node \
        --output-to main.js \
        -c org.splitwell.node

    # Run!
    node main.js
}

browser_repl() {
    # :launch-browser defaults to true, which is annoying.
    clj -M --main cljs.main \
        --repl-opts "{:launch-browser false}" \
        --compile org.splitwell.core \
        --repl

    # After a change, to reload the code in the repl, run:
    # 
    #   (require '[org.splitwell.core :as split] :reload)
}

browser_compile_advanced_and_serve() {
    clj -M -m cljs.main \
        --optimizations advanced \
        -c org.splitwell.core

    clj -M -m cljs.main --serve

    # Open the browser in localhost:9000 to check.
}
