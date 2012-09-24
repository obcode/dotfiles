"
"

" Setup to write mails with vim
" To use with Mutt, just put this line your ~/.vimrc :
"   autocmd BufRead /tmp/mutt*      :source ~/.vim/mail



"" ----------------------------------------------------------------------------
""   Automatic line wrap
"" ----------------------------------------------------------------------------

set textwidth=72        " lines length
set formatoptions=tcql

" * <F1> to re-format the current paragraph correctly
" * <F2> to format a line which is too long, and go to the next line
" * <F3> to merge the previous line with the current one, with a correct
"        formatting (sometimes useful associated with <F2>)
"
" These keys might be used both in command mode and edit mode.
"
" <F1> might be smarter to use with the Mail_Del_Empty_Quoted() function
" defined below

"nmap   <F1>    gqap
"nmap   <F2>    gqqj
"nmap   <F3>    kgqj
"map!   <F1>    <ESC>gqapi
"map!   <F2>    <ESC>gqqji
"map!   <F3>    <ESC>kgqji



"" ----------------------------------------------------------------------------
""   Suppressing quoted signature (if any) when replying
"" ----------------------------------------------------------------------------

" Thanks to Luc Hermitte for this function
" (http://hermitte.free.fr/vim/ressources/Mail_Sig.set)

function! Mail_Erase_Sig()
  " Search for the signature pattern : "^> -- $"
  let i = line ('$')
  while i >= 1
    " This pattern takes into account signature delimiters from broken mailers
    " that forget the space after the two dashes
    if getline(i) =~ '^> *-- \=$'
      break
    endif
    let i = i - 1
  endwhile
  " If found, then
  if i != 0
    " First, search for the last non empty (non sig) line
    while i >= 1
        let i = i - 1
      " rem : i can't value 1
      if getline(i) !~ '^\(>\s*\)*$'
        break
      endif
    endwhile
    " Second, delete these lines plus the signature
    let i = i + 1
    let j = line ('$')
"CHANGED!!!! In the next line replaced i by j !!!!!!
    while j >= 1
      if getline(j) =~ '^-- $'
        break
      endif
      let j = j - 1
    endwhile
    if i > j
      let j = line ('$')
    else
      let j = j - 1
    endif
    exe 'normal '.i.'Gd'.j.'G'
    exe 'normal '.i.'GO'
  endif
endfunction



"" ----------------------------------------------------------------------------
""   Replacing empty quoted lines (i.e. "> $") with empty lines
""   (convenient to automatically reformat one paragraph)
"" ----------------------------------------------------------------------------

function! Mail_Del_Empty_Quoted()
  "exe "normal :%s/^>\\s\\+$//e\<CR>"
  exe "normal :%s/^[> ]*$//e\<CR>"
endfunction



"" ----------------------------------------------------------------------------
""   Moving the cursor at the begining of the mail
"" ----------------------------------------------------------------------------

function! Mail_Begining()
  exe "normal gg"
  if getline (line ('.')) =~ '^From: '
    " if we use edit_headers in Mutt, then go after the headers
    exe "normal /^$/+\<CR>"
  endif
endfunction

command! -nargs=1 -complete=file Attach :call AttachFieldFunction(<q-args>)
function! AttachFieldFunction(file)
  execute "normal mx1G/^ *$/\<CR>"
  execute "normal OAttach: ". a:file . "\<ESC>`x"
endfunction()

map     <F6>    :Attach
imap    <F6>    <C-O>:Attach

"" ----------------------------------------------------------------------------
""
""   Initializations
""
"" ----------------------------------------------------------------------------

"call Mail_Erase_Sig()
call Mail_Del_Empty_Quoted()
call Mail_Begining()

" ===================================================================
" Email
" ===================================================================
"
"      ,ksr = "kill space runs"
"             substitutes runs of two or more space to a single space:
" nmap ,ksr :%s/  */ /g
" vmap ,ksr  :s/  */ /g
  nmap ,ksr :%s/  \+/ /g
  vmap ,ksr  :s/  \+/ /g
