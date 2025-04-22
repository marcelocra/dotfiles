-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local utils = require("utils")
local vimrc_folder = utils.vimrc_folder

local the_leader = " "
vim.g.mapleader = the_leader
vim.g.maplocalleader = the_leader

vim.opt.spell = true
vim.opt.spelllang = "en,pt_br,pt"
vim.opt.spellfile = vimrc_folder .. "/spell/dict.utf-8.add"
