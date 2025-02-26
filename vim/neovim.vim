" vim:fdm=marker:fmr={{{,}}}:fdl=0:fen:ai:et:ts=2:sw=2:tw=80:ff=unix:fenc=utf8:et:fixeol:eol:
"
"--------------------
"   Basic Settings
"--------------------


set nocompatible

if has("syntax")
  syntax on
endif
filetype plugin on

set completeopt=menu,menuone,noselect


"-----------
"  Plugins
"-----------


" Details on how to use vim-plug, with examples. {{{
"
" Plugin example usage:
"
"   " Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
"   Plug 'junegunn/vim-easy-align'
"
"   " Multiple Plug commands can be written in a single line using | separators
"   Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
"
"   " On-demand loading
"   Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
"
"   " Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
"   Plug 'fatih/vim-go', { 'tag': '*' }
"   Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }
"
"   " Plugin outside ~/.vim/plugged with post-update hook
"   Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
"   Plug 'junegunn/fzf.vim'
"
" Previously used plugins, to keep in mind:
"
"   " Allows one to easily traverse files.
"   Plug 'Lokaltog/vim-easymotion'
"
"   " JavaScript stuff.
"   Plug 'dense-analysis/ale'
"   Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
"   Plug 'ternjs/tern_for_vim', { 'do': 'yarn install' }
"
"   " Makes commenting easier on Vim.
"   Plug 'scrooloose/nerdcommenter'
"
"   " Colorschemes
"   Plug 'altercation/vim-colors-solarized'
"   Plug 'sjl/badwolf'
"   Plug 'tomasr/molokai'
"   Plug 'tpope/vim-vividchalk'
"   Plug 'marcelocra/vim-colorscheme'
"
" }}}
" --- -vim-plug( ----------------------------------------{{{
call _mcra_debug(1)

" Here we install the required plugins with vim-plug. {{{
function! s:install()

  " This installs vim-plug automatically when missing.
  " Remove this if .. endif if you don't need this.
  if empty(glob('~/.vim/autoload/plug.vim'))
        \ || empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif

  call plug#begin()

  " Fuzzy searching (files, lines, buffers, commands, etc).
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

  " Git support.
  Plug 'tpope/vim-fugitive'

  " Improved mappings for default stuff.
  Plug 'tpope/vim-unimpaired'

  " Simplify handling of stuff that wraps code (parens, [curly]braces, quotes,
  " etc).
  Plug 'tpope/vim-surround'

  " Simplify (un)commenting stuff out.
  Plug 'tpope/vim-commentary'

  " Improve repeat support (e.g. for surrounding stuff).
  Plug 'tpope/vim-repeat'

  " Widely used simple status line.
  Plug 'vim-airline/vim-airline'

  " Simplify jumping to stuff. Made by a NeoVim maintainer.
  Plug 'justinmk/vim-sneak'

  " Improved support for many language stuff, like highlighting, ast manipulation,
  " etc. Originally created at GitHub for use in the Atom editor:
  "   https://getpage.in/tree-sitter
  Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

  " GitHub Copilot.
  Plug 'github/copilot.vim'

  " Align stuff.
  Plug 'junegunn/vim-easy-align'

  " Colorschemes
  " ------------

  Plug 'folke/tokyonight.nvim'
  Plug 'altercation/vim-colors-solarized'
  Plug 'sjl/badwolf'
  Plug 'tpope/vim-vividchalk'

  " Clojure and Python support
  " --------------------------

  " Plugins for Clojure and other lisps.
  Plug 'Olical/conjure', { 'for': ['clojure', 'python'] }
  Plug 'guns/vim-sexp', { 'for': ['clojure'] }
  Plug 'tpope/vim-sexp-mappings-for-regular-people', { 'for': ['clojure'] }

  " Dart support
  " ------------

  " Official plugin:
  "   https://github.com/dart-lang/dart-vim-plugin
  Plug 'dart-lang/dart-vim-plugin'

  " TODO: figure out why it is not working (and then, uncomment).
  " Recommended by the official plugin:
  "   https://github.com/dart-lang/dart-vim-plugin/blob/4bdc04e2540edf90fda2812434c11d19dc04bc8f/README.md?plain=1#L100
  " Also, the creator is a Googler:
  "   https://github.com/natebosch
  " Plug 'natebosch/vim-lsc'
  " Plug 'natebosch/vim-lsc-dart'

  " F# support
  " ----------
  "
  " I followed Ionide's instructions to set up F# support in Vim, from here:
  "
  "   https://github.com/ionide/Ionide-vim/wiki/Configuration-Examples/c63dc429fb5160942da85a71282b76c03a76fa82#with-nvim-lspconfig-and-nvim-cmp-for-neovim-05
  "
  " The cmp-* plugins also work for other languages.

  Plug 'ionide/Ionide-vim'

  " Lsp support.
  Plug 'neovim/nvim-lspconfig'

  " Completion plugins.
  Plug 'hrsh7th/cmp-nvim-lsp', { 'branch': 'main' }
  Plug 'hrsh7th/cmp-buffer', { 'branch': 'main' }
  Plug 'hrsh7th/cmp-path', { 'branch': 'main' }
  Plug 'hrsh7th/cmp-cmdline', { 'branch': 'main' }
  Plug 'hrsh7th/nvim-cmp', { 'branch': 'main' }
  Plug 'hrsh7th/cmp-vsnip', { 'branch': 'main' }
  Plug 'hrsh7th/vim-vsnip'

  call plug#end()
