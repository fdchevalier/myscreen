#!/bin/bash
# Title: sty-updater.sh
# Version: 0.0
# Author: Frédéric CHEVALIER <fcheval@txbiomed.org>
# Created in: 2015-08-16
# Modified in:
# Licence : GPL v3



#======#
# Aims #
#======#

aim="Update STY variable. Useful when screen session has been renamed."



#==========#
# Versions #
#==========#

# v0.0 - 2015-08-16: creation



#===========#
# Functions #
#===========#

# Usage message
function usage {
    echo -e "
    \e[32m ${0##*/} \e[00m -h|--help

Aim: $aim

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


# Check the existence of obligatory options
if [[ -z "$STY" ]]
then
    info "No STY value detected."
    exit 0
fi



#============#
# Processing #
#============#

# Get the current STY value
old_sty=$STY

# Get the pid of the session
pid_session=$(echo $STY | cut -d "." -f 1)

# Update STY with the new value
export STY=$(screen -list | sed "s/^\t//g" | grep $pid_session | cut -f 1)

# Info message
info "The STY value has been updated:\n\t-old value: $old_sty\n\t-new value: $STY" 

#exit 0
