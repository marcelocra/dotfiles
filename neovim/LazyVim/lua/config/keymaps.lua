-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = function(mode, from, to, desc, opts)
  opts = opts or {}
  opts.no_vscode = opts.no_vscode or false

  -- If the user is using VSCode, don't set the mapping.
  if opts.no_vscode and vim.g.vscode then
    return
  end

  -- Keys that do not exist in vim API must be removed before calling the
  -- actual API.
  opts.no_vscode = nil

  opts.silent = opts.silent or true
  opts.noremap = opts.noremap or true

  opts.desc = desc
  vim.keymap.set(mode, from, to, opts)
end

local imap = function(from, to, desc, opts)
  map("i", from, to, desc, opts)
end
local nmap = function(from, to, desc, opts)
  map("n", from, to, desc, opts)
end
local vmap = function(from, to, desc, opts)
  map("v", from, to, desc, opts)
end
local inmap = function(from, to, desc, opts)
  map({ "i", "n" }, from, to, desc, opts)
end

-- Go back to normal mode.
imap("jf", "<Esc>", "Go to normal mode")
imap("fj", "<Esc>", "Go to normal mode")

-- Save faster.
-- NOTE: Use <C-s> instead.
-- inmap(",w", "<Esc>:w<CR>", "Saves the current buffer")
-- inmap(",s", "<Esc>:w<CR>", "Saves the current buffer")
inmap(",w", "<Esc>:echo 'Use ctrl+s!'<CR>", "Saves the current buffer")
inmap(",s", "<Esc>:echo 'Use ctrl+s!'<CR>", "Saves the current buffer")

-- Quit and close buffers faster.
nmap(",q", ":q<CR>", "Close the current buffer")
nmap(",,q", ":qa<CR>", "Close all buffers")

-- Save and quit faster.
nmap(",x", ":x<CR>", "Save and close the current buffer")
imap(",x", "<Esc>:x<CR>", "Save and close the current buffer")

-- Reload current file.
nmap(",e", ":e<CR>", "Reload current file")
imap(",e", "<Esc>:e<CR>", "Reload current file")

-- Port my most used mappings from VSCode.
nmap("<C-p>", "<Space><Space>", "Fuzzy search files in current folder")
nmap("<C-t>", "<Space>sS", "Fuzzy search workspace symbols")

-- -- Use <M-j/k> to move between tabs and <M-S-h/l> to move a line down/up.
-- nmap("<M-j>", "<M-S-h>", "Move to the left tab")
-- nmap("<M-k>", "<M-S-l>", "Move to the right tab")
-- imap("<M-j>", "ddp", "Move current line down")
-- imap("<M-k>", "ddkP", "Move current line up")

-- Print current file folder name.
nmap(",f", ':echo expand("%:p:h")<CR>', "Print current file folder name")

-- Easily open Neovim config files.
local edit_nvim_common = '$MYVIMRC<CR>:lcd <C-r>=expand("%:p:h")<CR><CR>'
nmap("<Leader>ev", ":tabe " .. edit_nvim_common, "[E]dit [V]imrc in a new tab")
nmap("<Leader>evh", ":spl " .. edit_nvim_common, "[E]dit [V]imrc in an [H]orizontal split")
nmap("<Leader>evv", ":vspl " .. edit_nvim_common, "[E]dit [V]imrc in a [V]ertical split")

-- Easily change colorschemes.
-- nmap("<Leader>cc", ":lua require('telescope.builtin').colorscheme()<CR>", "[C]hange [C]olorscheme")

-- Select file content.
nmap(",a", "ggVG", "Select full file content")
imap(",a", "<Esc>ggVG", "Select full file content")

-- Use - and | to split in normal mode.
nmap("-", ":split<CR>", "Easy vertical split")
nmap("|", ":vsplit<CR>", "Easy horizontal split")

-- Does this by deleting the selected content to the blackhole register and
-- then pasting the clipboard content to before the cursor position.
vmap("p", "_dP", "Avoid replace clipboard content when pasting.")

-- Clear last search (really.. it will erase the search and pressing 'n' won't
-- show it again).
nmap(",,cl", ':let @/ = ""<CR>', "Really clear the search")

-- Go to the Nth tab.
nmap("<M-1>", ":tabn 1<CR>")
nmap("<M-2>", ":tabn 2<CR>")
nmap("<M-3>", ":tabn 3<CR>")
nmap("<M-4>", ":tabn 4<CR>")
nmap("<M-5>", ":tabn 5<CR>")
nmap("<M-6>", ":tabn 6<CR>")
nmap("<M-7>", ":tabn 7<CR>")
nmap("<M-8>", ":tabn 8<CR>")
nmap("<M-9>", ":tabn 9<CR>")

-- Reminder that I'm using the wrong keyboard layout.
nmap("Ç", ':echo "Wrong keyboard layout!"<CR>')
nmap("ç", ':echo "wrong keyboard layout!"<CR>')

-- Toggle wrap.
nmap("<M-w>", ":set wrap!<CR>")
nmap("<M-w>", "<esc>:set wrap!<CR>a")

-- Add date to current buffer.
-- inoremap <M-d> <C-r>=strftime("%Y-%m-%d")<CR>
nmap("<M-d>", '<C-r>=strftime("%d%b%y")<CR>')

-- Add time to current buffer.
nmap("<M-t>", '<C-r>=strftime("%Hh%M")<CR>')

-- Eval current line or selection using Lua. (Edit: using Conjure instead.)
-- nk('<Leader>el', 'V:lua<CR>', 'Eval current line using Lua')
-- vk('<Leader>el', ':lua<CR>', 'Eval current selection using Lua')

-- Run current line in external shell and paste the output below.
-- Test with: echo hello world (select "echo hello").
-- TODO: deal with ^M (carriage return) characters. Currently they break the
-- command.
nmap("<Leader>es", ":exec 'r !' . getline('.')<CR>", "Run line externally and paste output")
vmap("<Leader>es", '"xy:r ! <C-r>x<CR>', "Run selection externally and paste output")

-- Use normal regex.
nmap("/", "/\\v", "Use normal regex")

-- Search for the selected text.
vmap("//", "y/\\V<C-r>=escape(@\",'/\\')<CR><CR>", "Search for current selection")

-- Move vertically by visual line (not jumping long lines).
map({ "n", "v" }, "j", "gj", "Move down by visual line")
map({ "n", "v" }, "k", "gk", "Move up by visual line")
map({ "n", "v" }, "$", "g$", "Move to the end of the line")
map({ "n", "v" }, "0", "g0", "Move to the beginning of the line")

-- Highlight last inserted text.
nmap("gV", "`[v`]")

-- Allow fast indenting when there is a chunck of text selected.
vmap("<", "<gv", "Indent selected text to the left")
vmap(">", ">gv", "Indent selected text to the right")

-- Clear search highlights.
nmap("<C-n>", ":nohlsearch<CR>")

-- Change unimpaired default mappings for [t and ]t for tab navigation.
nmap("[t", ":tabprevious<CR>", "Move to the previous tab")
nmap("]t", ":tabnext<CR>", "Move to the next tab")

-- Use ctrl-/ to comment/uncomment.
-- nmap("<C-_>", ":Commentary<CR>", "Comment/Uncomment current line")
-- vmap("<C-_>", ":Commentary<CR>", "Comment/Uncomment selection")

-- Use ctrl+f to search in current buffer.
nmap("<C-f>", function()
  Snacks.picker.lines()
end, "Search for current word in current buffer")

-- Next keymap/mapping/keybinding.
