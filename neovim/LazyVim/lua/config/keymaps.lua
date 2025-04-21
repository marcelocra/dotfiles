-- vim: foldmethod=marker foldlevel=0
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remove LazyVim default keymaps. {{{

-- Open the file explorer. New: <M-b>.
vim.keymap.del("n", "<Leader>e")

-- }}}

-- Setup and helpers functions. {{{

local vimrc_folder = vim.fn.fnamemodify(vim.env.MYVIMRC, ":h")

-- Use to write documentation instead of comments when it makes sense. See
-- usages for some examples.
local doc

-- Define a function to allow partial application.
--
-- Example usage:
--    local function add(a, b, c)
--      return a + b + c
--    end
--    local add5 = partial(add, 5)
--    print(add5(3, 2)) -- Output: 10
--
local partial = function(func, ...)
  local args = { ... } -- Capture the arguments to pre-fill.
  return function(...)
    local new_args = { ... } -- Capture new arguments.
    local all_args = { unpack(args) } -- Combine pre-filled and new arguments.
    for _, v in ipairs(new_args) do
      table.insert(all_args, v)
    end
    return func(unpack(all_args)) -- Call the original function.
  end
end

--- Simplifies the mapping of keys.
---
--- @param mode string
--- @param from string
--- @param to string
--- @param desc_or_opts string | table | nil
--- @param opts table | nil
local map = function(mode, from, to, desc_or_opts, opts)
  if type(desc_or_opts) == "table" then
    opts = desc_or_opts
    desc_or_opts = nil
  end

  opts = opts or {}
  opts.vscode = opts.vscode or true

  -- If the user is using VSCode, don't set the mapping.
  if (not opts.vscode) and vim.g.vscode then
    print("In VSCode. Skipping mapping: " .. from .. " -> " .. to)
    return
  end

  -- Keys that do not exist in vim API must be removed before calling the
  -- actual API.
  opts.vscode = nil

  opts.silent = opts.silent or true
  opts.noremap = opts.noremap or true
  opts.desc = desc_or_opts
  vim.keymap.set(mode, from, to, opts)
end

-- Simplifies even more the mapping of keys.
local imap = partial(map, "i")
local nmap = partial(map, "n")
local vmap = partial(map, "v")
local inmap = partial(map, { "i", "n" })
local vnmap = partial(map, { "v", "n" })

-- Opens the LazyVim file picker in current folder.
local fuzzy_search_files = function()
  LazyVim.pick.open()
end

-- Opens the LazyVim picker for workspace symbols.
local fuzzy_search_symbols = function()
  Snacks.picker.lsp_workspace_symbols({ filter = LazyVim.config.kind_filter })
end

-- Opens the LazyVim picker for searching in the current file (buffer).
local fuzzy_search_buffer = function()
  Snacks.picker.lines()
end

-- }}}

-- Go back to normal mode.
imap("jf", "<Esc>", "Go to normal mode")
imap("fj", "<Esc>", "Go to normal mode")

-- Save faster.
-- NOTE: Use <C-s> instead.
-- inmap(",w", "<Esc>:w<CR>", "Saves the current buffer")
-- inmap(",s", "<Esc>:w<CR>", "Saves the current buffer")
imap(",w", "<Esc>:echo 'Use Ctrl+S!'<CR>a", "Saves the current buffer")
imap(",s", "<Esc>:echo 'Use Ctrl+S!'<CR>a", "Saves the current buffer")
nmap(",w", ":echo 'Use Ctrl+S!'<CR>", "Saves the current buffer")
nmap(",s", ":echo 'Use Ctrl+S!'<CR>", "Saves the current buffer")

-- Quit and close buffers faster.
nmap(",q", ":q<CR>", "Close the current buffer")
nmap(",,q", ":qa<CR>", "Close all buffers")

-- Save and quit faster.
nmap(",x", ":x<CR>", "Save and close the current buffer")
imap(",x", "<Esc>:x<CR>", "Save and close the current buffer")

