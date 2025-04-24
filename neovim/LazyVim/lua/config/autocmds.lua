-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Simplify the creation of autocommand groups.
local ensure_uniq_group = function(name)
  return vim.api.nvim_create_augroup("my-autocmds-" .. name, { clear = true })
end

-- vim.api.nvim_create_autocmd("FileType", {
--   desc = "Run line or selection through external shell and paste output in current buffer",
--   pattern = { "sh" },
--   group = ensure_uniq_group("run-line-or-selection-external-shell"),
--   callback = function()
--     local u = require("utils")
--     -- NOTE: Test with: echo hello world (select "echo hello")
--     -- TODO: Deal with ^M (carriage return) characters. Currently they break the command.
--     u.nmap(
--       "<Leader>ee",
--       ":exec 'r !' . getline('.')<CR>",
--       "Run current line in external shell and paste the output below"
--     )
--     u.vmap("<Leader>E", '"xy:r ! <C-r>x<CR>', "Run selection in external shell and paste the output below")
--   end,
-- })

-- vim.api.nvim_create_autocmd("VimEnter", {
--   desc = "Example",
--   group = ensure_uniq_group("example"),
--   callback = function()
--     -- Do stuff here.
--   end,
-- })

-- vim.api.nvim_create_autocmd("VimEnter", {
--   desc = "Ensure that all required plugins for LSP are installed",
--   group = ensure_uniq_group("ensure-lsp-plugins"),
--   callback = function()
--   end,
-- })
