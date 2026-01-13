-- =============================================================================
-- Options
-- Only options that differ from LazyVim defaults or are critical preferences.
-- =============================================================================

-- stylua: ignore start
-- Visuals
vim.opt.wrap = true                                         -- Soft wrap lines
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" } -- Custom list chars
vim.opt.inccommand = "split"                                -- Show substitutions in a split preview
vim.opt.scrolloff = 10                                      -- Keep 10 lines context above/below cursor
vim.opt.colorcolumn = { "+1", "+21", "+41" }                -- Guide lines
vim.opt.ve = "onemore"                                      -- Allow cursor to move past end of line
-- stylua: ignore end

-- Behavior
vim.g.have_nerd_font = true -- Explicitly declare nerd font support

-- Abbreviations (Shell & Coding Helpers)
local cmd = vim.cmd
cmd("iab lv LazyVim")

-- Shebangs
cmd("iab _sb #!/usr/bin/env")
cmd("iab _posix #!/usr/bin/env sh")
cmd("iab _deno #!/usr/bin/env -S deno run --allow-read")
cmd("iab _fsx #!/usr/bin/env -S dotnet fsi")

-- EditorConfig fallback
cmd("iab _ec   vim: tw=120 ts=2 sw=2 ai et ff=unix fenc=utf-8 fixeol eol fdm=marker fdl=0 fen")
cmd("iab _ecpy vim: tw=80 ts=4 sw=4 ai et ff=unix fenc=utf-8 fixeol eol fdm=marker fdl=0 fen")

-- Shell Snippets
cmd("iab _euxo set -euxo pipefail")
cmd("iab _euo set -euo pipefail")
cmd("iab _devnull &>/dev/null 2>&1")
cmd("iab _dn &>/dev/null 2>&1")
cmd("iab _out >/dev/null 2>&1; then")
cmd("iab _command command -v _out")
