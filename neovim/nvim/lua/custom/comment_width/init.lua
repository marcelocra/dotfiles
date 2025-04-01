local M = {}

local ts_utils = require 'nvim-treesitter.ts_utils'
local parsers = require 'nvim-treesitter.parsers'

-- Filetype-based fallback patterns if Treesitter or commentstring doesn't cover the language
local fallback_patterns = {
  lua = '^%s*%-%-',
  python = '^%s*#',
  javascript = '^%s*//',
  typescript = '^%s*//',
  c = '^%s*//',
  cpp = '^%s*//',
  sh = '^%s*#',
  bash = '^%s*#',
}

--- Check if the current line is a comment using Treesitter
-- @param bufnr number: Buffer number
-- @param row number: Line number (0-based)
-- @return boolean: true if the line is a comment
function M.is_comment_ts(bufnr, row)
  if not parsers.has_parser() then
    return false
  end

  local lang = parsers.get_buf_lang(bufnr)
  local parser = parsers.get_parser(bufnr, lang)
  if not parser then
    return false
  end

  -- Get the syntax node at the beginning of the line (column 0)
  local node = ts_utils.get_node_at_pos(bufnr, row, 0)
  if not node then
    return false
  end

  -- Traverse upward until we find a comment node or hit the root
  while node do
    if node:type() == 'comment' then
      return true
    end
    node = node:parent()
  end

  return false
end

--- Check if a line is a comment using the commentstring option
-- @param line string: the actual line text
-- @return boolean: true if line matches commentstring
function M.is_comment_by_commentstring(line)
  local cs = vim.bo.commentstring
  if not cs or cs == '' then
    return false
  end

  -- Extract prefix from commentstring format, e.g. "// %s"
  local prefix = cs:match '^(.-)%%s'
  if not prefix then
    return false
  end

  -- Match prefix at beginning of line, ignoring leading whitespace
  return line:match('^%s*' .. vim.pesc(prefix)) ~= nil
end

--- Fallback method using hardcoded filetype → pattern mapping
-- @param line string: the actual line text
-- @return boolean: true if line matches fallback pattern
function M.is_comment_fallback(line)
  local ft = vim.bo.filetype
  local pat = fallback_patterns[ft]
  if not pat then
    return false
  end
  return line:match(pat) ~= nil
end

--- Determine whether the current line is a comment using all strategies
-- @param line string: the line text
-- @return boolean: true if the line is considered a comment
function M.is_comment_line(line)
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1

  return M.is_comment_ts(bufnr, row) or M.is_comment_by_commentstring(line) or M.is_comment_fallback(line)
end

--- Smartly set `textwidth` to 80 if inside a comment, or 0 otherwise
function M.smart_textwidth()
  local line = vim.api.nvim_get_current_line()

  if M.is_comment_line(line) then
    vim.opt_local.textwidth = 80
  else
    vim.opt_local.textwidth = 0
  end
end

--- Attach autocommands to automatically manage textwidth based on comment context
function M.attach_autocmd()
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'TextChanged' }, {
    desc = 'Dynamically adjust textwidth in comments',
    group = vim.api.nvim_create_augroup('dynamic-text-width', { clear = true }),
    pattern = '*',
    callback = function()
      M.smart_textwidth()
    end,
  })
end


return {
  name = 'comment_width',
  lazy = false, -- or true if you want to load on demand
  config = function
    M.attach_autocmd()
  end,
}
