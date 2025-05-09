-- INFO: Keep disabled plugins here for future reference and to avoid keeping
-- commented out code in the main files.

local DISABLED = true

-- stylua: ignore
if DISABLED then return {} end

return {

  -- Simplify (un)commenting stuff out. NOTE: Seems unnecessary with LazyVim.
  { "tpope/vim-commentary" },

  -- F# / FSharp support. NOTE: It is better in VSCode.
  {
    "ionide/Ionide-vim",
    ft = { "fsharp" },
    lazy = true,
    init = function()
      -- vim.g['fsharp#fsautocomplete_command'] = { 'dotnet', 'fsautocomplete', '--background-service-enabled' }

      -- Custom mapping example. The default is vscode.
      -- vim.g['fsharp#fsi_keymap'] = 'custom' -- vscode
      -- vim.g['fsharp#fsi_keymap_send'] = '<C-e>' -- vscode: Alt+Enter
      -- vim.g['fsharp#fsi_keymap_toggle'] = '<C-@>' -- vscode: Alt+Shift+2 (Alt+@)

      vim.g["fsharp#exclude_project_directories"] = { "paket-files" }
      -- vim.g['fsharp#fsi_command'] = 'dotnet fsi --compilertool:~/.nuget/packages/paket/8.0.3/tools/netcoreapp2.1/any/'
      -- vim.g['fsharp#use_sdk_scripts'] = false -- for net462 FSI
    end,
  },

  -- Golang support.
  -- NOTE: Currently disabled because there's a lazyextra for go.
  {
    "fatih/vim-go",
    ft = { "go" }, -- etc
  },

  {
    -- Add emoji support.
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    opts = function(_, opts)
      if type(opts.sources) == "table" then
        vim.list_extend(opts.sources, { name = "emoji" })
      end
    end,
  },
}
