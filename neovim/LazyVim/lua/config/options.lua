-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-------------------------------------------------------------------------------
-- Essential options
-------------------------------------------------------------------------------
-- TODO: Check if these are overwritten by LazyVim after it starts. I believe
-- they are, but that's ok, as LazyVim sets most of them already. It is useful
-- to have them here just in case there's some problem starting LazyVim and for
-- some reason we are left with Neovim/Vim defaults.
--
-- TODO: Check where we should put options that overwrite LazyVim options. I
-- believe it should be either in a specific plugin `init` function or in an
-- `autocmd`.
-------------------------------------------------------------------------------
local the_leader = " "
vim.g.mapleader = the_leader
vim.g.maplocalleader = the_leader

-- Configures all options in one go. Good to keep everything together.
require("mcra.lib.utils").call(function()
  local opt = vim.opt

  opt.smartindent = true
  opt.autoindent = true

  opt.tabstop = 2
  opt.shiftwidth = 2
  opt.expandtab = true

  opt.wrap = true

  -------------------------------------------------------------------------------
  -- Spell checker settings
  -------------------------------------------------------------------------------
  -- Enable with <Leader>us.
  opt.spell = false

  -- NOTE: The spelling_language and spelling_languages options in EditorConfig
  -- takes precedence over spelllang. If you are not seeing what you expect,
  -- check in your EditorConfig file.
  opt.spelllang = "en,en_us,pt_br,pt"
  opt.spellfile = os.getenv("MCRA_LOCAL_DOTFILES") .. "/backups/nvim/spell/dict.utf-8.add"
end)

vim.g.lazyvim_prettier_needs_config = false
vim.g.markdown_fenced_languages = { "ts=typescript" }
