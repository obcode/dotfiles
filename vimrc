
syntax on

call pathogen#runtime_append_all_bundles()

" autocommands

autocmd  BufRead *.htm,*.html se isk+=:,/,~
autocmd FileType make :set noexpandtab

" color

hi comment      ctermfg=blue   ctermbg=white guifg=blue guibg=white
hi SpecialKey   ctermfg=red   ctermbg=yellow guifg=red guibg=yellow
hi LineNr       term=NONE cterm=NONE
hi normal       term=NONE
hi nontext      term=NONE cterm=NONE ctermfg=blue   ctermbg=white
hi search       ctermfg=white ctermbg=red     guifg=white guibg=red
hi statusline   term=NONE cterm=NONE ctermfg=yellow ctermbg=red
hi statuslineNC term=NONE cterm=NONE ctermfg=black  ctermbg=white

hi    User1 cterm=NONE    ctermfg=red    ctermbg=black  guifg=red    guibg=black
hi    User2 cterm=NONE    ctermfg=green  ctermbg=black  guifg=green  guibg=black
hi    User3 cterm=NONE    ctermfg=red    ctermbg=black  guifg=red    guibg=black
hi    User4 cterm=NONE    ctermfg=white  ctermbg=black  guifg=white   guibg=black

fu! Options()
            let opt=""
  if &ai|   let opt=opt." ai"   |endif
  if &et|   let opt=opt." et"   |endif
  if &hls|  let opt=opt." hls"  |endif
  if &paste|let opt=opt." paste"|endif
  if &shiftwidth!=8|let opt=opt." sw=".&shiftwidth|endif
                    let opt=opt." tw=".&tw
  return opt
endf

fu! Version()
  return version
endf

set   statusline=%1*[%02n]%4*\ %(%M%R%H%)\ %<%2*%F%4*\ %=%{fugitive#statusline()}%4*\ %{Options()}\ %3*<%l,%c%V>%*
set noautoindent
set   autowrite
set nobackup
set   backspace=indent,eol,start
set nocompatible
set noerrorbells
set   esckeys
set   expandtab
set   formatoptions=cqrt
set   helpheight=0
set   hidden
set nohlsearch
set noicon
set   ignorecase
set   smartcase
set noinsertmode
set   iskeyword=@,48-57,_,192-255,-,.,@-@
set   joinspaces
set    keywordprg=man\ -s
set   laststatus=2
set   lazyredraw
set   magic
set   modeline
set   modelines=1
set nonumber
set   pastetoggle=<f11>
set   report=0
set   ruler
let &shell="zsh"
set   shiftwidth=4
set   shortmess=at
set   showcmd
set   showmatch
set   showmode
set   suffixes=.aux,.bak,.dvi,.gz,.idx,.log,.ps,.swp,.tar,.class,.hi
set nostartofline
set   splitbelow
set   tabstop=8
set nottyfast
set nottybuiltin
set   ttyscroll=0
set   viminfo=%,'50,\"100,:100,n~/.viminfo
set   visualbell
set   t_vb=
set   whichwrap=<,>,h,l,[,]
set   wildchar=<TAB>
set   wrapmargin=1
set nowritebackup
set autowrite
set list
set listchars=tab:»·,trail:·
set incsearch
set wildmenu
set exrc

map <SPACE> V
map <SPACE><SPACE> <C-v>
vmap <SPACE> mry`r

map <F2>   mr:retab<cr>:%s/\s\+$//g<cr>`r
imap <F2>   <esc><F2>a
map <F3>  :call ToggleListOption()<cr>

noremap Y y$

function ToggleListOption()
    if &list
        :set nolist
    else
        :set list
    endif
endfunction

nnoremap Q gq
vnoremap Q gq

" Project-Plugin
let g:proj_flags="bgmst"

" latex-suite
filetype plugin on
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'
let g:Tex_DefaultTargetFormat='pdf'
let g:Tex_CompileRule_pdf='pdflatex -interaction=nonstopmode $* ; xpdf -remote localhost -reload'
let g:Tex_ViewRule_pdf='xpdf -remote localhost -z page'
let g:Tex_FoldedEnvironments='frame,itemize'
let g:Tex_Env_frame = "\\begin{frame}[fragile]\<CR>{<++>}\<CR>\\begin{itemize}[<+->]\<CR>\\item <++>\<CR>\\end{itemize}\<CR>\\end{frame}<++>"
let g:Tex_Com_lstinline = "\\lstinline|<++>|<++>"
let g:Tex_UseMakefile = 0
let g:Tex_SmartQuoteOpen = ",,"
au BufEnter *.tex set tw=80

" Haskellmode
"
filetype plugin on
filetype indent on

let g:haddock_browser="/usr/bin/chromium"
"let g:haddock_browser_callformat="%s file://%s >/dev/null 2>&1 &"

au BufEnter *.hs compiler ghc
au BufEnter *.hs setl errorformat+=%A%f:%l:\ %m,%A%f:%l:,%C%\\s%m,%Z ai tw=0
au BufEnter *.lhs setl errorformat+=%A%f:%l:\ %m,%A%f:%l:,%C%\\s%m,%Z ai tw=0

au FileType haskell setl foldmethod=marker
au FileType haskell setl set foldmarker={{{,}}}
au FileType haskell setl foldlevelstart=2

" Java

au BufEnter *.java  setl errorformat=%Z%f:%l:\ %m,%A%p^,%-G%*[^sl]%.%#
au BufEnter *.java  setl makeprg=javac\ %\ 2>&1\ \\\|\ vim-javac-filter

" Scala

au BufEnter *.scala  setl makeprg=fsc\ %<.scala
au BufEnter *.scala  setl formatprg=scala\ -cp\ ~/opt/scalariform.jar\ scalariform.commandline.Main\ -f
au BufRead,BufNewFile *.scala setl filetype=scala

" Markdown
au BufEnter *.page  setl filetype=markdown

" vim:tw=70 et sw=4 comments=\:\"
