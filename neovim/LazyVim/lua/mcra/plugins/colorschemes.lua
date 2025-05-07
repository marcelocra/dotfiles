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
  -- NOTE: Priority should be a high number for colorschemes (normally, 1000 is
  -- used) to make sure they load before all the other start plugins, according
  -- to the docs: https://lazy.folke.io/spec#spec-loading

  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "altercation/vim-colors-solarized", priority = 1000 },
  { "sjl/badwolf", priority = 1000 },
  { "tpope/vim-vividchalk", priority = 1000 },
  { "ellisonleao/gruvbox.nvim", priority = 1000 },
  {
    "folke/tokyonight.nvim",
    priority = 1000,

    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },

    -- INFO: Example on how to configure.
    -- config = function()
    --   require("tokyonight").setup({
    --     styles = {
    --       comments = { italic = false }, -- Disable italics in comments
    --     },
    --   })
    -- end,
  },

  -- INFO: Choose the default colorscheme here. I also have a mapping (<M-d>)
  -- that allows changing colorscheme on the fly between the light and dark
  -- colorschemes configured in the file below.
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = require("mcra.lib.colorscheme").default,
    },
  },
}
