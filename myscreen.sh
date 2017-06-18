#!/bin/bash
# Title: myscreen.sh
# Version: 0.0
# Author: Frédéric CHEVALIER <fcheval@txbiomed.org>
# Created in: 2015-08-10
# Modified in:
# Licence : GPL v3



#======#
# Aims #
#======#

aim="List screen sessions available and start it."



#==========#
# Versions #
#==========#

# v0.0 - 2015-08-10: creation

version=$(grep -m 1 -i "version" "$0" | cut -d ":" -f 2 | sed "s/ * //g")



#===========#
# Functions #
#===========#

# Usage message
function usage {
    echo -e "
    \e[32m ${0##*/} \e[00m -h|--help

Aim: $aim

Version: $version

Options:
    -h, --help      this message
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

# List sessions
session_nb=$(screen -list | grep "^.*[0-9]" | head -n -1 | wc -l)
for i in $(seq "$session_nb")
do
    session=$(screen -list | grep "^.*[0-9]" | head -n -1 | sed -n "${i}p")
    echo -e "\t[$i] - $session"
done


# Ask session number
echo -e "\nWhat file has to be $action? [0 or enter = escape]"
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
    error "You have requested a session non listed. Exiting..." 1
fi


# Start session requested
session=$(screen -list | grep "^.*[0-9]" | head -n -1 | sed -n "${response}p" | sed "s/\t/ /g" | cut -d " " -f 2) # Select the session

screen -r "$session"


exit 0
