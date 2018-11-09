inoremap <leader>w <Esc>:w<CR>
inoremap <leader>; <Esc>A;
inoremap £ ->
nnoremap <leader>w :w<CR>
nnoremap <leader>d :bd<CR>
nnoremap <S-q> :NERDTreeToggle<CR>
nnoremap <leader>q :NERDTreeFind<CR>
nnoremap <C-p> :GFiles<CR>
nnoremap <leader>t :bn<CR>
nnoremap <leader>T :bp<CR>
nnoremap ? :TagbarOpenAutoClose<CR>/
nmap     <silent> <C-l> <Plug>(jsdoc)
nnoremap F :Files!<CR>
nnoremap S :Ag! 
vnoremap a :Tabularize /

autocmd FileType php nnoremap <leader>u :call PhpInsertUse()<CR>
autocmd FileType php nnoremap <buffer> <leader>l :call pdv#DocumentWithSnip()<CR>
