-- vim: tw=80 ts=2 sts=2 sw=2 et ai ff=unix fixeol eol fenc=utf-8 fdm=marker fdl=1 fen

-- ENABLE DEFAULT KICKSTART CONFIGURATION

require 'custom.kickstart-init'

-- OPTIONS {{{

vim.o.smartindent = true
vim.o.autoindent = true

-- Load the colorscheme, choosing the mode: 'time_based', 'dark', 'light'.
-- time_based: the colorscheme will be chosen based on the time of the day.

vim.g.colorscheme_modes = { 'time_based', 'dark', 'light' }
vim.g.colorscheme_mode = vim.g.colorscheme_modes[2]
vim.g.colorscheme_mode_dark = 'tokyonight-night'
-- vim.g.colorscheme_mode_light = 'tokyonight-day'
vim.g.colorscheme_mode_light = 'tokyonight-day'

vim.cmd.colorscheme(require('custom.time-based-colorscheme').define_colorscheme())

local transparent_background = function()
  -- vim.cmd 'hi Normal guibg=NONE ctermbg=NONE'
end

transparent_background()

-- Simplify toggling light and dark.
vim.keymap.set('n', '<M-d>', function()
  vim.cmd.colorscheme(require('custom.time-based-colorscheme').define_colorscheme 'dark')
  transparent_background()
end, { desc = 'Set colorscheme to vim.g.colorscheme_mode_dark' })
vim.keymap.set('n', '<M-l>', function()
  vim.cmd.colorscheme(require('custom.time-based-colorscheme').define_colorscheme 'light')
  transparent_background()
end, { desc = 'Set colorscheme to vim.g.colorscheme_mode_light' })

-- Next option/setting.
-- }}}

