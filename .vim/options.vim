filetype off                 
syntax on

set termguicolors
set incsearch
set nocompatible              
set number
set noswapfile
set hlsearch
set directory^=$HOME/.vim/tmp//
set tabstop=4 softtabstop=4 expandtab shiftwidth=4 smarttab
set ignorecase
set smartcase
set timeoutlen=400 ttimeoutlen=0
set backspace=indent,eol,start
set nowrap

set scrolloff=10


let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

set background=dark
colorscheme onedark

autocmd BufEnter * :syntax sync fromstart

" Indentation spécifique javascript
autocmd FileType javascript set tabstop=2
autocmd FileType javascript set softtabstop=2 
autocmd FileType javascript set expandtab 
autocmd FileType javascript set shiftwidth=2 
autocmd FileType javascript set smarttab

autocmd FileType typescript set tabstop=2
autocmd FileType typescript set softtabstop=2 
autocmd FileType typescript set expandtab 
autocmd FileType typescript set shiftwidth=2 
autocmd FileType typescript set smarttab

let g:loaded_matchparen = 1

let g:minimap_highlight="Visual"

let g:NERDSpaceDelims=1
let g:NERDCompactSexyComs=1
let g:NERDDefaultAlign="left"
let g:NERDCommentEmptyLines=1

let g:onedark_termcolors=16
let g:mapleader = ","
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme="onedark"
let g:indentLine_char = '┆'
let g:indentLine_enabled = 1
let g:UltiSnipsExpandTrigger="<tab>"
let s:ag_options = '-f --ignore app/cache --ignore app/logs '
let g:pdv_template_dir = $HOME .'/.vim/plugged/pdv/templates_snip'

command! -bang -nargs=+ -complete=dir Ag
        \ call fzf#vim#ag_raw(
        \   s:ag_options.<q-args>,
        \   <bang>0 ? fzf#vim#with_preview('up:80%')
        \           : fzf#vim#with_preview('right:50%:hidden', '?'),
        \   <bang>0
        \ )

command! -bang -nargs=? -complete=dir Files
        \ call fzf#vim#files(
        \ <q-args>,
        \ fzf#vim#with_preview('right:50%:hidden', '?'))

" use a blinking upright bar cursor in Insert mode, a blinking block in normal
let &t_SI = "\<Esc>[5 q"
let &t_EI = "\<Esc>[1 q"

