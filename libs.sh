#!/bin/bash
###### ######## ####### #######  ###  #######
###           ##       ##      ## ###
###      #######  ######  ###  ## ###  #######
###      ###  ##  ##  ##  ###  ## ###  ##
######  ###  ##  ##   ## ######  ###  ##

# move to script directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

# Json and script
START_SCRIPT="start.sh"
JSON_FILE="config.json"

# import jar file
JAR_FILE="$PWD/$SERVER/$(jq -r ".servers.${SERVER}.jar_file" "$JSON_FILE")"

# import log file
LOG_FILE="$PWD/$SERVER/$(jq -r ".files.logs_file" "$JSON_FILE")"

# import status file
STATUS_FILE="$PWD/$SERVER/$(jq -r ".files.status_file" "$JSON_FILE")"

# statuses import
declare -A STATUS=(
    ["on"]="$(jq -r ".statuses.on" "$JSON_FILE")"
    ["run"]="$(jq -r ".statuses.run" "$JSON_FILE")"
    ["res"]="$(jq -r ".statuses.res" "$JSON_FILE")"
    ["off"]="$(jq -r ".statuses.off" "$JSON_FILE")"
    ["err"]="$(jq -r ".statuses.err" "$JSON_FILE")"
)

# logging handling
function fn_to_log() {
    echo "[$(date)] : ${1}" >> "$LOG_FILE"
}

# change the server status
function fn_change_status() {
    echo "$1" > "$STATUS_FILE"
}

function fn_get_status() {
    cat "$STATUS_FILE"
}

# error handling
function fn_error() {
    echo "ERROR: $1"
    exit 1
}

# file presents check
function fn_is_present() {
    test -e "$1"
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