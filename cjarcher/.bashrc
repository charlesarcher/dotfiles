#===============================================================
#
# PERSONAL $HOME/.bashrc FILE for bash-2.05a (or later)
#
# Last modified: Tue Apr 15 20:32:34 CEST 2003
#
# This file is read (normally) by interactive shells only.
# Here is the place to define your aliases, functions and
# other interactive features like your prompt.
#
# This file was designed (originally) for Solaris but based
# on Redhat's default .bashrc file
# --> Modified for Linux.
# The majority of the code you'll find here is based on code found
# on Usenet (or internet).
# This bashrc file is a bit overcrowded - remember it is just
# just an example. Tailor it to your needs
#
#
#===============================================================

# --> Comments added by HOWTO author.
# --> And then edited again by ER :-)

#-----------------------------------
# Source global definitions (if any)
#-----------------------------------
export MOSH_TITLE_NOPREFIX=1
export EDITOR=emacs
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

#. /opt/intel/bin/compilervars.sh intel64

if [ -f /etc/bashrc ]; then
        . /etc/bashrc   # --> Read /etc/bashrc, if present.
fi
export LS_COLORS="di=93"

function _env_setup()
{
case $BUILD_ENV_NAME in
  ADE_AIX) if [[ -z $WORKON ]]; then
	       alias cmvc='clear'
               . /project/ode/bin/hpsslenv.sh
           else
	       alias cmvc='clear'
               . /project/ode/bin/ppssetup.ksh
           fi
           export PATH=/tools/bin:/project/ode/bin:$PATH
           ;;
  PDE_LINUX)
	   . /project/devtools/common/currentdevtoolset/bin/pde.setup
           export PATH=/u/cptbld/git/bin:$PATH
           export MANPATH=/u/cptbld/git/share/man:$MANPATH
           ;;
esac
}
alias env_setup='_env_setup'
_env_setup

#-------------------------------------------------------------
# Automatic setting of $DISPLAY (if not set already)
# This works for linux - your mileage may vary....
# The problem is that different types of terminals give
# different answers to 'who am i'......
# I have not found a 'universal' method yet
#-------------------------------------------------------------

function get_xserver ()
{
    case $TERM in
	xterm )
            XSERVER=$(who am i | awk '{print $NF}' | tr -d ')''(' )
            # Ane-Pieter Wieringa suggests the following alternative:
            # I_AM=$(who am i)
            # SERVER=${I_AM#*(}
            # SERVER=${SERVER%*)}

            XSERVER=${XSERVER%%:*}
	    ;;
	aterm | rxvt)
 	# find some code that works here.....
	    ;;
    esac
}

#if [ -z ${DISPLAY:=""} ]; then
#    get_xserver
#    if [[ -z ${XSERVER}  || ${XSERVER} == $(hostname) ||
#           ${XSERVER} == "unix" ]]; then
# 	DISPLAY=":0.0"		# Display on local host
#     else
# 	DISPLAY=${XSERVER}:0.0	# Display on remote host
#     fi
# fi
#
#export DISPLAY

#---------------
# Some settings
#---------------
ulimit -S -c 0        # Don't want any coredumps
set -o notify
set -o noclobber
#set -o ignoreeof
set -o nounset
#set -o xtrace        # Useful for debuging
set -o emacs
# Enable options:
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s mailwarn
shopt -s sourcepath
shopt -s no_empty_cmd_completion  # bash>=2.04 only
shopt -s cmdhist
shopt -s histappend histreedit histverify
shopt -s extglob      # Necessary for programmable completion

# Disable options:
shopt -u mailwarn
unset MAILCHECK       # I don't want my shell to warn me of incoming mail
export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTIGNORE="&:bg:fg:ll:h"
export HISTFILESIZE=50000
export HOSTFILE=$HOME/.hosts	# Put a list of remote hosts in ~/.hosts



#-----------------------
# Greeting, motd etc...
#-----------------------

# Define some colors first:
red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m'              # No Color
# --> Nice. Has the same effect as using "ansi.sys" in DOS.

# Looks best on a black background.....
#echo -e "${CYAN}This is BASH ${RED}${BASH_VERSION%.*}\
#${CYAN} - DISPLAY on ${RED}$DISPLAY${NC}\n"
#date
#if [ -x /usr/games/fortune ]; then
#    /usr/games/fortune -s     # makes our day a bit more fun.... :-)
#fi