endfunction  " }}}

" Here we configure Ionide-vim. {{{
function! s:fsharp()
  " Required: to be used with nvim-cmp.
  let g:fsharp#lsp_auto_setup = 0

  " Recommended: show tooptip when you hold cursor over something for 1 second.
  if has('nvim') && exists('*nvim_open_win')
    set updatetime=1000
    augroup FSharpShowTooltip
      autocmd!
      autocmd CursorHold *.fs,*.fsi,*.fsx call fsharp#showTooltip()
    augroup END
  endif

  " Recommended: Paket files are excluded from the project loader.
  let g:fsharp#exclude_project_directories = ['paket-files']
endfunction " }}}

" Finally, we call each functions.
" The last two are executed in the config.lua file.
call s:install()
call s:fsharp()
" call s:nvim_cmp()
" call s:nvim_lsp()

call _mcra_debug(2)

" )vim-plug- }}}


"------------
"  Settings
"------------


" Source common Vim stuff before anything else, so we can override stuff.
exec 'source ' . g:mcra_vimrc
call _mcra_debug('sourced ' . g:mcra_vimrc)

" --- -settings( ------------------------------------------------------------{{{

" Syntax highlighting.
syntax enable

" Indentation.
set autoindent

" Disable annoying error noise (now it blinks).
set vb t_vb=

" Lines with number and with a particular width (no variation when
" increasing).
set number
set norelativenumber

" Show line and column.
set ruler
set colorcolumn=80,100,120

" Highlight search matches as you type.
set hlsearch
set incsearch

" Always show the status line.
set laststatus=2

" Use utf-8 encoding.
set encoding=utf-8

" Change tab and trail characters.
let &showbreak = '+++ '
set listchars=eol:↲,tab:→\ ,trail:·,extends:>,precedes:<,nbsp:_
"set listchars=eol:$,tab:».,trail:.,extends:>,precedes:<,nbsp:%
set nolist

" Highlight the cursor line.
set cursorline

" Allow backspace to work like in every text editor.
set backspace=2

" Visual autocomplete for command menu.
set wildmenu

" Redraw only when needed to.
set lazyredraw

" Change Vim default splits (to bottom right).
set splitbelow
set splitright

" Set line endings using Unix style.
set fileformats=unix

" Set proper colors.
set t_Co=256


" My current favourite preeinstalled theme.
colorscheme slate  " git diffs works properly
colorscheme tokyonight-night

" Set how the status line will be shown in the bottom of Vim. (Not needed if
" using airline.)
"set statusline=%<%F\ %m%r%h\ %=lines:%l/%L\ col:%c%V

" Use the system clipboard to copy to/from.
set clipboard+=unnamedplus

" " Enable python3.
" let g:python3_host_prog = '/usr/bin/python3'

" If no .editorconfig is found, use these. -noeditorconfig( {{{
if !filereadable(expand("~/.editorconfig"))
    " When inserting a tab in the beggining of the line, it will be N spaces long
    " and a backspace will go back N spaces also (where N is the chosen number).
    set smarttab
    set shiftwidth=4
    set tabstop=4

    " Use spaces instead of tabs.
    set expandtab

    " brazilians unite!
    set spelllang=pt_br,en
endif

" )noeditorconfig- }}}
" )settings- }}}
" --- -mappings( ------------------------------------------------------------{{{

call _mcra_debug(3)

