--
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

-------------------------------------------------------------------------------
-- Remove LazyVim default keymaps.
-------------------------------------------------------------------------------

-- Open the file explorer. New: <M-b>.
vim.keymap.del("n", "<Leader>e")

-- Open terminal inside Neovim. New: No keymap, run :term.
vim.keymap.del("n", "<C-_>")

-- Open a profiler for debug.
vim.keymap.del("n", "<Leader>dpp")
vim.keymap.del("n", "<Leader>dph")
vim.keymap.del("n", "<Leader>dps")

-------------------------------------------------------------------------------
-- Actual mappings.
-------------------------------------------------------------------------------

vim.keymap.set({ "i" }, "jf", "<Esc>", { desc = "Go to normal mode" })
vim.keymap.set({ "i" }, "fj", "<Esc>", { desc = "Go to normal mode" })

-- INFO: Previously: <Cmd>w<CR>
vim.keymap.set(
  { "n", "i" },
  ",w",
  "<Cmd>echo 'Use Ctrl+S instead!'<CR>",
  { desc = "Saves the current buffer. If in INSERT mode, exits it" }
)

vim.keymap.set(
  { "n", "i" },
  ",s",
  "<Cmd>echo 'Use Ctrl+S instead!'<CR>",
  { desc = "Saves the current buffer. If in INSERT mode, exits it" }
)

vim.keymap.set({ "n" }, ",q", "<Cmd>q<CR>", { desc = "Quit/Close current buffer" })
vim.keymap.set({ "n" }, ",,q", "<Leader>qq", { desc = "Quit/Close all buffers", remap = true })

-- Save and quit faster.
vim.keymap.set({ "n" }, ",x", ":x<CR>", { desc = "Save and close the current buffer" })
vim.keymap.set({ "i" }, ",x", "<Esc>:x<CR>", { desc = "Save and close the current buffer" })

-- Reload current file.
vim.keymap.set({ "n", "i" }, ",e", "<Cmd>e<CR>", { desc = "Reload current file" })

-- NOTE: It is not possible to have multiple tabs without multiple buffers.
-- Therefore we can use the BufferLine plugin to manage the tabs and behave as
-- if they were tabs. Previously: <Cmd>tabprev<CR> | <Cmd>tabnext<CR>

vim.keymap.set({ "n", "i" }, "<M-j>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Focus on the buffer to the left" })
vim.keymap.set({ "n", "i" }, "<M-k>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Focus on the buffer to the right" })

require("mcra.lib.utils").fn("Move line or selection down", function(doc)
  local desc = { desc = doc }

  vim.keymap.set({ "n" }, "<M-Down>", "<Cmd>execute 'move .+' . v:count1<CR>==", desc)
  vim.keymap.set({ "n" }, "<M-S-j>", "<Cmd>execute 'move .+' . v:count1<CR>==", desc)

  vim.keymap.set({ "i" }, "<M-Down>", "<Esc><Cmd>m .+1<CR>==gi", desc)
  vim.keymap.set({ "i" }, "<M-S-j>", "<Esc><Cmd>m .+1<CR>==gi", desc)

  vim.keymap.set({ "v" }, "<M-Down>", ":<C-U>execute \"'<lt>,'>move '>+\" . v:count1<CR>gv=gv", desc)
  vim.keymap.set({ "v" }, "<M-S-j>", ":<C-U>execute \"'<lt>,'>move '>+\" . v:count1<CR>gv=gv", desc)
end)

require("mcra.lib.utils").fn("Move line or selection doc", function(doc)
  local desc = { desc = doc }

  vim.keymap.set({ "n" }, "<M-Up>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", desc)
  vim.keymap.set({ "n" }, "<M-S-k>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", desc)
  vim.keymap.set({ "i" }, "<M-Up>", "<Esc><Cmd>m .-2<CR>==gi", desc)
  vim.keymap.set({ "i" }, "<M-S-k>", "<Esc><Cmd>m .-2<CR>==gi", desc)
  vim.keymap.set({ "v" }, "<M-Up>", ":<C-U>execute \"'<lt>,'>move '<lt>-\" . (v:count1 + 1)<CR>gv=gv", desc)
  vim.keymap.set({ "v" }, "<M-S-k>", ":<C-U>execute \"'<lt>,'>move '<lt>-\" . (v:count1 + 1)<CR>gv=gv", desc)
end)

vim.keymap.set({ "n" }, ",f", ':echo expand("%:p:h")<CR>', { desc = "Print current file folder name" })

vim.keymap.set({ "n" }, ",a", "ggVG", { desc = "Select all the buffer content" })
vim.keymap.set({ "i" }, ",a", "<Esc>ggVG", { desc = "Select all the buffer content" })

