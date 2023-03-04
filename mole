#!/usr/bin/bash

# Config >>=============================================================
echo "zakomentuj před odevzdáním!!"
MOLE_USE_COLOR=yes
MOLE_RC=./test/MOLE_RC
EDITOR=vim
POSIXLY_CORRECT=yes


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

    SIGNATURE="$ESC[38;2;250;50;170mx$ESC[38;2;240;50;180ms\
$ESC[38;2;230;50;190mt$ESC[38;2;220;50;200mi$ESC[38;2;210;50;210mg\
$ESC[38;2;200;50;220ml$ESC[38;2;190;50;230m0$ESC[38;2;180;50;240m0$ESC[0m"
else
    SIGNATURE="xstigl00"
fi

# error message
ERR="mole: ${RED}Error:$RESET"

# echo to stderr and exit
# echoe MSG ERROR_CODE
function echoe() {
    echo "$1" >&2
    exit $2
}

# get the MOLE_RC file
if [ -z  ${MOLE_RC:+x} ] ; then
    echoe "$ERR MOLE_RC variable is not set" 1
fi
touch $MOLE_RC 2>/dev/null
EC=$?
if [[ $EC != 0 ]] ; then
    echoe "$ERR couldn't access file '$MOLE_RC'" $EC
fi

# get the editor
EDI=${EDITOR:-${VISUAL:-vi}}
type "$EDI" &>/dev/null
EC=$?
if [[ $EC != 0 ]] ; then
    echoe "$ERR '$EDI' is doesn't exist" $EC
fi


# Define functions >>===================================================

# Converts date to a number (exits on error)
function date_to_num() {
    # check for the basic format
    if [[ !("$1" =~ [0-9][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]) ]] ; then
        echoe "$ERR Invalid date format: '$1'. Expected the format YYYY-MM-DD"\
            1
    fi

    # convert from the format to seconds since epoch
    # stderr is redirected because the error message is handeled in the script
    RETURN=`date -d"$1" +%s 2>/dev/null`

    # return the error code on error
    EC=$?
    if [[ $EC != 0 ]] ; then
        echoe "$ERR Invalid date '$1'" $EC
    fi
}

# shows the help
function mole_help() {
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
    mole_help
    if [ -z ${2:+x} ] ; then
        exit 0
    else
        echoe "$ERR -h doesn't take any other arguments" 1
    fi
    ;;
*)  ;;
esac

while getopts :g:mb:a: arg ; do
    case $arg in
    g)  GROUP=$OPTARG ;;
    m)  MOST=true ;;
    b)
        date_to_num $OPTARG
        BEFORE=$RETURN
        ;;
    a)
        date_to_num $OPTARG
        AFTER=$RETURN
        ;;
    *)
        echoe "$ERR invalid option '$OPTARG'" 1
        ;;
    esac
done

((OPTIND--))
shift $OPTIND

# the item to operate on (file or directory)
ITEM=`realpath "${1:-./}"`


# MOLE_RC Format:
# <filename>;,<group names seprated by commas>,,-,<dates separated by commas>
# full filename;,group1,group2,...,,-,date1,date2,...
# full filename2;,group1,group2,...,,-,date1,date2,...
# ...

# - <filename> cannot contain the character ';'
# - <group name> cannot contain the character ',' and cannot be '-'
# - <date> is number of seconds since Epoch
# - each file has its own line -> none of the fields can contain the
#   newline character


# Script functions >>===================================================

# escapes the given string to be used in sed regex
# reg-escape STRING
function sed_escape() {
    sed -e 's/\\/\\\\/g' -e 's/\./\\./g' -e 's/\*/\\*/g' -e 's/\[/\\[/g' \
        -e 's/\//\\\//g' -e 's/\]/\\]/g' -e 's/\^/\\^/g' -e 's/\$/\\$/g' \
        -e 's/(/\\(/g'   -e 's/)/\\)/g' \
        <<__END__
$1
__END__
}

# escapes the given string to be used in grep regex
# reg-escape STRING
function grep_escape() {
    sed -e 's/\\/\\\\/g' -e 's/\./\\./g' -e 's/\*/\\*/g' -e 's/\[/\\[/g' \
                         -e 's/\]/\\]/g' -e 's/\^/\\^/g' -e 's/\$/\\$/g' \
        <<__END__
$1
__END__
}

# adds file to MOLE_RC if it doesn't exist with the current date
# rc_add_file FILENAME GROUP
# Set GROUP to '-' for no group
function rc_add_file() {
    # escape for use in regex
    _FNAME_S=`sed_escape $1`
    _FNAME_G=`grep_escape $1`
    _GROUP_S=`sed_escape $2`
    _GROUP_G=`grep_escape $2`

    # check if the file is in the MOLE_RC
    _COUNT=`grep -c "^$_FNAME_G;,.*$" "$MOLE_RC"`
    # current date and time
    _TIME=`date +%s`

    # file not in MOLE_RC
    if [[ $_COUNT == 0 ]] ; then
        if [[ $2 == "-" ]] ; then
            echo "$1;,,-,$_TIME" >>"$MOLE_RC"
        else
            echo "$1;,$2,,-,$_TIME" >>"$MOLE_RC"
        fi
        return
    fi

    # file is in MOLE_RC
    if [[ $2 == "-" ]] ; then
        # add time to the file
        sed -r -i "s/^$_FNAME_S;,.*$/\0,$_TIME/" "$MOLE_RC"
        return
    fi

    # check if the file already has the group
    COUNT=`grep -c "^$_FNAME_G;.*,$_GROUP_G,.*,-,.*" "$MOLE_RC"`
    if [[ $COUNT == 0 ]] ; then
        # add the group
        sed -r -i "s/^($_FNAME_S;,.*),-,(.*)$/\1$_GROUP_S,,-,\2,$_TIME/" \
            "$MOLE_RC"
    else
        # add only the time
        sed -r -i "s/^$_FNAME_S;,.*$/\0,$_TIME/" "$MOLE_RC"
    fi
}


# The script >>=========================================================

case "$ACTION" in
list) echoe "$ERR the list option is not supported yet" 1 ;;
slog) echoe "$ERR the secret-log is not supported yet" 1 ;;
*)
    # open and edit file
    if [ -f $ITEM ] ; then
        # check for invalid arguments for this action
        if [ -n "${MOST:+x}" ] ; then
            echoe "$ERR invalid flag when opening file: -m" 1
        elif [ -n "${BEFORE:+x}" ] ; then
            echoe "$ERR invalid flag when opening file: -b" 1
        elif [ -n "${AFTER:+x}" ] ; then
            echoe "$ERR invalid flag when opening file: -a" 1
        fi

        rc_add_file $ITEM ${GROUP:--}
        $EDI $ITEM
        exit $?
    fi

    # directory
    echoe "$ERR the directory option is not supported yet"
esac