function _exit()	# function to run upon exit of shell
{
    echo -e "${RED}Hasta la vista, baby${NC}"
}
#trap _exit EXIT

function mem()
{
    ps -eo rss,pid,euser,args:100 --sort %mem | grep -v grep | grep -i $@ | awk '{printf $1/1024 "MB"; $1=""; print }'
}

#---------------
# Shell Prompt
#---------------

# if [[ "${DISPLAY#$HOST}" != ":0.0" &&  "${DISPLAY}" != ":0" ]]; then
#     HILIT=${red}   # remote machine: prompt will be partly red
# else
#     HILIT=${cyan}  # local machine: prompt will be partly cyan
# fi

HILIT=${red}

#  --> Replace instances of \W with \w in prompt functions below
#+ --> to get display of full path name.

function fastprompt()
{
    unset PROMPT_COMMAND
    case $TERM in
        *term | rxvt )
           PS1="${HILIT}[\h]$NC \W > \[\033]0;\${TERM} [\u@\h] \w\007\] " ;;
	linux )
           PS1="${HILIT}[\h]$NC \W > " ;;
        *)
           PS1="[\h] \W > " ;;
    esac
}

function eliteprompt()
{
    local        BLACK="\[\033[1;30m\]"
    local         BLUE="\[\033[1;34m\]"
    local        GREEN="\[\033[1;32m\]"
    local         CYAN="\[\033[1;36m\]"
    local          RED="\[\033[1;31m\]"
    local       PURPLE="\[\033[1;35m\]"
    local        BROWN="\[\033[1;33m\]"
    local   LIGHT_GRAY="\[\033[1;37m\]"
    local         GRAY="\[\033[0;37m\]"
    local    DARK_GRAY="\[\033[0;30m\]"
    local   LIGHT_BLUE="\[\033[0;34m\]"
    local  LIGHT_GREEN="\[\033[0;32m\]"
    local   LIGHT_CYAN="\[\033[0;36m\]"
    local    LIGHT_RED="\[\033[0;31m\]"
    local LIGHT_PURPLE="\[\033[0;35m\]"
    local       YELLOW="\[\033[0;33m\]"
    local        WHITE="\[\033[0;37m\]"
    local    NO_COLOUR="\[\033[0m\]"
    if [ -z "${SLURM_NODELIST-}" ]; then
        NODELIST=""
    else
        NODELIST="s{$SLURM_NODELIST}:"
    fi
    case $TERM in
        xterm*|rxvt*|screen)
            local TITLEBAR="\[\033]0;${NODELIST}\u@\h:\w\007\]"
            ;;
        *)
            local TITLEBAR=""
            ;;
    esac


#$GRAY-$CYAN-$LIGHT_CYAN(\
#$LIGHT_CYAN)$CYAN-$LIGHT_CYAN(\
#$CYAN\#$GRAY/$CYAN$GRAD1\

local temp=$(tty)
local GRAD1=${temp:5}
PS1="$TITLEBAR\
$GREEN[\$(date +%H:%M)]\
$GREEN[\
$BLUE\u$GRAY@$RED\h\
$GREEN]\
$LIGHT_GRAY\n\
$GREEN[\
\$$GRAY:$YELLOW\w\
$GREEN} $GREEN>$LIGHT_GRAY$NO_COLOUR "
PS2="$LIGHT_CYAN-$CYAN-$GRAY-$NO_COLOUR "
}

tmup ()
{
    echo -n "Updating to latest tmux environment...";
    export IFS=",";
    for line in $(tmux showenv -t $(tmux display -p "#S") | tr "\n" ",");
    do
        if [[ $line == -* ]]; then
            unset $(echo $line | cut -c2-);
        else
            export $line;
        fi;
    done;
    unset IFS;
    echo "Done"
}