-- `_` is the blackhole register.
-- NOTE: Doesn't work when selecting one char at the very end of a line. In
-- those cases, add a space before pasting.
vim.keymap.set({ "v" }, "p", '"_dP', { desc = "Avoid replacing the clipboard content when pasting" })

vim.keymap.set(
  { "n" },
  ",,cl",
  ':let @/ = ""<CR>',
  { desc = "Clear the last search, erasing from the register ('n' won't work)" }
)

require("mcra.lib.utils").fn("Reminder that I'm using the wrong keyboard layout", function(doc)
  vim.keymap.set({ "n" }, "Ç", ':echo "Wrong keyboard layout!"<CR>', { desc = doc })
  vim.keymap.set({ "n" }, "ç", ':echo "wrong keyboard layout!"<CR>', { desc = doc })
end)

require("mcra.lib.utils").fn("Insert date or time in current buffer", function()
  local desc

  -- NOTE: Alternative format: %Y-%m-%d
  desc = "Add date to current buffer in the format 21abr25"
  vim.keymap.set({ "i" }, "<M-d>", '<C-r>=strftime("%d%b%y")<CR>', { desc = desc })

  desc = "Add time to current buffer"
  vim.keymap.set({ "i" }, "<M-t>", '<C-r>=strftime("%Hh%M")<CR>', { desc = desc })
end)

-- vim.keymap.set({"n"}, "/", "/\\v", { desc = "Use normal regex"})
vim.keymap.set(
  { "v" },
  "//",
  "y/\\V<C-r>=escape(@\",'/\\')<CR><CR>",
  { desc = "Search for the currently selected text" }
)

vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Move down by visual line" })
vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Move up by visual line" })
vim.keymap.set({ "n", "v" }, "$", "g$", { desc = "Move to the end of the line" })
vim.keymap.set({ "n", "v" }, "0", "g0", { desc = "Move to the beginning of the line" })

vim.keymap.set({ "n" }, "gV", "`[v`]", { desc = "Highlight last inserted text." })

vim.keymap.set({ "v" }, "<", "<gv", { desc = "Allow fast indenting when there is a chunck of text selected" })
vim.keymap.set({ "v" }, ">", ">gv", { desc = "Allow fast unindenting when there is a chunck of text selected" })

