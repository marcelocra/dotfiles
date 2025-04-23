-- ───────────────────────────────────────────────────────────────
-- 1) Configure your widths up front
-- ───────────────────────────────────────────────────────────────
-- vim.opt.textwidth = 80 -- code wrap width. Leave to EditorConfig
vim.g.comment_wrap_textwidth = 60 -- comment wrap width
-- store your normal width for later
vim.g.default_textwidth = vim.opt.textwidth:get()

-- ───────────────────────────────────────────────────────────────
-- 2) Helpers to detect your buffer's comment leader
-- ───────────────────────────────────────────────────────────────
local function get_leader()
  -- grab everything before %s in 'commentstring', e.g. "-- "
  local cs = vim.bo.commentstring or ""
  return cs:match("^(.-)%%s") or ""
end

local function is_comment_line(line)
  local leader = get_leader()
  if leader == "" then
    return false
  end
  -- strip indent and see if it begins with that leader
  local trimmed = line:gsub("^%s*", "")
  return vim.startswith(trimmed, leader)
end

-- ───────────────────────────────────────────────────────────────
-- 3) Override gq with an operatorfunc that swaps in your comment width
-- ───────────────────────────────────────────────────────────────
local function comment_gq(type)
  -- determine the line range
  local s, e
  if type == "line" then
    s, e = vim.v.line1, vim.v.line2
  else
    s = vim.fn.getpos("'<")[2]
    e = vim.fn.getpos("'>")[2]
  end

  -- if any line isn’t a comment, do normal gq
  for i = s, e do
    if not is_comment_line(vim.fn.getline(i)) then
      vim.cmd(string.format("%d,%dgq", s, e))
      return
    end
  end

  -- all comments → swap textwidth, gq, restore
  local old_tw = vim.bo.textwidth
  vim.bo.textwidth = vim.g.comment_wrap_textwidth
  vim.cmd(string.format("%d,%dgq", s, e))
  vim.bo.textwidth = old_tw
end

-- ───────────────────────────────────────────────────────────────
-- 4) Hook it all up with autocmds
-- ───────────────────────────────────────────────────────────────
local aug = vim.api.nvim_create_augroup("CommentWrap", { clear = true })

-- 4a) For every filetype: set formatoptions & map gq → our operatorfunc
vim.api.nvim_create_autocmd("FileType", {
  group = aug,
  pattern = "*",
  callback = function()
    -- only auto-wrap comments ('c'), allow gq on comments ('q'), keep new-line comment prefix ('r')
    vim.opt_local.formatoptions:remove({ "g", "t" })
    vim.opt_local.formatoptions:append({ "c", "q", "r" })

    -- remap gq in normal+visual mode to call our Lua function
    vim.keymap.set({ "n", "x" }, "gq", function()
      vim.go.operatorfunc = "v:lua._COMMENT_GQ"
      return "g@"
    end, { expr = true, buffer = true })

    -- expose it to Vimscript
    _G._COMMENT_GQ = comment_gq
  end,
})

-- 4b) In Lua files only: dynamically swap textwidth in Insert mode
vim.api.nvim_create_autocmd({ "InsertEnter", "TextChangedI" }, {
  group = aug,
  pattern = "lua",
  callback = function()
    if is_comment_line(vim.api.nvim_get_current_line()) then
      vim.bo.textwidth = vim.g.comment_wrap_textwidth
    else
      vim.bo.textwidth = vim.g.default_textwidth
    end
  end,
})

-- 4c) Restore your normal width when leaving Insert mode in Lua
vim.api.nvim_create_autocmd("InsertLeave", {
  group = aug,
  pattern = "lua",
  callback = function()
    vim.bo.textwidth = vim.g.default_textwidth
  end,
})
