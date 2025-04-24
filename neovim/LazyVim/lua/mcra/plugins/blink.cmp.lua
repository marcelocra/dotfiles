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
--   { "saghen/blink.compat", lazy = true, opts = {} },

  {
    "saghen/blink.cmp",
    -- dependencies = { "hrsh7th/cmp-emoji" },

    -- sources = {
    --   providers = {
    --     emoji = {
    --       name = "emoji",
    --       module = "blink.compat.source",
    --     },
    --   },
    -- },

    opts = {
      keymap = {
        -- Go back to using <Tab> and <S-Tab> for most things, like in VSCode.
        -- Docs: https://cmp.saghen.dev/configuration/keymap.html#super-tab
        preset = "super-tab",
      },
      appearance = {
        nerd_font_variant = "normal",
      },
    },
  },
}
