-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local key = function(mode, from, to, desc, opts)
  opts = opts or {}
  opts.desc = desc
  opts.silent = true
  opts.noremap = true
  vim.keymap.set(mode, from, to, opts)
end

local ik = function(from, to, desc, opts)
  opts = opts or {}
  opts.desc = desc
  key("i", from, to, desc, opts)
end

local nk = function(from, to, desc, opts)
  opts = opts or {}
  opts.desc = desc
  key("n", from, to, desc, opts)
end

-- Go back to normal mode.
ik("jf", "<Esc>", "Go to normal mode")
ik("fj", "<Esc>", "Go to normal mode")

-- Use <C-s> instead. It also leaves insert mode.
-- -- Save faster.
-- vim.keymap.set({ "i", "n" }, ",w", "<Esc>:w<CR>", { desc = "Saves the current buffer" })
-- vim.keymap.set({ "i", "n" }, ",s", "<Esc>:w<CR>", { desc = "Saves the current buffer" })
vim.keymap.set({ "i", "n" }, ",w", "<Esc>:echo 'Use <C-s>!'<CR>", { noremap = true, desc = "Saves the current buffer" })
vim.keymap.set({ "i", "n" }, ",s", "<Esc>:echo 'Use <C-s>!'<CR>", { noremap = true, desc = "Saves the current buffer" })

-- Quit and close buffers faster.
nk(",q", ":q<CR>", "Close the current buffer")
nk(",,q", ":qa<CR>", "Close all buffers")

-- Save and quit faster.
nk(",x", ":x<CR>", "Save and close the current buffer")
ik(",x", "<Esc>:x<CR>", "Save and close the current buffer")

-- Reload current file.
nk(",e", ":e<CR>", "Reload current file")
ik(",e", "<Esc>:e<CR>", "Reload current file")

-- Port my most used mappings from VSCode.
nk("<C-p>", "<Space><Space>", "Fuzzy search files in current folder")
nk("<C-t>", "<Space>sS", "Fuzzy search workspace symbols")

-- Use <M-j/k> to move between tabs and <M-S-h/l> to move a line down/up.
ik("<M-j>", "<Esc>:tabp<CR>", { desc = "Move to the left tab" })
ik("<M-k>", "<Esc>:tabn<CR>", { desc = "Move to the right tab" })
ik("<M-S-j>", "<Esc>:tabp<CR>", { desc = "Move to the left tab" })
ik("<M-S-k>", "<Esc>:tabn<CR>", { desc = "Move to the right tab" })

-- Print current file folder name.
nk(",f", ':echo expand("%:p:h")<CR>', "Print current file folder name")

-- Easily open Neovim config files.
local edit_nvim_common = '$MYVIMRC<CR>:lcd <C-r>=expand("%:p:h")<CR><CR>'
nk("<Leader>ev", ":tabe " .. edit_nvim_common, "[E]dit [V]imrc in a new tab")
nk("<Leader>evh", ":spl " .. edit_nvim_common, "[E]dit [V]imrc in an [H]orizontal split")
nk("<Leader>evv", ":vspl " .. edit_nvim_common, "[E]dit [V]imrc in a [V]ertical split")

-- Easily change colorschemes.
nk("<Leader>cc", ":lua require('telescope.builtin').colorscheme()<CR>", "[C]hange [C]olorscheme")

-- Select file content.
nk(",a", "ggVG", "Select full file content")
ik(",a", "<Esc>ggVG", "Select full file content")

-- Use - and | to split in normal mode.
vim.cmd([[
  nnoremap - :split<cr>
  nnoremap \| :vsplit<cr>
]])

-- Avoids replacing the clipboard content with the selected content. Does this
-- by deleting the selected content to the blackhole register and then pasting
-- the clipboard content to before the cursor position.
vim.cmd('vnoremap p "_dP')

-- Clear last search (really.. it will erase the search and pressing 'n' won't
-- show it again).
vim.cmd('nnoremap ,,cl :let @/ = ""<cr>')

-- Go to the Nth tab.
vim.cmd([[
  nnoremap <M-1> :tabn 1<CR>
  nnoremap <M-2> :tabn 2<CR>
  nnoremap <M-3> :tabn 3<CR>
  nnoremap <M-4> :tabn 4<CR>
  nnoremap <M-5> :tabn 5<CR>
  nnoremap <M-6> :tabn 6<CR>
  nnoremap <M-7> :tabn 7<CR>
  nnoremap <M-8> :tabn 8<CR>
  nnoremap <M-9> :tabn 9<CR>
]])

-- Reminder that I'm using the wrong keyboard layout.
vim.cmd([[
  nnoremap Ç :echo "Wrong keyboard layout!"<cr>
  nnoremap ç :echo "wrong keyboard layout!"<cr>
]])

-- Toggle wrap.
vim.cmd([[
  nnoremap <a-w> :set wrap!<cr>
  inoremap <a-w> <esc>:set wrap!<cr>a
]])

-- Add date to current buffer.
-- inoremap <a-d> <c-r>=strftime("%Y-%m-%d")<cr>
vim.cmd('inoremap <a-d> <c-r>=strftime("%d%b%y")<cr>')

-- Add time to current buffer.
vim.cmd('inoremap <a-t> <c-r>=strftime("%Hh%M")<cr>')

-- Eval current line or selection using Lua. (Edit: using Conjure instead.)
-- nk('n', '<Leader>el', 'V:lua<CR>', { desc = 'Eval current line using Lua' })
-- vim.keymap.set('v', '<Leader>el', ':lua<CR>', { desc = 'Eval current selection using Lua' })

-- Run current line in external shell and paste the output below.
-- Test with: echo hello world (select "echo hello").
-- TODO: deal with ^M (carriage return) characters. Currently they break the
-- command.
nk("<Leader>es", ":exec 'r !' . getline('.')<CR>", "Run line externally and paste output")
vim.keymap.set("v", "<Leader>es", '"xy:r ! <C-r>x<CR>', { desc = "Run selection externally and paste output" })

-- Use normal regex.
nk("/", "/\\v", "Use normal regex")

-- Search for the selected text.
vim.keymap.set("v", "//", "y/\\V<C-r>=escape(@\",'/\\')<CR><CR>", { desc = "Search for current selection" })

-- Move vertically by visual line (not jumping long lines).
vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Move down by visual line" })
vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Move up by visual line" })
vim.keymap.set({ "n", "v" }, "$", "g$", { desc = "Move to the end of the line" })
vim.keymap.set({ "n", "v" }, "0", "g0", { desc = "Move to the beginning of the line" })

-- Highlight last inserted text.
nk("gV", "`[v`]")

-- Allow fast indenting when there is a chunck of text selected.
vim.keymap.set("v", "<", "<gv", { desc = "Indent selected text to the left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent selected text to the right" })

-- Clear search highlights.
nk("<C-n>", ":nohlsearch<CR>")

-- Change unimpaired default mappings for [t and ]t for tab navigation.
nk("[t", ":tabprevious<CR>", "Move to the previous tab")
nk("]t", ":tabnext<CR>", "Move to the next tab")

-- Use ctrl-/ to comment/uncomment.
nk("<C-_>", ":Commentary<CR>", { noremap = false, desc = "Comment/Uncomment current line" })
vim.keymap.set("v", "<C-_>", ":Commentary<CR>", { noremap = false, desc = "Comment/Uncomment selection" })
