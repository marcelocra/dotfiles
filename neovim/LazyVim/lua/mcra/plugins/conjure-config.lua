--
-- Defaults merging rules:
--  * cmd: the list of commands will be extended with your custom commands
--  * event: the list of events will be extended with your custom events
--  * ft: the list of filetypes will be extended with your custom filetypes
--  * keys: the list of keymaps will be extended with your custom keymaps
--  * opts: your custom opts will be merged with the default opts
--  * dependencies: the list of dependencies will be extended with your custom
--    dependencies any other property will override the defaults
--
-- For ft, event, keys, cmd and opts you can instead also specify a values
-- function that can make changes to the default values, or return new values to
-- be used instead.
--
-- Docs from:
-- https://www.lazyvim.org/configuration/plugins#%EF%B8%8F-customizing-plugin-specs
--

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

      -- -- Uses clj with nrepl instead of babashka. Requires an alias named
      -- -- :repl/conjure in ~/.clojure/deps.edn (mine is in the root of this
      -- -- repo).
      -- vim.g["conjure#client#clojure#nrepl#connection#auto_repl#cmd"] = "clj -M:repl/conjure"
    end,

    config = function()
      -- Ignore <M-j/k> mappings from vim-sexp to avoid conflict with my
      -- preferred mappings.
      vim.g["sexp_mappings"] = {
        ["sexp_swap_list_backward"] = "",
        ["sexp_swap_list_forward"] = "",
      }

      -- Alternative evaluation mappings.

      vim.keymap.set({ "n" }, "<S-CR>", "<LocalLeader>ew", { silent = true, remap = true })
      vim.keymap.set({ "n" }, "<M-S-CR>", "<LocalLeader>ew", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<S-CR>", "<Esc><LocalLeader>ewa", { silent = true, remap = true })
      vim.keymap.set({ "i" }, "<M-S-CR>", "<Esc><LocalLeader>ewa", { silent = true, remap = true })

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

    -- TODO: Uncomment this once the integration is fixed.
    -- -- Optional cmp-conjure integration
    -- dependencies = { 'marcelocra/cmp-conjure' },
  },

  -- TODO: Figure out how to use this with blink.
  -- {
  --   -- Integrates Conjure with cmp.
  --   "marcelocra/cmp-conjure",
  --   lazy = true,
  --   config = function()
  --     local cmp = require("cmp")
  --     local config = cmp.get_config()
  --     table.insert(config.sources, { name = "conjure" })
  --     return cmp.setup(config)
  --   end,
  -- },

  {
    -- Better Lisp (s-exp) support.
    "guns/vim-sexp",
    ft = { "clojure", "fennel", "racket" }, -- etc
    lazy = true,
  },

  {
    -- Better Lisp (s-exp) mappings.
    "tpope/vim-sexp-mappings-for-regular-people",
    ft = { "clojure", "fennel", "racket" }, -- etc
    lazy = true,
  },
}
