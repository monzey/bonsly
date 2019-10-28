inoremap <leader>w <Esc>:w<CR>
inoremap <leader>; <Esc>A;
inoremap £ ->
nnoremap <leader>, <C-o>
nnoremap <leader>; <C-i>
nnoremap <leader>w :w<CR>
nnoremap <leader>d <C-W><C-O>:bd<CR>
nnoremap <leader>b :Buffer<CR>
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
nnoremap <leader>cl :let @*=expand("%:p")<CR>
nnoremap <leader><C-y> :let @"=expand("%:p")<CR>
vnoremap <leader>s y:Ag! "<C-R>*<CR>"

autocmd FileType php nnoremap <leader>u :call PhpInsertUse()<CR>
autocmd FileType php nnoremap <buffer> <leader>l :call pdv#DocumentWithSnip()<CR>
