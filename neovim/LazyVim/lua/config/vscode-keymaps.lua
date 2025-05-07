--
-- VSCode-only Neovim keymaps. This is called from ./keymaps.lua.
--

if not vim.g.vscode then
  error("This file should only be sourced in VSCode Neovim.")
end
print("In VSCode. Activating VSCode-only config.")

-- INFO: Keymaps that are common to Neovim and VSCode should be moved here.
require("config.common-keymaps")

local vscode = require("vscode")

-- INFO: Required config for <C-d> to work with multi-cursors in VSCode in
-- visual mode.
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
--
vim.keymap.set({ "n", "i", "x" }, "<C-d>", function()
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
vscode.notify("Successfully loaded VSCode-specific Neovim keymaps file!")