function powerprompt()
{
    _powerprompt()
    {
        LOAD=$(uptime|sed -e "s/.*: \([^,]*\).*/\1/" -e "s/ //g")
    }

 PROMPT_COMMAND=_powerprompt
 case $TERM in
   *term | rxvt  )
      PS1="${HILIT}[\A \$LOAD]$NC\n[\h \#] \W > \
           \[\033]0;\${TERM} [\u@\h] \w\007\]" ;;
        linux )
           PS1="${HILIT}[\A - \$LOAD]$NC\n[\h \#] \w > " ;;
        * )
           PS1="[\A - \$LOAD]\n[\h \#] \w > " ;;
 esac
}

eliteprompt     # This is the default prompt -- might be slow
#powerprompt     # This is the default prompt -- might be slow.
                # If too slow, use fastprompt instead.

#===============================================================
#
# ALIASES AND FUNCTIONS
#
# Arguably, some functions defined here are quite big
# (ie 'lowercase') but my workstation has 512Meg of RAM, so ...
# If you want to make this file smaller, these functions can
# be converted into scripts.
#
# Many functions were taken (almost) straight from the bash-2.04
# examples.
#
#===============================================================

#-------------------
# Personnal Aliases
#-------------------
alias h='cd ~/'
alias c='cd /home/archerc/code/'
alias s='cd /home/archerc/stage/'
alias i='cd /home/archerc/code/install'
alias j='jobs -l'
alias r='rlogin'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias glist='for ref in $(git for-each-ref --sort=-committerdate --format="%(refname)" refs/heads/ refs/remotes ); do git log -n1 $ref --pretty=format:"%Cgreen%cr%Creset %C(yellow)%d%Creset %C(bold blue)<%an>%Creset%n" | cat ; done | awk '"'! a["'$0'"]++'"
# -> Prevents accidentally clobbering files.
alias mkdir='mkdir -p'
alias xemacs='\emacs -f server-start -fg white -bg black'
alias emacsserver='\emacs --daemon -q --load ~/.emacs.d/init.el -fg white -bg black'
alias emacs='emacsclient -nw'
alias which='type -all'
alias ..='cd ..'
alias path='echo -e ${PATH//:/\\n}'
alias print='/usr/bin/lp -o nobanner -d $LPDEST'
      # Assumes LPDEST is defined
alias pjet='enscript -h -G -fCourier9 -d $LPDEST'
      # Pretty-print using enscript
alias background='xv -root -quit -max -rmode 5'
      # Put a picture in the background
alias du='du -kh'
alias df='df -kTh'
alias rdm='rdm --daemon --data-dir /home/archerc/.cache/rtags'

# The 'ls' family (this assumes you use the GNU ls)
export OS_NAME=`uname`
case $OS_NAME in
    Linux)
    alias ls='ls -hF --color'	# add colors for filetype recognition
    ;;
    Darwin)
    export PATH=/opt/local/bin:/opt/local/sbin:$PATH
    alias ls='ls -hF --color'	# add colors for filetype recognition
    ;;
    AIX)
    alias ls='ls -F'
    ;;
esac

export PATH=/home/archerc/tools/x86/bin:/home/archerc/.nimble/bin/:/home/archerc/tools/x86/bin:/bin:$PATH

alias la='ls -Al'               # show hidden files
alias lx='ls -lXB'              # sort by extension
alias lk='ls -lSr'              # sort by size
alias lc='ls -lcr'		# sort by change time
alias lu='ls -lur'		# sort by access time
alias lr='ls -lR'               # recursive ls
alias lt='ls -ltr'              # sort by date
alias lm='ls -al |more'         # pipe through 'more'
alias tree='tree -Csu'		# nice alternative to 'ls'
alias cmake37='/net/binlib/tools/cmake-3.7.1-Linux-x86_64/bin/cmake'		# nice alternative to 'ls'

# tailoring 'less'
alias  more='less'
export PAGER=less
export LESSCHARSET='latin1'
export LESSOPEN='|/usr/bin/lesspipe.sh %s 2>&-'
       # Use this if lesspipe.sh exists.
export LESS='-i -w -z-4 -g -e -M -X -R -P%t?f%f :stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'

#----------------
# a few fun ones
#----------------

function xtitle ()
{
    case "$TERM" in
        *term | rxvt |screen)
            echo -n -e "\033]0;$*\007" ;;
        *)
	    ;;
    esac
}

# aliases...
alias top='xtitle Processes on $HOST && top'
alias make='xtitle Making $(basename $PWD) ; make'
alias ncftp="xtitle ncFTP ; ncftp"

