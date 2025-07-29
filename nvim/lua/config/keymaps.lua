--
-- Keymaps are automatically loaded on the VeryLazy event.
-- Default keymaps that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here.
--

-- INFO: In VSCode, load the correct file (if any) and ignore this one.
if vim.g.vscode then
  require("config.vscode-keymaps")
  return
end

-- INFO: Keymaps that are common to Neovim and VSCode should be moved here.
require("config.common-keymaps")

-- Change some LazyVim defaults.
do
  ------------------------------------------------------------------------------
  --- Use ctrl+/ to toggle comments instead of the terminal.
  ------------------------------------------------------------------------------
  -- NOTE: <C-_> is <C-/>, but we need to use both as some terminals don't
  -- recognize one or the other: Alacritty seems to recognize both, while Wezterm
  -- only recognizes <C-/>.
  local ctrl_underscore = "<C-_>"
  local ctrl_slash = "<C-/>"

  vim.keymap.del({ "n", "t" }, ctrl_underscore)
  vim.keymap.del({ "n", "t" }, ctrl_slash)

  vim.keymap.set("n", "<C-`>", function()
    Snacks.terminal(nil, { cwd = LazyVim.root(), win = { position = "right" } })
  end, { desc = "Terminal (Root Dir)" })
  vim.keymap.set("t", "<C-`>", "<Cmd>close<CR>", { desc = "Close terminal" })

  local desc = "Comment and uncomment line or selection"
  local opts = { desc = desc, remap = true, silent = true }

  -- Normal.
  vim.keymap.set({ "n" }, ctrl_underscore, "gcc", opts)
  vim.keymap.set({ "n" }, ctrl_slash, "gcc", opts)
  -- Insert.
  vim.keymap.set({ "i" }, ctrl_underscore, "<Esc>gcc", opts)
  vim.keymap.set({ "i" }, ctrl_slash, "<Esc>gcc", opts)
  -- Visual.
  vim.keymap.set({ "v" }, ctrl_underscore, "gcgv", opts)
  vim.keymap.set({ "v" }, ctrl_slash, "gcgv", opts)

  ------------------------------------------------------------------------------
  --- Disable LazyVim's default profiler keymaps.
  ------------------------------------------------------------------------------
  vim.keymap.del("n", "<Leader>dpp")
  vim.keymap.del("n", "<Leader>dph")
  -- vim.keymap.del("n", "<Leader>dps")
end

do
  local desc = "Easily alternate between the two most recent buffers"
  local opts = { desc = desc, remap = true, silent = true }

  -- If <C-Tab> doesn't work in a terminal, use the other ones.
  -- Without extra plugins, use: "<Cmd>e #<CR>" in the rhs.
  vim.keymap.set({ "n" }, "<C-Tab>", "<Leader>bb", opts)
  vim.keymap.set({ "n" }, "<S-Tab>", "<Leader>bb", opts)

  -- Alternative mappings if the ones above don't work.
  -- vim.keymap.set({ "n" }, "<Leader><Leader>", "<Leader>bb", opts)
  -- vim.keymap.set({ "n" }, "<M-l>", "<Leader>bb", opts)
end

vim.keymap.set({ "i" }, "jf", "<Esc>", { desc = "Go to normal mode" })
vim.keymap.set({ "i" }, "fj", "<Esc>", { desc = "Go to normal mode" })

vim.keymap.set({ "n", "i", "v" }, ",d", "<Leader>bd", { desc = "Delete current buffer", silent = true, remap = true })
vim.keymap.set({ "n", "i", "v" }, ",q", "<Cmd>q<CR>", { desc = "Quit/Close current buffer", silent = true })
vim.keymap.set({ "n" }, ",,q", "<Leader>qq", { desc = "Quit/Close all buffers", silent = true, remap = true })

-- Save and quit faster.
vim.keymap.set({ "n", "i" }, ",x", "<Cmd>x<CR>", { desc = "Save and close the current buffer", silent = true })

