#!/usr/bin/env bash

DULL=0
BRIGHT=1

FG_BLACK=30
FG_RED=31
FG_GREEN=32
FG_YELLOW=33
FG_BLUE=34
FG_VIOLET=35
FG_CYAN=36
FG_WHITE=37

FG_NULL=00

BG_BLACK=40
BG_RED=41
BG_GREEN=42
BG_YELLOW=43
BG_BLUE=44
BG_VIOLET=45
BG_CYAN=46
BG_WHITE=47

BG_NULL=00

##
# ANSI Escape Commands
##
ESC="\033"
NORMAL="\[$ESC[m\]"
RESET="\[$ESC[${DULL};${FG_WHITE};${BG_NULL}m\]"

##
# Shortcuts for Colored Text ( Bright and FG Only )
##

# DULL TEXT
BLACK="\[$ESC[${DULL};${FG_BLACK}m\]"
RED="\[$ESC[${DULL};${FG_RED}m\]"
GREEN="\[$ESC[${DULL};${FG_GREEN}m\]"
YELLOW="\[$ESC[${DULL};${FG_YELLOW}m\]"
BLUE="\[$ESC[${DULL};${FG_BLUE}m\]"
VIOLET="\[$ESC[${DULL};${FG_VIOLET}m\]"
CYAN="\[$ESC[${DULL};${FG_CYAN}m\]"
WHITE="\[$ESC[${DULL};${FG_WHITE}m\]"

# BRIGHT TEXT
BRIGHT_BLACK="\[$ESC[${BRIGHT};${FG_BLACK}m\]"
BRIGHT_RED="\[$ESC[${BRIGHT};${FG_RED}m\]"
BRIGHT_GREEN="\[$ESC[${BRIGHT};${FG_GREEN}m\]"
BRIGHT_YELLOW="\[$ESC[${BRIGHT};${FG_YELLOW}m\]"
BRIGHT_BLUE="\[$ESC[${BRIGHT};${FG_BLUE}m\]"
BRIGHT_VIOLET="\[$ESC[${BRIGHT};${FG_VIOLET}m\]"
BRIGHT_CYAN="\[$ESC[${BRIGHT};${FG_CYAN}m\]"
BRIGHT_WHITE="\[$ESC[${BRIGHT};${FG_WHITE}m\]"

# REV TEXT as an example
REV_CYAN="\[$ESC[${DULL};${BG_WHITE};${BG_CYAN}m\]"
REV_RED="\[$ESC[${DULL};${FG_YELLOW}; ${BG_RED}m\]"

# This function replaces rm in a normal shell to move files to the trash instead of immediately deleting them. This has no effect on scripts or apps that make use of rm normally. :)
function rm () {
  local path
  for path in "$@"; do
    if [[ "$path" = -* ]]; then :
    else
      mv "$path" ~/.Trash/"$path"
    fi
  done
}

