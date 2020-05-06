#!/usr/bin/env sh
# getopts config
set -e
# set -u

# Global Varibles
SNIPPYSCRIPTNAME="$(basename $0)"
SNIPPYSCRIPTLOCATION="$(dirname $0)"
SNIPPYGITLOCATION="$(dirname $(ls -l $0 | awk -F ' -> ' '{print $NF}'))"
SNIPPYCODENAME="Who Will Cut Our Hair When We're Gone?"
UNAME=$(uname)
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

[ -z "$SNIPPYCATCMD" ] && isInstalled bat && {
    # BAT COMMAND OPTIONS
    export BAT_PAGER=''
    export BAT_STYLE='plain'
    SNIPPYCATCMD=$(which bat)
} || ([ -z "$SNIPPYCATCMD" ] && SNIPPYCATCMD="$(which cat)") || SNIPPYCATCMD="$SNIPPYCATCMD"


# Main Functions
helper () {
    echo "$SNIPPYSCRIPTNAME $SNIPPYVERSION"
    echo "USAGE:"
    echo "\t$SNIPPYSCRIPTNAME [-lendpUcvh] [snippet]"
    echo "OPTIONS:"
    echo "\t-l\tList all exiting snippets"
    echo "\t-e\tEdit snippet"
    echo "\t-n\tCreates new snippet"
    echo "\t-d\tDelete snippet"
    echo "\t-p\tPreview snippet"
    echo "\t-U\tUpdates $SCRIPTNAME (Requires git)"
    isMac && echo "\t-c\tCopy snippet content"
    echo "\t-v\tPrints $SCRIPTNAME version"
    echo "\t-h\tPrints this help menu"

    exit
}

version () {
    echo "$SNIPPYSCRIPTNAME $SNIPPYVERSION ($SNIPPYCODENAME)"
    echo
    echo "To anyone who knows me it is no big secret that I love TV.\nOne of my favorite show to re-binge is \"How I Met Your Mother\" (Cristin Milioti what a gem).\nDuring the great COVID-19 re-binge I spent alot my of my time focused on the music of HIMYM.\nThat is where I first heard of the band The Unicorns, and the album that gives this versions its code name."
    echo
    echo "\"Who Will Cut Our Hair When We're Gone?\" is the second and final studio album by Canadian indie rock band the Unicorns.\nIt features several re-arranged versions of songs from their earlier self-released album Unicorns Are People Too."
    echo
    echo "Album release date: October 21, 2003"
    echo "https://open.spotify.com/album/3CZAwft1FIOixtUqkIPiUI"
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
    ! isMac && echo 'This option is currently only available on Mac OS' || $SNIPPYCATCMD $SNIPPYFILES/$1 | pbcopy && echo "$1 copied to clipboard"
    exit
}

preview () {
    $SNIPPYCATCMD $SNIPPYFILES/$1
    exit
}

upgrade () {
    isInstalled git && {
        cd $SNIPPYGITLOCATION
        git pull > /dev/null && echo 'Upgrade complete!' || echo 'Upgrade failed!'
        exit
    } || echo "git is required to update $SCRIPTNAME"
}

while getopts "e:n:c:p:d:hlvU" o; do
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
        U )
            upgrade
            ;;
        [?] )
            helper
            ;;

    esac
done

helper
