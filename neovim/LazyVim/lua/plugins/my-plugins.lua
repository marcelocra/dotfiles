return {
  -- Git support.
  { "tpope/vim-fugitive" },

  -- Improved mappings for default stuff.
  { "tpope/vim-unimpaired" },

  -- Simplify handling of stuff that wraps code (parens, [curly]braces, quotes,
  -- etc).
  { "tpope/vim-surround" },

  -- Improve repeat support (e.g. for surrounding stuff).
  { "tpope/vim-repeat" },

  -- Simplify (un)commenting stuff out.
  { "tpope/vim-commentary" },

  {
    -- Copilot support.
    "github/copilot.vim",
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
    config = function()
      -- Good alternative to tab: <C-y>.
      vim.keymap.set("i", "<Tab>", 'copilot#Accept("\\<Tab>")', {
        expr = true,
        replace_keycodes = false,
      })

      vim.keymap.set("i", "<C-y>", 'copilot#Accept("\\<Tab>")', {
        expr = true,
        replace_keycodes = false,
      })

      vim.keymap.set("i", "<C-l>", "<Plug>(copilot-accept-word)")

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "solarized",
        -- group = ...,
        callback = function()
          vim.api.nvim_set_hl(0, "CopilotSuggestion", {
            fg = "#555555",
            ctermfg = 8,
            force = true,
          })
        end,
      })

      -- Default mappings:

      -- <C-]>       Dismiss the current suggestion.                               <Plug>(copilot-dismiss)
      -- <M-]>       Cycle to the next suggestion, if one is available.            <Plug>(copilot-next)
      -- <M-[>       Cycle to the previous suggestion.                             <Plug>(copilot-previous)
      -- <M-\>       Explicitly request a suggestion, even if Copilot is disabled. <Plug>(copilot-suggest)
      -- <M-Right>   Accept the next word of the current suggestion.               <Plug>(copilot-accept-word)
      -- <M-C-Right> Accept the next line of the current suggestion.               <Plug>(copilot-accept-line)

      --
    end,
  },

  {
    -- Align stuff.
    "junegunn/vim-easy-align",
    config = function()
      -- Start interactive EasyAlign in visual mode (e.g. vipga)
      vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")

      -- Start interactive EasyAlign for a motion/text object (e.g. gaip)
      vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")
    end,
  },

  -- COLORSCHEMES
  -- NOTE: Recommended for colorschemes: https://lazy.folke.io/spec#spec-loading

  { "altercation/vim-colors-solarized", priority = 1000 },
  { "sjl/badwolf", priority = 1000 },
  { "tpope/vim-vividchalk", priority = 1000 },

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

  -- {
  --   -- F# / FSharp support.
  --   'ionide/Ionide-vim',
  --   ft = { 'fsharp' }, -- etc
  --   lazy = true,
  --   init = function()
  --     -- vim.g['fsharp#fsautocomplete_command'] = { 'dotnet', 'fsautocomplete', '--background-service-enabled' }

  --     -- Custom mapping example. The default is vscode.
  --     -- vim.g['fsharp#fsi_keymap'] = 'custom' -- vscode
  --     -- vim.g['fsharp#fsi_keymap_send'] = '<C-e>' -- vscode: Alt+Enter
  --     -- vim.g['fsharp#fsi_keymap_toggle'] = '<C-@>' -- vscode: Alt+Shift+2 (Alt+@)

  --     vim.g['fsharp#exclude_project_directories'] = { 'paket-files' }
  --     -- vim.g['fsharp#fsi_command'] = 'dotnet fsi --compilertool:~/.nuget/packages/paket/8.0.3/tools/netcoreapp2.1/any/'
  --     -- vim.g['fsharp#use_sdk_scripts'] = false -- for net462 FSI
  --   end,
  -- },

  -- {
  --   -- Golang.
  --   'fatih/vim-go',
  --   ft = { 'go' }, -- etc
  -- },

  -- Next plugin.
}
