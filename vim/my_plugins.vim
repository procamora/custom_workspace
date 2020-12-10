
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif


" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin('~/.vim/plugged')


" Theme colors
"Plug 'morhetz/gruvbox'
Plug 'altercation/vim-colors-solarized'

" Custom config in ~/.vimrc
Plug 'pearofducks/ansible-vim'

" Markdown
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

" 
Plug 'Vimjas/vim-python-pep8-indent'

" Custom config in ~/.vimrc
Plug 'preservim/nerdtree'

Plug 'scrooloose/syntastic'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

"Plug 'kovetskiy/sxhkd-vim'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Custom config in ~/.vimrc
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"Plug 'hashivim/vim-terraform'

Plug 'syngan/vim-vimlint'
Plug 'vim-jp/vim-vimlparser'




" Initialize plugin system
call plug#end()

