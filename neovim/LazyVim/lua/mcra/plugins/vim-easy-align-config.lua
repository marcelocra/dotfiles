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
    "junegunn/vim-easy-align",

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
}