# .. and functions
function man ()
{
    for i ; do
	xtitle The $(basename $1|tr -d .[:digit:]) manual
	command man -a "$i"
    done
}

function ll()
{ ls -l "$@"| egrep "^d" ; ls -lXB "$@" 2>&-| egrep -v "^d|total "; }

function te()  # wrapper around xemacs/gnuserv
{
    if [ "$(gnuclient -batch -eval t 2>&-)" == "t" ]; then
        gnuclient -q "$@";
    else
        ( xemacs "$@" &);
    fi
}

#-----------------------------------
# File & strings related functions:
#-----------------------------------

# Find a file with a pattern in name:
function ff()

{ find . -type f -iname '*'$*'*' -ls ; }
# Find a file with pattern $1 in name and Execute $2 on it:

function fe()
{ find . -type f -iname '*'$1'*' -exec "${2:-file}" {} \;  ; }
# find pattern in a set of filesand highlight them:

function fstr()
{
    OPTIND=1
    local case=""
    local usage="fstr: find string in files.
Usage: fstr [-i] \"pattern\" [\"filename pattern\"] "
    while getopts :it opt
    do
        case "$opt" in
        i) case="-i " ;;
        *) echo "$usage"; return;;
        esac
    done
    shift $(( $OPTIND - 1 ))
    if [ "$#" -lt 1 ]; then
        echo "$usage"
        return;
    fi
    local SMSO=$(tput smso)
    local RMSO=$(tput rmso)
    find . -type f -name "${2:-*}" -print0 |
    xargs -0 grep -sn ${case} "$1" 2>&- | \
    sed "s/$1/${SMSO}\0${RMSO}/gI" | more
}

function cuttail() # Cut last n lines in file, 10 by default.
{
    nlines=${2:-10}
    sed -n -e :a -e "1,${nlines}!{P;N;D;};N;ba" $1
}

