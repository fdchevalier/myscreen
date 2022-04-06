#!/bin/bash
# Title: myscreen.sh
# Version: 0.8
# Author: Frédéric CHEVALIER <fcheval@txbiomed.org>
# Created in: 2015-08-10
# Modified in: 2022-04-06
# Licence : GPL v3



#======#
# Aims #
#======#

aim="List screen sessions available and start it."



#==========#
# Versions #
#==========#

# v0.8 - 2022-04-09: correct bug when selecting session with a numbered folder in current directory
# v0.7 - 2021-08-31: correct bug preventing to access sessions >= 10 / improve list formatting
# v0.6 - 2021-05-15: sort list session by name by default / improve list formatting
# v0.5 - 2016-12-21: sort list session by number / load automatically the session when there is only one / detection of sty-updater function improved
# v0.4 - 2016-08-12: list display improved
# v0.3 - 2016-02-16: -s 
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
    \e[32m ${0##*/} \e[00m -s|--session number -p|--pid -r|--rnm -h|--help

Aim: $aim

Version: $version

Options:
    -s, --session   number of the session to attached (avoid printing list if number session is known). \e[31mIncompatible with -r.\e[00m
    -p, --pid       sort session list by process ID [default: by session name]
    -r, --rnm       rename a specified session. \e[33mAttention:\e[00m This option requires the sty-updater.sh script to individually update the STY variable.
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
        -s|--session ) response=$2 ; sn=1 ; shift 2;;
        -p|--pid     ) pid="pid" ; shift 1 ;;
        -r|--rnm     ) rnm="1" ; shift 1 ;;
        -h|--help    ) usage ; exit 0 ;;
        *            ) error "Invalid option: $1\n$(usage)" 1 ;;
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


# Get info about sessions
if [[ -n "$pid" ]]
then
    session_list=$(screen -list | grep "^.*[0-9]" | head -n -1 | sort -k1n)
else
    session_list=$(screen -list | grep "^.*[0-9]" | head -n -1 | sort -t . -k2)
fi
session_nb=$(echo "$session_list" | wc -l)


# List sessions if -s not used
if [[ -z "$sn" ]]
then
    echo ""
    for i in $(seq -w "$session_nb")
    do
        session=$(echo "$session_list" | sed "s/\t/\`/g ; s/\`//" | column -s "." -t | column -s "\`" -t | sed -n "${i}p")
        echo -e "\t[$i] - $session"
    done


    # Ask session number if more than one
    echo ""
    if [[ 10#"$session_nb" -gt 1 || -n "$rnm" ]]
    then
        echo "What session do you want to select? [0 or enter = escape]"
        read response
    else
        info "The only active session will be load in 3 seconds."
        response=1
        sleep 3s
    fi
fi


# Check if the number corresponds to the criteria
if [[ -z $response || $response == 0 ]]
then
    exit 0
fi

if [[ ! $(echo $response | grep -x "[[:digit:]]*") ]]
then
    error "You did not enter an integer. Exiting..." 1
fi

if [[ 10#$response -lt 0 || 10#$response -gt 10#$session_nb ]]
then
    error "You have requested a session not listed. Exiting..." 1
fi


# Select session requested
session=$(echo "$session_list" | sed -n "${response}p" | sed "s/\t/ /g" | cut -d " " -f 2) # Select the session


# Rename session
if [[ -n "$rnm" ]]
then
    
    # Test if sty-updater function exists
    if [[ ! $(bash -i -c 'typeset -F' | grep sty-updater0) ]]
    then
        echo ""
        warning "The sty-updater function is missing from your environment. You will not be able to create new window in the renamed screen session unless you update manually the STY variable. Do you still want to rename a session? [Y/n]"
        read answer
        [[ -z $answer ]] && answer=y

        case $answer in
            Y|y|yes ) ;;
            N|n|no  ) exit 0 ;;
            *       ) exit 1 ;;
        esac

        unset answer
    fi

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