-- Reload current file.
nmap(",e", ":e<CR>", "Reload current file")
imap(",e", "<Esc>:e<CR>", "Reload current file")
--
-- Port my most used mappings from VSCode.
nmap("<C-p>", fuzzy_search_files, "Fuzzy search files in current folder", { vscode = false })
nmap("<C-t>", fuzzy_search_symbols, "Fuzzy search workspace symbols", { vscode = false })
nmap("<C-f>", fuzzy_search_buffer, "Fuzzy search current buffer", { vscode = false })

-- -- -- Use <M-j/k> to move between tabs and <M-S-h/l> to move a line down/up.
-- nmap("<M-j>", "<M-S-h>", "Move to the left tab")
-- nmap("<M-k>", "<Cmd>tabnext<CR>", "Move to the right tab") -- Trying instead of <M-S-l>. Didn't work.
-- nmap("<M-k>", "<M-S-l>", "Move to the right tab")
-- imap("<M-j>", "ddp", "Move current line down")
-- imap("<M-k>", "ddkP", "Move current line up")
inmap("<M-j>", "<Cmd>BufferLineCyclePrev<CR>", "Move to the left tab")
inmap("<M-k>", "<Cmd>BufferLineCycleNext<CR>", "Move to the right tab")

doc = "Move line or selection down"
nmap("<M-Down>", "<Cmd>execute 'move .+' . v:count1<CR>==", doc)
nmap("<M-S-j>", "<Cmd>execute 'move .+' . v:count1<CR>==", doc)
imap("<M-Down>", "<Esc><Cmd>m .+1<CR>==gi", doc)
imap("<M-S-j>", "<Esc><Cmd>m .+1<CR>==gi", doc)
vmap("<M-Down>", ":<C-U>execute \"'<lt>,'>move '>+\" . v:count1<CR>gv=gv", doc)
vmap("<M-S-j>", ":<C-U>execute \"'<lt>,'>move '>+\" . v:count1<CR>gv=gv", doc)

doc = "Move line or selection up"
nmap("<M-Up>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", doc)
nmap("<M-S-k>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", doc)
imap("<M-Up>", "<Esc><Cmd>m .-2<CR>==gi", doc)
imap("<M-S-k>", "<Esc><Cmd>m .-2<CR>==gi", doc)
vmap("<M-Up>", ":<C-U>execute \"'<lt>,'>move '<lt>-\" . (v:count1 + 1)<CR>gv=gv", doc)
vmap("<M-S-k>", ":<C-U>execute \"'<lt>,'>move '<lt>-\" . (v:count1 + 1)<CR>gv=gv", doc)

nmap(",f", ':echo expand("%:p:h")<CR>', "Print current file folder name")

doc = "Edit Neovim config file"
local edit_nvim_file
local edit_nvim_common = function(name)
  return "./lua/config/" .. name .. "<CR>:lcd " .. vimrc_folder .. "<CR>"
end
edit_nvim_file = edit_nvim_common("keymaps.lua")
nmap("<Leader>evk", ":e " .. edit_nvim_file, doc, { vscode = false })
nmap("<Leader>ev-k", ":spl " .. edit_nvim_file, doc, { vscode = false })
nmap("<Leader>ev|k", ":vspl " .. edit_nvim_file, doc, { vscode = false })
edit_nvim_file = edit_nvim_common("options.lua")
nmap("<Leader>evo", ":e " .. edit_nvim_file, doc, { vscode = false })
nmap("<Leader>ev-o", ":spl " .. edit_nvim_file, doc, { vscode = false })
nmap("<Leader>ev|o", ":vspl " .. edit_nvim_file, doc, { vscode = false })
edit_nvim_file = edit_nvim_common("lazy.lua")
nmap("<Leader>evl", ":e " .. edit_nvim_file, doc, { vscode = false })
nmap("<Leader>ev-l", ":spl " .. edit_nvim_file, doc, { vscode = false })
nmap("<Leader>ev|l", ":vspl " .. edit_nvim_file, doc, { vscode = false })
edit_nvim_file = edit_nvim_common("autocmds.lua")
nmap("<Leader>eva", ":e " .. edit_nvim_file, doc, { vscode = false })
nmap("<Leader>ev-a", ":spl " .. edit_nvim_file, doc, { vscode = false })
nmap("<Leader>ev|a", ":vspl " .. edit_nvim_file, doc, { vscode = false })

