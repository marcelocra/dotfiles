" vim:fdm=marker:fmr={{{,}}}:fdl=0:fen:ai:et:ts=2:sw=2:tw=80:ff=unix:fenc=utf8:et:fixeol:eol:
"
" This file chooses which Vim/Neovim config files should load.



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
    echom 'No file at: ' . s:vimrc
    finish
  endif

  exec 'source ' . s:vimrc
  finish
endif



" NEOVIM SETTINGS


" We need all these files to exist. The main one is sourced here and then it
" sources the other ones, in the correct order.
let g:mcra_neovim_init = expand("~/.config/nvim/neovim.vim")
let g:mcra_vimrc = expand("~/.config/nvim/vimrc")
let g:mcra_neovim_init_lua = expand("~/.config/nvim/neovim.lua")


if !filereadable(g:mcra_vimrc)
  \ || !filereadable(g:mcra_neovim_init)
  \ || !filereadable(g:mcra_neovim_init_lua)
  echom 'Missing some config files in ~/.config/nvim. I expect all of these: vimrc, neovim.vim, neovim.lua'
  finish
endif

echom 'Found all required files! Will start sourcing them shortly...'

" This file source the other two.
exec 'source ' . g:mcra_neovim_init

