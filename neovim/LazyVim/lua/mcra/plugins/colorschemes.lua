--
-- Customizing Plugin Specs
-- Defaults merging rules:
--
--  * cmd: the list of commands will be extended with your custom commands
--  * event: the list of events will be extended with your custom events
--  * ft: the list of filetypes will be extended with your custom filetypes
--  * keys: the list of keymaps will be extended with your custom keymaps
--  * opts: your custom opts will be merged with the default opts
--  * dependencies: the list of dependencies will be extended with your custom
--    dependencies any other property will override the defaults
--
-- For ft, event, keys, cmd and opts you can instead also specify a values function that can make changes to the default values, or return new values to be used instead.
--
-- Docs from:
-- https://www.lazyvim.org/configuration/plugins#%EF%B8%8F-customizing-plugin-specs
--

return {
  -- NOTE: Priority recommended for colorschemes:
  -- https://lazy.folke.io/spec#spec-loading

  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "altercation/vim-colors-solarized" },
  { "sjl/badwolf" },
  { "tpope/vim-vividchalk" },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
