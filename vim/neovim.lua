-- vim:tw=80:ts=4:sw=4:ai:et:ff=unix:fenc=utf-8:et:fixeol:eol:fdm=marker:fmr=<<<,>>>:fdl=0:fen:



-- LEARNING LUA <<<


--[[
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

-- >>>



-- CONFIGURE COMPLETION PLUGIN


-- Create a function to configure nvim-cmp.<<<
-- See https://github.com/hrsh7th/nvim-cmp for more info.
function nvim_cmp()
    local cmp = require'cmp'

    cmp.setup({
        snippet = {
            expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
            end,
        },
        mapping = {
            -- Set your bindings for auto completion feature here.
            ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
            ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
            ['<M-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
            ['<C-y>'] = cmp.config.disable,
            ['<C-e>'] = cmp.mapping({
                i = cmp.mapping.abort(),
                c = cmp.mapping.close(),
            }),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
        },
        sources = cmp.config.sources({ { name = 'nvim_lsp' }, { name = 'vsnip' }, { name = 'buffer' } })
    })

    cmp.setup.cmdline('/', { sources = { { name = 'buffer' } } })

    cmp.setup.cmdline(':', { sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } }) })
end-- >>>

-- Create a function to configure nvim's LSP feature and nvim-lspconfig.<<<
function nvim_lsp()
    local on_attach = function(client, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

        local opts = { noremap=true, silent=true }
        -- Set your bindings for LSP features here.
        -- Default values:
        buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
        buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
        -- My bindings:
        buf_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    end

    local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

    local setup = function(server)
        server.setup {
            autostart = true,
            on_attach = on_attach,
            flags = {
                debounce_text_changes = 150,
            },
            capabilities = capabilities
        }
    end
    local lspconfig = require('lspconfig')
    setup(require('ionide'))
    -- -- add other languages here
    -- setup(lspconfig.ocamllsp)
    -- setup(lspconfig.ccls)

    -- Recommended: this makes the hover windows unfocusable.
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, { focusable = true } -- default: false
    )

    -- Optional: this changes the prefix of diagnostic texts.
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = {
            prefix = '!',
        },
    }
    )
end-- >>>

-- Finally, call each function.<<<

-- First two are executed at the start of init.vim, with other plugins.
-- install()
-- fsharp()
nvim_cmp()
nvim_lsp()
-- >>>



-- ADJUST COLORSCHEME BASED ON TIME OF THE DAY


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
        vim.cmd([[
            colorscheme slate
            colorscheme elflord
            colorscheme tokyonight
            hi MatchParen ctermfg=red ctermbg=black
            hi ColorColumn ctermfg=gray ctermbg=black
        ]])

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



-- USE TRANSPARENT BACKGROUND

-- Removes the background color for all highlight groups that have. This is a
-- per-colorscheme thing.
--
-- Other possible groups:
--
--      highlight SignColumn ctermbg=NONE
--      highlight LineNr ctermbg=NONE
--      highlight CursorLine ctermbg=NONE

vim.cmd([[
    highlight Normal ctermbg=NONE
]])



-- KEYBINDINGS TO LOAD NEOVIM INIT FILES


-- Load init file in a new tab or split. <<<
function load_init(command, init_filename)
    -- Use the path to $MYVIMRC to get the path to the lua file.
    local myvimrc = vim.fn.expand("$MYVIMRC")
    -- TODO: use init.lua eventually. Can't use yet, otherwise it will conflict
    -- with init.vim.
    local init_lua_path = myvimrc:gsub("init%.vim$", init_filename)
    vim.cmd(command .. " " .. init_lua_path)
end

-- Actual Neovim init.
vim.api.nvim_set_keymap('n', '<leader><leader>etl', ':lua load_init("tabedit", "neovim.vim")<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>el', ':lua load_init("vspl", "neovim.vim")<cr>', { noremap = true, silent = true })
-- Additional settings (in Lua), loaded from the init above.
vim.api.nvim_set_keymap('n', '<leader><leader>etl', ':lua load_init("tabedit", "neovim.lua")<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><leader>el', ':lua load_init("vspl", "neovim.lua")<cr>', { noremap = true, silent = true })

-- >>>



-- EVAL SOME JAVASCRIPT CODE


-- -- Choose a JavaScript runtime to use. <<<
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



-- CONFIGURE VIM-SEXP


-- vim-sexp - Ignore the default keybindings that use alt (M). <<<
-- I change tabs using <M-j> and <M-k>, so they scramble my workflow.

vim.g.sexp_mappings = {
    sexp_swap_list_backward = '', -- <M-k>
    sexp_swap_list_forward = '' -- <M-j>
}

-- >>>



-- CONFIGURE CLOJURE CONJURE


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



-- CREATE A TEMPLATE FOR NEW SECTIONS HERE


-- 🖨️ Copy/paste this template including the empty line below. <<<
-- >>>



-- ARCHIVED STUFF


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


vim.cmd([[
  call _mcra_silent_echo('neovim.lua loaded!')
]])

