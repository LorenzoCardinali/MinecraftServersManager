#!/bin/bash

# error handling
function fn_error() {
    echo "ERROR: $1"
    exit 1
}

# file presents check
function fn_is_present() {
    if [ $# == 2 ]
    then
        if ! test -e "$1"
        then
            fn_error "$2"
        fi
    else
        test -e "$1"
    fi
}

# y/n request
function fn_prompt_yn() {
    local prompt="$1"
    local initial="$2"
    
    if [ "${initial}" == "Y" ]
    then
        prompt+=" [Y/n] "
    elif [ "${initial}" == "N" ]
    then
        prompt+=" [y/N] "
    else
        prompt+=" [y/n] "
    fi
    
    while true; do
        read -e -i "${initial}" -p "${prompt}" -r yn
        case "${yn}" in
            [Yy] | [Yy][Ee][Ss]) return 0 ;;
            [Nn] | [Nn][Oo]) return 1 ;;
            *) echo -e "Please answer yes or no." ;;
        esac
    done
}

# logging handling
function fn_to_log() {
    echo "[$(date)] : ${1}" >> "$LOG_FILE"
}

# change server status
function fn_change_status() {
    echo "$1" > "$STATUS_FILE"
}

# get server status
function fn_get_status() {
    cat "$STATUS_FILE"
}