-- KEYMAPS {{{

-- NOTE: I'm used to `,` as my <Leader>, so to avoid conflicts with Kickstart
-- and Lazy's default keybindings, I'm keeping space as the leader and using
-- literal `,` for my previous mappings, as I'm already used to them. For new
-- ones, if they fit with Lazy's approach, use <Leader>, otherwise, ','.

-- Go back to normal mode.
vim.keymap.set('i', 'jf', '<Esc>', { desc = 'Go to normal mode' })
vim.keymap.set('i', 'fj', '<Esc>', { desc = 'Go to normal mode' })

-- Save faster.
vim.keymap.set({ 'i', 'n' }, ',w', '<Esc>:w<CR>', { desc = 'Saves the current buffer' })
vim.keymap.set({ 'i', 'n' }, ',s', '<Esc>:w<CR>', { desc = 'Saves the current buffer' })

-- Quit and close buffers faster.
vim.keymap.set('n', ',q', ':q<CR>', { desc = 'Close the current buffer' })
vim.keymap.set('n', ',,q', ':qa<CR>', { desc = 'Close all buffers' })

-- Save and quit faster.
vim.keymap.set('n', ',x', ':x<CR>', { desc = 'Save and close the current buffer' })
vim.keymap.set('i', ',x', '<Esc>:x<CR>', { desc = 'Save and close the current buffer' })

-- Port my most used mappings from VSCode.
vim.keymap.set('n', '<C-p>', ':Telescope find_files<CR>', { desc = 'Fuzzy search files in current folder' })
vim.keymap.set('n', '<C-t>', ':Telescope lsp_dynamic_workspace_symbols<CR>', { desc = 'Fuzzy search workspace symbols' })

-- Move between tabs.
vim.keymap.set('n', '<M-j>', ':tabp<CR>', { desc = 'Move to the left tab' })
vim.keymap.set('n', '<M-k>', ':tabn<CR>', { desc = 'Move to the right tab' })
vim.keymap.set('i', '<M-j>', '<Esc>:tabp<CR>', { desc = 'Move to the left tab' })
vim.keymap.set('i', '<M-k>', '<Esc>:tabn<CR>', { desc = 'Move to the right tab' })

-- Easily open Neovim config files.
-- vim.keymap.set('n', ',e', '<NOP>', { desc = '[E]dit' })
-- vim.keymap.set('n', ',ev', '<NOP>', { desc = '[V]imrc' })
vim.keymap.set('n', ',evv', ':vspl $MYVIMRC<CR>', { desc = '[E]dit [V]imrc in a [V]ertical split' })
vim.keymap.set('n', ',evh', ':spl $MYVIMRC<CR>', { desc = '[E]dit [V]imrc in an [H]orizontal split' })
vim.keymap.set('n', ',evt', ':tabe $MYVIMRC<CR>', { desc = '[E]dit [V]imrc in a new [T]ab' })

-- Easily change colorschemes.
vim.keymap.set('n', '<Leader>cc', ":lua require('telescope.builtin').colorscheme()<CR>", { desc = '[C]hange [C]olorscheme' })

-- Select file content.
vim.keymap.set('n', ',a', 'ggVG', { desc = 'Select full file content' })
vim.keymap.set('i', ',a', '<Esc>ggVG', { desc = 'Select full file content' })

-- Use - and | to split in normal mode.
vim.cmd [[
  nnoremap - :split<cr>
  nnoremap \| :vsplit<cr>
]]

-- Avoids replacing the clipboard content with the selected content. Does this
-- by deleting the selected content to the blackhole register and then pasting
-- the clipboard content to before the cursor position.
vim.cmd 'vnoremap p "_dP'

-- Clear last search (really.. it will erase the search and pressing 'n' won't
-- show it again).
vim.cmd 'nnoremap ,,cl :let @/ = ""<cr>'

-- Go to the Nth tab.
vim.cmd [[
  nnoremap <M-1> :tabn 1<CR>
  nnoremap <M-2> :tabn 2<CR>
  nnoremap <M-3> :tabn 3<CR>
  nnoremap <M-4> :tabn 4<CR>
  nnoremap <M-5> :tabn 5<CR>
  nnoremap <M-6> :tabn 6<CR>
  nnoremap <M-7> :tabn 7<CR>
  nnoremap <M-8> :tabn 8<CR>
  nnoremap <M-9> :tabn 9<CR>
]]

-- Reminder that I'm using the wrong keyboard layout.
vim.cmd [[
  nnoremap Ç :echo "Wrong keyboard layout!"<cr>
  nnoremap ç :echo "wrong keyboard layout!"<cr>
]]

-- Toggle wrap.
vim.cmd [[
  nnoremap <a-w> :set wrap!<cr>
  inoremap <a-w> <esc>:set wrap!<cr>a
]]

-- Add date to current buffer.
-- inoremap <a-d> <c-r>=strftime("%Y-%m-%d")<cr>
vim.cmd 'inoremap <a-d> <c-r>=strftime("%d%b%y")<cr>'

-- Add time to current buffer.
vim.cmd 'inoremap <a-t> <c-r>=strftime("%Hh%M")<cr>'

-- Eval current line or selection using Lua.
vim.keymap.set('n', '<Leader>el', 'V:lua<CR>', { desc = 'Eval current line using Lua' })
vim.keymap.set('v', '<Leader>el', ':lua<CR>', { desc = 'Eval current selection using Lua' })

-- Run current line in external shell and paste the output below.
vim.keymap.set('n', '<Leader>es', ":exec 'r !' . getline('.')<CR>", { desc = 'Run line externally and paste output' })
-- TODO: figure out how to do the selection version.
-- vim.keymap.set('v', '<Leader>es', "\"xy :exec 'r !' . <C-r>x", { desc = 'Run selection externally and paste output' })

-- Use normal regex.
vim.keymap.set('n', '/', '/\\v', { desc = 'Use normal regex' })

-- Search for the selected text.
vim.keymap.set('v', '//', "y/\\V<C-r>=escape(@\",'/\\')<CR><CR>", { desc = 'Search for current selection' })

-- Move vertically by visual line (not jumping long lines).
vim.keymap.set({ 'n', 'v' }, 'j', 'gj', { desc = 'Move down by visual line' })
vim.keymap.set({ 'n', 'v' }, 'k', 'gk', { desc = 'Move up by visual line' })
vim.keymap.set({ 'n', 'v' }, '$', 'g$', { desc = 'Move to the end of the line' })
vim.keymap.set({ 'n', 'v' }, '0', 'g0', { desc = 'Move to the beginning of the line' })

-- Highlight last inserted text.
vim.keymap.set('n', 'gV', '`[v`]')

-- Allow fast indenting when there is a chunck of text selected.
vim.keymap.set('v', '<', '<gv', { desc = 'Indent selected text to the left' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent selected text to the right' })

-- Clear search highlights.
vim.keymap.set('n', '<C-n>', ':nohlsearch<CR>')

-- Create a local shell file in the current directory, to use as a scratch file.
vim.keymap.set('n', ',,s', ':e /tmp/tmp-shell-helper_<C-r>=strftime("%Y%m%d%H%M%S")<CR>.sh<CR>', { desc = 'Create and load scratch shell file' })

-- Next keymap/keybinding/mapping.
-- }}}

-- ABBREVIATIONS {{{

-- Shebangs.
vim.cmd [[
  iab _sb #!/usr/bin/env
  iab _posix #!/usr/bin/env sh
  iab _deno #!/usr/bin/env -S deno run --allow-read
  iab _fsx #!/usr/bin/env -S dotnet fsi
]]

-- EditorConfig alternatives.
-- When EditorConfig is not available, creates a modeline with my prefs.
-- For most languages I use the next line. Change tab (spaces) width, usually for Python.
vim.cmd [[
  iab _ec   vim: tw=80 ts=2 sw=2 ai et ff=unix fenc=utf-8 et fixeol eol fdm=marker fdl=0 fen
  iab _ecpy vim: tw=80 ts=4 sw=4 ai et ff=unix fenc=utf-8 et fixeol eol fdm=marker fdl=0 fen
]]

-- Shell
-- -e: exit on error
-- -u: exit on undefined variable
-- -o pipefail: exits on command pipe failures
-- -x: print commands before execution. Use only if necessary... too verbose.
vim.cmd [[
  iab _euxo set -euxo pipefail
  iab _euo set -euo pipefail
]]

-- The first one is not as portable as the other ones.
vim.cmd [[
  iab _devnullshort &>/dev/null
  iab _devnull &>/dev/null 2>&1
  iab _dn &>/dev/null 2>&1
]]

-- Simplify writing shell command checks.
vim.cmd [[
  iab _out >/dev/null 2>&1; then
  iab _command command -v _out
]]

-- Unicode, emoji, etc.
vim.cmd [[
  iab __ch ✓
  iab __ch ✅️
  iab __not ⛔️
  iab __star ⭐️
  iab __bolt ⚡️
  iab __cros ❌️
  iab __heartp 💜️
  iab __heartw 🤍️
  iab __handdown 👇🏽️
  iab __handup 👆🏽️
  iab __k - [ ]
  iab __- - [ ]
  iab __ret ↲
]]

-- Command mode: open help in a new tab, unless it is typed fully ("help").
vim.cmd 'cab h tab help'

-- Next abbreviation.
-- }}}

-- AUTOCOMMANDS {{{

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Removes ANSI escape sequences from the entire buffer for specific files.',
  group = vim.api.nvim_create_augroup('rm-buffer-ansi-escape-sequences', { clear = true }),
  pattern = '/tmp/kitty-less-tempfile.*',
  callback = function()
    -- Call some Python code to clean the buffer.
    vim.cmd '1,$d|0r !cat % | python3 ~/.config/nvim/scripts/clean_ansi_escape_sequences.py'
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Force format options',
  group = vim.api.nvim_create_augroup('set-formatoptions', { clear = true }),
  pattern = '*',
  callback = function()
    vim.opt_local.formatoptions = 'jcroqn'
  end,
})

vim.g.tw_comments = 80

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Sets different textwidth for comments. Otherwise it is controlled by EditorConfig.',
  group = vim.api.nvim_create_augroup('dynamic-text-width', { clear = true }),
  pattern = '*',
  callback = function()
    vim.api.nvim_create_autocmd('CursorMoved', {
      group = vim.api.nvim_create_augroup('dynamic-text-width-cursor-moved', { clear = true }),
      buffer = 0,
      callback = function()
        local line = vim.api.nvim_get_current_line()
        local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1
        local before_cursor = line:sub(1, cursor_col)

        -- If inside a comment, update tw.
        if before_cursor:match '^%s*[%/%*#;%-%-%!]' then
          vim.opt_local.textwidth = vim.g.tw_comments
        end
      end,
    })
  end,
})

-- Next autocommand.
-- }}}