function setTitle {  
	ssh=$SSH_CLIENT
	
	if [[ ! -z $ssh ]]; then
		sshvars=($SSH_CONNECTION)
		ssh="[${sshvars[2]}] "
	fi

    local SEARCH=' ';
    local REPLACE='%20';
    local PWD_URL="file://$HOSTNAME${PWD//$SEARCH/$REPLACE}";
    printf '\e]7;%s\a' "$PWD_URL"
	
	git rev-parse > /dev/null 2>&1
	
	if [[ $? -eq 0 ]]; then		
		status=$(git status 2> /dev/null | tail -n1)
		branch=$(git branch | grep \*)
		branch=${branch//\* /}
	
		if [[ $status != 'nothing to commit (working directory clean)' && $status != 'nothing added to commit but untracked files present (use "git add" to track)' ]]; then
			# the repo has changes
			PS1="\[\e]2;$ssh ${PWD##*/}\a\]${RED}$ssh${RESET}${YELLOW}[$branch]${RESET} \W # "
		else
			# the repo doesn't have any uncommitted changes
			PS1="\[\e]2;$ssh ${PWD##*/}\a\]${RED}$ssh${RESET}[$branch] \W # "
		fi
	else
		# we're not inside a repo
		PS1="\[\e]2;$ssh ${PWD##*/}\a\]${RED}$ssh${RESET}\W # "
	fi
}

export PROMPT_COMMAND='setTitle'
export PS2='# '
export PS3='# '
export PS4='# '
export EDITOR="$HOME/bin/mate -w"

# miscellaneous
alias grep='grep --color=auto'
alias mate_bash="mate ~/.bash_profile"

# history
alias th="cut -f1 -d\" \" ~/.bash_history | sort | uniq -c | sort -nr | head -n 30" # list top 30 most used commands
alias h='history'
alias c='printf "# -------------------- #" && clear' # clears the terminal and inserts a line ---- for easy searching/locating
alias line='printf "\n# -------------------- #\n\n"' # just draw a line ----
alias num='set -- * && echo $# results' # prints the number of lines from the last command

# change directory - shortcuts for jumping between command directories.
alias cd_dropbox="cd ~/Dropbox"
alias cd_desktop="cd ~/Desktop"
alias cd_documents="cd ~/Documents"
alias cd_downloads="cd ~/Downloads"

# ls
alias ls="gls --color --group-directories-first -h -p"
alias lla="ls -lhAG"				  # Long list everything.
alias lh='ls -cdG .*'          	      # Hidden files only.
alias ll='ls -lhG && num'             	  # Long list.
alias la='ls -cAG'                	  # List everything.
alias ld='ls -CGdp */ | sed "s/\///g"'     # Directories only.
alias lf="ls | grep -v '/'"  	  # Files only.

h="\e[0;33mHidden\e[m"
d="\e[0;33mDirectories\e[m"
f="\e[0;33mFiles\e[m"

# prints a specially formatter directory listing, excluding hidden directories
alias l='printf "\n$d\n" && ld && printf "\n$f\n" && lf && echo ""' 
# prints a specially formatter directory listing, including hidden directories
alias l.='printf "\n$h\n" && lh && printf "\n\n$d\n" && ld && printf "\n\n$f\n" && lf && echo ""'

# Get greeting from time
# get current hour (24 clock format i.e. 0-23)
hour=$(date +"%H")

USERNAME="\e[1;34m$USER\e[m"
 
# if it is midnight to midafternoon will say G'morning
if [ $hour -ge 0 -a $hour -lt 12 ]
then
  greet="Good Morning, $USERNAME"
# if it is midafternoon to evening ( before 6 pm) will say G'noonx
elif [ $hour -ge 12 -a $hour -lt 18 ] 
then
  greet="Good Afternoon, $USERNAME"
else # it is good evening till midnight
  greet="Good evening, $USERNAME"
fi

# this is much better now, prints all found ip addresses
ip=$(ifconfig | awk -F "[: ]+" '/inet / { if ($2 != "127.0.0.1") printf $2 ", " }' | sed 's/, $//')
	
network=""

if [[ $(uname) = "Darwin" ]]; then
	ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')

	ping -s 10 -c 1 -t 1 google.com >> /dev/null 2>&1
		
	if [[ ! -z $ssid ]]; then
		ssid="<\033[1;34m$ssid\e[0m> "	
	elif [[ $? -ne 0 ]]; then
		ssid="<\033[1;33mNo Internet\e[0m> "	
	fi
fi

if [[ -z $ip ]]; then
	ip="Not connected."
fi

# clear and display message of the day
clear
cat <<EOF    
                         ''~\`\`
                        ( o o )
+------------------.oooO--(_)--Oooo.------------------+
|                                                     |
|                    .oooO                            |
|                    (   )   Oooo.                    |
+---------------------\ (----(   )--------------------+


EOF

printf "$greet\n"


printf "\n%20s  " "Interfaces:"
printf "$ssid"

int=true
for i in $ip; do 
	if [[ $int = true ]]; then
		printf "\033[1;34m$i\e[0m "; 	
		int=false
	else
		printf "$i "
	fi
done

uptime=$(uptime | grep -ohe 'up .*' | sed 's/,//g' | awk '{ print $2" "$3 }')
users=$(uptime | grep -ohe '[0-9.*] user[s,]' | cut -b 1)

printf "\n%20s  %s" "Current Path:" "${PWD//$HOME/~}"
printf "\n%20s  %b" "Uptime:"		"$uptime"
printf "\n%20s  %b" "Users:" 		"$users"
printf "\n\n"