-- Reload current file.
vim.keymap.set({ "n", "i" }, ",e", "<Cmd>e<CR>", { desc = "Reload current file", silent = true })

-- NOTE: It is not possible to have multiple tabs without multiple buffers.
-- Therefore we can use the BufferLine plugin to manage the tabs and behave as
-- if they were tabs. Previously: <Cmd>tabprev<CR> | <Cmd>tabnext<CR>
vim.keymap.set({ "n", "i" }, "<M-j>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Focus on the buffer to the left" })
vim.keymap.set({ "n", "i" }, "<M-k>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Focus on the buffer to the right" })

-- Move line or selection up and down.
do
  local doc = "Move line or selection down"
  local desc = { desc = doc }

  vim.keymap.set({ "n" }, "<M-Down>", "<Cmd>execute 'move .+' . v:count1<CR>==", desc)
  vim.keymap.set({ "n" }, "<M-S-j>", "<Cmd>execute 'move .+' . v:count1<CR>==", desc)
  vim.keymap.set({ "i" }, "<M-Down>", "<Esc><Cmd>m .+1<CR>==gi", desc)
  vim.keymap.set({ "i" }, "<M-S-j>", "<Esc><Cmd>m .+1<CR>==gi", desc)
  vim.keymap.set({ "v" }, "<M-Down>", ":<C-U>execute \"'<lt>,'>move '>+\" . v:count1<CR>gv=gv", desc)
  vim.keymap.set({ "v" }, "<M-S-j>", ":<C-U>execute \"'<lt>,'>move '>+\" . v:count1<CR>gv=gv", desc)

  doc = "Move line or selection up"
  desc = { desc = doc }

  vim.keymap.set({ "n" }, "<M-Up>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", desc)
  vim.keymap.set({ "n" }, "<M-S-k>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", desc)
  vim.keymap.set({ "i" }, "<M-Up>", "<Esc><Cmd>m .-2<CR>==gi", desc)
  vim.keymap.set({ "i" }, "<M-S-k>", "<Esc><Cmd>m .-2<CR>==gi", desc)
  vim.keymap.set({ "v" }, "<M-Up>", ":<C-U>execute \"'<lt>,'>move '<lt>-\" . (v:count1 + 1)<CR>gv=gv", desc)
  vim.keymap.set({ "v" }, "<M-S-k>", ":<C-U>execute \"'<lt>,'>move '<lt>-\" . (v:count1 + 1)<CR>gv=gv", desc)
end

-- Manage colorschemes, particularly changing between light and dark.
do
  local color = require("mcra.lib.colorscheme")
  local set = color.set
  local toggle = color.toggle

  vim.keymap.set({ "n" }, "<Leader>oct", set(nil), { desc = "Use time-based colorscheme" })
  vim.keymap.set({ "n" }, "<Leader>ocd", set("dark"), { desc = "Set colorscheme to vim.g.colorscheme_mode_dark" })
  vim.keymap.set({ "n" }, "<Leader>ocl", set("light"), { desc = "Set colorscheme to vim.g.colorscheme_mode_light" })
  vim.keymap.set({ "n" }, "<M-d>", toggle, { desc = "Set colorscheme to vim.g.colorscheme_mode_light" })
end

-- vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Move down by visual line", silent = true })
-- vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Move up by visual line", silent = true })
-- vim.keymap.set({ "n", "v" }, "$", "g$", { desc = "Move to the end of the line", silent = true })
-- vim.keymap.set({ "n", "v" }, "0", "g0", { desc = "Move to the beginning of the line", silent = true })

vim.keymap.set({ "n" }, "<Leader>d", "<Leader>xx", { desc = "Toggle the diagnostics window", remap = true })

vim.keymap.set({ "n" }, "<Leader>mt", function()
  local tasks_file = os.getenv("HOME") .. "/doc/TODO.md"
  vim.cmd("vspl " .. tasks_file)
end, { desc = "Open my tasks files" })

