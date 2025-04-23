-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local the_leader = " "
vim.g.mapleader = the_leader
vim.g.maplocalleader = the_leader

vim.o.smartindent = true
vim.o.autoindent = true

-- Enable with <Leader>us.
vim.opt.spell = false
-- NOTE: The spelling_language and spelling_languages options in EditorConfig
-- takes precedence over spelllang. If you are not seeing what you expect,
-- check in your EditorConfig file.
vim.opt.spelllang = "en,en_us,pt_br,pt"
vim.opt.spellfile = os.getenv("MCRA_LOCAL_DOTFILES") .. "/backups/nvim/spell/dict.utf-8.add"

vim.o.wrap = true
