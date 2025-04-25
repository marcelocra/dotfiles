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

--- @type function
M.TEST = function(fn, opts, ...)
  opts = opts or { run = false }
  if not opts.run then
    return
  end

  local args = { ... }
  fn(unpack(args))
end

--- Define a function to allow partial application.
---
--- Example usage:
---    local function add(a, b, c)
---      return a + b + c
---    end
---    local add_alias = partial(add)
---    local add5 = partial(add, 5)
---    print(add5(3, 2)) -- Output: 10
---
--- @type function
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
M.call = M.partial

-- Test the partial function.
M.TEST(function()
  local somefunc = function(a, b, c)
    print(a, b, c)
  end

  local other = M.partial(somefunc)
  other("hello", "you", "beautiful")
end, { run = false })

-- Different implementation.
M.partial2 = function(func, ...)
  local bound = { ... }
  return function(...)
    local new_args = { ... }

    local args = {}

    -- Copy bound args, if any.
    for i = 1, #bound do
      args[i] = bound[i]
    end

    -- Append new args.
    for i = 1, #new_args do
      -- print(#new_args, " ", i, " ", new_args[i])
      args[#bound + i] = new_args[i]
    end

    -- Call the original function with whatever you got (even none).
    return func(unpack(args))
  end
end

M.TEST(function()
  local somefunc = function(a, b, c)
    print(a .. " " .. b .. " " .. c)
  end
  local other = M.partial2(somefunc)
  other("hello", "you", "beautiful")
end, { run = false })

-------------------------------------------------------------------------------
-- Next function/util above. The function below should be the last one in the
-- file, to use the M table correctly.
-------------------------------------------------------------------------------

---
--- Facilitates running and documenting a block of code.
---
---   run("This function is cool!", function(doc)
---     print(doc)   -- "This function is cool!"
---   end)
---
--- Or, if you have more options:
---
---   run({ doc = "This function is cool!", say_hello = true }, function(opts)
---     print(opts.doc)   -- "This function is cool!"
---     if opts.say_hello then
---       print("Hello!")
---     end
---   end)
---
--- Or, if you want to use other functions from this module:
---
---   run({ doc = "This function is cool!" }, function(opts, u)
---     -- Use the functions here, like: u.partial(...)
---   end)
---
--- @param str_or_opts string|table A string documenting this block or a table
--- with whatever you want, including a doc field.
--- @param cb function The function that will be called. It can receive options
--- if you need.
M.fn = function(str_or_opts, cb)
  if (type(str_or_opts) ~= "string" and type(str_or_opts) ~= "table") or type(cb) ~= "function" then
    error("Incorrect argument type... you should have a type error somewhere")
  end

  return cb(str_or_opts, M)
end

return M
