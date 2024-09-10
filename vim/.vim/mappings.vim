inoremap <leader>w <Esc>:w<CR>
inoremap <leader>; <Esc>A;
inoremap £ ->
nnoremap <leader>, <C-o>
nnoremap <leader>; <C-i>
nnoremap <leader>w :w<CR>
nnoremap <leader>d <C-W><C-O>:bd<CR>
" <C-@> actually maps to <C-space>
nnoremap <C-space> :Buffer<CR> 
nnoremap <S-q> :NERDTreeToggle<CR>
nnoremap <leader>q :NERDTreeFind<CR>
nnoremap <C-p> :GFiles<CR>
nnoremap <C-j> :bp<CR>
nnoremap <C-k> :bn<CR>
nnoremap ? :TagbarOpenAutoClose<CR>/
nmap     <silent> <C-l> <Plug>(jsdoc)
nnoremap F :Files!<CR>
nnoremap S :Ag! 
nnoremap <leader>s :Ag! <C-R><C-W><CR>
nnoremap <leader><C-f> :Ag! <C-R>=expand('%:t')<CR><CR>
nnoremap <leader>r :%s/<C-R><C-W>//g<left><left>
vnoremap a :Tabularize /
nnoremap <leader>f :Goyo<CR>
nnoremap <leader><CR> :Tags <C-R><C-W><CR>
nnoremap <CR> :
vnoremap <CR> :
nnoremap <leader>$ :vsplit ~/.vimrc<CR>
nnoremap <leader>p :GFiles<CR><C-R><C-W>
nnoremap <space> za
nnoremap <leader><C-t> :TestFile<CR>
nmap <leader>< ysiw<
nnoremap <leader><C-l> :Ag! <C-R>=expand("%:te")<CR><CR>

vnoremap <leader>s y :Ag! "<C-R>"<CR>"

" ####################### coc.nvim
" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

nmap <leader>rn <Plug>(coc-rename)

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <C-p>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><C-n> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-p> to trigger completion.
inoremap <silent><expr> <C-n> coc#refresh()

" ####################### coc.nvim

" execute "set <A-j>=\ej"
" execute "set <A-m>=\em"
" execute "set <A-k>=\ek"
" execute "set <A-l>=\el"
nnoremap <A-j> <C-W>h
nnoremap <A-m> <C-W>l
nnoremap <A-k> <C-W>j
nnoremap <A-l> <C-W>k

autocmd FileType php nnoremap <leader>u :call PhpInsertUse()<CR>
autocmd FileType php nnoremap <buffer> <leader>l :call pdv#DocumentWithSnip()<CR>

" Vim smooth scroll
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>
