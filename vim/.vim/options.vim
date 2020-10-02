  filetype off                 
  syntax on

  set clipboard=unnamedplus
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
  set shortmess+=c
  set signcolumn=yes
  hi CursorLineNR cterm=NONE

  " Autocompletion
  filetype plugin on
  set omnifunc=syntxcomplete#Complete

  " For node module resolution
  " set path=.,src,node_modules
  set suffixesadd=.js,.jsx
  set includeexpr=LoadMainNodeModule(v:fname)

  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

  set background=dark
  colorscheme dracula

  autocmd BufEnter * :syntax sync fromstart
  " autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))

  autocmd FileType html,html.twig,php,yaml set tabstop=4
  autocmd FileType html,html.twig,php,yaml set softtabstop=4 
  autocmd FileType html,html.twig,php,yaml set expandtab 
  autocmd FileType html,html.twig,php,yaml set shiftwidth=4 
  autocmd FileType html,html.twig,php,yaml set smarttab

  let g:loaded_matchparen = 1

  let g:minimap_highlight="Visual"

  let g:NERDSpaceDelims=1
  let g:NERDCompactSexyComs=1
  let g:NERDDefaultAlign="left"
  let g:NERDCommentEmptyLines=1
  let g:NERDTreeWinPos = "right"
  let NERDTreeShowHidden=1
  let g:NERDTreeWinSize=50
  let g:NERDTreeHighlightCursorline = 0

  let g:mapleader = ","
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline_theme="dracula"
  let g:indentLine_char = '┆'
  let g:indentLine_enabled = 1
  let g:UltiSnipsExpandTrigger="<tab>"
  let g:UltiSnipsSnippetDirectories=["~/.vim/plugged/vim-snippets/UltiSnips"]
  let s:ag_options = '-f --ignore app/cache --ignore app/logs '
  let g:pdv_template_dir = $HOME .'/.vim/plugged/pdv/templates_snip'

  let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.5, 'highlight': 'Comment' } }
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

  if has('nvim') && !exists('g:fzf_layout')
    autocmd! FileType fzf
    autocmd  FileType fzf set laststatus=0 noshowmode noruler
      \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
  endif

  " use a blinking upright bar cursor in Insert mode, a blinking block in normal
  let &t_SI = "\<Esc>[5 q"
  let &t_EI = "\<Esc>[1 q"

  " theme
  let g:onedark_termcolors=256
  let g:onedark_color_overrides = {
  \ "black": {"gui": "#2F343F", "cterm": "235", "cterm16": "0" },
  \ "purple": { "gui": "#C678DF", "cterm": "170", "cterm16": "5" }
  \}

  "Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
  "If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
  "(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif

  " Vim Outliner
  let maplocalleader = ',,'

  " Vim debug
  let g:vdebug_options = {'ide_key': 'vimsession'}
  let g:vdebug_options.port = 9009
  let g:vdebug_options.path_maps = {"/home/vagrant/rgsupv-core": "/home/monzey/rg/rgsupv-core", "/home/vagrant/rgsupv-dashboard": "/home/monzey/rg/rgsupv-dashboard"}
  let g:vdebug_options.server = ""
  let g:vdebug_options.break_on_open = "0"

  " Goyo
  let g:goyo_width="80%"
  let g:goyo_height="100%"

  " Vim jsx
  let g:vim_jsx_pretty_colorful_config = 1

  " JsDoc
  let g:jsdoc_allow_input_prompt = 1

  " Snippets
  let g:UltiSnipsExpandTrigger="<tab>"
  let g:UltiSnipsJumpForwardTrigger="<c-b>"
  let g:UltiSnipsJumpBackwardTrigger="<c-z>"
  let g:UltiSnipsEditSplit="vertical"

  "CTags
  let g:easytags_async = 1

  " Vim surround
  let g:surround_60 = "<\r>"

  " Vim test
  let test#strategy = 'vimterminal'

  " Highlight symbol under cursor on CursorHold
  autocmd CursorHold * silent call CocActionAsync('highlight')
  " autocmd FileType javascript,javascriptreact,javascript.jsx 
    " \ autocmd BufWriteCmd * silent call CocAction('runCommand', 'eslint.executeAutofix') 

  let g:coc_global_extensions = [
    \ 'coc-tsserver'
    \ ]

  set fillchars+=vert:\ 
