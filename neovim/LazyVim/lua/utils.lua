-- Setup and helpers functions.

local M = {}

M.vimrc_folder = vim.fn.fnamemodify(vim.env.MYVIMRC, ":h")

--- Same as doc, but when there's need for some args.
--- @type function
M.docfn = function(text)
  return function(...)
    local sep = " "
    return text .. sep .. table.concat({ ... }, sep)
  end
end

-- Define a function to allow partial application.
--
-- Example usage:
--    local function add(a, b, c)
--      return a + b + c
--    end
--    local add5 = partial(add, 5)
--    print(add5(3, 2)) -- Output: 10
--
M.partial = function(func, ...)
  local args = { ... } -- Capture the arguments to pre-fill.
  return function(...)
    local new_args = { ... } -- Capture new arguments.
    local all_args = { unpack(args) } -- Combine pre-filled and new arguments.
    for _, v in ipairs(new_args) do
      table.insert(all_args, v)
    end
    return func(unpack(all_args)) -- Call the original function.
  end
end

--- Simplifies the mapping of keys.
---
--- @param mode string
--- @param from string
--- @param to string
--- @param desc_or_opts string | table | nil
--- @param opts table | nil
local map = function(mode, from, to, desc_or_opts, opts)
  if type(desc_or_opts) == "table" then
    opts = desc_or_opts
    desc_or_opts = nil
  end

  opts = opts or {}
  opts.vscode = opts.vscode or true

  -- If the user is using VSCode, don't set the mapping.
  if (not opts.vscode) and vim.g.vscode then
    print("In VSCode. Skipping mapping: " .. from .. " -> " .. to)
    return
  end

  -- Keys that do not exist in vim API must be removed before calling the
  -- actual API.
  opts.vscode = nil

  opts.silent = opts.silent or true
  opts.noremap = opts.noremap or true
  opts.desc = desc_or_opts
  vim.keymap.set(mode, from, to, opts)
end

-- Simplifies even more the mapping of keys.
M.imap = M.partial(map, "i")
M.nmap = M.partial(map, "n")
M.vmap = M.partial(map, "v")
M.inmap = M.partial(map, { "i", "n" })
M.vnmap = M.partial(map, { "v", "n" })

return M