" Why can't the removal of space runs be
" an option of "text formatting"? *hrmpf*
"
"    ,Sel = "squeeze empty lines"
"    Convert blocks of empty lines (not even whitespace included)
"    into *one* empty line (within current visual):
   map ,Sel :g/^$/,/./-j
"
"    ,Sbl = "squeeze blank lines"
"    Convert all blocks of blank lines (containing whitespace only)
"    into *one* empty line (within current visual):
"  map ,Sbl :g/^\s*$/,/[^ <C-I>]/-j
"  map ,Sbl :g/^\s*$/,/[^ \t]/-j
   map ,Sbl :g/^\s*$/,/\S/-j
" Attribution Fixing: from "Last, First" to "First Last":
   map ,ATT gg}jWdWWPX
"
" ===================================================================
" Editing of email replies and Usenet followups - using autocommands
" ===================================================================
"
"      ,dp = de-quote current inner paragraph
"  map ,dp {jma}kmb:'a,'bs/^> //<CR>
   map ,dp vip:s/^> //<CR>
  vmap ,dp    :s/^> //<CR>
"      ,qp = quote current inner paragraph (works since vim-5.0q)
"            select inner paragraph
"            then do the quoting as a substitution:
   map ,qp   vip:s/^/> /<CR>
"
"      ,qp = quote current paragraph
"            just do the quoting as a substitution:
  vmap ,qp    :s/^/> /<CR>
"
"       ## = comment current inner paragraph with '#':
  nmap  ##   vip:s/^/#<space>/<CR>
  vmap  ##      :s/^/#<space>/<CR>
"
" Changing quote style to *the* true quote prefix string "> ":
"
"       Fix Supercite aka PowerQuote (Hi, Andi! :-):
"       before ,kpq:    >   Sven> text
"       after  ,kpq:    > > text
"      ,kpq kill power quote
  vmap ,kpq :s/^> *[a-zA-Z]*>/> >/<C-M>
