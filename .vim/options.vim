filetype off                 
syntax on

set nocompatible              
set t_Co=256
set number
set noswapfile
set hlsearch
set directory^=$HOME/.vim/tmp//
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

let g:mapleader = ","
let g:airline_powerline_fonts = 1

" use a blinking upright bar cursor in Insert mode, a blinking block in normal
let &t_SI = "\<Esc>[5 q"
let &t_EI = "\<Esc>[1 q"

colorscheme nord
