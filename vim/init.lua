-- vim:tw=80:ts=4:sw=4:ai:et:ff=unix:fenc=utf-8:et:fixeol:eol:fdm=marker:fmr=<<<,>>>:fdl=0:fen:
--
--[[ Learning Lua
## Iterating over tables in order (indexes start at 1). <<<

local keys = { 'val1', 'val2' }

for i, key in ipairs(keys) do
    print(i .. '-' .. key)
end

>>>
## Iterating over tables by keys. <<<

local keys = { el1 = '<leader>w', el2 = '<leader>s' }

for k, v in pairs(keys) do
    print(k .. " - " .. v)
end

>>>
--]]

-- Adjust colorscheme based on time of the time of the day. <<<
-- You can override it manually if you want.
local hour_now = tonumber(os.date("%H"))
local daylight_ends = 17
local daylight_starts = 6

-- Use this to either choose a mode or allow it to be time based. Options:
local ColorMode = {
    TimeBased = 0,
    Dark = 1,
    Light = 2,
}

-- local mode = ColorMode.Dark
vim.g.colorsheme_mode = ColorMode.TimeBased

function define_colorscheme(mode)
    -- If not forcing light mode, then check if forcing dark. If not, then use the
    -- time-based approach.
    --
    -- Try to make paranthesis matching useful and less confusing (hi MatchParen
    -- needs to be changed after setting a colorscheme).
    if mode ~= ColorMode.Light and (mode == ColorMode.Dark or hour_now < daylight_starts or hour_now >= daylight_ends) then
        vim.cmd[[
            colorscheme slate
            colorscheme elflord
            colorscheme tokyonight
            hi MatchParen ctermfg=red ctermbg=black
            hi ColorColumn ctermfg=gray ctermbg=black
        ]]

    else
        vim.cmd([[
            colorscheme zellner
            colorscheme tokyonight
            hi MatchParen ctermfg=black ctermbg=lightgreen
            hi ColorColumn ctermfg=gray ctermbg=white
        ]])

    end
end
define_colorscheme(vim.g.colorsheme_mode)
-- >>>

-- Toggle colorsheme between light/dark with a keybinding. <<<
vim.keymap.set('n', '<a-L>', function()
    if vim.g.colorsheme_mode == ColorMode.Dark
    then
        vim.g.colorsheme_mode = ColorMode.Light
    else
        vim.g.colorsheme_mode = ColorMode.Dark
    end
    define_colorscheme(vim.g.colorsheme_mode)
end)
-- >>>

-- Load lua init in a new tab. <<<
function load_init_lua(command)
    -- Use the path to $MYVIMRC to get the path to the lua file.
    local myvimrc = vim.fn.expand("$MYVIMRC")
    -- TODO: use init.lua eventually. Can't use yet, otherwise it will conflict
    -- with init.vim.
    local init_lua_path = myvimrc:gsub("init%.vim$", "config.lua")
    vim.cmd(command .. " " .. init_lua_path)
end

-- Create a normal mode mapping to trigger this function.
vim.api.nvim_set_keymap('n', '<leader><leader>etl', ':lua load_init_lua("tabedit")<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>el', ':lua load_init_lua("vspl")<cr>', { noremap = true, silent = true })

-- >>>

-- Eval some JavaScript code. <<<

-- -- Choose a JavaScript runtime to use.
-- vim.g.mcra_js_cmd = "deno eval" -- node uses -e

-- -- Create a normal mode mapping to select the current paragraph and execute it.
-- vim.api.nvim_set_keymap('n', '<leader>er', [[vip :w !<c-r>=luaeval("vim.g.mcra_js_cmd")<cr><cr>]], { noremap = true, silent = false })


-- Choose which command to eval JavaScript.
vim.g.mcra_js_eval = "deno eval"

-- Function to execute the current paragraph of JavaScript code
function ExecuteJsBlock()
    -- Get the start and end line of the current paragraph and the lines between
    -- them.
    local start_line = vim.fn.line("'{")
    local end_line = vim.fn.line("'}")
    local lines = vim.fn.getline(start_line, end_line)

    -- Combine them into a single string of JavaScript code
    local js_code = table.concat(lines, "\n")

    -- Escape double quotes in the JavaScript code before passing to the shell.
    js_code = js_code:gsub('"', '\\"')

    -- Get the eval command and use it in the code.
    local eval_cmd = vim.g.mcra_js_eval
    local command = string.format('%s "%s"', eval_cmd, js_code)

    -- Execute the command.
    print(vim.fn.system(command))
end

vim.api.nvim_set_keymap('n', '<localleader>er', ':lua ExecuteJsBlock()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<localleader>ep', ':lua ExecuteJsBlock()<cr>', { noremap = true, silent = true })

-- >>>

-- vim-sexp - Ignore the default keybindings that use alt (M). <<<
-- I change tabs using <M-j> and <M-k>, so they scramble my workflow.

vim.g.sexp_mappings = {
    sexp_swap_list_backward = '', -- <M-k>
    sexp_swap_list_forward = '' -- <M-j>
}

-- >>>

-- In Conjure, eval the current buffer up to the point where the cursor is. <<<

-- vim.keymap.set('n', '<leader>el', '<localleader>Egg<c-o>', { noremap = true })
-- vim.keymap.set('!', '<localleader>el', '<localleader>Egg<c-o>', { noremap = true, silent = true })

-- vim.keymap.set('n', '<localleader>el', function()
--     print('running the thing')
--     -- Trigger the operator-pending motion
--     vim.api.nvim_feedkeys(
--         vim.api.nvim_replace_termcodes('<localleader>Egg<c-o>', true, true, true),
--         'n',
--         false)
--     print('done')
-- end, { noremap = true, silent = false })

-- vim.keymap.set('n', '<localleader>el', function()
--     vim.cmd('normal! ' .. vim.api.nvim_replace_termcodes(' Egg', true, true, true))

--     -- local localleader = vim.api.nvim_replace_termcodes('<localleader>', true, false, true)
--     -- local ctrlO = vim.api.nvim_replace_termcodes('<c-o>', true, false, true)

--     -- vim.api.nvim_feedkeys(' Egg', 't', false)
--     print('not done')
-- end)

vim.keymap.set('n', '<localleader>el', function()
  -- Save the macro to register 'a'
  vim.fn.setreg('a', 'Vgg E')  -- Replace with your desired macro sequence

  -- Execute the macro stored in register 'a'
  vim.cmd('normal! @a')

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<c-o>', true, true, true), 'n', false)
end, { noremap = true, silent = true })

-- >>>

-- 🖨️ Copy/paste this template including the empty line below. <<<
-- >>>

-- Next 👆. Archived 👇. <<<

-- -- Nim lsp setup.
-- require'lspconfig'.nim_langserver.setup{
--   settings = {
--     nim = {
--       nimsuggestPath = "~/.nimble/bin/custom_lang_server_build"
--     }
--   }
-- }

-- >>>

print('config.lua sourced!')
