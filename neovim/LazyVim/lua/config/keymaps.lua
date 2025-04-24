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
-- Setup and helpers functions.
-------------------------------------------------------------------------------

require("mcra.run").run(nil, {}, function(_, _, utils)
  local nmap = utils.nmap
  local imap = utils.imap
  local vmap = utils.vmap
  local nimap = utils.nimap
  local nvmap = utils.nvmap
  local nivmap = utils.nivmap

  local run = require("mcra.run").run

  run("Go to normal mode", { key = "<Esc>" }, function(doc, opts, _)
    imap("jf", opts.key, doc)
    imap("fj", opts.key, doc)
  end)

  local use_lazyvim_mappings = function(keys)
    return "<Cmd>echo 'Use " .. keys .. " instead!'<CR>"
  end

  local doc, cmd

  -- INFO: Previously: <Cmd>w<CR>
  doc = "Saves the current buffer. If in INSERT mode, exits it"
  cmd = use_lazyvim_mappings("Ctrl+S")
  nimap(",w", cmd, doc)
  nimap(",s", cmd, doc)

  nmap(",q", "<Cmd>q<CR>", "Quit/Close current buffer")
  nmap(",,q", "<Leader>qq", "Quit/Close all buffers", { remap = true })

  -- Save and quit faster.
  nmap(",x", ":x<CR>", "Save and close the current buffer")
  imap(",x", "<Esc>:x<CR>", "Save and close the current buffer")

  -- Reload current file.
  nmap(",e", ":e<CR>", "Reload current file")
  imap(",e", "<Esc>:e<CR>", "Reload current file")

  -- Port my most used mappings from VSCode.
  nmap("<C-p>", function()
    LazyVim.pick.open()
  end, "Fuzzy search for files in current folder", { vscode = false })
  nmap("<C-f>", function()
    Snacks.picker.lines()
  end, "Fuzzy search for text in the current buffer", { vscode = false })
  nmap("<C-t>", function()
    Snacks.picker.lsp_symbols({ filter = LazyVim.config.kind_filter })
  end, "Fuzzy search for symbols in the current file (buffer)", { vscode = false })
  nmap("<F2>", "<Leader>cr", "Rename variable", { remap = true })

  -- NOTE: It is not possible to have multiple tabs without multiple buffers.
  -- Therefore we can use the BufferLine plugin to manage the tabs and behave
  -- as if they were tabs. Previous config:
  -- doc = docfn("Focus on the tab to the")
  -- inmap("<M-j>", "<Cmd>tabprev<CR>", doc("left"))
  -- inmap("<M-k>", "<Cmd>tabnext<CR>", doc("right"))
  nimap("<M-j>", "<Cmd>BufferLineCyclePrev<CR>", "Move to the left tab")
  nimap("<M-k>", "<Cmd>BufferLineCycleNext<CR>", "Move to the right tab")

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
    return utils.vimrc_folder .. "/lua/config/" .. name .. "<CR>:lcd " .. utils.vimrc_folder .. "<CR>"
  end
  local cmds = { open = ":e ", spl = ":spl ", vsp = ":vspl " }
  edit_nvim_file = edit_nvim_common("keymaps.lua")
  nmap("<Leader>evk", cmds.open .. edit_nvim_file, doc, { vscode = false })
  nmap("<Leader>ev-k", cmds.spl .. edit_nvim_file, doc, { vscode = false })
  nmap("<Leader>ev|k", cmds.vsp .. edit_nvim_file, doc, { vscode = false })
  edit_nvim_file = edit_nvim_common("options.lua")
  nmap("<Leader>evo", cmds.open .. edit_nvim_file, doc, { vscode = false })
  nmap("<Leader>ev-o", cmds.spl .. edit_nvim_file, doc, { vscode = false })
  nmap("<Leader>ev|o", cmds.vsp .. edit_nvim_file, doc, { vscode = false })
  edit_nvim_file = edit_nvim_common("lazy.lua")
  nmap("<Leader>evl", cmds.open .. edit_nvim_file, doc, { vscode = false })
  nmap("<Leader>ev-l", cmds.spl .. edit_nvim_file, doc, { vscode = false })
  nmap("<Leader>ev|l", cmds.vsp .. edit_nvim_file, doc, { vscode = false })
  edit_nvim_file = edit_nvim_common("autocmds.lua")
  nmap("<Leader>eva", cmds.open .. edit_nvim_file, doc, { vscode = false })
  nmap("<Leader>ev-a", cmds.spl .. edit_nvim_file, doc, { vscode = false })
  nmap("<Leader>ev|a", cmds.vsp .. edit_nvim_file, doc, { vscode = false })

  doc = "Select the whole file content"
  nmap(",a", "ggVG", doc)
  imap(",a", "<Esc>ggVG", doc)

  nmap("-", ":split<CR>", "Easy vertical split", { vscode = false })
  nmap("|", ":vsplit<CR>", "Easy horizontal split", { vscode = false })

  -- `_` is the blackhole register.
  -- NOTE: Doesn't work when selecting one char at the very end of a line. In
  -- those cases, add a space before pasting.
  vmap("p", '"_dP', "Avoid replacing the clipboard content when pasting")

  doc = "Clear the last search, erasing from the register ('n' won't work)"
  nmap(",,cl", ':let @/ = ""<CR>', doc)

  doc = "Reminder that I'm using the wrong keyboard layout"
  nmap("Ç", ':echo "Wrong keyboard layout!"<CR>', doc)
  nmap("ç", ':echo "wrong keyboard layout!"<CR>', doc)

  -- <Leader>uw
  -- nmap("<M-w>", ":set wrap!<CR>", "Toggle line wrapping", { vscode = false, silent = false })

  -- NOTE: Alternative format: %Y-%m-%d
  imap("<M-d>", '<C-r>=strftime("%d%b%y")<CR>', "Add date to current buffer in the format 21abr25")
  imap("<M-t>", '<C-r>=strftime("%Hh%M")<CR>', "Add time to current buffer")

  -- nmap("/", "/\\v", "Use normal regex")
  vmap("//", "y/\\V<C-r>=escape(@\",'/\\')<CR><CR>", "Search for the currently selected text")

  nvmap("j", "gj", "Move down by visual line")
  nvmap("k", "gk", "Move up by visual line")
  nvmap("$", "g$", "Move to the end of the line")
  nvmap("0", "g0", "Move to the beginning of the line")

  nmap("gV", "`[v`]", "Highlight last inserted text.")

  vmap("<", "<gv", "Allow fast indenting when there is a chunck of text selected")
  vmap(">", ">gv", "Allow fast unindenting when there is a chunck of text selected")

  nmap("<C-n>", ":nohlsearch<CR>", "Clear search highlights")

  nivmap("<C-_>", "<Cmd>Commentary<CR>", "Comment and uncomment line or selection")

  local colorscheme_init = require("colorscheme-init")
  nmap("<Leader>oct", colorscheme_init.set(nil), "Use time-based colorscheme")
  nmap("<Leader>ocd", colorscheme_init.set("dark"), "Set colorscheme to vim.g.colorscheme_mode_dark")
  nmap("<Leader>ocl", colorscheme_init.set("light"), "Set colorscheme to vim.g.colorscheme_mode_light")
  nmap("<M-d>", colorscheme_init.toggle, "Set colorscheme to vim.g.colorscheme_mode_light")

  require("mcra.run").run("Open explorer in root directory", { cwd = LazyVim.root() }, function(doc, opts, u)
    u.nmap("<M-b>", u.partial(Snacks.explorer, opts), doc)
    u.nmap("<M-e>", u.partial(Snacks.explorer, opts), doc)
  end)

  require("mcra.run").run(
    "Easily alternate between the two most recent buffers",
    { key = "<Cmd>e #<CR>" },
    function(doc, opts, u)
      u.nmap("<C-Tab>", opts.key, doc) -- Doesn't work in terminals.
      u.nmap("<S-Tab>", opts.key, doc) -- This one does, but gt might be better.
      u.nmap("<Leader><Leader>", "<Leader>bb", doc, { remap = true })
    end
  )

  nmap("<Leader>d", "<Leader>xx", "Toggle the diagnostics window", { remap = true })

  nmap(
    "<Leader>mt",
    utils.call_fn(function()
      local tasks_file = vim.fn.resolve(os.getenv("MCRA_MONOREPO") .. "/todo.md")
      vim.cmd("vspl " .. tasks_file)
    end),
    "Open my tasks files"
  )
end)

-- Next keymap/mapping/keybinding.
