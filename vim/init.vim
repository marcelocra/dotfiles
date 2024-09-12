" vim:fdm=marker:fmr={{{,}}}:fdl=0:fen:ai:et:ts=2:sw=2:tw=80:ff=unix:fenc=utf8:et:fixeol:eol:
"
" Choose which files to load, based on where Neovim is running.



" HELPERS

" Enable logs by setting this to 1.
let g:mcra_debug = 1
let g:mcra_debug_out = ''
let g:mcra_output = ''

" printf-like function, for debugging.
function! _mcra_debug(text)
  if g:mcra_debug
    let g:mcra_debug_out = g:mcra_debug_out . a:text . '; '
  endif
endfunction

" Do not show a message right away, but append it to `:messages`.
function! _mcra_silent_echo(text)
  let g:mcra_output = g:mcra_output . a:text . '; '
endfunction



" VSCODE NEOVIM SETTINGS



if exists('g:vscode')
  call _mcra_silent_echo("neovim inside vscode")
  finish
endif



" VIM SETTINGS
" For when Neovim is not available.


if !has('nvim')
  let s:vimrc = expand("~/.vim/vimrc")

  if !filereadable(s:vimrc)
    echom 'No file at: ' .. s:vimrc
    finish
  endif

  exec 'source '.. s:vimrc
  finish
endif



" NEOVIM SETTINGS


let s:neovim_vim = expand("~/.config/nvim/neovim.vim")
let s:neovim_vimrc = expand("~/.config/nvim/vimrc")
let s:neovim_lua = expand("~/.config/nvim/neovim.lua")


if !filereadable(s:neovim_vim)
  \ || !filereadable(s:neovim_vimrc)
  \ || !filereadable(s:neovim_lua)
  echom 'Missing some config files in ~/.config/nvim. I expect all of these: neovim.vim, vimrc, neovim.lua'
  finish
endif

call _mcra_silent_echo('Loading config files...')

exec 'source ' .. s:neovim_vim
exec 'source ' .. s:neovim_vimrc

exec 'luafile ' ..  s:neovim_lua

