-------------------------------------------------------------------------------
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-------------------------------------------------------------------------------
-- CHANGE SOME LAZYVIM DEFAULTS
-------------------------------------------------------------------------------

-- LazyVim: Open the file explorer
----------------------------------
vim.keymap.del("n", "<Leader>e")
vim.keymap.set(
  { "n" },
  "<M-b>",
  require("i").partial(Snacks.explorer, { cwd = LazyVim.root() }),
  { desc = "Open explorer in root directory" }
)
vim.keymap.set(
  { "n" },
  "<M-e>",
  require("i").partial(Snacks.explorer, { cwd = LazyVim.root() }),
  { desc = "Open explorer in root directory" }
)

-- LazyVim: Open/Close Neovim embedded terminal
-- New: <M-/>
-----------------------------------------------
-- NOTE: <C-_> is <C-/>. Also, I use it to comment code mostly in visual mode,
-- so I'll keep the default on for now. Edit: I immediately missed commenting
-- code with Ctrl-/ and reversed this..
-- NOTE: Remove (and add) <C-/> too, as it seems like the other one doesn't work
-- in Wezterm.
vim.keymap.del({ "n", "t" }, "<C-_>")
vim.keymap.del({ "n", "t" }, "<C-/>")
vim.keymap.set("n", "<C-`>", function()
  Snacks.terminal(nil, { cwd = LazyVim.root(), win = { position = "right" } })
end, { desc = "Terminal (Root Dir)" })
vim.keymap.set("t", "<C-`>", "<Cmd>close<CR>", { desc = "Close terminal" })

-- NOTE: Add both because some terminals might not recognize one or the other.
-- Wezterm doesn't recognize <C-_> but recognizes <C-/>.
-- Alacritty recognizes <C-_>.
vim.keymap.set({ "n" }, "<C-_>", "gcc", { desc = "Comment and uncomment line or selection", remap = true })
vim.keymap.set({ "n" }, "<C-/>", "gcc", { desc = "Comment and uncomment line or selection", remap = true })
vim.keymap.set({ "i" }, "<C-_>", "<Esc>gcc", { desc = "Comment and uncomment line or selection", remap = true })
vim.keymap.set({ "i" }, "<C-/>", "<Esc>gcc", { desc = "Comment and uncomment line or selection", remap = true })
vim.keymap.set({ "v" }, "<C-_>", "gcgv", { desc = "Comment and uncomment line or selection", remap = true })
vim.keymap.set({ "v" }, "<C-/>", "gcgv", { desc = "Comment and uncomment line or selection", remap = true })

-- LazyVim: Open a profiler for debug
-------------------------------------
vim.keymap.del("n", "<Leader>dpp")
vim.keymap.del("n", "<Leader>dph")
vim.keymap.del("n", "<Leader>dps")

--------------------------------------------------------------------------------
-- NEOVIM AND VSCODE START
--------------------------------------------------------------------------------

-- Next here.

--------------------------------------------------------------------------------
-- NEOVIM AND VSCODE END
--------------------------------------------------------------------------------
-- NEOVIM ONLY START
--------------------------------------------------------------------------------