" Use normal regex.
nnoremap / /\v\c
vnoremap / /\v\c

" Simpler way to go to command mode from insert mode.
" inoremap <c-n> <esc>
" inoremap jf <esc>
" inoremap fj <esc>

" Quicker window movement.
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-h> <c-w><c-h>
nnoremap <c-l> <c-w><c-l>

" Move vertically by visual line (not jumping long lines).
nnoremap j gj
nnoremap k gk
nnoremap $ g$
nnoremap 0 g0

vnoremap j gj
vnoremap k gk
vnoremap $ g$
vnoremap 0 g0

" Highlight last inserted text.
nnoremap gV `[v`]

" Allow fast indenting when there is a chunck of text selected.
vnoremap < <gv
vnoremap > >gv

" Use alt to change tabs.
" TODO(marcelocra): figure how to avoid this conflicting with vim-sexp.
" nnoremap <m-j> :tabprevious<cr>
" nnoremap <m-k> :tabnext<cr>
" inoremap <m-j> <esc>:tabprevious<cr>
" inoremap <m-k> <esc>:tabnext<cr>

inoremap <a-j> <esc>:tabprevious<cr>
inoremap <a-k> <esc>:tabnext<cr>
nnoremap <a-j> :tabprevious<cr>
nnoremap <a-k> :tabnext<cr>

" Search for the selected text.
vnoremap // y/\V<c-r>=escape(@",'/\')<cr><cr>

" Count occurrences. In normal mode, count occurrences for the word where the
" cursor is in. In visual mode, count occurrences for the selected text.
"
" Note: this can be easily achieved by selecting whatever, pressing '/' twice
" and looking at the bottom right: it will show something like '[1/N]', where N
" is the number of matches.
"
" nnoremap <leader><leader>c *N:%s///gn<cr>
" vnoremap <leader><leader>c y/\V<c-r>=escape(@",'/\')<cr><cr>:%s///gn<cr>

" Use alt-c to toggle folds.
nnoremap <a-c> za

" Use - and | to split in normal mode.
nnoremap - :split<cr>
nnoremap \| :vsplit<cr>

" Avoids replacing the clipboard content with the selected content. Does this
" by deleting the selected content to the blackhole register and then pasting
" the clipboard content to before the cursor position.
vnoremap p "_dP

" Remove last search highlight.
nnoremap <silent> <c-n> :nohl<cr>
"inoremap <silent> <c-c> <esc>:nohl<cr>a

" Clear last search (really.. it will erase the search and pressing 'n' won't
" show it again).
nnoremap <silent> <leader><leader>cl :let @/ = ""<cr>

" Go to the Nth tab.
nnoremap <a-1> :tabn 1<cr>
nnoremap <a-2> :tabn 2<cr>
nnoremap <a-3> :tabn 3<cr>
nnoremap <a-4> :tabn 4<cr>
nnoremap <a-5> :tabn 5<cr>
nnoremap <a-6> :tabn 6<cr>
nnoremap <a-7> :tabn 7<cr>
nnoremap <a-8> :tabn 8<cr>
nnoremap <a-9> :tabn 9<cr>

" Change tabs.
nnoremap [t :tabprevious<cr>
nnoremap ]t :tabnext<cr>

" Reminder that I'm using the wrong keyboard layout.
nnoremap Ç :echo 'wrong keyboard layout!'<cr>

" Simulate multiple cursors.
vnoremap <c-d> y:%s/<c-r>"

" Insert current time.
"nnoremap <a-h> r!bb '(-> "HH:mm" (java.text.SimpleDateFormat.) (.format (java.util.Date.)) (str/replace (re-pattern ":") "h") (println))'

" Resize splits.
nnoremap <leader>> <c-w>10+
nnoremap <leader>< <c-w>10-

" Toggle wrap.
nnoremap <a-w> :set wrap!<cr>
inoremap <a-w> <esc>:set wrap!<cr>a

" Add date to current buffer.
" inoremap <a-d> <c-r>=strftime("%Y-%m-%d")<cr>
inoremap <a-d> <c-r>=strftime("%d%b%y")<cr>

" Add time to current buffer.
inoremap <a-t> <c-r>=strftime("%Hh%M")<cr>

" Add a divider and the current time.
inoremap <a-s> <c-r>=strftime("\n\n---\n\n%Hh%M\n\n")<cr>

" Add current date and time.
inoremap <a-n> <c-r>=strftime("%Y-%m-%d %H:%M")<cr>

