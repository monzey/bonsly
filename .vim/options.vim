filetype off                 
syntax on

set incsearch
set nocompatible              
set t_Co=256
set number
set noswapfile
set hlsearch
set directory^=$HOME/.vim/tmp//
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

let g:loaded_matchparen = 1

let g:mapleader = ","
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:indentLine_char = '┆'
let g:indentLine_enabled = 1
let g:UltiSnipsExpandTrigger="<tab>"
let s:ag_options = '-f --ignore app/cache --ignore app/logs --ignore sql --ignore web'

command! -bang -nargs=* Ag
        \ call fzf#vim#ag(
        \   <q-args>,
        \   s:ag_options,
        \  <bang>0 ? fzf#vim#with_preview('up:60%')
        \        : fzf#vim#with_preview('right:50%:hidden', '?'),
        \   <bang>0
        \ )

" use a blinking upright bar cursor in Insert mode, a blinking block in normal
let &t_SI = "\<Esc>[5 q"
let &t_EI = "\<Esc>[1 q"

colorscheme nord
