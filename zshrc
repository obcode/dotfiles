######################################################################
# Antigen
source ~/dotfiles/antigen/antigen.zsh
antigen use oh-my-zsh

antigen bundle brew
antigen bundle brew-cask
antigen bundle forklift
antigen bundle git
antigen bundle osx
antigen bundle vi-mode

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions src

# nice themes:
# arrow obraun candy apple edvardm fino juanghurtado kphoen miloshadzic
# wedisagree
antigen-theme wedisagree
antigen-apply
######################################################################

# Customize to your needs...
export PATH=./.cabal-sandbox/bin:~/bin:~/.cabal/bin:/usr/local/bin:/usr/local/sbin:/usr/texbin:/Applications/ghc-7.8.4.app/Contents/bin:$PATH

export EDITOR=/usr/bin/vim

export LANG="de_DE.UTF-8"
export LC_COLLATE="C"

# nocorrect
alias mv='nocorrect mv'       # no spelling correction on mv
alias cp='nocorrect cp'       # no spelling correction on cp
alias mkdir='nocorrect mkdir' # no spelling correction on mkdir

#alias ls='/bin/ls --color=yes'
# jeez I'm lazy ...
alias l='ls -l'
alias ll='ls -l'
alias la='ls -a'
alias lsa='ls -la'
alias lsh='ls -d .*'
alias ld='ls -ld'
# damn, missed out lsd :-)
alias sl=ls # often screw this up

alias dirs='dirs -v'
alias d=dirs

# Hosts to use for completion (see later zstyle)
hosts=(
    "$_etc_hosts[@]"
    localhost
    freefall.freebsd.org
    ob.cs.hm.edu
    terraform.cs.hm.edu
)

zstyle ':completion:*' hosts $hosts

# All my accounts:
my_accounts=(
    obraun:
)
zstyle ':completion:*:my-accounts' users-hosts $my_accounts
zstyle ':completion:*:other-accounts' users-hosts $other_accounts

export EMAIL="ob@obraun.net"

export PAGER=vimpager
#export MANPAGER=/usr/bin/vimmanpager

export READNULLCMD=most

# su changes window title, even if we're not a login shell
su () {
  command su "$@"
  cx
}

alias man='nocorrect man'

set_title () {
  local num title

  type="$1"
  shift
  case "$type" in
    window) num=2
            ;;
      icon) num=1
            ;;
         *) print "Usage: set_title ( window | title ) <title>"
            return 1
            ;;
  esac

  title="$1"

  # Other checks will need to be added here.
  if [[ "$TERM" == 'linux' ]]; then
#    print "Cannot currently display $1 title; only remembering value set."
  else
    echo -n "\e]$num;$title\a"
  fi
}

cx () {
  local long_host short_host title_host short_from_opts

  long_host=${HOST}
  short_host=${HOST%%.*}

  if [[ "$1" == "-s" ]]; then
    short_from_opts=yes
    shift
  fi

  if [[ ${+CX_SHORT_HOSTNAMES} -eq 1 || "$short_from_opts" == "yes" ]]; then
    title_host=$short_host
  else
    title_host=$long_host
  fi

  if [[ "$ZSH_VERSION_TYPE" == 'new' ]]; then
    (( $+title )) || typeset -gT TITLE title
    (( $+title )) || typeset -gT ITITLE ititle
  fi

  : ${TITLE_SHLVL:=$SHLVL}
  export TITLE_SHLVL

  if [[ "$SHLVL" != "$TITLE_SHLVL" ]]; then
    # We've changed shell; assume that the most recently pushed entry
    # is the starting piont for the new shell.
    TITLE_SHLVL=$SHLVL
    [[  ${(t)title} == 'array' ]] &&  title=( "$title[1]" )
    [[ ${(t)ititle} == 'array' ]] && ititle=( "$ititle[1]" )
  fi

  suffix="$USERNAME@${title_host}"
  isuffix="$USERNAME@${short_host}"

  export TITLE ITITLE

  if (( $# == 0 )); then
    # restore current setting
    if (( $#title == 0 )); then
      full_title="$suffix"
      full_ititle="$isuffix"
    else
      full_title="$title[1] : $suffix"
      full_ititle="$ititle[1] : $isuffix"
    fi
  else
    # push new setting
    if (( $#title )); then
      title=(  "$*" "$title[@]" )
      ititle=( "$*" "$ititle[@]" )
    else
      title=( "$*" )
      ititle=( "$*" )
    fi

    if [[ -z "$*" ]]; then
      # allow pushing of ""
      full_title="$suffix"
      full_ititle="$isuffix"
    else
      full_title="$* : $suffix"
      full_ititle="$* : $isuffix"
    fi
  fi

  set_title window "$full_title"
  set_title icon "$full_ititle"
}

cxx () {
  # pop
  (( $#title )) && shift title ititle
  cx "$@"
}

cxl () {
  # show stack
  echo ${(F)title}
}

livehacking () {
  export PROMPT="%{${fg_bold[blue]}%}$%{$reset_color%} "
}

livehackingtmp () {
  livehacking();
  mkdir /tmp/live
  cd /tmp/live
}

compdef '_files -g "*.pdf"' /Applications/Skim.app/Contents/MacOS/Skim

rip () {
    diskutil unmount /dev/disk2
    abcde
    diskutil eject /dev/disk2
}

#git_prompt_info() {}

# vim:ft=zsh:tw=99999
