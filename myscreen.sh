#!/bin/bash
# Title: myscreen.sh
# Version: 0.2
# Author: Frédéric CHEVALIER <fcheval@txbiomed.org>
# Created in: 2015-08-10
# Modified in: 2015-08-16
# Licence : GPL v3



#======#
# Aims #
#======#

aim="List screen sessions available and start it."



#==========#
# Versions #
#==========#

# v0.2 - 2015-08-16: check for sty-updater.sh presence / warning message when renaming
# v0.1 - 2015-08-13: session renaming option added / first question corrected
# v0.0 - 2015-08-10: creation

version=$(grep -m 1 -i "version" "$0" | cut -d ":" -f 2 | sed "s/ * //g")



#===========#
# Functions #
#===========#

# Usage message
function usage {
    echo -e "
    \e[32m ${0##*/} \e[00m -r|--rnm -h|--help

Aim: $aim

Version: $version

Options:
    -r, --rnm   rename a specified session. \e[33mAttention:\e[00m This option requires the sty-updater.sh script to individually update the STY variable.
    -h, --help  this message
    "
}


# Info message
function info {
    if [[ -t 1 ]]
    then
        echo -e "\e[32mInfo:\e[00m $1"
    else
        echo -e "Info: $1"
    fi
}


# Warning message
function warning {
    if [[ -t 1 ]]
    then
        echo -e "\e[33mWarning:\e[00m $1"
    else
        echo -e "Warning: $1"
    fi
}


# Error message
## usage: error "message" exit_code
## exit code optional (no exit allowing downstream steps)
function error {
    if [[ -t 1 ]]
    then
        echo -e "\e[31mError:\e[00m $1"
    else
        echo -e "Error: $1"
    fi

    if [[ -n $2 ]]
    then
        exit $2
    fi
}


# Dependency test
function test_dep {
    which $1 &> /dev/null
    if [[ $? != 0 ]]
    then
        error "Package $1 is needed. Exiting..." 1
    fi
}



#==============#
# Dependencies #
#==============#

test_dep screen



#===========#
# Variables #
#===========#

# Options
while [[ $# -gt 0 ]]
do
    case $1 in
        -r|--rnm    ) rnm="1" ; shift 1 ;;
        -h|--help   ) usage ; exit 0 ;;
        *           ) error "Invalid option: $1\n$(usage)" 1 ;;
    esac
done



#============#
# Processing #
#============#

# Test if session exists
if [[ $(screen -list | grep "^.*[0-9]" | head -n -1 | wc -l) == 0 ]]
then
    info "No session opened."
    exit 0
fi

# Test if sty-updater function exists
if [[ ! $(grep "sty-updater.*{" "$HOME"/.bash*) ]]
then
    warning "The sty-updater function is missing from you .bashrc or .bash_profile. You will not be able to create new window in the renamed screen session unless you update manually the STY variable. Do you still want to rename a session? [Y/n]"
    read answer
    [[ -z $answer ]] && answer=y

    case $answer in
        [y]|[yes] ) ;;
        [n]|[no]  ) exit 0 ;;
        *     ) exit 1 ;;
    esac

    unset answer
fi

# List sessions
session_nb=$(screen -list | grep "^.*[0-9]" | head -n -1 | wc -l)
for i in $(seq "$session_nb")
do
    session=$(screen -list | grep "^.*[0-9]" | head -n -1 | sed -n "${i}p")
    echo -e "\t[$i] - $session"
done


# Ask session number
echo -e "\nWhat session do you want to select? [0 or enter = escape]"
read response


# Check if the number correspond to the criteria
if [[ -z $response || $response == 0 ]]
then
    exit 0
fi

if [[ ! $(echo $response | grep -x [[:digit:]]) ]]
then
    error "You did not enter an integer. Exiting..." 1
fi

if [[ $response -lt 0 || $response -gt $session_nb ]]
then
    error "You have requested a session not listed. Exiting..." 1
fi


# Select session requested
session=$(screen -list | grep "^.*[0-9]" | head -n -1 | sed -n "${response}p" | sed "s/\t/ /g" | cut -d " " -f 2) # Select the session

if [[ -n "$rnm" ]]
then
    echo -e "\nWhat name do you want to give to this session? [enter = escape]"
    read name

    # If nothing, escape
    [[ -z $name ]] && exit 0

    # Rename session (source: http://superuser.com/a/370553)
    screen -S "$session" -X sessionname "$name"

    # Warning message
    echo ""
    warning "If you want to create a new window in the renamed session, you need to run the sty-updater before creating it."
else
    screen -d -r "$session"
fi


exit 0
