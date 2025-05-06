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
    -- F# / FSharp support.
    "ionide/Ionide-vim",
    ft = { "fsharp" }, -- etc
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

  -- -- [note] Currently disabled because there's a lazyextra for go.
  -- {
  --   -- Golang support.
  --   'fatih/vim-go',
  --   ft = { 'go' }, -- etc
  -- },
}
