-- init-nvim-vscode.lua
--
-- Settings, keymaps, commands, etc., that works both for Neovim and for VSCode
-- when using the `vscode-neovim` extension.
--
-- For more details and options: https://github.com/vscode-neovim/vscode-neovim
--

-- Save faster.
vim.keymap.set('n', ',w', '<Esc>:w<CR>', { desc = 'Saves the current buffer' })
vim.keymap.set('n', ',s', '<Esc>:w<CR>', { desc = 'Saves the current buffer' })

-- Quit and close buffers faster.
vim.keymap.set('n', ',q', ':q<CR>', { desc = 'Close the current buffer' })
vim.keymap.set('n', ',,q', ':qa<CR>', { desc = 'Close all buffers' })

-- Save and quit faster.
vim.keymap.set('n', ',x', ':x<CR>', { desc = 'Save and close the current buffer' })

-- Reload current file.
vim.keymap.set('n', ',e', ':e<CR>', { desc = 'Reload current file' })

print 'hello vscode-neovim!'
