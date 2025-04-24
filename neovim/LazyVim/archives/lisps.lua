return {
  {
    -- Clojure, Lisps, Python, etc, REPL support in Neovim.
    "Olical/conjure",
    ft = { "clojure", "fennel", "python", "racket", "lua" }, -- etc
    lazy = true,
    init = function()
      -- Set configuration options here
      -- Uncomment this to get verbose logging to help diagnose internal Conjure issues
      -- This is VERY helpful when reporting an issue with the project
      -- vim.g["conjure#debug"] = true

      vim.g["conjure#extract#tree_sitter#enabled"] = true

      -- vim.g['conjure#client_on_load'] = false
      vim.g["conjure#log#jump_to_latest#enabled"] = true
      vim.g["conjure#log#jump_to_latest#cursor_scroll_position"] = "center"

      vim.g["conjure#log#wrap"] = true

      vim.g["conjure#log#hud#anchor"] = "SE"
      vim.g["conjure#log#hud#width"] = 1.0

      vim.g["conjure#log#botright"] = true
      -- vim.g['conjure#log#fold#enabled'] = true

      vim.g["conjure#highlight#enabled"] = true

      -- Uses clj with nrepl instead of babashka. Requires an alias named
      -- :repl/conjure in ~/.clojure/deps.edn (mine is in the root of this
      -- repo).
      vim.g["conjure#client#clojure#nrepl#connection#auto_repl#cmd"] = "clj -M:repl/conjure"
    end,

    config = function()
      -- Ignore <M-j/k> mappings from vim-sexp to avoid conflict with my
      -- preferred mappings.
      vim.g["sexp_mappings"] = {
        ["sexp_swap_list_backward"] = "",
        ["sexp_swap_list_forward"] = "",
      }
    end,
  },

  {
    -- Better Lisp support.
    "guns/vim-sexp",
    ft = { "clojure", "fennel", "racket" }, -- etc
    lazy = true,
  },

  {
    -- Better Lisp support.
    "tpope/vim-sexp-mappings-for-regular-people",
    ft = { "clojure", "fennel", "racket" }, -- etc
    lazy = true,
  },
}
