set nocompatible
filetype off

"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" better split
set splitbelow
set splitright

" tab help
ca tn tabnew
ca th tabp
ca tl tabn

" member undo
set undodir=~/.vim/undo
set undofile
set undolevels=1000
set undoreload=10000

" member cursor
au BufReadPost *
\ if line("'\"") > 0 && line ("'\"") <= line("$") |
\   exe "normal! g'\"" |
\   exe "nohlsearch" |
\ endif


" toggle paste
set pastetoggle=<F7>
augroup paste
	au!
	au InsertLeave * set nopaste
augroup END

" use tab to select completor 
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"

set tabstop=4
set shiftwidth=4

"enable folding (collapse code)
set foldmethod=indent
set foldlevel=99
"enable folding with spacebar
nnoremap <space> za


"open nerdtree ctrl+n
nmap <C-n> :NERDTreeToggle<CR>

"pep8 standard
au BufNewFile,BufRead *.py
	\ set tabstop=4 |
	\ set softtabstop=4 |
  	\ set shiftwidth=4 |
	\ set textwidth=79 |
	\ set expandtab |
	\ set autoindent |
	\ set fileformat=unix

set encoding=utf-8


if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'fatih/molokai'
Plug 'mdempsky/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }
Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'
Plug 'bazelbuild/vim-bazel'
Plug 'maralla/completor.vim'
Plug 'scrooloose/nerdtree', { 'on':  'nerdtreetoggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'fatih/vim-go', { 'tag': '*' }
Plug 'cocopon/iceberg.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'morhetz/gruvbox'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-fugitive'
Plug 'vim-syntastic/syntastic'
Plug 'rust-lang/rust.vim'
Plug 'tmhedberg/SimpylFold'
Plug 'vim-scripts/indentpython.vim'
Plug 'pangloss/vim-javascript'
Plug 'google/vim-codefmt'
Plug 'moll/vim-node'
Plug 'crusoexia/vim-monokai'
Plug 'nvie/vim-flake8'
Plug 'airblade/vim-gitgutter'
Plug 'JamshedVesuna/vim-markdown-preview'
Plug 'plasticboy/vim-markdown'
Plug 'morhetz/gruvbox'
call plug#end()

let python_highlight_all=1

call glaive#Install()

augroup autoformat_settings
	autocmd FileType bzl AutoFormatBuffer buildifier
	autocmd FileType go AutoFormatBuffer gofmt
	autocmd FileType python AutoFormatBuffer yapf 
augroup END

au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml foldmethod=indent
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

set autochdir


colorscheme gruvbox
let g:gruvbox_contrast_dark="hard"
let g:gruvbox_italic=1
set background=dark
set cursorcolumn
set number relativenumber
augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
	autocmd BufLeave,FocusGained,InsertEnter * set norelativenumber
augroup END



let g:completor_python_binary = '/usr/bin/python'
let g:completor_gocode_binary = '/home/t/go/bin/gocode'
let g:completor_node_binary = '/home/t/.nvm/versions/node/v8.11.3/bin/node'
let g:completor_clang_binary = '/usr/bin/clang'
let g:completor_racer_binary = '/home/t/.cargo/bin/racer'

let g:airline#extensions#whitespace#enabled = 0
let g:airline_theme='iceberg'


filetype plugin indent on

