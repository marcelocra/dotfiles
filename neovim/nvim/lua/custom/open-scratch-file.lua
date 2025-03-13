-- Create a new scratch file.
local time_now = function()
  return os.date '%Y%m%d%H%M%S'
end

local mcra_scratch_dir = os.getenv 'MCRA_SCRATCH_DIR'

vim.keymap.set(
  'n',
  ',,s',
  function()
    local curr_time = time_now()

    --     -- Create a Python scratch file.
    --     local scratch_file = mcra_scratch_dir .. '/scratch_' .. curr_time .. '.py'
    --     local scratch_file_content = [[
    -- import os
    -- import sys
    --
    --
    -- ]]

    -- Create a Clojure scratch file.
    local scratch_file = mcra_scratch_dir .. '/scratch_' .. curr_time .. '.clj'
    local scratch_file_content = '(ns scratch-'
      .. curr_time
      .. [[(:require [clojure.java.shell] [clojure.string]))

(defn bash [cmd]
  (let [res (clojure.java.shell/sh "bash" "-c" (clojure.string.join #" | " cmd))]
    (if (= 0 (:exit res))
      (println (:out res))
      res)))

(bash [; Commands below this line.



       ; Do not wrap.
       ])

    ]]

    -- Write scratch file content to file.
    local file = io.open(scratch_file, 'w')
    if not file then
      print('Error: could not open file ' .. scratch_file)
      return
    end

    file:write(scratch_file_content)
    file:close()

    -- Open file.
    vim.cmd('e ' .. scratch_file)

    -- Change directory to scripts dir.
    vim.cmd('lcd ' .. mcra_scratch_dir)
  end,

  -- ':e ' .. scratch_file .. ':lcd ' .. mcra_scratch_dir .. '<CR>' .. 'i(ns scratch-' .. time_now() .. '<C-r>=expand("^M")  (:require []))<CR>',
  { desc = 'Create and load scratch file' }
)
