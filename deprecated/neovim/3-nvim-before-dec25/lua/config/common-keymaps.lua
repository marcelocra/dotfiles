--
-- Neovim and VSCode common keymaps. This is called from ./keymaps.lua.
--

-- NOTE: I tried to use only the LazyVim default shortcut (ctrl+s), but I'm so
-- used to ,{w,s} that I missed them a LOT. Also, I do believe that they are
-- faster to type. I used this to try to change the habit:
--  <Cmd>echo 'Use Ctrl+S instead!'<CR>

vim.keymap.set({ "n", "v" }, ",w", "<Cmd>w<CR>", { desc = "Save current buffer", silent = true })
vim.keymap.set({ "i" }, ",w", "<Esc><Cmd>w<CR>", { desc = "Save current buffer and exit INSERT mode", silent = true })
vim.keymap.set({ "n", "v" }, ",s", "<Cmd>w<CR>", { desc = "Save current buffer", silent = true })
vim.keymap.set({ "i" }, ",s", "<Esc><Cmd>w<CR>", { desc = "Save current buffer and exit INSERT mode", silent = true })

vim.keymap.set({ "n", "i", "v" }, ",,f", '<Cmd>echo expand("%:p")<CR>', { desc = "Print current file path." })

-- TODO: Figure out why this doesn't select all in some files (e.g. output of
-- fc-list).
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
  { desc = "Clear the last search, erasing from the register ('n' won't work)", silent = true }
)

do
  local doc = "Reminder that I'm using the wrong keyboard layout"
  vim.keymap.set({ "n" }, "Ç", ':echo "Wrong keyboard layout!"<CR>', { desc = doc })
  vim.keymap.set({ "n" }, "ç", ':echo "wrong keyboard layout!"<CR>', { desc = doc })
end

-- vim.keymap.set({"n"}, "/", "/\\v", { desc = "Use normal regex"})
vim.keymap.set(
  { "v" },
  "//",
  "y/\\V<C-r>=escape(@\",'/\\')<CR><CR>",
  { desc = "Search for the currently selected text" }
)

do
  local opts = { desc = "Move by display line", silent = true, remap = true }
  vim.keymap.set({ "n", "v" }, "j", "gj", opts)
  vim.keymap.set({ "n", "v" }, "k", "gk", opts)
  vim.keymap.set({ "n", "v" }, "$", "g$", opts)
  vim.keymap.set({ "n", "v" }, "0", "g0", opts)
end

vim.keymap.set({ "n" }, "gV", "`[v`]", { desc = "Highlight last inserted text." })

do
  local desc = "Allow fast indenting (>) and unindenting (<) the selected text"
  vim.keymap.set({ "v" }, "<", "<gv", { desc = desc, silent = true })
  vim.keymap.set({ "v" }, ">", ">gv", { desc = desc, silent = true })
end

vim.keymap.set({ "n" }, "<C-n>", ":nohlsearch<CR>", { desc = "Clear search highlights", silent = true })

vim.keymap.set({ "n" }, "<Leader><Leader>q", "@q", { desc = "Easily run the macro stored at 'q'", silent = true })

-- Insert date or time in current buffer.
do
  local desc

  -- NOTE: Alternative format: %Y-%m-%d
  desc = "Add date to current buffer in the format 21abr25"
  vim.keymap.set({ "i" }, "<M-d>", '<C-r>=strftime("%d%b%y")<CR>', { desc = desc })

  desc = "Add time to current buffer"
  vim.keymap.set({ "i" }, "<M-t>", '<C-r>=strftime("%Hh%M")<CR>', { desc = desc })
end
