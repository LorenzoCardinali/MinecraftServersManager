#!/bin/bash

# error handling
function fn_error() {
    echo -e "ERROR: $1"
    if "${2-true}"; then
        exit 1
    fi
}
export -f fn_error

# file presents check
function fn_is_present() {
    if [ $# == 2 ]
    then
        if ! test -e "$1"; then
            fn_error "$2"
        fi
    else
        test -e "$1"
    fi
}
export -f fn_is_present

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
export -f fn_prompt_yn

# logging handling
function fn_to_log() {
    echo "[$(date)] : $1" >> "$2"
}
export -f fn_to_log 

# change server status
function fn_change_status() {
    echo "$1" > "$2"
}
export -f fn_change_status

# get server status
function fn_get_status() {
    cat "$1"
}
export -f fn_get_status