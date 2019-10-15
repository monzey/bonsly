filetype off                 
syntax on

set nocompatible              
set hidden
set termguicolors
set incsearch
set noswapfile
set hlsearch
set directory^=$HOME/.vim/tmp//
set tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab
set ignorecase
set smartcase
set timeoutlen=400 ttimeoutlen=0
set backspace=indent,eol,start
set nowrap
set nu rnu
set wildmenu
set lazyredraw
set showmatch
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent
set scrolloff=10
set diffopt+=vertical
set history=1000
set undolevels=1000
set title
set nobackup
set noswapfile
hi CursorLineNR cterm=NONE

" For node module resolution
" set path=.,src,node_modules
set suffixesadd=.js,.jsx
set includeexpr=LoadMainNodeModule(v:fname)

let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

set background=dark
colorscheme badwolf

autocmd BufEnter * :syntax sync fromstart
" autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))

" Indentation spécifique javascript
autocmd FileType javascript set tabstop=2
autocmd FileType javascript set softtabstop=2 
autocmd FileType javascript set expandtab 
autocmd FileType javascript set shiftwidth=2 
autocmd FileType javascript set smarttab

autocmd FileType javascriptreact set tabstop=2
autocmd FileType javascriptreact set softtabstop=2 
autocmd FileType javascriptreact set expandtab 
autocmd FileType javascriptreact set shiftwidth=2 
autocmd FileType javascriptreact set smarttab

autocmd FileType html set tabstop=4
autocmd FileType html set softtabstop=4 
autocmd FileType html set expandtab 
autocmd FileType html set shiftwidth=4 
autocmd FileType html set smarttab

autocmd FileType html.twig set tabstop=4
autocmd FileType html.twig set softtabstop=4 
autocmd FileType html.twig set expandtab 
autocmd FileType html.twig set shiftwidth=4 
autocmd FileType html.twig set smarttab

autocmd FileType php set tabstop=4
autocmd FileType php set softtabstop=4 
autocmd FileType php set expandtab 
autocmd FileType php set shiftwidth=4 
autocmd FileType php set smarttab

autocmd FileType yaml set tabstop=4
autocmd FileType yaml set softtabstop=4 
autocmd FileType yaml set expandtab 
autocmd FileType yaml set shiftwidth=4 
autocmd FileType yaml set smarttab

autocmd FileType dart set tabstop=2
autocmd FileType dart set softtabstop=2 
autocmd FileType dart set expandtab 
autocmd FileType dart set shiftwidth=2 
autocmd FileType dart set smarttab

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

let g:mapleader = ","
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme="badwolf"
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

" Vim Outliner
let maplocalleader = ',,'

" Vim debug
let g:vdebug_options = {'ide_key': 'vimsession'}
let g:vdebug_options.port = 9009
let g:vdebug_options.path_maps = {"/home/vagrant/rgsupv-core": "/home/monzey/rg/rgsupv-core", "/home/vagrant/rgsupv-dashboard": "/home/monzey/rg/rgsupv-dashboard"}
let g:vdebug_options.server = ""
let g:vdebug_options.break_on_open = "0"

" Ale
let g:ale_fixers = { 'javascript': ['prettier', 'eslint']}
let g:ale_fix_on_save = 0
let g:ale_set_highlights = 0
let g:ale_sign_column_always = 1
" highlight clear ALEWarningSign

" Goyo
let g:goyo_width="60%"
let g:goyo_height="100%"

" Badwolf
let g:badwolf_tabline = 1

" Vim jsx
let g:vim_jsx_pretty_colorful_config = 1

" JsDoc
let g:jsdoc_allow_input_prompt = 1

" Snippets
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsEditSplit="vertical"

" Polyglot
let g:polyglot_disabled = ['jsx']

"CTags
let g:easytags_async = 1

" Vim surround
let g:surround_60 = "<\r>"

" Vim test
let test#strategy = 'vimterminal'