function lowercase()  # move filenames to lowercase
{
    for file ; do
        filename=${file##*/}
        case "$filename" in
        */*) dirname==${file%/*} ;;
        *) dirname=.;;
        esac
        nf=$(echo $filename | tr A-Z a-z)
        newname="${dirname}/${nf}"
        if [ "$nf" != "$filename" ]; then
            mv "$file" "$newname"
            echo "lowercase: $file --> $newname"
        else
            echo "lowercase: $file not changed."
        fi
    done
}

function swap()         # swap 2 filenames around
{
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}


#-----------------------------------
# Process/system related functions:
#-----------------------------------

function my_ps()
{ ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }

function pp()
{ my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"} ; }

# This function is roughly the same as 'killall' on linux
# but has no equivalent (that I know of) on Solaris
function killps()   # kill by process name
{
   local pid pname sig="-TERM"   # default signal
   if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
       echo "Usage: killps [-SIGNAL] pattern"
       return;
   fi
   if [ $# = 2 ]; then sig=$1 ; fi
   for pid in $(my_ps| awk '!/awk/ && $0~pat { print $1 }' pat=${!#} ) ; do
       pname=$(my_ps | awk '$1~var { print $5 }' var=$pid )
       if ask "Kill process $pid <$pname> with signal $sig?"
           then kill $sig $pid
       fi
   done
}

function my_ip() # get IP adresses
{
    MY_IP=$(/sbin/ifconfig ppp0 | awk '/inet/ { print $2 } ' | \
sed -e s/addr://)
    MY_ISP=$(/sbin/ifconfig ppp0 | awk '/P-t-P/ { print $3 } ' | \
sed -e s/P-t-P://)
}

function ii()   # get current host related info
{
  echo -e "\nYou are logged on ${RED}$HOST"
  echo -e "\nAdditionnal information:$NC " ; uname -a
  echo -e "\n${RED}Users logged on:$NC " ; w -h
  echo -e "\n${RED}Current date :$NC " ; date
  echo -e "\n${RED}Machine stats :$NC " ; uptime
  echo -e "\n${RED}Memory stats :$NC " ; free
  my_ip 2>&- ;
  echo -e "\n${RED}Local IP Address :$NC" ; echo ${MY_IP:-"Not connected"}
  echo -e "\n${RED}ISP Address :$NC" ; echo ${MY_ISP:-"Not connected"}
  echo
}

# Misc utilities:

function repeat()       # repeat n times command
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do  # --> C-like syntax
        eval "$@";
    done
}

function ask()
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

#=======================================================================
#
# PROGRAMMABLE COMPLETION - ONLY SINCE BASH-2.04
# Most are taken from the bash 2.05 documentation and from Ian McDonalds
# 'Bash completion' package
#  (http://www.caliban.org/bash/index.shtml#completion)
# You will in fact need bash-2.05a for some features
#
#=======================================================================

if [ "${BASH_VERSION%.*}" \< "2.05" ]; then
   echo "You will need to upgrade to version 2.05 \
for programmable completion"
   return
fi

shopt -s extglob        # necessary
set +o nounset          # otherwise some completions will fail

complete -A hostname   rsh rcp telnet rlogin r ftp ping disk
complete -A export     printenv
complete -A variable   export local readonly unset
complete -A enabled    builtin
complete -A alias      alias unalias
complete -A function   function
complete -A user       su mail finger

complete -A helptopic  help     # currently same as builtins
complete -A shopt      shopt
complete -A stopped -P '%' bg
complete -A job -P '%'     fg jobs disown

complete -A directory  mkdir rmdir
complete -A directory   -o default cd

# Compression
complete -f -o default -X '*.+(zip|ZIP)'  zip
complete -f -o default -X '!*.+(zip|ZIP)' unzip
complete -f -o default -X '*.+(z|Z)'      compress
complete -f -o default -X '!*.+(z|Z)'     uncompress
complete -f -o default -X '*.+(gz|GZ)'    gzip
complete -f -o default -X '!*.+(gz|GZ)'   gunzip
complete -f -o default -X '*.+(bz2|BZ2)'  bzip2
complete -f -o default -X '!*.+(bz2|BZ2)' bunzip2
# Postscript,pdf,dvi.....
complete -f -o default -X '!*.ps'  gs ghostview ps2pdf ps2ascii
complete -f -o default -X '!*.dvi' dvips dvipdf xdvi dviselect dvitype
complete -f -o default -X '!*.pdf' acroread pdf2ps
complete -f -o default -X '!*.+(pdf|ps)' gv
complete -f -o default -X '!*.texi*' makeinfo texi2dvi texi2html texi2pdf
complete -f -o default -X '!*.tex' tex latex slitex
complete -f -o default -X '!*.lyx' lyx
complete -f -o default -X '!*.+(htm*|HTM*)' lynx html2ps
# Multimedia
complete -f -o default -X '!*.+(jp*g|gif|xpm|png|bmp)' xv gimp
complete -f -o default -X '!*.+(mp3|MP3)' mpg123 mpg321
complete -f -o default -X '!*.+(ogg|OGG)' ogg123



complete -f -o default -X '!*.pl'  perl perl5

# This is a 'universal' completion function - it works when commands have
# a so-called 'long options' mode , ie: 'ls --all' instead of 'ls -a'

_get_longopts ()
{
    $1 --help | sed  -e '/--/!d' -e 's/.*--\([^[:space:].,]*\).*/--\1/'| \
grep ^"$2" |sort -u ;
}

_longopts_func ()
{
    case "${2:-*}" in
	-*)	;;
	*)	return ;;
    esac

    case "$1" in
	\~*)	eval cmd="$1" ;;
	*)	cmd="$1" ;;
    esac
    COMPREPLY=( $(_get_longopts ${1} ${2} ) )
}
complete  -o default -F _longopts_func configure bash
complete  -o default -F _longopts_func wget id info a2ps ls recode


