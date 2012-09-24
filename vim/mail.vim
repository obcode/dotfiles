"
"

" Setup to write mails with vim
" To use with Mutt, just put this line your ~/.vimrc :
"   autocmd BufRead /tmp/mutt*      :source ~/.vim/mail



"" ----------------------------------------------------------------------------
""   Automatic line wrap
"" ----------------------------------------------------------------------------

set textwidth=72	" lines length
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

"nmap	<F1>	gqap
"nmap	<F2>	gqqj
"nmap	<F3>	kgqj
"map!	<F1>	<ESC>gqapi
"map!	<F2>	<ESC>gqqji
"map!	<F3>	<ESC>kgqji



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

map	<F6>	:Attach 
imap    <F6>    <C-O>:Attach 

"" ----------------------------------------------------------------------------
""
""   Initializations
""
"" ----------------------------------------------------------------------------

"call Mail_Erase_Sig()
call Mail_Del_Empty_Quoted()
call Mail_Begining()

" vim:ft=vim:
