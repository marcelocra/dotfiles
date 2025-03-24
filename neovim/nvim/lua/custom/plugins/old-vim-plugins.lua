return {
  -- Git support.
  { 'tpope/vim-fugitive' },

  -- Improved mappings for default stuff.
  { 'tpope/vim-unimpaired' },

  -- Simplify handling of stuff that wraps code (parens, [curly]braces, quotes,
  -- etc).
  { 'tpope/vim-surround' },

  -- NOTE: Might not be necessary, as current defaults already support my needs.
  -- Simplify (un)commenting stuff out.
  -- { 'tpope/vim-commentary' },

  -- Improve repeat support (e.g. for surrounding stuff).
  { 'tpope/vim-repeat' },

  -- {
  --   -- Simplify jumping to stuff. Made by a NeoVim maintainer.
  --   'justinmk/vim-sneak',
  --   init = function()
  --     vim.g['sneak#label'] = true
  --     vim.g['sneak#s_next'] = true
  --   end,
  --   config = function()
  --     vim.keymap.set('n', 'f', '<Plug>Sneak_f', { desc = 'Replaces f with Sneak_f' })
  --     vim.keymap.set('n', 'F', '<Plug>Sneak_F', { desc = 'Replaces F with Sneak_F' })
  --     vim.keymap.set('n', 't', '<Plug>Sneak_t', { desc = 'Replaces t with Sneak_t' })
  --     vim.keymap.set('n', 'T', '<Plug>Sneak_T', { desc = 'Replaces T with Sneak_T' })
  --   end,
  -- },

  {
    -- Simplify jumping to stuff. Made by LazyVim creator.
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  {
    -- Copilot support.
    'github/copilot.vim',
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
    config = function()
      vim.keymap.set('i', '<C-y>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
      })

      vim.keymap.set('i', '<C-l>', '<Plug>(copilot-accept-word)')

      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = 'solarized',
        -- group = ...,
        callback = function()
          vim.api.nvim_set_hl(0, 'CopilotSuggestion', {
            fg = '#555555',
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
    'junegunn/vim-easy-align',
    config = function()
      -- Start interactive EasyAlign in visual mode (e.g. vipga)
      vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)')

      -- Start interactive EasyAlign for a motion/text object (e.g. gaip)
      vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)')
    end,
  },

  { 'vim-airline/vim-airline' },

  -- COLORSCHEMES
  -- NOTE: Recommended for colorschemes: https://lazy.folke.io/spec#spec-loading

  { 'folke/tokyonight.nvim', priority = 1000 },
  { 'altercation/vim-colors-solarized', priority = 1000 },
  { 'sjl/badwolf', priority = 1000 },
  { 'tpope/vim-vividchalk', priority = 1000 },
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },

  {
    -- Clojure, Lisps, Python, etc, REPL support in Neovim.
    'Olical/conjure',
    ft = { 'clojure', 'fennel', 'python', 'racket', 'lua' }, -- etc
    lazy = true,
    init = function()
      -- Set configuration options here
      -- Uncomment this to get verbose logging to help diagnose internal Conjure issues
      -- This is VERY helpful when reporting an issue with the project
      -- vim.g["conjure#debug"] = true

      vim.g['conjure#extract#tree_sitter#enabled'] = true

      -- vim.g['conjure#client_on_load'] = false
      vim.g['conjure#log#jump_to_latest#enabled'] = true
      vim.g['conjure#log#jump_to_latest#cursor_scroll_position'] = 'center'

      vim.g['conjure#log#wrap'] = true

      vim.g['conjure#log#hud#anchor'] = 'SE'
      vim.g['conjure#log#hud#width'] = 1.0

      vim.g['conjure#log#botright'] = true
      -- vim.g['conjure#log#fold#enabled'] = true

      vim.g['conjure#highlight#enabled'] = true

      -- Uses clj with nrepl instead of babashka. Requires an alias named
      -- :repl/conjure in ~/.clojure/deps.edn (mine is in the root of this
      -- repo).
      vim.g['conjure#client#clojure#nrepl#connection#auto_repl#cmd'] = 'clj -M:repl/conjure'
    end,

    config = function()
      -- Ignore <M-j/k> mappings from vim-sexp to avoid conflict with my
      -- preferred mappings.
      vim.g['sexp_mappings'] = {
        ['sexp_swap_list_backward'] = '',
        ['sexp_swap_list_forward'] = '',
      }
    end,

    -- Optional cmp-conjure integration
    dependencies = { 'marcelocra/cmp-conjure' },
  },

  {
    -- Integrates Conjure with cmp.
    'marcelocra/cmp-conjure',
    lazy = true,
    config = function()
      local cmp = require 'cmp'
      local config = cmp.get_config()
      table.insert(config.sources, { name = 'conjure' })
      return cmp.setup(config)
    end,
  },

  {
    -- Better Lisp support.
    'guns/vim-sexp',
    ft = { 'clojure', 'fennel', 'racket' }, -- etc
    lazy = true,
  },

  {
    -- Better Lisp support.
    'tpope/vim-sexp-mappings-for-regular-people',
    ft = { 'clojure', 'fennel', 'racket' }, -- etc
    lazy = true,
  },

  {
    -- F# / FSharp support.
    'ionide/Ionide-vim',
    ft = { 'fsharp' }, -- etc
    lazy = true,
    init = function()
      -- vim.g['fsharp#fsautocomplete_command'] = { 'dotnet', 'fsautocomplete', '--background-service-enabled' }

      -- Custom mapping example. The default is vscode.
      -- vim.g['fsharp#fsi_keymap'] = 'custom' -- vscode
      -- vim.g['fsharp#fsi_keymap_send'] = '<C-e>' -- vscode: Alt+Enter
      -- vim.g['fsharp#fsi_keymap_toggle'] = '<C-@>' -- vscode: Alt+Shift+2 (Alt+@)

      vim.g['fsharp#exclude_project_directories'] = { 'paket-files' }
      -- vim.g['fsharp#fsi_command'] = 'dotnet fsi --compilertool:~/.nuget/packages/paket/8.0.3/tools/netcoreapp2.1/any/'
      -- vim.g['fsharp#use_sdk_scripts'] = false -- for net462 FSI
    end,
  },

  {
    -- Golang.
    'fatih/vim-go',
    ft = { 'go' }, -- etc
  },

  -- {
  --   'folke/snacks.nvim',
  --   priority = 1000,
  --   lazy = false,
  --   ---@type snacks.Config
  --   opts = {
  --     bigfile = { enabled = true },
  --     dashboard = { enabled = true },
  --     explorer = { enabled = true },
  --     indent = { enabled = true },
  --     input = { enabled = true },
  --     notifier = {
  --       enabled = true,
  --       timeout = 3000,
  --     },
  --     picker = { enabled = true },
  --     quickfile = { enabled = true },
  --     scope = { enabled = true },
  --     scroll = { enabled = true },
  --     statuscolumn = { enabled = true },
  --     words = { enabled = true },
  --     styles = {
  --       notification = {
  --         -- wo = { wrap = true } -- Wrap notifications
  --       },
  --     },
  --   },
  --   -- stylua: ignore
  --   keys = {
  --     -- Top Pickers & Explorer
  --     { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
  --     { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
  --     { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
  --     { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
  --     { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
  --     { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
  --     -- find
  --     { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
  --     { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
  --     { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
  --     { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
  --     { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
  --     { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
  --     -- git
  --     { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
  --     { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
  --     { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
  --     { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
  --     { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
  --     { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
  --     { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
  --     -- Grep
  --     { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
  --     { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
  --     { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
  --     { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
  --     -- search
  --     { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
  --     { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
  --     { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
  --     { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
  --     { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
  --     { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
  --     { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
  --     { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
  --     { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
  --     { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
  --     { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
  --     { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
  --     { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
  --     { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
  --     { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
  --     { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
  --     { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
  --     { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
  --     { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
  --     { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
  --     { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
  --     -- LSP
  --     { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
  --     { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
  --     { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
  --     { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
  --     { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
  --     { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
  --     { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
  --     -- Other
  --     { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
  --     { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
  --     { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
  --     { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
  --     { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
  --     { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
  --     { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
  --     { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
  --     { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
  --     { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
  --     { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
  --     { "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore" },
  --     { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
  --     { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
  --     {
  --       "<leader>N",
  --       desc = "Neovim News",
  --       function()
  --         Snacks.win({
  --           file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
  --           width = 0.6,
  --           height = 0.6,
  --           wo = {
  --             spell = false,
  --             wrap = false,
  --             signcolumn = "yes",
  --             statuscolumn = " ",
  --             conceallevel = 3,
  --           },
  --         })
  --       end,
  --     }
  --   },
  --   init = function()
  --     vim.api.nvim_create_autocmd('User', {
  --       pattern = 'VeryLazy',
  --       callback = function()
  --         -- Setup some globals for debugging (lazy-loaded)
  --         _G.dd = function(...)
  --           Snacks.debug.inspect(...)
  --         end
  --         _G.bt = function()
  --           Snacks.debug.backtrace()
  --         end
  --         vim.print = _G.dd -- Override print to use snacks for `:=` command
  --
  --         -- Create some toggle mappings
  --         Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
  --         Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
  --         Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
  --         Snacks.toggle.diagnostics():map '<leader>ud'
  --         Snacks.toggle.line_number():map '<leader>ul'
  --         Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>uc'
  --         Snacks.toggle.treesitter():map '<leader>uT'
  --         Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
  --         Snacks.toggle.inlay_hints():map '<leader>uh'
  --         Snacks.toggle.indent():map '<leader>ug'
  --         Snacks.toggle.dim():map '<leader>uD'
  --       end,
  --     })
  --   end,
  --
  --   -- To view all highlight groups, run:
  --   -- Snacks.picker.highlights({pattern = "hl_group:^Snacks"})
  -- },

  -- Next plugin.
}