_make_targets ()
{
    local mdef makef gcmd cur prev i

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    # if prev argument is -f, return possible filename completions.
    # we could be a little smarter here and return matches against
    # `makefile Makefile *.mk', whatever exists
    case "$prev" in
        -*f)    COMPREPLY=( $(compgen -f $cur ) ); return 0;;
    esac

    # if we want an option, return the possible posix options
    case "$cur" in
        -)      COMPREPLY=(-e -f -i -k -n -p -q -r -S -s -t); return 0;;
    esac

    # make reads `makefile' before `Makefile'
    if [ -f makefile ]; then
        mdef=makefile
    elif [ -f Makefile ]; then
        mdef=Makefile
    else
        mdef=*.mk               # local convention
    fi

    # before we scan for targets, see if a makefile name was specified
    # with -f
    for (( i=0; i < ${#COMP_WORDS[@]}; i++ )); do
        if [[ ${COMP_WORDS[i]} == -*f ]]; then
            eval makef=${COMP_WORDS[i+1]}      # eval for tilde expansion
            break
        fi
    done

        [ -z "$makef" ] && makef=$mdef

    # if we have a partial word to complete, restrict completions to
    # matches of that word
    if [ -n "$2" ]; then gcmd='grep "^$2"' ; else gcmd=cat ; fi

    # if we don't want to use *.mk, we can take out the cat and use
    # test -f $makef and input redirection
    COMPREPLY=( $(cat $makef 2>/dev/null | \
    awk 'BEGIN {FS=":"} /^[^.#   ][^=]*:/ {print $1}' \
    | tr -s ' ' '\012' | sort -u | eval $gcmd ) )
}

complete -F _make_targets -X '+($*|*.[cho])' make gmake pmake


# cvs(1) completion
_cvs ()
{
    local cur prev
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    if [ $COMP_CWORD -eq 1 ] || [ "${prev:0:1}" = "-" ]; then
        COMPREPLY=( $( compgen -W 'add admin checkout commit diff \
        export history import log rdiff release remove rtag status \
        tag update' $cur ))
    else
        COMPREPLY=( $( compgen -f $cur ))
    fi
    return 0
}
complete -F _cvs cvs

_killall ()
{
    local cur prev
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    # get a list of processes (the first sed evaluation
    # takes care of swapped out processes, the second
    # takes care of getting the basename of the process)
    COMPREPLY=( $( /usr/bin/ps -u $USER -o comm  | \
        sed -e '1,1d' -e 's#[]\[]##g' -e 's#^.*/##'| \
        awk '{if ($0 ~ /^'$cur'/) print $0}' ))

    return 0
}

complete -F _killall killall killps


# A meta-command completion function for commands like sudo(8), which
# need to first complete on a command,
# then complete according to that command's own
# completion definition - currently not quite foolproof
# (e.g. mount and umount don't work properly),
# but still quite useful --
# By Ian McDonald, modified by me.

_my_command()
{
    local cur func cline cspec

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    if [ $COMP_CWORD = 1 ]; then
	COMPREPLY=( $( compgen -c $cur ) )
    elif complete -p ${COMP_WORDS[1]} &>/dev/null; then
	cspec=$( complete -p ${COMP_WORDS[1]} )
	if [ "${cspec%%-F *}" != "${cspec}" ]; then
	    # complete -F <function>
	    #
	    # COMP_CWORD and COMP_WORDS() are not read-only,
	    # so we can set them before handing off to regular
	    # completion routine

	    # set current token number to 1 less than now
	    COMP_CWORD=$(( $COMP_CWORD - 1 ))
	    # get function name
	    func=${cspec#*-F }
	    func=${func%% *}
	    # get current command line minus initial command
	    cline="${COMP_LINE#$1 }"
	    # split current command line tokens into array
		COMP_WORDS=( $cline )
	    $func $cline
	elif [ "${cspec#*-[abcdefgjkvu]}" != "" ]; then
          # complete -[abcdefgjkvu]
          #func=$( echo $cspec | sed -e 's/^.*\(-[abcdefgjkvu]\).*$/\1/' )
          func=$( echo $cspec | sed -e 's/^complete//' -e 's/[^ ]*$//' )
	    COMPREPLY=( $( eval compgen $func $cur ) )
	elif [ "${cspec#*-A}" != "$cspec" ]; then
	    # complete -A <type>
	    func=${cspec#*-A }
	func=${func%% *}
	COMPREPLY=( $( compgen -A $func $cur ) )
	fi
    else
	COMPREPLY=( $( compgen -f $cur ) )
    fi
}


complete -o default -F _my_command nohup exec eval \
trace truss strace sotruss gdb
complete -o default -F _my_command command type which man nice

# . ~/.git-clang-format-completion

# Local Variables:
# mode:shell-script
# sh-shell:bash
# End:

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/archerc/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/archerc/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/archerc/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/archerc/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