doc = "Select the whole file content"
nmap(",a", "ggVG", doc)
imap(",a", "<Esc>ggVG", doc)

nmap("-", ":split<CR>", "Easy vertical split", { vscode = false })
nmap("|", ":vsplit<CR>", "Easy horizontal split", { vscode = false })

-- `_` is the blackhole register.
vmap("p", '"_dP', "Avoid replacing the clipboard content when pasting")

doc = "Clear the last search, erasing from the register ('n' won't work)"
nmap(",,cl", ':let @/ = ""<CR>', doc)

doc = "Go to the Nth tab"
nmap("<M-1>", ":tabn 1<CR>", doc)
nmap("<M-2>", ":tabn 2<CR>", doc)
nmap("<M-3>", ":tabn 3<CR>", doc)
nmap("<M-4>", ":tabn 4<CR>", doc)
nmap("<M-5>", ":tabn 5<CR>", doc)
nmap("<M-6>", ":tabn 6<CR>", doc)
nmap("<M-7>", ":tabn 7<CR>", doc)
nmap("<M-8>", ":tabn 8<CR>", doc)
nmap("<M-9>", ":tabn 9<CR>", doc)

doc = "Reminder that I'm using the wrong keyboard layout"
nmap("Ç", ':echo "Wrong keyboard layout!"<CR>', doc)
nmap("ç", ':echo "wrong keyboard layout!"<CR>', doc)

nmap("<M-w>", ":set wrap!<CR>", "Toggle line wrapping", { vscode = false, silent = false })

-- Alternative format: %Y-%m-%d
imap("<M-d>", '<C-r>=strftime("%d%b%y")<CR>', "Add date to current buffer in the format 21abr25")
imap("<M-t>", '<C-r>=strftime("%Hh%M")<CR>', "Add time to current buffer")

-- NOTE: Test with: echo hello world (select "echo hello")
-- TODO: Deal with ^M (carriage return) characters. Currently they break the command.
nmap("<Leader>es", ":exec 'r !' . getline('.')<CR>", "Run line external shell and paste output")
vmap("<Leader>es", '"xy:r ! <C-r>x<CR>', "Run selection externally and paste output")

nmap("/", "/\\v", "Use normal regex")
vmap("//", "y/\\V<C-r>=escape(@\",'/\\')<CR><CR>", "Search for the currently selected text")

vnmap("j", "gj", "Move down by visual line")
vnmap("k", "gk", "Move up by visual line")
vnmap("$", "g$", "Move to the end of the line")
vnmap("0", "g0", "Move to the beginning of the line")

nmap("gV", "`[v`]", "Highlight last inserted text.")

vmap("<", "<gv", "Allow fast indenting when there is a chunck of text selected")
vmap(">", ">gv", "Allow fast unindenting when there is a chunck of text selected")

-- Clear search highlights.
nmap("<C-n>", ":nohlsearch<CR>")

-- Use ctrl-/ to comment/uncomment.
doc = "Comment and uncomment line or selection"
nmap("<C-_>", ":Commentary<CR>", doc)
vmap("<C-_>", ":Commentary<CR>", doc)

vim.keymap.set("n", "<C-Tab>", "<Cmd>e #<CR>", { desc = "Easily alternate between the two most recent buffers" })

nmap("<Leader>oct", require("colorscheme-init").set(nil), "Use time-based colorscheme")
nmap("<Leader>ocd", require("colorscheme-init").set("dark"), "Set colorscheme to vim.g.colorscheme_mode_dark")
nmap("<Leader>ocl", require("colorscheme-init").set("light"), "Set colorscheme to vim.g.colorscheme_mode_light")

doc = "Open explorer in root dir"
nmap("<M-b>", partial(Snacks.explorer, { cwd = LazyVim.root() }), doc)
nmap("<M-e>", partial(Snacks.explorer, { cwd = LazyVim.root() }), doc)

-- Next keymap/mapping/keybinding.
