print("Loading my-plugins.lua")

return {
  -- INFO: Example of how to disable a plugin.
  -- { "folke/trouble.nvim", enabled = false },

  -- Amazing Git support.
  { "tpope/vim-fugitive" },

  -- Improve mappings for default stuff.
  { "tpope/vim-unimpaired", vscode = true },

  -- Simplify handling "wrappings" (parens, [curly]braces, quotes, etc).
  { "tpope/vim-surround", vscode = true },

  -- Improve repeat support (e.g. for surrounding stuff).
  { "tpope/vim-repeat", vscode = true },

  -- [note] Seems unnecessary with LazyVim.
  -- Simplify (un)commenting stuff out.
  -- { "tpope/vim-commentary" },

  {
    -- Copilot support.
    "github/copilot.vim",
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
    config = function()
      -- Insert the full suggestion.
      vim.keymap.set("i", "<Tab>", 'copilot#Accept("\\<Tab>")', {
        expr = true,
        replace_keycodes = false,
      })
      vim.keymap.set("i", "<C-y>", 'copilot#Accept("\\<Tab>")', {
        expr = true,
        replace_keycodes = false,
      })

      -- Insert only the next world.
      vim.keymap.set("i", "<C-l>", "<Plug>(copilot-accept-word)")

      -- Suggestion colors (ghost text).
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
    "junegunn/vim-easy-align",
    vscode = true,

    init = function()
      -- Default: vim.g.easy_align_ignore_groups = { "Comment",  "String" }
      -- But I want to align at least in comments. Not sure if strings make
      -- sense though.
      vim.g.easy_align_ignore_groups = { "String" }
    end,

    config = function()
      -- Start interactive EasyAlign in visual mode (e.g. vipga)
      vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")

      -- Start interactive EasyAlign for a motion/text object (e.g. gaip)
      vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")
    end,
  },

  -- NOTE: Not using F# now and support is better in VSCode.
  -- {
  --   -- F# / FSharp support.
  --   "ionide/Ionide-vim",
  --   ft = { "fsharp" },
  --   lazy = true,
  --   init = function()
  --     -- vim.g['fsharp#fsautocomplete_command'] = { 'dotnet', 'fsautocomplete', '--background-service-enabled' }
  --
  --     -- Custom mapping example. The default is vscode.
  --     -- vim.g['fsharp#fsi_keymap'] = 'custom' -- vscode
  --     -- vim.g['fsharp#fsi_keymap_send'] = '<C-e>' -- vscode: Alt+Enter
  --     -- vim.g['fsharp#fsi_keymap_toggle'] = '<C-@>' -- vscode: Alt+Shift+2 (Alt+@)
  --
  --     vim.g["fsharp#exclude_project_directories"] = { "paket-files" }
  --     -- vim.g['fsharp#fsi_command'] = 'dotnet fsi --compilertool:~/.nuget/packages/paket/8.0.3/tools/netcoreapp2.1/any/'
  --     -- vim.g['fsharp#use_sdk_scripts'] = false -- for net462 FSI
  --   end,
  -- },

  -- NOTE: Currently disabled because there's a lazyextra for go.
  -- {
  --   -- Golang support.
  --   'fatih/vim-go',
  --   ft = { 'go' }, -- etc
  -- },

  -- {
  --   -- Add emoji support.
  --   "hrsh7th/nvim-cmp",
  --   dependencies = { "hrsh7th/cmp-emoji" },
  --   opts = function(_, opts)
  --     if type(opts.sources) == "table" then
  --       vim.list_extend(opts.sources, { name = "emoji" })
  --     end
  --   end,
  -- },

  {
    -- Change the default (gpt-4o) Copilot model to use in chat.
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      model = "claude-3.7-sonnet",
    },
  },
}
