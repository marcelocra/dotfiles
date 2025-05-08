--- Function to check opts parameters.
local check_opts = function(opts)
  if type(opts) ~= "table" then
    error("`opts` must be a table, got " .. type(opts))
  end

  opts = opts or {}
  return opts
end

--- Dump all keymaps to a file.
-- :redir! > vim_keys.txt
-- :silent verbose map
-- :redir END
