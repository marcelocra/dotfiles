return {
  -- Modern, high-performance colorscheme.
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  -- Tokyonight is already installed by LazyVim.

  -- ===========================================================================
  -- Legacy Colorschemes (Disabled)
  -- ===========================================================================
  -- NOTE: These are Vimscript themes. Kept for reference.
  -- { "altercation/vim-colors-solarized", priority = 1000 },
  -- { "sjl/badwolf", priority = 1000 },
  -- { "tpope/vim-vividchalk", priority = 1000 },
  -- {
  -- 	"folke/tokyonight.nvim",
  -- 	priority = 1000,
  -- 	-- opts = { transparent = true, styles = { sidebars = "transparent", floats = "transparent" } },
  -- },

  -- Set default colorscheme.
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "habamax", -- Built-in Neovim colorscheme (fast & clean)
      colorscheme = "catppuccin-latte",
    },
  },
}