"
"       Fix various other quote characters:
"      ,fq "fix quoting"
  vmap ,fq :s/^> \([-":}\|][ <C-I>]\)/> > /
"
"  Fix the quoting of "Microsoft Internet E-Mail":
"  The guilty mailer identifies like this:
"  X-Mailer: Microsoft Internet E-Mail/MAPI - 8.0.0.4211
"
"  And this is how it quotes - with a pseudo header:
"
"  -----Ursprungliche Nachricht-----
"  Von:            NAME [SMTP:ADDRESS]
"  Gesendet am:    Donnerstag,  6. April 2000 12:07
"  An:             NAME
"  Cc:             NAME
"  Betreff:        foobar
"
" And here's how I "fix" this quoting:
" (it makes use of the mappings ",dp" and ",qp"):
  map #fix /^> -----.*-----$<cr>O<esc>j,dp<c-o>dapVG,qp
"
" Part 5 - Reformatting Text
"
"  NOTE:  The following mapping require formatoptions to include 'r'
"    and "comments" to include "n:>" (ie "nested" comments with '>').
"
" Formatting the current paragraph according to
" the current 'textwidth' with ^J (control-j):
  imap <C-J> <C-O>gqap
  nmap <C-J>      gqap
  vmap <C-J>      gq
"
" Here is a variation of this command.  It inserts the character
" CTRL-Z at the current position to enable to rebound to the
" previous position within the text.  [Hello, Y. K. Puckett!]
"  map <C-J> i<C-Z><esc>gqip?<C-Z><cr>x
" imap <C-J>  <C-Z><esc>gqip?<C-Z><cr>xi
"
"      ,b = break line in commented text (to be used on a space)
" nmap ,b dwi<CR>> <ESC>
  nmap ,b r<CR>
"      ,j = join line in commented text
"           (can be used anywhere on the line)
" nmap ,j Jxx
  nmap ,j Vjgq
"
"      ,B = break line at current position *and* join the next line
" nmap ,B i<CR>><ESC>Jxx
  nmap ,B r<CR>Vjgq
"
"      ,,, break current line at current column,
"          inserting ellipsis and "filling space":
" nmap ,,,  ,,1,,2
" nmap ,,1  a...X...<ESC>FXr<CR>lmaky$o<CC-R>"<ESC>
" nmap ,,2  :s/./ /g<C-M>3X0"yy$dd`a"yP
"
"
" ===================================================================
" Edit your reply!  (Or else!)
" ===================================================================
"
" Part 6  - Inserting Special or Standard Text
" Part 6a - The header

"    Add adresses for To: and Cc: lines
"
"     ,ca = check alias (reads in expansion of alias name)
" map ,ca :r!elmalias -f "\%v (\%n)"
"     ,Ca = check alias (reads in expansion of alias name)
" map ,Ca :r!elmalias -f "\%n <\%v>"
"
"     ,cS = change Sven's address.
"  map ,cS 1G/^From: /e+1<CR>CSven Guckes <guckes@vim.org><ESC>
"     Used when replying as the "guy from vim".
"
"               Adjusting my Reply-To line [001010]
"
"       Reply-To: guckes-usenet@math.fu-berlin.de
"
"     ,cr = change Reply-TO line
"  map ,cr 1G/^Reply-To: guckes-usenet/e-5<CR>ct@
"
"               Fixing the Subject line
"
"    Pet peeve:  Unmeaningful Subject lines.  Change them!
"     ,cs = change Subject: line
  map ,cs 1G/^Subject: <CR>yypIX-Old-<ESC>-W
"    This command keeps the old Subject line in "X-Old-Subject:" -
"    so the recipient can still search for it and
"    you keep a copy for editing.
"
"
"     ,re : Condense multiple "Re:_" to just one "Re:":
  map ,re 1G/^Sub<CR>:s/\(Re: \)\+/Re: /<CR>
"
"     ,Re : Change "Re: Re[n]" to "Re[n+1]" in Subject lines:
  map ,Re 1G/^Subject: <C-M>:s/Re: Re\[\([0-9]\+\)\]/Re[\1]/<C-M><C-A>
"
" Put parentheses around "visual text"
"      Used when commenting out an old subject.
"      Example:
"      Subject: help
"      Subject: vim - using autoindent (Re: help)
"
"      ,) and ,( :
  vmap ,( v`<i(<ESC>`>a)<ESC>
  vmap ,) v`<i(<ESC>`>a)<ESC>
"
" Part 6  - Inserting Special or Standard Text
" Part 6a - Start of text - saying "hello".
"
"     ,hi = "Hi!"        (indicates first reply)
  map ,hi 1G}oHi!<CR><ESC>
"
"     ,ha = "helloagain"  (indicates reply to reply)
  map ,ha 1G}oHello, again!<CR><ESC>
"
"     ;HA = "Hallo, <NAME>!"  (German equivalent of "hi!" for replies)
" map ;HA G/Quoting /e+1<CR>ye1G}oHallo, !<ESC>Po<ESC>
" map ;HA G/^\* /e+1<CR>ye1G}oHallo, !<ESC>Po<ESC>
  map ;;  G/^\* /e+1<CR>ye1G}oHi <c-r>",<cr><ESC>
  map ;hh  G/^\* <CR>wwye1G}oHallo Herr <c-r>",<cr><ESC>
  map ;hf  G/^\* <CR>wwye1G}oHallo Frau <c-r>",<cr><ESC>
  map ;sh  G/^\* <CR>wwye1G}oSehr geehrter Herr <c-r>",<cr><ESC>
  map ;sf  G/^\* <CR>wwye1G}oSehr geehrte Frau <c-r>",<cr><ESC>

"
"     ,He = "Hello, <NAME>!"
" map ,He G/Quoting /e+1<CR>ye1G}oHallo, !<ESC>Po<ESC>
  map ,He G/^\* /e+1<CR>ye1G}oHello, !<ESC>Po<ESC>
"

  map ;fo  mx1G/^From: <CR>:s/<.*>/<ob@obraun.net>/<CR>`x
  map ;fh  mx1G/^From: <CR>:s/<.*>/<ob@cs.hm.edu>/<CR>`x

" vim:ft=vim:
