#!/usr/bin/env sh
# TODO
# - look for necessary commands at startup
# - linux copy support

# getopts config
set -e
# set -u

# Global Varibles
SCRIPTNAME=$(basename $0)
UNAME=$(uname)
CATCMD=$(which cat)
[ -z $SNIPPYEDITOR ] && SNIPPYEDITOR=$EDITOR
[ -z $SNIPPYFILES ] && SNIPPYFILES="$HOME/.snippy"
SNIPPYVERSION='v1.0'

# Helper Functions
isInstalled () {
    if type "$1" > /dev/null; then
        return 0
    fi

    return 1
}

isMac () {
    [ "$UNAME" = "Darwin" ]
}

isLinux () {
    [ "$UNAME" = "Linux" ]
}


# Config
[ ! -d "$SNIPPYFILES" ] && mkdir -p $SNIPPYFILES
[ ! -d "$SNIPPYFILES/.trash" ] && mkdir -p "$SNIPPYFILES/.trash"

isInstalled bat && { 
    # BAT COMMAND OPTIONS
    export BAT_PAGER=''
    export BAT_STYLE='plain'
    CATCMD=$(which bat)
}


# Main Functions
helper () {
    echo "$SCRIPTNAME $SNIPPYVERSION"
    echo "USAGE:"
    echo "\t$SCRIPTNAME [-lendpcvh] [snippet]"
    echo "OPTIONS:"
    echo "\t-l\tList all exiting snippets"
    echo "\t-e\tEdit snippet"
    echo "\t-n\tCreates new snippet"
    echo "\t-d\tDelete snippet"
    echo "\t-p\tPreview snippet"
    isMac && echo "\t-c\tCopy snippet content"
    echo "\t-v\tPrints $SCRIPTNAME version"
    echo "\t-h\tPrints this help menu"
}

version () {
    echo "$SCRIPTNAME $SNIPPYVERSION"
    exit
}

list () {
    ls -1p $SNIPPYFILES | egrep -v /$ || echo "You don't have any snippets yet."
    exit
}

edit () {
    [ -f "$SNIPPYFILES/$1" ] || echo "Creating snippet $1"
    $SNIPPYEDITOR $SNIPPYFILES/$1
    exit
}

new () {
    [ ! -f "$SNIPPYFILES/$1" ] && $SNIPPYEDITOR "$SNIPPYFILES/$1" && echo "Created snippet $1" || echo "$1 already exist"
    exit
}

remove () {
    mv "$SNIPPYFILES/$1" "$SNIPPYFILES/.trash/"
    exit
}

copy () {
    ! isMac && echo 'This option is currently only available on Mac OS' || $CATCMD $SNIPPYFILES/$1 | pbcopy && echo "$1 copied to clipboard"
    exit
}

preview () {
    $CATCMD $SNIPPYFILES/$1
    exit
}

while getopts "e:n:c:p:d:hlv" o; do
    case "$o" in
        n )
            new "$OPTARG"
            ;;
        e )
            edit "$OPTARG"
            ;;
        l )
            list
            ;;
        c )
            copy "$OPTARG"
            ;;
        p )
            preview "$OPTARG"
            ;;
        d )
            remove "$OPTARG"
            ;;
        h )
            helper
            ;;
        v )
            version
            ;;
        [?] )
            helper
            ;;
        
    esac
done

helper