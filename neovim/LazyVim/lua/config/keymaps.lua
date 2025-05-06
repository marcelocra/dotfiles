-- vim: foldmethod=marker foldlevel=1 foldenable
-------------------------------------------------------------------------------
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- LazyVim: Handle embedded terminal and commenting.
do
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
  local opts = { desc = desc, remap = true }

  -- Normal.
  vim.keymap.set({ "n" }, ctrl_underscore, "gcc", opts)
  vim.keymap.set({ "n" }, ctrl_slash, "gcc", opts)
  -- Insert.
  vim.keymap.set({ "i" }, ctrl_underscore, "<Esc>gcc", opts)
  vim.keymap.set({ "i" }, ctrl_slash, "<Esc>gcc", opts)
  -- Visual.
  vim.keymap.set({ "v" }, ctrl_underscore, "gcgv", opts)
  vim.keymap.set({ "v" }, ctrl_slash, "gcgv", opts)
end

-- LazyVim: Open a profiler for debug.
do
  vim.keymap.del("n", "<Leader>dpp")
  vim.keymap.del("n", "<Leader>dph")
  -- vim.keymap.del("n", "<Leader>dps")
end

-------------------------------------------------------------------------------
-- CHANGE LAZYVIM DEFAULTS END }}}
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- NEOVIM AND VSCODE START {{{
--------------------------------------------------------------------------------

-- INFO: Normal and visual mode keymaps might work in VSCode, while insert mode
-- ones most likely won't.

do
  -- NOTE: I tried to use only the LazyVim default shortcut (ctrl+s), but I'm so
  -- used to ,{w,s} that I missed them a LOT. Also, I do believe that they are
  -- faster to type. I used this to try to change the habit:
  --  <Cmd>echo 'Use Ctrl+S instead!'<CR>

  vim.keymap.set({ "n", "v" }, ",w", "<Cmd>w<CR>", { desc = "Save current buffer", silent = true })
  vim.keymap.set({ "i" }, ",w", "<Esc><Cmd>w<CR>", { desc = "Save current buffer and exit INSERT mode", silent = true })
  vim.keymap.set({ "n", "v" }, ",s", "<Cmd>w<CR>", { desc = "Save current buffer", silent = true })
  vim.keymap.set({ "i" }, ",s", "<Esc><Cmd>w<CR>", { desc = "Save current buffer and exit INSERT mode", silent = true })

  vim.keymap.set({ "n", "i", "v" }, ",f", '<Cmd>echo expand("%:p:h")<CR>', { desc = "Print current file folder name" })

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

  vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Move down by visual line", silent = true })
  vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Move up by visual line", silent = true })
  vim.keymap.set({ "n", "v" }, "$", "g$", { desc = "Move to the end of the line", silent = true })
  vim.keymap.set({ "n", "v" }, "0", "g0", { desc = "Move to the beginning of the line", silent = true })

  vim.keymap.set({ "n" }, "gV", "`[v`]", { desc = "Highlight last inserted text." })

  do
    local desc = "Allow fast indenting (>) and unindenting (<) the selected text"
    vim.keymap.set({ "v" }, "<", "<gv", { desc = desc, silent = true })
    vim.keymap.set({ "v" }, ">", ">gv", { desc = desc, silent = true })
  end

  vim.keymap.set({ "n" }, "<C-n>", ":nohlsearch<CR>", { desc = "Clear search highlights", silent = true })

  vim.keymap.set({ "n" }, "<Leader><Leader>", "@q", { desc = "Easily run the macro stored at 'q'" })

  do
    local desc = "Go to previous buffer"
    vim.keymap.set({ "n" }, "<Leader><Leader>", "<Leader>bb", { desc = desc, remap = true, silent = true })
    vim.keymap.set({ "n" }, "<M-l>", "<Leader>bb", { desc = desc, remap = true, silent = true })
  end

  -- Next common keymaps/mappings/bindings for Neovim and VSCode above.
end

--------------------------------------------------------------------------------
-- NEOVIM AND VSCODE END }}}
--------------------------------------------------------------------------------
-- NEOVIM ONLY START {{{
--------------------------------------------------------------------------------

do
  if vim.g.vscode then
    print("Neovim-only code being ignored!")
    return
  end
  print("In Neovim, not in VSCode")

  -- INFO: Don't work in VSCode.
  vim.keymap.set({ "i" }, "jf", "<Esc>", { desc = "Go to normal mode" })
  vim.keymap.set({ "i" }, "fj", "<Esc>", { desc = "Go to normal mode" })

  -- [info] Don't work in VSCode.
  vim.keymap.set({ "n", "i", "v" }, ",d", "<Leader>bd", { desc = "Delete current buffer", silent = true, remap = true })
  vim.keymap.set({ "n", "i", "v" }, ",q", "<Cmd>q<CR>", { desc = "Quit/Close current buffer", silent = true })
  vim.keymap.set({ "n" }, ",,q", "<Leader>qq", { desc = "Quit/Close all buffers", silent = true, remap = true })

  -- Save and quit faster. INFO: Don't work in VSCode.
  vim.keymap.set({ "n", "i" }, ",x", "<Cmd>x<CR>", { desc = "Save and close the current buffer", silent = true })

  -- Reload current file. INFO: Don't work in VSCode.
  vim.keymap.set({ "n", "i" }, ",e", "<Cmd>e<CR>", { desc = "Reload current file", silent = true })

  -- NOTE: It is not possible to have multiple tabs without multiple buffers.
  -- Therefore we can use the BufferLine plugin to manage the tabs and behave as
  -- if they were tabs. Previously: <Cmd>tabprev<CR> | <Cmd>tabnext<CR>
  vim.keymap.set({ "n", "i" }, "<M-j>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Focus on the buffer to the left" })
  vim.keymap.set({ "n", "i" }, "<M-k>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Focus on the buffer to the right" })

  -- INFO: Don't work in VSCode.
  do
    local doc = "Move line or selection down"
    local desc = { desc = doc }

    vim.keymap.set({ "n" }, "<M-Down>", "<Cmd>execute 'move .+' . v:count1<CR>==", desc)
    vim.keymap.set({ "n" }, "<M-S-j>", "<Cmd>execute 'move .+' . v:count1<CR>==", desc)
    vim.keymap.set({ "i" }, "<M-Down>", "<Esc><Cmd>m .+1<CR>==gi", desc)
    vim.keymap.set({ "i" }, "<M-S-j>", "<Esc><Cmd>m .+1<CR>==gi", desc)
    vim.keymap.set({ "v" }, "<M-Down>", ":<C-U>execute \"'<lt>,'>move '>+\" . v:count1<CR>gv=gv", desc)
    vim.keymap.set({ "v" }, "<M-S-j>", ":<C-U>execute \"'<lt>,'>move '>+\" . v:count1<CR>gv=gv", desc)
  end

  -- INFO: Don't work in VSCode.
  do
    local doc = "Move line or selection up"
    local desc = { desc = doc }

    vim.keymap.set({ "n" }, "<M-Up>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", desc)
    vim.keymap.set({ "n" }, "<M-S-k>", "<Cmd>execute 'move .-' . (v:count1 + 1)<CR>==", desc)
    vim.keymap.set({ "i" }, "<M-Up>", "<Esc><Cmd>m .-2<CR>==gi", desc)
    vim.keymap.set({ "i" }, "<M-S-k>", "<Esc><Cmd>m .-2<CR>==gi", desc)
    vim.keymap.set({ "v" }, "<M-Up>", ":<C-U>execute \"'<lt>,'>move '<lt>-\" . (v:count1 + 1)<CR>gv=gv", desc)
    vim.keymap.set({ "v" }, "<M-S-k>", ":<C-U>execute \"'<lt>,'>move '<lt>-\" . (v:count1 + 1)<CR>gv=gv", desc)
  end

  -- Manage colorschemes, particularly changing between light and dark.
  -- INFO: Don't work in VSCode.
  do
    local color = require("mcra.lib.colorscheme")
    local set = color.set
    local toggle = color.toggle

    vim.keymap.set({ "n" }, "<Leader>oct", set(nil), { desc = "Use time-based colorscheme" })
    vim.keymap.set({ "n" }, "<Leader>ocd", set("dark"), { desc = "Set colorscheme to vim.g.colorscheme_mode_dark" })
    vim.keymap.set({ "n" }, "<Leader>ocl", set("light"), { desc = "Set colorscheme to vim.g.colorscheme_mode_light" })
    vim.keymap.set({ "n" }, "<M-d>", toggle, { desc = "Set colorscheme to vim.g.colorscheme_mode_light" })
  end

  -- Doesn't work in terminals. EDIT: Not true. It works in Alacritty without
  -- tmux. INFO: Don't work in VSCode.
  vim.keymap.set({ "n" }, "<C-Tab>", "<Cmd>e #<CR>", { desc = "Easily alternate between the two most recent buffers" })
  -- This one does, but gt might be better. EDIT: actually, gt is for actual
  -- Neovim tabs while this is for buffers. INFO: Don't work in VSCode.
  vim.keymap.set({ "n" }, "<S-Tab>", "<Cmd>e #<CR>", { desc = "Easily alternate between the two most recent buffers" })

  -- INFO: Don't work in VSCode.
  vim.keymap.set({ "n" }, "<Leader>d", "<Leader>xx", { desc = "Toggle the diagnostics window", remap = true })

  -- INFO: Don't work in VSCode.
  vim.keymap.set({ "n" }, "<Leader>mt", function()
    local tasks_file = os.getenv("HOME") .. "/doc/TODO.md"
    vim.cmd("vspl " .. tasks_file)
  end, { desc = "Open my tasks files" })

  -- Insert date or time in current buffer.
  -- INFO: Don't work in VSCode.
  do
    local desc

    -- NOTE: Alternative format: %Y-%m-%d
    desc = "Add date to current buffer in the format 21abr25"
    vim.keymap.set({ "i" }, "<M-d>", '<C-r>=strftime("%d%b%y")<CR>', { desc = desc })

    desc = "Add time to current buffer"
    vim.keymap.set({ "i" }, "<M-t>", '<C-r>=strftime("%Hh%M")<CR>', { desc = desc })
  end

  -- Port some VSCode mappings that I like back to Neovim.
  -- INFO: Not necessary in VSCode.
  do
    vim.keymap.set({ "n" }, "<C-p>", LazyVim.pick.open, { desc = "Fuzzy search for files in current folder" })
    vim.keymap.set({ "n" }, "<C-f>", Snacks.picker.lines, { desc = "Fuzzy search for text in the current buffer" })

    local symbol = require("i").partial(Snacks.picker.lsp_symbols, { filter = LazyVim.config.kind_filter })
    vim.keymap.set({ "n" }, "<C-t>", symbol, { desc = "Fuzzy search for symbols in the current file (buffer)" })

    vim.keymap.set({ "n" }, "<F2>", "<Leader>cr", { desc = "Rename variable", remap = true })
  end

  -- Simplify editing Neovim config files.
  -- INFO: Don't work in VSCode.
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
      return { desc = "Edit Neovim " .. file .. " file in a " .. pos }
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

  -- INFO: Don't work in VSCode.
  vim.keymap.set({ "n" }, "-", ":split<CR>", { desc = "Easy vertical split", silent = true })
  vim.keymap.set({ "n" }, "|", ":vsplit<CR>", { desc = "Easy horizontal split", silent = true })

  -- INFO: Don't work in VSCode.
  do
    local desc = "Create a new terminal in a vertical split"
    vim.keymap.set({ "n" }, "<Leader>tn", "<Cmd>vsplit<CR><Cmd>term<CR>i", { desc = desc })
  end

  -- [info] Doesn't work in VSCode.
  vim.keymap.set({ "n" }, "<S-CR>", "<LocalLeader>ew", { silent = true, remap = true })
  vim.keymap.set({ "n" }, "<M-S-CR>", "<LocalLeader>ew", { silent = true, remap = true })
  vim.keymap.set({ "i" }, "<S-CR>", "<Esc><LocalLeader>ewa", { silent = true, remap = true })
  vim.keymap.set({ "i" }, "<M-S-CR>", "<Esc><LocalLeader>ewa", { silent = true, remap = true })

  vim.keymap.set({ "n" }, "<C-CR>", "<LocalLeader>ee", { silent = true, remap = true })
  vim.keymap.set({ "n" }, "<M-C-CR>", "<LocalLeader>ece", { silent = true, remap = true })
  vim.keymap.set({ "i" }, "<C-CR>", "<Esc><LocalLeader>eea", { silent = true, remap = true })
  vim.keymap.set({ "i" }, "<M-C-CR>", "<Esc><LocalLeader>ecea", { silent = true, remap = true })

  vim.keymap.set({ "n" }, "<M-CR>", "<LocalLeader>er", { silent = true, remap = true })
  vim.keymap.set({ "n" }, "<C-S-M-CR>", "<LocalLeader>ecr", { silent = true, remap = true })
  vim.keymap.set({ "i" }, "<M-CR>", "<Esc><LocalLeader>era", { silent = true, remap = true })
  vim.keymap.set({ "i" }, "<C-S-M-CR>", "<Esc><LocalLeader>ecra", { silent = true, remap = true })

  vim.keymap.set({ "v" }, "<C-CR>", "<LocalLeader>E", { silent = true, remap = true })
  vim.keymap.set({ "v" }, "<M-CR>", "<LocalLeader>e!", { silent = true, remap = true })

  -- Next Neovim-only above.
end

--------------------------------------------------------------------------------
-- NEOVIM ONLY END }}}
--------------------------------------------------------------------------------
-- VSCODE ONLY START {{{
--------------------------------------------------------------------------------

do
  if not vim.g.vscode then
    print("VSCode-only code being ignored!")
    return
  end
  print("In VSCode, not in native Neovim")

  local vscode = require("vscode")
  -- vscode.notify("Hello from Neovim keymaps config!")

  -- WARN: What is necessary for <C-d> to work as expected in VSCode.
  --
  -- The documentation suggests[1] using the keybinding below to have
  -- <C-d> working in all modes, but I couldn't get that to work. I tried the
  -- same thing with <C-a> and <C-n> and they worked, as long as I put them in
  -- the ctrlKeysForNormalMode setting option. But doing the same with <C-d>
  -- wouldn't make it work, I don't know why. In the end, I found a way to send
  -- <C-d> to Neovim through VSCode keybindings[2] and this way it worked! My
  -- keybinding file has the following:
  --
  --    {
  --      "key": "ctrl+d",
  --      "command": "vscode-neovim.send",
  --      "args": "<C-d>",
  --      "when": "editorTextFocus && neovim.mode == 'visual'"
  --    },
  --    {
  --      "key": "ctrl+n",
  --      "command": "editor.action.moveSelectionToNextFindMatch",
  --      "when": "editorTextFocus && editorHasSelection && neovim.mode == 'insert'"
  --    },
  --    {
  --      "key": "ctrl+p",
  --      "command": "editor.action.moveSelectionToPreviousFindMatch",
  --      "when": "editorTextFocus && editorHasSelection && neovim.mode == 'insert'"
  --    },
  --
  -- Links:
  --  [1]: https://github.com/vscode-neovim/vscode-neovim?tab=readme-ov-file#vscodewith_insertcallback
  --  [2]: https://github.com/vscode-neovim/vscode-neovim?tab=readme-ov-file#keybinding-passthroughs

  vim.keymap.set({ "n", "i", "x" }, "<C-d>", function()
    vscode.with_insert(function()
      vscode.action("editor.action.addSelectionToNextFindMatch")
    end)
  end)
  vim.keymap.set({ "n", "i", "x" }, "<C-n>", function()
    vscode.with_insert(function()
      vscode.action("editor.action.addSelectionToNextFindMatch")
    end)
  end)

  -- -- NOTE: See above. This was a test to help debug the problem.
  --
  -- -- It doesn't print the ctrl+a, but otherwise it works as expected, showing
  -- -- the notification and creating a new selection.
  -- vim.keymap.set({ "x" }, "<C-a>", function()
  --   print("ctrl+a in visual mode") -- This never prints.
  --   vscode.notify(vscode.eval("return vscode.window.activeTextEditor.document.fileName"))
  --   vscode.with_insert(function()
  --     vscode.action("editor.action.addSelectionToNextFindMatch")
  --   end)
  -- end)

  -- Next VSCode-only above.
end

--------------------------------------------------------------------------------
-- VSCODE ONLY END }}}
--------------------------------------------------------------------------------
