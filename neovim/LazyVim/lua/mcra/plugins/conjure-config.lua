return {

  {
    -- Clojure, Lisps, Python, etc, REPL support in Neovim.
    "Olical/conjure",
    ft = { "clojure", "fennel", "python", "racket", "lua" },
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

      -- NOTE: Uses clj with nrepl instead of babashka. Requires an alias named
      -- :repl/conjure in ~/.clojure/deps.edn (mine is in the root of this
      -- repo).
      -- vim.g["conjure#client#clojure#nrepl#connection#auto_repl#cmd"] = "clj -M:repl/conjure"
    end,

    config = function()
      -- INFO: 'vim-sexp' defaults that use Alt (M).

      -- <M-k>      *<Plug>(sexp_swap_list_backward)*
      -- <M-j>      *<Plug>(sexp_swap_list_forward)*
      -- <M-h>      *<Plug>(sexp_swap_element_backward)*
      -- <M-l>      *<Plug>(sexp_swap_element_forward)*
      -- <M-S-j>    *<Plug>(sexp_emit_head_element)*
      -- <M-S-k>    *<Plug>(sexp_emit_tail_element)*
      -- <M-S-h>    *<Plug>(sexp_capture_prev_element)*
      -- <M-S-l>    *<Plug>(sexp_capture_next_element)*

      -- Ignore them to avoid conflict with my preferred mappings. Use the
      -- vim-sexp-mappings-for-regular-people keybindings instead.
      vim.g["sexp_mappings"] = {
        ["sexp_swap_list_backward"] = "",
        ["sexp_swap_list_forward"] = "",
        ["sexp_swap_element_backward"] = "",
        ["sexp_swap_element_forward"] = "",
        ["sexp_emit_head_element"] = "",
        ["sexp_emit_tail_element"] = "",
        ["sexp_capture_prev_element"] = "",
        ["sexp_capture_next_element"] = "",

        -- These doesn't seem to be working.
        ["sexp_insert_double_quote"] = "",
        ["sexp_insert_backspace"] = "",
      }

      -- Alternative evaluation mappings.

      vim.keymap.set({ "n" }, "<S-CR>", "<LocalLeader>ew", { silent = true, remap = true })
      vim.keymap.set({ "n" }, "<M-S-CR>", "<LocalLeader>ecw", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<S-CR>", "<Esc><LocalLeader>ewa", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<M-S-CR>", "<Esc><LocalLeader>ecwa", { silent = true, remap = true })

      vim.keymap.set({ "n" }, "<C-CR>", "<LocalLeader>ee", { silent = true, remap = true })
      vim.keymap.set({ "n" }, "<M-C-CR>", "<LocalLeader>ece", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<C-CR>", "<Esc><LocalLeader>eea", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<M-C-CR>", "<Esc><LocalLeader>ecea", { silent = true, remap = true })

      vim.keymap.set({ "n" }, "<M-CR>", "<LocalLeader>er", { silent = true, remap = true })
      vim.keymap.set({ "n" }, "<C-S-M-CR>", "<LocalLeader>ecr", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<M-CR>", "<Esc><LocalLeader>era", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<C-S-M-CR>", "<Esc><LocalLeader>ecra", { silent = true, remap = true })

      vim.keymap.set({ "v" }, "<C-CR>", "<LocalLeader>E", { silent = true, remap = true })
      vim.keymap.set({ "v" }, "<M-CR>", "<LocalLeader>e!", { silent = true, remap = true })
    end,

    -- keys = {
    --   { "<M-j>", false },
    --   { "<M-k>", false },
    --
    --   -- Alternative evaluation mappings. {{{
    --
    --   { "<S-CR>", mode = { "n" }, "<LocalLeader>ew" },
    --   { "<M-S-CR>", mode = { "n" }, "<LocalLeader>ecw" },
    --   { "<S-CR>", mode = { "i" }, "<Esc><LocalLeader>ewa" },
    --   { "<M-S-CR>", mode = { "i" }, "<Esc><LocalLeader>ecwa" },
    --
    --   { "<C-CR>", mode = { "n" }, "<LocalLeader>ee" },
    --   { "<M-C-CR>", mode = { "n" }, "<LocalLeader>ece" },
    --   { "<C-CR>", mode = { "i" }, "<Esc><LocalLeader>eea" },
    --   { "<M-C-CR>", mode = { "i" }, "<Esc><LocalLeader>ecea" },
    --
    --   { "<M-CR>", mode = { "n" }, "<LocalLeader>er" },
    --   { "<C-S-M-CR>", mode = { "n" }, "<LocalLeader>ecr" },
    --   { "<M-CR>", mode = { "i" }, "<Esc><LocalLeader>era" },
    --   { "<C-S-M-CR>", mode = { "i" }, "<Esc><LocalLeader>ecra" },
    --
    --   { "<C-CR>", mode = { "v" }, "<LocalLeader>E" },
    --   { "<M-CR>", mode = { "v" }, "<LocalLeader>e!" },
    --
    --   -- }}}
    --
    -- },

    dependencies = {
      -- cmp-conjure integration.
      "marcelocra/cmp-conjure",
    },
  },

  {
    -- cmp-conjure integration.
    "saghen/blink.cmp",
    dependencies = { "saghen/blink.compat", "marcelocra/cmp-conjure" },

    opts = {
      sources = {
        compat = { "conjure" },
      },
    },
  },

  {
    -- Better Lisp (s-exp) support.
    "guns/vim-sexp",
    ft = { "clojure", "fennel", "racket" },
    lazy = true,
  },

  {
    -- Better Lisp (s-exp) mappings.
    "tpope/vim-sexp-mappings-for-regular-people",
    ft = { "clojure", "fennel", "racket" },
    lazy = true,
  },
}
