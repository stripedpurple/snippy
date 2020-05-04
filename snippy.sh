#!/usr/bin/env sh
# TODO
# - write main functions
# - allow for visual editors
# - allow bat command for syntax hightlighting
# - configure bat env variables [see dotfiles]
# - look for necessary commands at startup
# - linux copy support

# getopts config
set -e
set -u

# Global Varibles
UNAME=$(uname)
CATCMD=$(which cat)
[ -z $SNIPPYFILES ] && SNIPPYFILES="$HOME/.snippy"
SNIPPYVERSION='v1.0'

isInstalled bat && {
    # BAT COMMAND OPTIONS
    export BAT_PAGER=''
    export BAT_STYLE='plain'
    CATCMD=$(which bat)
}


# CONFIG
[ ! -d "$SNIPPYFILES" ] && mkdir -p $SNIPPYFILES

# Helper Functions
function helper () {
    echo "$SCRIPTNAME $SNIPPYVERSION"
    echo "USAGE:"
    echo -e "\t$SCRIPTNAME [-lendpcvh] [snippet]"
    echo "OPTIONS:"
    echo -e "\t-l\tList all exiting snippets"
    echo -e "\t-e\tEdit snippet"
    echo -e "\t-n\tCreates new snippet"
    echo -e "\t-d\tDelete snippet"
    echo -e "\t-p\tPreview snippet"
    isMac && echo -e "\t-c\tCopy snippet content"
    echo -e "\t-v\tPrints $SCRIPTNAME version"
    echo -e "\t-h\tPrints this help menu"
}


function isInstalled () {
    if type "$1" > /dev/null; then
        return 0
    fi

    return 1
}

function isMac () {
    [ "$UNAME" == "Darwin" ]
}

function isLinux () {
    [ "$UNAME" == "Linux" ]
}


# Main Functions
function list () {
    ls -1p $SNIPPYFILES | egrep -v /$
}

function edit () {
    [ -f $SNIPPYFILES/$1 ] || echo "Creating snippet $1"
    $EDITOR $SNIPPYFILES/$1
}

function new () {
    [ ! -f $SNIPPYFILES/$1 ] && echo "Creating snippet $1" && $EDITOR $SNIPPYFILES/$1 || echo '$1 already exist'
}

function remove () {
    mv $SNIPPYFILES/$1 $SNIPPYFILES/.trash
}

function copy () {
    ! isMac && echo 'This option is currently only available on Mac OS' || $CATCMD $SNIPPYFILES/$1 | pbcopy && echo "$1 copied to clipboard"
}

function preview () {
    $CATCMD $SNIPPYFILES/$1
}

while getopts :qw:e o; do
    case $o in
        n )
            new $OPTARG
            ;;
        e )
            edit $OPTARG
            ;;
        l )
            list
            ;;
        c )
            copy $OPTARG
            ;;
        p )
            preview $OPTARG
            ;;
        d )
            remove $OPTARG
            ;;
        h )
            helper
            ;;
        \? )
            helper
            ;;
    esac
done
