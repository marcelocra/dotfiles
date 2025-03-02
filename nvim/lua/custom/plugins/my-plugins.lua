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
  -- { 'tpope/vim-commentary', lazy = true },

  -- Improve repeat support (e.g. for surrounding stuff).
  { 'tpope/vim-repeat' },

  -- Simplify jumping to stuff. Made by a NeoVim maintainer.
  {
    'justinmk/vim-sneak',
    init = function()
      vim.g['sneak#label'] = true
      vim.g['sneak#s_next'] = true
    end,
    config = function()
      vim.keymap.set('n', 'f', '<Plug>Sneak_f', { desc = 'Replaces f with Sneak_f' })
      vim.keymap.set('n', 'F', '<Plug>Sneak_F', { desc = 'Replaces F with Sneak_F' })
      vim.keymap.set('n', 't', '<Plug>Sneak_t', { desc = 'Replaces t with Sneak_t' })
      vim.keymap.set('n', 'T', '<Plug>Sneak_T', { desc = 'Replaces T with Sneak_T' })
    end,
  },

  -- Align stuff.
  {
    'junegunn/vim-easy-align',
    config = function()
      -- Start interactive EasyAlign in visual mode (e.g. vipga)
      vim.cmd 'xnoremap ga <Plug>(EasyAlign)'

      -- Start interactive EasyAlign for a motion/text object (e.g. gaip)
      vim.cmd 'nnoremap ga <Plug>(EasyAlign)'
    end,
  },

  --
  --
  -- COLORSCHEMES
  --

  { 'tpope/vim-vividchalk' },

  --
  --
  -- CLOJURE, LISPS, PYTHON, LUA
  --

  {
    'Olical/conjure',
    ft = { 'clojure', 'fennel', 'python', 'racket' }, -- etc
    lazy = true,
    init = function()
      -- Set configuration options here
      -- Uncomment this to get verbose logging to help diagnose internal Conjure issues
      -- This is VERY helpful when reporting an issue with the project
      -- vim.g["conjure#debug"] = true

      -- vim.g['conjure#client_on_load'] = false
      vim.g['conjure#log#jump_to_latest#enabled'] = false
      vim.g['conjure#log#jump_to_latest#cursor_scroll_position'] = 'center'

      vim.g['conjure#log#wrap'] = true

      vim.g['conjure#log#hud#anchor'] = 'SE'
      vim.g['conjure#log#hud#width'] = 1.0

      vim.g['conjure#log#botright'] = true
      -- vim.g['conjure#log#fold#enabled'] = true

      vim.g['conjure#highlight#enabled'] = true
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

  --
  --
  -- MISC
  --

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
}
