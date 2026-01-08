-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local the_leader = " "
vim.g.mapleader = the_leader
vim.g.maplocalleader = the_leader
vim.g.have_nerd_font = true  -- Terminal font must be nerd font to work
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.wrap = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"  -- Useful resizing splits.
vim.opt.showmode = false  -- Mode already in statusline
vim.schedule(function()  -- After UiEnter because it can increase startup-time
  vim.opt.clipboard = "unnamedplus"  -- Sync with OS.
end)

-- TODO: Review if this is really necessary.
-- -- Use OSC 52 for clipboard (works over SSH).
-- vim.g.clipboard = {
--   name = "OSC 52",
--   copy = {
--     ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
--   },
--   paste = {
--     ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
--   },
-- }

vim.opt.breakindent = true
vim.opt.breakindentopt = { shift = 2, minlines = 1 }
vim.opt.undofile = true  -- Undo even after closing a file
vim.opt.ignorecase = true  -- UNLESS \C or capitals
vim.opt.smartcase = true  -- UNLESS \C or capitals
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250  -- Decrease update time
vim.opt.timeoutlen = 300  -- Decrease mapped sequence wait time
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true  -- How to show certain whitespace characters.
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"  -- Preview substitutions live, as you type!
vim.opt.cursorline = true  -- Show which line your cursor is on.
vim.opt.scrolloff = 10  -- Lines to keep above and below cursor
vim.opt.colorcolumn = { "+1", "+21", "+41" }  -- Rulers +N after textwidth
vim.opt.ve = "onemore"  -- Virtual edit mode. Read :h 've' (with quotes).

-- Next option above.

--------------------------------------------------------------------------------
-- Abbreviations
--------------------------------------------------------------------------------

vim.cmd("iab lv LazyVim")

-- Shebangs.
vim.cmd("iab _sb #!/usr/bin/env")
vim.cmd("iab _posix #!/usr/bin/env sh")
vim.cmd("iab _deno #!/usr/bin/env -S deno run --allow-read")
vim.cmd("iab _fsx #!/usr/bin/env -S dotnet fsi")

-- EditorConfig alternatives.
-- When EditorConfig is not available, creates a modeline with my prefs.
-- For most languages I use the next line. Change tab (spaces) width, usually for Python.
vim.cmd("iab _ec   vim: tw=120 ts=2 sw=2 ai et ff=unix fenc=utf-8 fixeol eol fdm=marker fdl=0 fen")
vim.cmd("iab _ecpy vim: tw=80 ts=4 sw=4 ai et ff=unix fenc=utf-8 fixeol eol fdm=marker fdl=0 fen")

-- Shell
-- -e: exit on error
-- -u: exit on undefined variable
-- -o pipefail: exits on command pipe failures
-- -x: print commands before execution. Use only to debug, as it makes the
--     output really verbose.
vim.cmd("iab _euxo set -euxo pipefail")
vim.cmd("iab _euo set -euo pipefail")

vim.cmd("iab _devnull &>/dev/null 2>&1")
vim.cmd("iab _dn &>/dev/null 2>&1")
vim.cmd("iab _devnullshort &>/dev/null") -- Shorter but less portable.
vim.cmd("iab _dnsh &>/dev/null") -- Shorter but less portable.

-- Simplify writing shell command checks.
vim.cmd("iab _out >/dev/null 2>&1; then")
vim.cmd("iab _command command -v _out")