-- Port some VSCode mappings that I like back to Neovim.
do
  vim.keymap.set({ "n" }, "<C-p>", LazyVim.pick.open, { desc = "Fuzzy search for files in current folder" })
  vim.keymap.set({ "n" }, "<C-f>", Snacks.picker.lines, { desc = "Fuzzy search for text in the current buffer" })

  local symbol = require("i").partial(Snacks.picker.lsp_symbols, { filter = LazyVim.config.kind_filter })
  vim.keymap.set({ "n" }, "<C-t>", symbol, { desc = "Fuzzy search for symbols in the current file (buffer)" })

  vim.keymap.set({ "n" }, "<F2>", "<Leader>cr", { desc = "Rename variable", remap = true })
end

-- Simplify editing Neovim config files.
do
  local keymap = vim.keymap.set
  local vimrc_folder = require("i").vimrc_folder

  ---
  --- Use the given `cmd` to open the file `name`, changing the local working directory to the Neovim config folder.
  ---
  --- @param cmd string Command to open the file. Shortcuts: b (buffer), h (horizontal split), v (vertical split).
  --- @param name string Name of the file to open. It should be in 'lua/config' folder.
  --- @return string command Command to open the file.
  local cfg = function(cmd, name)
    local cmds = { b = ":e ", h = ":spl ", v = ":vspl " }

    cmd = cmds[cmd] or ":e "
    return cmd .. vimrc_folder .. "/lua/config/" .. name .. "<CR>:lcd " .. vimrc_folder .. "<CR>"
  end

  local desc = function(file, pos)
    return { desc = "Edit Neovim " .. file .. " file in a " .. pos, silent = true }
  end

  keymap({ "n" }, "<Leader>evk", cfg("b", "keymaps.lua"), desc("keymaps", "buffer"))
  keymap({ "n" }, "<Leader>ev-k", cfg("h", "keymaps.lua"), desc("keymaps", "split"))
  keymap({ "n" }, "<Leader>ev|k", cfg("v", "keymaps.lua"), desc("keymaps", "vsplit"))

  keymap({ "n" }, "<Leader>evo", cfg("b", "options.lua"), desc("options", "buffer"))
  keymap({ "n" }, "<Leader>ev-o", cfg("h", "options.lua"), desc("options", "split"))
  keymap({ "n" }, "<Leader>ev|o", cfg("v", "options.lua"), desc("options", "vsplit"))

  keymap({ "n" }, "<Leader>evl", cfg("b", "lazy.lua"), desc("file", "buffer"))
  keymap({ "n" }, "<Leader>ev-l", cfg("h", "lazy.lua"), desc("file", "split"))
  keymap({ "n" }, "<Leader>ev|l", cfg("v", "lazy.lua"), desc("file", "vsplit"))

  keymap({ "n" }, "<Leader>eva", cfg("b", "autocmds.lua"), desc("autocmds", "buffer"))
  keymap({ "n" }, "<Leader>ev-a", cfg("h", "autocmds.lua"), desc("autocmds", "split"))
  keymap({ "n" }, "<Leader>ev|a", cfg("v", "autocmds.lua"), desc("autocmds", "vsplit"))
end

vim.keymap.set({ "n" }, "-", ":split<CR>", { desc = "Easy vertical split", silent = true })
vim.keymap.set({ "n" }, "|", ":vsplit<CR>", { desc = "Easy horizontal split", silent = true })

do
  local desc = "Open explorer in root directory"
  vim.keymap.set({ "n" }, "<M-b>", require("i").partial(Snacks.explorer, { cwd = LazyVim.root() }), { desc = desc })
  vim.keymap.set({ "n" }, "<M-e>", require("i").partial(Snacks.explorer, { cwd = LazyVim.root() }), { desc = desc })
end

-- Exit terminal mode in the builtin terminal.
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode.
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Next keymaps/mappings/bindings above.
