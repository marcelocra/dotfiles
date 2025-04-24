-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Simplify the creation of autocommand groups.
local ensure_uniq_group = function (name)
  return vim.api.nvim_create_augroup("my-autocmds-" .. name, { clear = true })
end

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
