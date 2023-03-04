#!/usr/bin/bash

# Config >>=============================================================
echo "zakomentuj před odevzdáním!!"
MOLE_USE_COLOR=yes
MOLE_RC=./MOLE_RC
EDITOR=vim


# Setup >>==============================================================

# define used colors
if [[ $MOLE_USE_COLOR = yes ]] ; then
    ESC=`printf "\e"`

    RESET="$ESC[0m"

    ITALIC="$ESC[3m"

    DARK="$ESC[90m"
    DGREEN="$ESC[32m"
    DYELLOW="$ESC[33m"

    RED="$ESC[91m"
    GREEN="$ESC[92m"
    YELLOW="$ESC[93m"
    WHITE="$ESC[97m"

    SIGNATURE="$ESC[38;2;250;50;170mŠ$ESC[38;2;240;50;180mt\
$ESC[38;2;230;50;190mi$ESC[38;2;220;50;200mg$ESC[38;2;210;50;210ml\
$ESC[38;2;200;50;220me$ESC[38;2;190;50;230mr$ESC[0m"
else
    SIGNATURE="Štigler"
fi

# error message
ERR="mole: ${RED}Error:$RESET"

# echo to stderr
function echoe() {
    echo "$1" >&2
}

# get the MOLE_RC file
if [ -z  ${MOLE_RC:+x} ] ; then
    echoe "$ERR MOLE_RC variable is not set"
    exit 1
fi
touch $MOLE_RC 2>/dev/null
EC=$?
if [[ $EC != 0 ]] ; then
    echoe "$ERR couldn't access file '$MOLE_RC'"
    exit $EC
fi

# get the editor
EDI=${EDITOR:-${VISUAL:-vi}}
type "$EDI" &>/dev/null
EC=$?
if [[ $EC != 0 ]] ; then
    echoe "$ERR '$EDI' is doesn't exist"
    exit $EC
fi


# Define functions >>===================================================

# Converts date to a number (exits on error)
function date-to-num() {
    # check for the basic format
    if [[ !("$1" =~ [0-9][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]) ]] ; then
        echoe "$ERR Invalid date format: '$1'. Expected the format YYYY-MM-DD"
        exit 1
    fi

    # convert from the format to seconds since epoch
    # stderr is redirected because the error message is handeled in the script
    RETURN=`date -d"$1" +%s 2>/dev/null`

    # return the error code on error
    EC=$?
    if [[ $EC != 0 ]] ; then
        echoe "$ERR Invalid date '$1'"
        exit $EC
    fi
}

# shows the help
function mole-help() {
    echo "Welcome in $GREEN${ITALIC}mole$RESET by $SIGNATURE

${GREEN}Usage:$RESET
  ${WHITE}mole -h$RESET
    Shows this help.

  ${WHITE}mole ${DARK}[-g GROUP] ${WHITE}FILE$RESET
    Opens the given FILE and adds it to the GROUP if -g is specified.

  ${WHITE}mole ${DARK}[-m] [FILTERS] [DIRECTORY]$RESET
    Opens file from the given DIRECTORY. FILTERS can change the range of files
    to look for. If the -m flag is specified, the file opened the most times is
    chosen. Otherwise the last opened file is chosen. The current directory is
    used when no DIRECTORY is specified.

  ${WHITE}mole ${YELLOW}list ${DARK}[FILTERS] [DIRECTORY]$RESET
    Lists all files edited by mole in the given DIRECTORY. FILTERS can change
    the range of files to list. The current directory is used when no DIRECTORY
    is specified.

${GREEN}Filters:$RESET
  $YELLOW-g ${WHITE}GROUP1${DARK}[,GROUP2[,...]]$RESET
    Filters only files that fall into any of the groups

  $YELLOW-a ${WHITE}DATE$RESET
    Filters out files opened before the given DATE

  $YELLOW-b ${WHITE}DATE$RESET
    Filters out files opened after the given DATE

${GREEN}DATE$RESET is in the format ${WHITE}YYYY-MM-DD$RESET"
}


# Process arguments >>==================================================

case "$1" in
list)
    ACTION=list
    shift
    ;;
secret-log)
    ACTION=slog
    shift
    ;;
-h)
    mole-help
    if [ -z ${2:+x} ] ; then
        exit 0
    else
        echoe "$ERR -h doesn't take any other arguments"
        exit 1
    fi
    ;;
*)  ;;
esac

while getopts :g:mb:a: arg ; do
    case $arg in
    g)  GROUP=$OPTARG ;;
    m)  MOST=true ;;
    b)
        date-to-num $OPTARG
        BEFORE=$RETURN
        ;;
    a)
        date-to-num $OPTARG
        AFTER=$RETURN
        ;;
    *)
        echoe "$ERR invalid option '$OPTARG'"
        exit 1
        ;;
    esac
done

((OPTIND--))
shift $OPTIND

# the item to operate on (file or directory)
ITEM=`realpath "${1:-./}"`


# The script >>=========================================================

# MOLE_RC Format:
# full filename;group1,group2,...,-,date1,date2,...
# full filename2;group1,group2,...,-,date1,date2,...
# ...

# adds file to MOLE_RC
# rc-add-file FILENAME [GROUP]
# function rc-add-file() {
#
# }
