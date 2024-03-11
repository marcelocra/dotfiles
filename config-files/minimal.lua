-- vim:ts=4:sw=4:et:ai:fdm=marker:fmr={{{,}}}:fdl=0:fen
--
-- Absolute minimal and essential vim settings (lua
-- version).


-- Settings


vim.cmd([[
    syntax enable
    colorscheme default
    colorscheme elflord
    colorscheme morning
]])

vim.o.smarttab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.autoindent = true
vim.o.vb = 't_vb='
vim.o.number = true
vim.o.norelativenumber = false
vim.o.ruler = true
vim.o.colorcolumn = '60,80,100,120' 
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.laststatus = 2
vim.o.encoding = 'utf-8'
vim.o.showbreak = '+++ '
vim.o.listchars = 'eol:↲,tab:→ ,trail:·,extends:>,precedes:<,nbsp:%'
vim.o.nolist = true
vim.o.cursorline = true
vim.o.backspace = 2
vim.o.wildmenu = true
vim.o.lazyredraw = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.fileformats = 'unix'
vim.o.t_Co = 256
vim.o.statusline = '%<%F %m%r%h %=lines:%l/%L col:%c%V'
vim.o.clipboard = 'unnamedplus'

