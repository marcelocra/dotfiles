return {
  -- NOTE: Priority should be a high number for colorschemes (normally, 1000 is
  -- used) to make sure they load before all the other start plugins, according
  -- to the docs: https://lazy.folke.io/spec#spec-loading

  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "altercation/vim-colors-solarized", priority = 1000 },
  { "sjl/badwolf", priority = 1000 },
  { "tpope/vim-vividchalk", priority = 1000 },
  {
    "folke/tokyonight.nvim",
    priority = 1000,

    -- -- INFO: How to make tokyonight transparent.
    -- opts = {
    --   transparent = true,
    --   styles = {
    --     sidebars = "transparent",
    --     floats = "transparent",
    --   },
    -- },

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
      colorscheme = "habamax",
    },
  },
}
