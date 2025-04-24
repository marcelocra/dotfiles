local M = {}

--- Executes the function in the block, providing it common documentation,
--- options and utils so that it can run code in a documented context. Example:
---
---   run("Maps stuff", { dry_run = true }, function(doc, opts, utils)
---     -- doc == "Maps stuff"
---     -- opts == { dry_run = true }
---     -- utils == require("utils")
---
---     -- Use the arguments above to do stuff like defining multiple mappings
---     -- that have the same goal and some common options.
---   end)
---
--- The function parameter below must receive the input doc, opts and the N
--- defined above.
---
--- @alias Doc string|nil
--- @alias Opts table
--- @param doc Doc
--- @param opts table
--- @param fn function(doc: Doc, opts: Opts, utils: Utils)
M.run = function(doc, opts, fn)
  if (type(doc) ~= "string" or type(doc) ~= "nil") and type(opts) ~= "table" and type(fn) ~= "function" then
    error("Incorrect argument type")
  end

  return fn(doc, opts, require("utils"))
end

return M
