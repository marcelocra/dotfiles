local map = vim.keymap.set

-- =============================================================================
-- Core / File Operations
-- =============================================================================

-- Save shortcuts (legacy habits)
map({ "n", "v" }, ",w", "<Cmd>w<CR>", { desc = "Save current buffer", silent = true })
map({ "i" }, ",w", "<Esc><Cmd>w<CR>", { desc = "Save current buffer", silent = true })
map({ "n", "v" }, ",s", "<Cmd>w<CR>", { desc = "Save current buffer", silent = true })
map({ "i" }, ",s", "<Esc><Cmd>w<CR>", { desc = "Save current buffer", silent = true })

-- Quit / Close shortcuts
map({ "n", "i", "v" }, ",q", "<Cmd>q<CR>", { desc = "Quit/Close current buffer", silent = true })
map({ "n", "i" }, ",x", "<Cmd>x<CR>", { desc = "Save and close buffer", silent = true })
map({ "n", "i" }, ",e", "<Cmd>e<CR>", { desc = "Reload current file", silent = true })

-- Utility
map({ "n", "i", "v" }, ",,f", '<Cmd>echo expand("%:p")<CR>', { desc = "Print current file path" })
map({ "n" }, "<C-n>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlights", silent = true })

-- =============================================================================
-- Selection & Editing
-- =============================================================================

-- Select all
map({ "n" }, ",a", "ggVG", { desc = "Select all content" })
map({ "i" }, ",a", "<Esc>ggVG", { desc = "Select all content" })

-- Paste without losing clipboard (Visual Mode)
map("v", "p", '"_dP', { desc = "Paste without replacing clipboard" })

-- Search selected text (Visual Mode)
-- map("v", "//", 'y/\V<C-r>=escape(@", "/\")<CR><CR>', { desc = "Search for selected text" })

-- Clear search register
map("n", ",,cl", ':let @/ = ""<CR>', { desc = "Clear search register", silent = true })

-- Highlight last inserted text
map("n", "gV", "`[v`]", { desc = "Highlight last inserted text" })

-- Insert Date/Time
map("i", "<M-d>", '<C-r>=strftime("%d%b%y")<CR>', { desc = "Insert date (21abr25)" })
map("i", "<M-t>", '<C-r>=strftime("%Hh%M")<CR>', { desc = "Insert time (HHhMM)" })

-- Keyboard Layout Warnings
local wrong_layout_msg = ':echo "Wrong keyboard layout!"<CR>'
map("n", "Ç", wrong_layout_msg, { desc = "Warn wrong layout" })
map("n", "ç", wrong_layout_msg, { desc = "Warn wrong layout" })

-- =============================================================================
-- Window & Buffer Management
-- =============================================================================

-- Split shortcuts
map("n", "-", "<Cmd>split<CR>", { desc = "Horizontal Split", silent = true })
map("n", "|", "<Cmd>vsplit<CR>", { desc = "Vertical Split", silent = true })

-- Buffer Navigation (BufferLine)
map({ "n", "i" }, "<M-j>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Buffer Left" })
map({ "n", "i" }, "<M-k>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Buffer Right" })
map({ "n", "i", "v" }, ",d", "<Leader>bd", { desc = "Delete Buffer", remap = true, silent = true })
map("n", ",,q", "<Leader>qq", { desc = "Quit All", remap = true, silent = true })

-- Alternate Buffers
local alt_buffer_opts = { desc = "Alternate buffer", remap = true, silent = true }
map("n", "<C-Tab>", "<Leader>bb", alt_buffer_opts)
map("n", "<S-Tab>", "<Leader>bb", alt_buffer_opts)

-- =============================================================================
-- Movement (Line Moving)
-- =============================================================================

-- Move lines up/down
-- NOTE: This overrides LazyVim's default <M-j>/<M-k> which we used for buffers above
local move_down = { desc = "Move line down" }
map("n", "<M-Down>", "<Cmd>execute 'move .+' . v:count1<CR>==", move_down)
map("n", "<M-S-j>", "<Cmd>execute 'move .+' . v:count1<CR>==", move_down)
map("i", "<M-Down>", "<Esc><Cmd>m .+1<CR>==gi", move_down)
map("i", "<M-S-j>", "<Esc><Cmd>m .+1<CR>==gi", move_down)
map("v", "<M-Down>", ":<C-U>execute \"'<,'>move '>+\" . v:count1<CR>gv=gv", move_down)
map("v", "<M-S-j>", ":<C-U>execute \"'<,'>move '>+\" . v:count1<CR>gv=gv", move_down)