require("i").run("NEOVIM ONLY!", function(_, u)
  if vim.g.vscode then
    print("Neovim-only code being ignored!")
    return
  end
  print("In Neovim, not in VSCode")

  vim.keymap.set({ "i" }, "jf", "<Esc>", { desc = "Go to normal mode" })
  vim.keymap.set({ "i" }, "fj", "<Esc>", { desc = "Go to normal mode" })

  -- NOTE: I tried to use only the LazyVim default shortcut (ctrl+s), but I'm so
  -- used to ,{w,s} that I missed them a LOT. Also, I do believe that they are
  -- faster to type. I used this to try to change the habit:
  -- <Cmd>echo 'Use Ctrl+S instead!'<CR>
  vim.keymap.set({ "n", "v" }, ",w", "<Cmd>w<CR>", { desc = "Save current buffer" })
  vim.keymap.set({ "i" }, ",w", "<Esc><Cmd>w<CR>", { desc = "Save current buffer and exit INSERT mode" })
  vim.keymap.set({ "n", "v" }, ",s", "<Cmd>w<CR>", { desc = "Save current buffer" })
  vim.keymap.set({ "i" }, ",s", "<Esc><Cmd>w<CR>", { desc = "Save current buffer and exit INSERT mode" })

  vim.keymap.set({ "n", "i" }, ",q", "<Cmd>q<CR>", { desc = "Quit/Close current buffer" })
  vim.keymap.set({ "n" }, ",,q", "<Leader>qq", { desc = "Quit/Close all buffers", remap = true })

  -- Save and quit faster.
  vim.keymap.set({ "n", "i" }, ",x", "<Cmd>x<CR>", { desc = "Save and close the current buffer" })

  -- Reload current file.
  vim.keymap.set({ "n", "i" }, ",e", "<Cmd>e<CR>", { desc = "Reload current file" })

  -- NOTE: It is not possible to have multiple tabs without multiple buffers.
  -- Therefore we can use the BufferLine plugin to manage the tabs and behave as
  -- if they were tabs. Previously: <Cmd>tabprev<CR> | <Cmd>tabnext<CR>
  vim.keymap.set({ "n", "i" }, "<M-j>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Focus on the buffer to the left" })
  vim.keymap.set({ "n", "i" }, "<M-k>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Focus on the buffer to the right" })

  require("i").run("Move line or selection down", function(doc)
    local desc = { desc = doc }

    vim.keymap.set({ "n" }, "<M-Down>", "<Cmd>execute 'move .+' . v:count1<CR>==", desc)
    vim.keymap.set({ "n" }, "<M-S-j>", "<Cmd>execute 'move .+' . v:count1<CR>==", desc)

    vim.keymap.set({ "i" }, "<M-Down>", "<Esc><Cmd>m .+1<CR>==gi", desc)
    vim.keymap.set({ "i" }, "<M-S-j>", "<Esc><Cmd>m .+1<CR>==gi", desc)

    vim.keymap.set({ "v" }, "<M-Down>", ":<C-U>execute \"'<lt>,'>move '>+\" . v:count1<CR>gv=gv", desc)
    vim.keymap.set({ "v" }, "<M-S-j>", ":<C-U>execute \"'<lt>,'>move '>+\" . v:count1<CR>gv=gv", desc)
  end)

  require("i").run("Move line or selection doc", function(doc)
    local desc = { desc = doc }

    vim.keymap.set({ "n" }, "<M-Up>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", desc)
    vim.keymap.set({ "n" }, "<M-S-k>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", desc)
    vim.keymap.set({ "i" }, "<M-Up>", "<Esc><Cmd>m .-2<CR>==gi", desc)
    vim.keymap.set({ "i" }, "<M-S-k>", "<Esc><Cmd>m .-2<CR>==gi", desc)
    vim.keymap.set({ "v" }, "<M-Up>", ":<C-U>execute \"'<lt>,'>move '<lt>-\" . (v:count1 + 1)<CR>gv=gv", desc)
    vim.keymap.set({ "v" }, "<M-S-k>", ":<C-U>execute \"'<lt>,'>move '<lt>-\" . (v:count1 + 1)<CR>gv=gv", desc)
  end)

  vim.keymap.set({ "n" }, ",f", ':echo expand("%:p:h")<CR>', { desc = "Print current file folder name" })

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
    { desc = "Clear the last search, erasing from the register ('n' won't work)" }
  )

  require("i").run("Reminder that I'm using the wrong keyboard layout", function(doc)
    vim.keymap.set({ "n" }, "Ç", ':echo "Wrong keyboard layout!"<CR>', { desc = doc })
    vim.keymap.set({ "n" }, "ç", ':echo "wrong keyboard layout!"<CR>', { desc = doc })
  end)

  require("i").run("Insert date or time in current buffer", function()
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

  vim.keymap.set({ "n" }, "<C-n>", ":nohlsearch<CR>", { desc = "Clear search highlights", silent = true })

  require("i").run("Manage colorschemes, particularly changing between light and dark.", function()
    local color = require("mcra.lib.colorscheme")
    local set = color.set
    local toggle = color.toggle

    vim.keymap.set({ "n" }, "<Leader>oct", set(nil), { desc = "Use time-based colorscheme" })
    vim.keymap.set({ "n" }, "<Leader>ocd", set("dark"), { desc = "Set colorscheme to vim.g.colorscheme_mode_dark" })
    vim.keymap.set({ "n" }, "<Leader>ocl", set("light"), { desc = "Set colorscheme to vim.g.colorscheme_mode_light" })
    vim.keymap.set({ "n" }, "<M-d>", toggle, { desc = "Set colorscheme to vim.g.colorscheme_mode_light" })
  end)

  -- Doesn't work in terminals.
  vim.keymap.set({ "n" }, "<C-Tab>", "<Cmd>e #<CR>", { desc = "Easily alternate between the two most recent buffers" })
  -- This one does, but gt might be better.
  -- NOTE: actually, gt is for actual Neovim tabs while this is for buffers.
  vim.keymap.set({ "n" }, "<S-Tab>", "<Cmd>e #<CR>", { desc = "Easily alternate between the two most recent buffers" })
  -- vim.keymap.set({ "n" }, "<Leader><Leader>", "@q", { desc = "Easily run the macro stored at 'q'" })
  vim.keymap.set(
    { "n" },
    "<Leader><Leader>",
    "<Leader>bb",
    { desc = "Easily run the macro stored at 'q'", remap = true }
  )

  vim.keymap.set({ "n" }, "<Leader>d", "<Leader>xx", { desc = "Toggle the diagnostics window", remap = true })

  vim.keymap.set({ "n" }, "<Leader>mt", function()
    local tasks_file = vim.fn.resolve(os.getenv("HOME") .. "/docs/TODO.md")
    vim.cmd("vspl " .. tasks_file)
  end, { desc = "Open my tasks files" })

  -- INFO: Native in LazyVim: <Leader>uw
  -- vim.keymap.set({"n", "i"}, "<M-w>", "<Esc>set wrap!<CR>", { desc = "Toggle line wrapping", silent = false })

  vim.keymap.set({ "n" }, "<C-p>", LazyVim.pick.open, { desc = "Fuzzy search for files in current folder" })
  vim.keymap.set({ "n" }, "<C-f>", Snacks.picker.lines, { desc = "Fuzzy search for text in the current buffer" })
  vim.keymap.set(
    { "n" },
    "<C-t>",
    u.partial(Snacks.picker.lsp_symbols, { filter = LazyVim.config.kind_filter }),
    { desc = "Fuzzy search for symbols in the current file (buffer)" }
  )
  vim.keymap.set({ "n" }, "<F2>", "<Leader>cr", { desc = "Rename variable", remap = true })

  require("i").run("Simplify editing Neovim config files", function(_, u)
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

  vim.keymap.set(
    { "n" },
    "<Leader>tn",
    "<Cmd>vsplit<CR><Cmd>term<CR>i",
    { desc = "Create a new terminal in a vertical split" }
  )

  -- Next Neovim above.
end)

--------------------------------------------------------------------------------
-- NEOVIM ONLY END
--------------------------------------------------------------------------------
-- VSCODE ONLY START
--------------------------------------------------------------------------------

require("i").run("VSCODE ONLY!", function()
  if not vim.g.vscode then
    print("VSCode-only code being ignored!")
    return
  end
  print("In VSCode, not in native Neovim")

  local vscode = require("vscode")
  -- vscode.notify("Hello from Neovim keymaps config!")

  -- TODO: Figure out why this is not working when the same thing for a
  -- different mapping (below) works.
  --
  -- vim.keymap.del({ "n", "i", "x" }, "<C-d>")
  vim.keymap.set({ "n", "i", "x" }, "<C-d>", function()
    vscode.with_insert(function()
      vscode.action("editor.action.addSelectionToNextFindMatch")
    end)
  end)

  -- -- NOTE: See above. This was a test to help debug the problem.
  -- -- It doesn't print the ctrl+a, but otherwise it works as expected, showing
  -- -- the notification and creating a new selection.
  -- vim.keymap.set({ "x" }, "<C-a>", function()
  --   print("ctrl+a in visual mode") -- This never prints.
  --   vscode.notify(vscode.eval("return vscode.window.activeTextEditor.document.fileName"))
  --   vscode.with_insert(function()
  --     vscode.action("editor.action.addSelectionToNextFindMatch")
  --   end)
  -- end)

  -- Next VSCode above.
end)

--------------------------------------------------------------------------------
-- VSCODE ONLY END
--------------------------------------------------------------------------------