" Copy current file path to clipboard, trying to replace user home path with $HOME.
nnoremap <leader><leader>cp :let @+ = substitute(expand('%'), expand('~'), '$HOME', '')<cr>:echo @+<cr>
nnoremap <leader><leader>cw :echo getcwd()<cr>

" Execute last macro recorded in register 'q'.
nnoremap <space><space>q @q

" I prefer c-j/k instead of c-n/p.
inoremap <silent> <c-k> <c-p>
inoremap <silent> <c-j> <c-n>

" Start interactive EasyAlign in visual mode (e.g. vipga)
xnoremap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nnoremap ga <Plug>(EasyAlign)

" " Use c-/ to comment block.
" nnoremap <c-\/> gcc
" vnoremap <c-\/> gc
" inoremap <c-\/> <esc>gcca

" Print all mappings to a new buffer.
function! PrintMappingsToBuffer()
  redir @a | silent map | redir END | new | put a
endfunction

nnoremap <leader><leader>m :call PrintMappingsToBuffer()<cr>

call _mcra_debug(4)

" )mappings- }}}
" --- -abbreviations( -------------------------------------------------------{{{

" ///// CODE ///////////////////////////////////////////////////////////////////
"
" Prefix all of them with capital c, to avoid replacing when typing variables, comments, etc.

call _mcra_debug(5)

" Shebangs
" ========

iab Cshebang #!/usr/bin/env
iab Csb #!/usr/bin/env

iab Cposix #!/usr/bin/env sh
iab Cps #!/usr/bin/env sh

iab Cdeno #!/usr/bin/env -S deno run --allow-read

iab Cfsx #!/usr/bin/env -S dotnet fsi


" Vim modeline with my preferred defaults.
" ============
"
" EDIT: now I put the defaults in the ~/.editorconfig, which superseeds modelines, as they work in
" all editors.


" Lets use the default marker, as recommended by Vim.
iab Cfold vim:fdm=marker:fmr={{{,}}}:fdl=0:fen:
iab Cfoldmd ft=markdown:

" When EditorConfig is not available, creates a modeline with my prefs.
" For most languages I use the next line.
iab Cec vim:tw=100:ts=2:sw=2:ai:et:ff=unix:fenc=utf-8:et:fixeol:eol:fdm=marker:fdl=0:fen:
" Change text and tab (spaces) width for some stuff (Python, shells, etc).
iab Cecpy vim:tw=80:ts=4:sw=4:ai:et:ff=unix:fenc=utf-8:et:fixeol:eol:fdm=marker:fdl=0:fen:
" To be used with one of the above (mostly for Lua, as the default breaks indentation).
iab Clua fmr=<<(,)>>:
" Define the filetype. I normally use for shell.
iab Cft ft=sh:

" " Trying to automatically create a modeline that works for notes in md.
" iab note <!-- vim: fdm=marker:fmr={,}:fdl=1:fen:ai:et:ts=4:sw=4:tw=80:wrap --><left><left><left><cr><esc><left>o
" iab note <!-- vim: fdm=marker:fmr={,}:fdl=1:fen:ai:et:ts=4:sw=4:tw=80:wrap --><left><left><left><cr><left>o
" iab note <!-- vim: fdm=marker:fmr={,}:fdl=1:fen:ai:et:ts=4:sw=4:tw=80:wrap --><left><left><left><bs><cr>
" iab note <!-- vim: fdm=marker:fmr={,}:fdl=1:fen:ai:et:ts=4:sw=4:tw=80:wrap<cr>--><cr><c-u>
" iab note <!-- vim: fdm=marker:fmr={,}:fdl=1:fen:ai:et:ts=4:sw=4:tw=80:wrap<cr>--><cr><bs>
" iab note <!-- vim: fdm=marker:fmr={,}:fdl=1:fen:ai:et:ts=4:sw=4:tw=80:wrap<cr>--><cr><left>
"
" So far, this is the best one, but doesn't leave the cursor exactly where I
" want yet.
" iab note <!-- vim: fdm=marker:fmr={,}:fdl=1:fen:ai:et:ts=4:sw=4:tw=80:wrap<cr>--><cr>


" Shell stuff
" ===========
" Create better bash scripts with these options at the top
" of them.
"
" EDIT: I'm replacing my bash scripts with posix, see below.
" -e: exit on error
" -u: exit on undefined variable
" -o pipefail: exits on command pipe failures
" -x: print commands before execution
iab Ceuxo set -euxo pipefail

