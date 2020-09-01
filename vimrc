"================= Basic Config =================

" mouse scrolling support
set mouse=a

" layout/format
set expandtab
set tabstop=4
set shiftwidth=4

" line number
set relativenumber
set number

" column & line highlight
set cursorcolumn
set cursorline

highlight CursorLine    cterm=NONE ctermbg=white ctermfg=NONE guibg=NONE guifg=NONE
highlight CursorColumn  cterm=NONE ctermbg=white ctermfg=NONE guibg=NONE guifg=NONE

" search
set ignorecase
set incsearch
set hlsearch
set smartcase

" always show status line
set laststatus=2
"================================================


"===================== Plugins ==================
" automated installation of vimplug if not installed
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source ~/.config/nvim/init.vim
endif

" automatically install missing plugins on startup
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif

" load plugins
call plug#begin()

" status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" colorscheme
Plug 'ayu-theme/ayu-vim' 

Plug 'neoclide/coc.nvim', { 'branch': 'release' }

Plug 'tpope/vim-sleuth'
Plug 'editorconfig/editorconfig-vim'

Plug 'jiangmiao/auto-pairs'
Plug 'machakann/vim-sandwich'

" git
Plug 'airblade/vim-gitgutter'

" nerdtree
Plug 'preservim/nerdtree'

" tags
Plug 'ludovicchabant/vim-gutentags'
Plug 'skywind3000/gutentags_plus'
Plug 'vim-scripts/taglist.vim'

" ack vim
Plug 'mileszs/ack.vim'

call plug#end()

"================================================


"================ Plugins Config ================

" airline
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#enabled = 1

" nerdtree
let NERDTreeShowHidden=0
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
let g:NERDTreeWinSize=35
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark<Space>
map <leader>nf :NERDTreeFind<cr>

" gutentags
" enable gtags module
let g:gutentags_modules = ['ctags', 'gtags_cscope']

" config project root markers.
let g:gutentags_project_root = ['.root', '.git', '.idea', '.vscode']

" generate datebases in my cache directory, prevent gtags files polluting my project
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

""" taglist
nnoremap <silent> <F8> :TlistToggle<CR>
let Tlist_Show_One_File = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Use_Right_Window = 1

" change focus to quickfix window after search (optional).
let g:gutentags_plus_switch = 1

set statusline+=%{gutentags#statusline()}
let g:gutentags_project_root = ['Makefile']
let g:gutentags_cache_dir = '~/.vim/tags'

"================================================


"================= Color Themes =================

colorscheme ayu

" ayu colorscheme config
set termguicolors     " enable true colors support
let ayucolor="light"  " for light version of theme
let ayucolor="mirage" " for mirage version of theme
let ayucolor="dark"   " for dark version of theme

" airline colorscheme config
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'
let g:airline_powerline_fonts = 1

"================================================


"================= Key Mappings =================

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

inoremap <silent><expr> <C-space> coc#refresh()

"GoTo code navigation
nmap <leader>g <C-o>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nmap <leader>rn <Plug>(coc-rename)

"show all diagnostics.
nnoremap <silent> <space>d :<C-u>CocList diagnostics<cr>
"manage extensions.
nnoremap <silent> <space>e :<C-u>CocList extensions<cr>

" window spliting/movement
function! WinMove(key)
    let t:curwin = winnr()
    exec "wincmd ".a:key
    if (t:curwin == winnr())
        if (match(a:key,'[jk]'))
            wincmd v
        else
            wincmd s
        endif
        exec "wincmd ".a:key
    endif
endfunction

nnoremap <silent> <C-h> :call WinMove('h')<CR>
nnoremap <silent> <C-j> :call WinMove('j')<CR>
nnoremap <silent> <C-k> :call WinMove('k')<CR>
nnoremap <silent> <C-l> :call WinMove('l')<CR>

"================================================

