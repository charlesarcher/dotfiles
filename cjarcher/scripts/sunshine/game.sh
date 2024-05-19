if [ $# -ge 1 ]; then
        game="$(which $1)"
        shift
        dwm="$(which dwm)"
        tmpgame="/tmp/tmpgame.sh"
        echo -e "${dwm} &
                 sunshine &
                 ${game} $*" > ${tmpgame}
        echo "starting ${game} $*"
        DISPLAY=:1.0 xinit ${tmpgame} -- :1 -sharevts -novtswitch -xf86config x11.conf || exit 1
        #DISPLAY=:10.0 strace -f -e trace=openat xinit ${tmpgame} -- :10 -xf86config x11.conf vt || exit 1
else
        echo "not a valid argument"
fi
