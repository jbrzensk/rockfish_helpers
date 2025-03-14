#!/bin/bash
# ======================================================================
# NAME
#
#   color_text.sh
#
# DESCRIPTION
#
#   A simple example of how to print out colors in linux bash scripts.
#   There are some examples with echo, and printf. echo requires the
#   additional -e so it can render escaped characters.
#
# USAGE
#
#   To print out the color text example, 
#
#     ./color_text.sh
#
# AUTHOR
#
#   Jared Brzenski
#
# LAST UPDATED
#
#   January 5, 2025
#
#---------------------------------------------------------------------
#--------------------------------------------------------------------+
#Color picker, usage: printf ${BLD}${CUR}${RED}${BBLU}"Hello!)"${DEF}|
#-------------------------+--------------------------------+---------+
#       Text color        |       Background color         |         |
#-----------+-------------+--------------+-----------------+         |
# Base color|Lighter shade|  Base color  | Lighter shade   |         |
#-----------+-------------+--------------+-----------------+         |
BLK='\e[30m'; blk='\e[90m'; BBLK='\e[40m'; bblk='\e[100m' #| Black   |
RED='\e[31m'; red='\e[91m'; BRED='\e[41m'; bred='\e[101m' #| Red     |
GRN='\e[32m'; grn='\e[92m'; BGRN='\e[42m'; bgrn='\e[102m' #| Green   |
YLW='\e[33m'; ylw='\e[93m'; BYLW='\e[43m'; bylw='\e[103m' #| Yellow  |
BLU='\e[34m'; blu='\e[94m'; BBLU='\e[44m'; bblu='\e[104m' #| Blue    |
MGN='\e[35m'; mgn='\e[95m'; BMGN='\e[45m'; bmgn='\e[105m' #| Magenta |
CYN='\e[36m'; cyn='\e[96m'; BCYN='\e[46m'; bcyn='\e[106m' #| Cyan    |
WHT='\e[37m'; wht='\e[97m'; BWHT='\e[47m'; bwht='\e[107m' #| White   |
#----------------------------------------------------------+---------+
# Effects                                                            |
#--------------------------------------------------------------------+
DEF='\e[0m'   #Default color and effects                             |
BLD='\e[1m'   #Bold\brighter                                         |
DIM='\e[2m'   #Dim\darker                                            |
CUR='\e[3m'   #Italic font                                           |
UND='\e[4m'   #Underline                                             |
INV='\e[7m'   #Inverted                                              |
COF='\e[?25l' #Cursor Off                                            |
CON='\e[?25h' #Cursor On                                             |
#--------------------------------------------------------------------+
# Text positioning, usage: XY 10 10 "Hello World!"                   |
XY   () { printf "\e[${2};${1}H${3}";   } #                          |
#--------------------------------------------------------------------+
# Print line, usage: line - 10 | line -= 20 | line "Hello World!" 20 |
line () { printf -v LINE "%$2s"; printf -- "${LINE// /$1}"; } #      |
# Create sequence like {0..X}                                        |
cnt () { printf -v _N %$1s; _N=(${_N// / 1}); printf "${!_N[*]}"; } #|
#--------------------------------------------------------------------+
#
# we can print simple thigns with the opening and colsing tags defined above
# using printf or echo
#
echo -e "I ${RED}LOVE${DEF} printing in color with echo!"
#
printf  "I ${RED}LOVE${DEF} printing in color with printf!\n\n"
#
# You can stack them for combinations
#
printf  "I ${RED}${BWHT}${CUR}LOVE${DEF} printing in color with printf!\n\n"
#
# AND you can make functions, to print out all at once
#
rockfish_text=(''
$WHT"░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░\n"$DEF
$WHT"░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   ░░░░░░░░░░   ░░░░░░░░░░░░░░░░░░░░░░░░\n"$DEF
$CYN"▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒▒\n"$DEF
$CYN"▒▒  ▒    ▒▒▒▒   ▒▒▒▒▒▒▒▒    ▒   ▒▒   ▒    ▒  ▒▒▒▒▒▒▒     ▒▒   ▒▒▒▒▒▒▒\n"$DEF
$BLU"▓▓▓   ▓▓▓▓▓   ▓▓   ▓▓▓   ▓▓▓▓   ▓   ▓▓▓▓   ▓▓▓▓   ▓   ▓▓▓▓▓     ▓▓▓▓▓\n"$DEF
$BLU"▓▓▓   ▓▓▓▓   ▓▓▓▓   ▓   ▓▓▓▓▓     ▓▓▓▓▓▓   ▓▓▓▓   ▓▓▓    ▓▓   ▓▓  ▓▓▓\n"$DEF
$BLU"▓▓▓   ▓▓▓▓▓   ▓▓   ▓▓▓   ▓▓▓▓   ▓   ▓▓▓▓   ▓▓▓▓   ▓▓▓▓▓   ▓  ▓▓▓   ▓▓\n"$DEF
$BLU"██    ███████   ████████    █   ██   ███   ████   █      ██  ███   ██\n"$DEF
$BLU"█████████████████████████████████████████████████████████████████████\n"$DEF
)
#
welcome=(''
$RED" ____      ____  ________  _____       ______    ___   ____    ____  ________      \n"$DEF
$RED"|_  _|    |_  _||_   __  ||_   _|    .' ___  | .'   \`.|_   \  /   _||_   __  |    \n"$DEF
$GRN"  \ \  /\  / /    | |_ \_|  | |     / .'   \_|/  .-.  \ |   \/   |    | |_ \_|     \n"$DEF
$GRN"   \ \/  \/ /     |  _| _   | |   _ | |       | |   | | | |\  /| |    |  _| _      \n"$DEF
$BLU"    \  /\  /     _| |__/ | _| |__/ |\ \`.___.'\\\\\  \`-'  /_| |_\/_| |_  _| |__/ |\n"$DEF
$BLU"     \/  \/     |________||________| \`.____ .' \`.___.'|_____||_____||________|   \n"$DEF
)
#
rkfsh=(''
"\n"$DEF
$WHT"██████╗  ██████╗  ██████╗██╗  ██╗███████╗██╗███████╗██╗  ██╗ \n"$DEF
$WHT"██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██║██╔════╝██║  ██║ \n"$DEF
$WHT"██████╔╝██║   ██║██║     █████╔╝ █████╗  ██║███████╗███████║ \n"$DEF
$WHT"██╔══██╗██║   ██║██║     ██╔═██╗ ██╔══╝  ██║╚════██║██╔══██║ \n"$DEF
$WHT"██║  ██║╚██████╔╝╚██████╗██║  ██╗██║     ██║███████║██║  ██║ \n"$DEF
$WHT"╚═╝  ╚═╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝ \n"$DEF
)
#
# Print the 'functions' defined above with
printf "${welcome[*]}"