vim.keymap.set({ "n" }, "<C-n>", ":nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set({ "n", "i", "v" }, "<C-_>", "<Cmd>Commentary<CR>", { desc = "Comment and uncomment line or selection" })

require("mcra.lib.utils").fn("Manage colorschemes, particularly changing between light and dark.", function()
  local color = require("mcra.lib.colorscheme")
  local set = color.set
  local toggle = color.toggle

  vim.keymap.set({ "n" }, "<Leader>oct", set(nil), { desc = "Use time-based colorscheme" })
  vim.keymap.set({ "n" }, "<Leader>ocd", set("dark"), { desc = "Set colorscheme to vim.g.colorscheme_mode_dark" })
  vim.keymap.set({ "n" }, "<Leader>ocl", set("light"), { desc = "Set colorscheme to vim.g.colorscheme_mode_light" })
  vim.keymap.set({ "n" }, "<M-d>", toggle, { desc = "Set colorscheme to vim.g.colorscheme_mode_light" })
end)

vim.keymap.set(
  { "n" },
  "<M-b>",
  require("mcra.lib.utils").partial(Snacks.explorer, { cwd = LazyVim.root() }),
  { desc = "Open explorer in root directory" }
)
vim.keymap.set(
  { "n" },
  "<M-e>",
  require("mcra.lib.utils").partial(Snacks.explorer, { cwd = LazyVim.root() }),
  { desc = "Open explorer in root directory" }
)

vim.keymap.set({ "n" }, "<C-Tab>", "<Cmd>e #<CR>", { desc = "Easily alternate between the two most recent buffers" }) -- Doesn't work in terminals.
vim.keymap.set({ "n" }, "<S-Tab>", "<Cmd>e #<CR>", { desc = "Easily alternate between the two most recent buffers" }) -- This one does, but gt might be better.
vim.keymap.set(
  { "n" },
  "<Leader><Leader>",
  "<Leader>bb",
  { desc = "Easily alternate between the two most recent buffers", remap = true }
)

vim.keymap.set({ "n" }, "<Leader>d", "<Leader>xx", { desc = "Toggle the diagnostics window", remap = true })

vim.keymap.set({ "n" }, "<Leader>mt", function()
  local tasks_file = vim.fn.resolve(os.getenv("HOME") .. "/TODO.md")
  vim.cmd("vspl " .. tasks_file)
end, { desc = "Open my tasks files" })

-- INFO: Native in LazyVim: <Leader>uw
-- vim.keymap.set({"n", "i"}, "<M-w>", "<Esc>set wrap!<CR>", { desc = "Toggle line wrapping", silent = false })

--------------------------------------------------------------------------------
-- Next keymap/mapping/keybinding for Neovim AND VSCode above.
--------------------------------------------------------------------------------

require("mcra.lib.utils").fn("Mappings for when inside Neovim ONLY!", function(_, u)
  if vim.g.vscode then
    print("In VSCode, not in native Neovim")
    return
  end
  print("In Neovim, not in VSCode")

  vim.keymap.set({ "n" }, "<C-p>", LazyVim.pick.open, { desc = "Fuzzy search for files in current folder" })
  vim.keymap.set({ "n" }, "<C-f>", Snacks.picker.lines, { desc = "Fuzzy search for text in the current buffer" })
  vim.keymap.set(
    { "n" },
    "<C-t>",
    u.partial(Snacks.picker.lsp_symbols, { filter = LazyVim.config.kind_filter }),
    { desc = "Fuzzy search for symbols in the current file (buffer)" }
  )
  vim.keymap.set({ "n" }, "<F2>", "<Leader>cr", { desc = "Rename variable", remap = true })

  require("mcra.lib.utils").fn("Simplify editing Neovim config files", function(_, u)
    local keymap = vim.keymap.set

    ---
    --- Use the given `cmd` to open the file `name`, changing the local working directory to the Neovim config folder.
    ---
    --- @param cmd string: Command to open the file. Shortcuts: b (buffer), h (horizontal split), v (vertical split).
    --- @param name string: Name of the file to open. It should be in 'lua/config' folder.
    --- @return string: Command to open the file.
    local cfg = function(cmd, name)
      local cmds = { b = ":e ", h = ":spl ", v = ":vspl " }

      cmd = cmds[cmd] or ":e "
      return cmd .. u.vimrc_folder .. "/lua/config/" .. name .. "<CR>:lcd " .. u.vimrc_folder .. "<CR>"
    end

    keymap({ "n" }, "<Leader>evk", cfg("b", "keymaps.lua"), { desc = "Edit Neovim keymaps file in a buffer" })
    keymap({ "n" }, "<Leader>ev-k", cfg("h", "keymaps.lua"), { desc = "Edit Neovim keymaps file in a split" })
    keymap({ "n" }, "<Leader>ev|k", cfg("v", "keymaps.lua"), { desc = "Edit Neovim keymaps file in a vsplit" })

    keymap({ "n" }, "<Leader>evo", cfg("b", "options.lua"), { desc = "Edit Neovim options file in a buffer" })
    keymap({ "n" }, "<Leader>ev-o", cfg("h", "options.lua"), { desc = "Edit Neovim options file in a split" })
    keymap({ "n" }, "<Leader>ev|o", cfg("v", "options.lua"), { desc = "Edit Neovim options file in a vsplit" })

    keymap({ "n" }, "<Leader>evl", cfg("b", "lazy.lua"), { desc = "Edit LazyVim file in a buffer" })
    keymap({ "n" }, "<Leader>ev-l", cfg("h", "lazy.lua"), { desc = "Edit LazyVim file in a split" })
    keymap({ "n" }, "<Leader>ev|l", cfg("v", "lazy.lua"), { desc = "Edit LazyVim file in a vsplit" })

    keymap({ "n" }, "<Leader>eva", cfg("b", "autocmds.lua"), { desc = "Edit Neovim autocmds file in a buffer" })
    keymap({ "n" }, "<Leader>ev-a", cfg("h", "autocmds.lua"), { desc = "Edit Neovim autocmds file in a split" })
    keymap({ "n" }, "<Leader>ev|a", cfg("v", "autocmds.lua"), { desc = "Edit Neovim autocmds file in a vsplit" })
  end)

  vim.keymap.set({ "n" }, "-", ":split<CR>", { desc = "Easy vertical split" })
  vim.keymap.set({ "n" }, "|", ":vsplit<CR>", { desc = "Easy horizontal split" })

  --------------------------------------------------------------------------------
  -- Next keymap/mapping/keybinding for Neovim ONLY above.
  --------------------------------------------------------------------------------
end)

require("mcra.lib.utils").fn("Mappings for when inside VSCode ONLY!", function()
  if not vim.g.vscode then
    print("In Neovim, not in VSCode")
    return
  end
  print("In VSCode, not in native Neovim")

  -- vim.keymap.del({ "n", "i", "x" }, "<C-d>")
  vim.keymap.set({ "n", "i", "x" }, "<C-d>", function()
    local vscode = require("vscode")
    vscode.with_insert(function()
      vscode.action("editor.action.addSelectionToNextFindMatch")
    end)
  end)

  --------------------------------------------------------------------------------
  -- Next keymap/mapping/keybinding for VSCode ONLY above.
  --------------------------------------------------------------------------------
end)
