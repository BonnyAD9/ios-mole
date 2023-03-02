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

    SIGNATURE="$ESC[38;2;250;50;170mŠ$ESC[38;2;240;50;180mt\
$ESC[38;2;230;50;190mi$ESC[38;2;220;50;200mg$ESC[38;2;210;50;210ml\
$ESC[38;2;200;50;220me$ESC[38;2;190;50;230mr$ESC[0m"
else
    SIGNATURE="Štigler"
fi

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
  ${YELLOW}-g ${WHITE}GROUP1${DARK}[,GROUP2[,...]]$RESET
    Filters only files that fall into any of the groups

  ${YELLOW}-a ${WHITE}DATE$RESET
    Filters out files opened before the given DATE

  ${YELLOW}-b ${WHITE}DATE$RESET
    Filters out files opened after the given DATE

${GREEN}DATE$RESET is in the format ${WHITE}YYYY-MM-DD$RESET"
}

while getopts hg:mba arg ; do
    case $arg in
    h)  mole-help ;;
    *) echo error ;;
    esac
done