local move_up = { desc = "Move line up" }
map("n", "<M-Up>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", move_up)
map("n", "<M-S-k>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", move_up)
map("i", "<M-Up>", "<Esc><Cmd>m .-2<CR>==gi", move_up)
map("i", "<M-S-k>", "<Esc><Cmd>m .-2<CR>==gi", move_up)
map("v", "<M-Up>", ":<C-U>execute \"'<,'>move '<-\" . (v:count1 + 1)<CR>gv=gv", move_up)
map("v", "<M-S-k>", ":<C-U>execute \"'<,'>move '<-\" . (v:count1 + 1)<CR>gv=gv", move_up)

-- =============================================================================
-- Plugin Specifics & Overrides
-- =============================================================================

-- Comments (Override LazyVim terminal mapping for <C-/>)
local ctrl_slash = "<C-/>"
local ctrl_underscore = "<C-_>"

-- Remove default terminal toggle to use for comments
pcall(vim.keymap.del, { "n", "t" }, ctrl_slash)
pcall(vim.keymap.del, { "n", "t" }, ctrl_underscore)

-- Re-map Terminal to <C-`>
map("n", "<C-`>", function()
  Snacks.terminal(nil, { cwd = LazyVim.root(), win = { position = "right" } })
end, { desc = "Terminal (Root)" })
map("t", "<C-`>", "<Cmd>close<CR>", { desc = "Close terminal" })

-- Comment Mappings
local comment_opts = { desc = "Toggle Comment", remap = true, silent = true }
map("n", ctrl_slash, "gcc", comment_opts)
map("i", ctrl_slash, "<Esc>gcc", comment_opts)
map("v", ctrl_slash, "gcgv", comment_opts)
-- Support for <C-_> (often sent by terminals for <C-/>)
map("n", ctrl_underscore, "gcc", comment_opts)
map("i", ctrl_underscore, "<Esc>gcc", comment_opts)
map("v", ctrl_underscore, "gcgv", comment_opts)

-- Diagnostics
map("n", "<Leader>d", "<Leader>xx", { desc = "Diagnostics (Trouble)", remap = true })

-- Pickers (VSCode habits)
-- CRITICAL FIX: Wrapped LazyVim.pick in function to prevent load-time crash
map("n", "<C-p>", function()
  LazyVim.pick.open()
end, { desc = "Find Files (Root)" })
map("n", "<C-f>", function()
  Snacks.picker.lines()
end, { desc = "Find in Buffer" })
map("n", "<C-t>", function()
  Snacks.picker.lsp_symbols({ filter = LazyVim.config.kind_filter })
end, { desc = "LSP Symbols" })

-- Explorer
map("n", "<M-b>", function()
  Snacks.explorer({ cwd = LazyVim.root() })
end, { desc = "Explorer (Root)" })
map("n", "<M-e>", function()
  Snacks.explorer({ cwd = LazyVim.root() })
end, { desc = "Explorer (Root)" })

-- Rename
map("n", "<F2>", "<Leader>cr", { desc = "Rename", remap = true })

-- Escape Insert Mode
map("i", "jf", "<Esc>", { desc = "Exit Insert Mode" })
map("i", "fj", "<Esc>", { desc = "Exit Insert Mode" })

-- =============================================================================
-- Config Helpers (Edit this file)
-- =============================================================================
local function config_edit(cmd, name)
  local vimrc_folder = vim.fn.fnamemodify(vim.env.MYVIMRC, ":h")
  local open_cmd = ({ b = ":e ", h = ":spl ", v = ":vspl " })[cmd] or ":e "
  return open_cmd .. vimrc_folder .. "/lua/config/" .. name .. "<CR>:lcd " .. vimrc_folder .. "<CR>"
end

map("n", "<Leader>evk", config_edit("b", "keymaps.lua"), { desc = "Edit keymaps" })
map("n", "<Leader>evo", config_edit("b", "options.lua"), { desc = "Edit options" })
map("n", "<Leader>eva", config_edit("b", "autocmds.lua"), { desc = "Edit autocmds" })