" Printing all commands make it very verbose and hard to read.
iab Ceuo set -euo pipefail

" Add Rich Hickey comment block comment.
iab Crich ;; rcf - rich comment form

" Not as portable as the ones below.
iab Cdevnullshort &>/dev/null
" More portable.
iab Cdevnull &>/dev/null 2>&1
iab Cdnposix &>/dev/null 2>&1

" Simplify writing shell command checks.
iab Cout >/dev/null 2>&1; then
iab Ccommand command -v Cout

" Unicode, emoji, etc.
" ====================

iab Cch ✓
iab Cch ✅️
iab Cnot ⛔️
iab Cstar ⭐️
iab Cbolt ⚡️
iab Ccros ❌️
iab Cheartp 💜️
iab Cheartw 🤍️
iab Chanddown 👇🏽️
iab Chandup 👆🏽️
iab Ck - [ ]
iab C- - [ ]
iab Cret ↲

" Text.
" iab js JavaScript
" iab ts TypeScript

" ///// COMMAND ////////////////////////////////////////////////////////////////


" Open help in a new tab, unless it is typed fully ("help").
cab h tab help

call _mcra_debug(6)

" )abbreviations- }}}
" --- -leader-mappings( -----------------------------------------------------{{{

call _mcra_debug(7)

" Change leader.
let mapleader = ","
let maplocalleader = " "

" Creates a number of save mappings, using leader+s and ctrl+s.
nnoremap <leader>s :w<cr>
nnoremap <c-s> :w<cr>
" Save and exit insert mode.
inoremap <leader>s <esc>:w<cr>
" Save but stay in insert mode.
inoremap <c-s> <esc>:w<cr>a

" Save and reload the file
inoremap <leader>e <esc>:w<cr>:e<cr>
nnoremap <leader>e :w<cr>:e<cr>

" Quit easily.
nnoremap <leader>q :q<cr>
nnoremap <leader><leader>q :qa<cr>
inoremap <leader>q <esc>:q<cr>

" Save and quit easily.
inoremap <leader>x <esc>:x<cr>
nnoremap <leader>x :x<cr>

" Select all.
nnoremap <leader>a ggVG

" Delete current buffer
noremap <silent><leader><leader>d :bd<cr>

" Eval current selection/file with Node/Deno.
let g:mcra#eval_with = 'node'
nnoremap <leader>er :exe "normal vip:w !node"

call _mcra_debug(8)

" )leader-mappings- }}}
" --- -plugin-mappings( -----------------------------------------------------{{{

call _mcra_debug(9)

" vscode-vim settings --------------------------------------
" For vscode-neovim. Settings that should be enabled only in
" cmdline vim should go here.
if !exists('g:vscode')
endif

" fzf settings ---------------------------------------------

nnoremap <c-p> :Files<cr>
" " Ignore <c-b>, as I want to get used to <c-u>.
" nnoremap <c-b> :echo 'use <' . 'c-u> instead!'<cr>
" Use c-b to list buffers!
nnoremap <c-b> :Buffers<cr>

" Search lines in all open buffers.
nnoremap <localleader>l :Lines<cr>

nnoremap <localleader>c :Commands<cr>

" vim-sneak mapping ----------------------------------------

map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

call _mcra_debug(10)

" )plugin-mappings- }}}
" --- -plugin-settings( -----------------------------------------------------{{{

call _mcra_debug(11)

" vim-sneak settings -----------------------------------------------------------

let g:sneak#label = 1
let g:sneak#s_next = 1

" conjure settings -------------------------------------------------------------

" let g:conjure#client_on_load = 0
let g:conjure#log#jump_to_latest#enabled = 0
let g:conjure#log#jump_to_latest#cursor_scroll_position = 'center'

let g:conjure#log#wrap = 1

let g:conjure#log#hud#anchor = "SE"
let g:conjure#log#hud#width = 1.0

let g:conjure#log#botright = 1
" let g:conjure#log#fold#enabled = 1

let g:conjure#highlight#enabled = 1

" dart-vim-pluging settings ----------------------------------------------------

let g:dart_html_in_string = v:true
let g:dart_style_guide = 2
" let g:dart_format_on_save = v:true
" configure format options with `let g:dartfmt_options = ...`

" vim-lsc settings -------------------------------------------------------------

" let g:lsc_auto_map = v:true

