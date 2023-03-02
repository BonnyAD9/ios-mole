# CONFIG

USE_COLOR=yes

if [[ $USE_COLOR = yes ]] ; then
    ESC=`printf "\e"`

    RESET="$ESC[0m"

    ITALIC="$ESC[3m"

    DARK="$ESC[90m"
    DGREEN="$ESC[32m"
    DYELLOW="$ESC[33m"

    GREEN="$ESC[92m"
    YELLOW="$ESC[93m"
    WHITE="$ESC[97m"
fi

function mole-help() {
    echo "Welcome to ${ITALIC}mole$RESET help

${GREEN}Usage:$RESET
  ${WHITE}${ITALIC}mole$RESET ${DYELLOW}-h$RESET
    Shows this help.

  ${ITALIC}mole$RESET ${DARK}[${DYELLOW}-g$DARK GROUP] ${WHITE}FILE$RESET
    Opens the given ${WHITE}FILE$RESET and adds it to the ${WHITE}GROUP$RESET
    if ${YELLOW}-g$RESET is specified.

  ${ITALIC}mole$RESET ${DARK}[${DYELLOW}-m${DARK}] [${DGREEN}FILTERS${DARK}] \
[DIRECTORY]$RESET
    Opens file from the given ${WHITE}DIRECTORY${RESET}. ${GREEN}FILTERS$RESET
    can change the range of files to look for. If the -m flag is specified, the
    file opened the most times is chosen. Otherwise the last opened
    file is chosen. The current directory is used when no
    ${WHITE}DIRECTORY$RESET is specified.

  ${ITALIC}mole$RESET ${YELLOW}list ${DARK}[${DGREEN}FILTERS${DARK}] \
[DIRECTORY]$RESET
    Lists all files edited by mole in the given ${WHITE}DIRECTORY${RESET}.
    ${GREEN}FILTERS$RESET can change the range of files to list. The current
    directory is used when no ${WHITE}DIRECTORY$RESET is specified.

${GREEN}Filters:$RESET
  ${YELLOW}-g ${WHITE}GROUP1${DARK}[,GROUP2[,...]]$RESET
    Filters only files that fall into any of the groups

  ${YELLOW}-a ${WHITE}DATE$RESET
    Filters out files opened before the given ${WHITE}DATE$RESET

  ${YELLOW}-b ${WHITE}DATE$RESET
    Filters out files opened after the given ${WHITE}DATE$RESET

*${WHITE}DATE$RESET is in the format ${WHITE}YYYY-MM-DD$RESET"
}

while getopts hg:mba arg ; do
    case $arg in
    h)  mole-help ;;
    *) echo error ;;
    esac
done
