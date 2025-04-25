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

---
--- Facilitates documenting a block of code, using a string as docs (1st arg).
--- The 2nd argument should the function that will be run. You can use the
--- string in the function if you want. It is the first parameter:
---
---   run("This function is cool!", function(doc)
---     print(doc)   -- "This function is cool!"
---   end)
---
--- @param doc string The string used to document this block.
M.call_doc = function(doc, fn)
  if type(doc) ~= "string" or type(fn) ~= "function" then
    error("Incorrect argument type... you should have a type error somewhere.")
  end

  return fn()
end

-- Next function/util above.

return M
