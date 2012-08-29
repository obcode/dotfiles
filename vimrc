
syntax on

call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" autocommands

autocmd BufRead *.htm,*.html se isk+=:,/,~
autocmd FileType make :set noexpandtab
autocmd BufNewFile,BufRead *.markdown,*.md,*.mdown,*.mkd,*.mkdn,*.txt set ft=pandoc

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
set listchars=tab:»·,trail:·,extends:#,nbsp:.
set incsearch
set wildmenu
set exrc

map <SPACE> V
map <SPACE><SPACE> <C-v>
vmap <SPACE> mry`r

map <F2>   mr:retab<cr>:%s/\s\+$//g<cr>`r
imap <F2>   <esc><F2>a
map <F3>  :call ToggleListOption()<cr>

map <F4>  :BufExplorer<cr>
imap <F4>   <esc><F4>a

nmap <F8> :TagbarToggle<CR>

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
let g:Tex_CompileRule_pdf='pdflatex -interaction=nonstopmode $*'
"let g:Tex_CompileRule_pdf='pdflatex -interaction=nonstopmode $* ; xpdf -remote localhost -reload'
"let g:Tex_ViewRule_pdf='xpdf -remote localhost -z page'
let g:Tex_ViewRule_pdf='/Applications/Skim.app/Contents/MacOS/Skim'
let g:Tex_FoldedEnvironments='frame,itemize'
let g:Tex_Env_frame = "\\begin{frame}[fragile]\<CR>{<++>}\<CR>\\begin{itemize}[<+->]\<CR>\\item <++>\<CR>\\end{itemize}\<CR>\\end{frame}<++>"
let g:Tex_Com_lstinline = "\\lstinline|<++>|<++>"
let g:Tex_UseMakefile = 0
let g:Tex_SmartQuoteOpen = ",,"
au BufEnter *.tex set tw=80

" Haskellmode
"
filetype indent on

let g:haddock_browser="/usr/bin/chromium"
"let g:haddock_browser_callformat="%s file://%s >/dev/null 2>&1 &"
let g:haddock_indexfiledir="/home/obraun/.vim/"

au BufEnter *.hs compiler ghc
au BufEnter *.hs setl errorformat+=%A%f:%l:\ %m,%A%f:%l:,%C%\\s%m,%Z ai tw=0
au BufEnter *.lhs setl errorformat+=%A%f:%l:\ %m,%A%f:%l:,%C%\\s%m,%Z ai tw=0

au FileType haskell setl foldmethod=marker
au FileType haskell setl foldmarker={{{,}}}
au FileType haskell setl foldlevelstart=2
au FileType haskell setl iskeyword=a-z,A-Z,_,.,39

function! OpenHaskellFile()
  let f = tr(matchstr(getline(line('.')), '\(import\s*qualified\|import\)\s*\zs[A-Za-z0-9.]\+'), ".", "/") . ".hs"
  if f == ".hs"
     echohl ErrorMsg
     echo "Not on a valid import line!"
     echohl NONE
     return
  endif
  if filereadable(f)
     if (&modified)
       echohl ErrorMsg
       echo "Current buffer is modified, save it first!"
       echohl NONE
     else
       execute ':e ' . f
     endif
  else
     echohl ErrorMsg
     echo "Can't find file \"" . f . "\" in path"
     echohl NONE
  endif
endfunction
:map <silent> ghf :call OpenHaskellFile()<CR>

" Java

au Filetype java set makeprg=javac\ %
au Filetype java set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
au FileType java map  <F5> <CR>:make<CR>
au FileType java imap <F5> <esc><F5>a
au FileType java map  <F6> :!echo %\|awk -F. '{print $1}'\|xargs java<CR>
au FileType java imap <F6> <esc><F6>a

" Scala

au BufEnter *.scala  setl makeprg=fsc\ %<.scala
au BufEnter *.scala  setl formatprg=scala\ -cp\ ~/opt/scalariform.jar\ scalariform.commandline.Main\ -f
au BufRead,BufNewFile *.scala setl filetype=scala

" Markdown
au BufEnter *.page  setl filetype=markdown

" syntactics
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=1
let g:syntastic_quiet_warnings=1
let g:syntastic_mode_map = { 'mode': 'active',
                           \ 'active_filetypes': [],
                           \ 'passive_filetypes': ['tex'] }

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" supertab
"let g:SuperTabDefaultCompletionType = "<C-X><C-O>"

" Go
au BufRead,BufNewFile *.go set filetype=go

" Pandoc
au FileType pandoc map <F5> :w<CR>:PandocHtml<CR><ESC>
au FileType pandoc imap <F5>   <esc><F5>a
au FileType pandoc map <F6> :w<CR>:PandocPdf<CR><ESC>
au FileType pandoc imap <F6>   <esc><F6>a

" Neocomplcache
let g:neocomplcache_enable_at_startup = 1

" vim:tw=70 et sw=4 comments=\:\"
