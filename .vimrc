set nocompatible              " be iMproved, required
filetype off                  " required
set t_Co=256
set number
set noswapfile
set hlsearch
let g:mapleader = ","
set directory^=$HOME/.vim/tmp//
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
set so=999

" use a blinking upright bar cursor in Insert mode, a blinking block in normal
if &term == 'xterm-256color' || &term == 'screen-256color'
    let &t_SI = "\<Esc>[5 q"
    let &t_EI = "\<Esc>[1 q"
endif

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Themes
Plugin 'jdkanani/vim-material-theme'
Plugin 'arcticicestudio/nord-vim'
colorscheme nord

" Languages
Plugin 'sheerun/vim-polyglot'
Plugin 'nelsyeung/twig.vim'

" Statusline
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
let g:airline_theme='nord'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'

" Navigation 
Plugin 'scrooloose/nerdtree'
map Q :NERDTreeToggle<CR>
map <Leader>q :NERDTreeFind<CR>
nmap <C-S-Tab> :bp<Cr>
Plugin 'ctrlpvim/ctrlp.vim'
nmap <C-S-Tab> :bp<Cr>

Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

Plugin 'majutsushi/tagbar'
nmap ? :TagbarOpenAutoClose<CR>

" Utility
Plugin 'godlygeek/tabular'
Plugin 'honza/vim-snippets'
Plugin 'scrooloose/nerdcommenter'
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

inoremap <leader>; <C-o>A;
nnoremap <leader>; <C-o>A;<Esc>
inoremap <leader>w <Esc>:w<CR>
nnoremap <Esc> :noh<CR><Esc>
nnoremap <leader>d :bd<CR>
" Ne fonctionne pas
inoremap <C-$> ->
let g:comfortable_motion_no_default_key_mappings = 1
nnoremap <silent> <C-d> :call comfortable_motion#flick(100)<CR>
nnoremap <silent> <C-u> :call comfortable_motion#flick(-100)<CR>

nnoremap <silent> <C-f> :call comfortable_motion#flick(200)<CR>
nnoremap <silent> <C-b> :call comfortable_motion#flick(-200)<CR>

Plugin 'airblade/vim-gitgutter'
Plugin 'ervandew/supertab'

Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'

Plugin 'jiangmiao/auto-pairs'
Plugin 'yuttie/comfortable-motion.vim'
" Ignore files in .gitignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