" fsharp f# --------------------------------------------------------------------
let g:fsharp#fsautocomplete_command =
      \ [ 'dotnet',
      \   'fsautocomplete',
      \   '--background-service-enabled',
      \ ]

" Custom mapping example. The default is vscode.
" let g:fsharp#fsi_keymap = "custom"  " vscode
" let g:fsharp#fsi_keymap_send   = "<C-e>"  " vscode: Alt+Enter
" let g:fsharp#fsi_keymap_toggle = "<C-@>"  " vscode: Alt+Shift+2 (Alt+@)

let g:fsharp#exclude_project_directories = ['paket-files']
" let g:fsharp#fsi_command = "dotnet fsi --compilertool:~/.nuget/packages/paket/8.0.3/tools/netcoreapp2.1/any/"
" let g:fsharp#use_sdk_scripts = 0 " for net462 FSI

" lsp settings ---------------------

" Show full lsp error msg.
 nnoremap <leader><leader>e :lua vim.diagnostic.open_float(0, {scope="line"})<cr>

call _mcra_debug(12)

" )plugin-settings- }}}
" --- -autocommands( --------------------------------------------------------{{{

call _mcra_debug(13)

augroup myautocommands
    autocmd!

    " Git commit messages.
    autocmd FileType gitcommit set colorcolumn=51


    " Markdown
    " ========

    " Ignoring this for now, leaving it to EditorConfig.
    " function SetMarkdownOptions()
    "     set fdm=marker
    "     set fmr={,}
    "     set fdl=1
    "     set fen
    "     set ai
    "     set et
    "     set ts=4
    "     set sw=4
    "     set tw=80
    "     set wrap
    " endfunction
    " autocmd FileType markdown call SetMarkdownOptions()


    " F# FSharp
    " =========

    " When in a F# file, keep the signcolumn always present, otherwise it keeps
    " shifting code when warnings/errors appear.
    autocmd FileType fsharp set signcolumn=yes

    autocmd BufNewFile,BufRead *.fs,*.fsx,*.fsi set filetype=fsharp

augroup END

call _mcra_debug(14)

" )autocommands- }}}
" --- -functions( -----------------------------------------------------------{{{

"" From StackOverflow, in case changing the highlight colors doesn't work:
""
""   https://stackoverflow.com/a/47361068/1814970
""
" set noshowmatch

" function! g:FuckThatMatchParen ()
"     if exists(":NoMatchParen")
"         :NoMatchParen
"     endif
" endfunction

" augroup plugin_initialize
"     autocmd!
"     autocmd VimEnter * call FuckThatMatchParen()
" augroup END

" function! MyFoldText()
"   set fillchars=fold:\ ,
"   let foldlevel = v:foldlevel
"   if foldclosed(v:foldstart)
"     return foldlevel.' ▶ '.getline(v:foldstart)
"   else
"     " TODO: Currently this doesn't work, as opened folds do not have a
"     " v:foldstart value.
"     echo foldlevel.' ▼ '.getline(v:foldstart)
"   endif
" endfunction
" setlocal foldtext=MyFoldText()

" function! MyFoldText()
"   let foldlevel = v:foldlevel
"   let linecount = v:foldend - v:foldstart + 1
"   if foldclosed(v:foldstart)
"     return '▶ '.foldlevel.' ('.linecount.' lines) '.getline(v:foldstart)
"   else
"     return '▼ '.foldlevel.' ('.linecount.' lines) '.getline(v:foldstart)
"   endif
" endfunction

" TODO: This was suggested by Gemini. Figure out alternatives for FoldEnter
" and FoldLeave, as they do not exist.
"
" function! MyFoldSign(event)
"   if a:event ==# 'opened'
"     exe 'sign unplace '.v:foldstart
"   else
"     exe 'sign place '.v:foldstart.' line='.v:foldstart.' name=myfoldmarker'
"   endif
" endfunction

" augroup MyFoldSigns
"   autocmd!
"   autocmd FoldEnter * call MyFoldSign('enter')
"   autocmd FoldLeave * call MyFoldSign('leave')
"   autocmd BufWinLeave * sign unplace *
" augroup END

" sign define myfoldmarker text=▶ texthl=FoldColumn

" )functions- }}}


" I'm moving stuff to lua slowly. For now it should be loaded last.
exec 'luafile ' .  g:mcra_neovim_init_lua
call _mcra_debug('sourced ' . g:mcra_neovim_init_lua)

