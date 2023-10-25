#!/bin/bash
###### ######## ####### #######  ###  #######
###           ##       ##      ## ###
###      #######  ######  ###  ## ###  #######
###      ###  ##  ##  ##  ###  ## ###  ##
######  ###  ##  ##   ## ######  ###  ##

# move to script directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

# arguments
SERVER=${1}
COMMAND=${2}
ARG=${3}

# Json and script
START_SCRIPT="start.sh"
JSON_FILE="config.json"

# error handling
function fn_error() {
    echo "ERROR: $1"
    exit 1
}

# file presents check
function fn_is_present() {
    test -e "$1"
}

# help function
function fn_help() {
    echo "Script usage: ${0} [Server name] [Command]"
    echo "Commands list:"
    echo -e "start \011\011- Start server"
    echo -e "stop \011\011- Stop server"
    echo -e "restart \011- Restart server"
    echo -e "status \011\011- Display the server status"
    echo -e "console \011- Open the server console"
    echo -e "broad [string] \011- Broadcast a string"
    echo -e "cmd [string] \011- Execute a command"
    exit
}

if [ "${SERVER}" == "-help" ] || [ "${SERVER}" == "" ]
then
    fn_help
fi

######################
# Imports and checks #
######################

# start script check
if ! fn_is_present $START_SCRIPT
then
    fn_error "Start script not present."
fi

# json file check
if ! fn_is_present $JSON_FILE
then
    fn_error "Json file not present."
fi

# server check
if ! jq -r ".servers | keys" $JSON_FILE | grep -q "$SERVER"
then
    if ! fn_is_present "$SERVER"
    then
        if fn_prompt_yn "Server foulder not present, want to make one?" Y
        then
            mkdir "$SERVER"
        else
            fn_error "Can't start the server."
        fi
    else
        fn_error "Server not present."
    fi
fi

# Jar import and check
JAR_FILE=$(jq -r ".servers.${SERVER}.jar_file" "$JSON_FILE")
if [ ! $JAR_FILE == null ]
then
    if ! fn_is_present "$SERVER/$JAR_FILE"
    then
        fn_error "Jar file not present or incorrect."
    fi
fi

# log file import and check
LOG_FILE="$SERVER/$(jq -r ".files.logs_file" "$JSON_FILE")"
if ! fn_is_present "$LOG_FILE"
then
    echo "Log file not present, making a new one..."
    touch "$LOG_FILE"
fi

# status file import
STATUS_FILE="$SERVER/$(jq -r ".files.status_file" "$JSON_FILE")"

# statuses import
declare -A STATUS=(
    ["on"]="$(jq -r ".statuses.on" "$JSON_FILE")"
    ["run"]="$(jq -r ".statuses.run" "$JSON_FILE")"
    ["res"]="$(jq -r ".statuses.res" "$JSON_FILE")"
    ["off"]="$(jq -r ".statuses.off" "$JSON_FILE")"
    ["err"]="$(jq -r ".statuses.err" "$JSON_FILE")"
)

# session parameters
SESSION_NAME="MC_${SERVER}"

#############
# Functions #
#############

# y/n request
function fn_prompt_yn() {
    local prompt="$1"
    local initial="$2"
    
    if [ "${initial}" == "Y" ]; then
        prompt+=" [Y/n] "
        elif [ "${initial}" == "N" ]; then
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

# eula check
function fn_eula_check() {
    if fn_is_present "$SERVER/eula.txt"
    then
        if grep -q "false" "$SERVER/eula.txt"
        then
            fn_eula_agree
        fi
    else
        echo "EULA file missing, making one..."
        fn_eula_agree
    fi
}

# asks for eula agreement
function fn_eula_agree() {
    echo "You need to agree to the EULA in order to run the server."
    if fn_prompt_yn "Do you agree?" Y
    then
        printf "#%s \neula=true\n" "$(date)" > "$SERVER"/eula.txt
    else
        fn_error "Can't start the server without the agreement of the eula."
    fi
}

# server and session start
function fn_server_start() {
    tmux new -d -s "${SESSION_NAME}" ./$START_SCRIPT "$SERVER" "$JSON_FILE"
}

# check if session exist
function fn_session_check() {
    tmux ls 2>/dev/null | grep -qc "${SESSION_NAME}"
}

# open session
function fn_open_session(){
    echo -e "Press \"CTRL+b\" then \"d\" to exit console."
    echo -e "Do NOT press CTRL+c to exit."
    
    if fn_prompt_yn "Continue?" Y
    then
        tmux attach-session -t "$SESSION_NAME"
    fi
}

# execute a command in the server console
function fn_to_console() {
    tmux send -t "${SESSION_NAME}" "${1}" Enter
}

# change the server status
function fn_change_status() {
    echo "$1" > "$STATUS_FILE"
}

##################
# Commands cases #
##################

case $COMMAND
    in
    start)
        if fn_session_check
        then
            fn_error "Server is already running..."
        else
            fn_eula_check
            echo "Server starting..."
            fn_change_status "${STATUS[on]}"
            fn_server_start
        fi
    ;;
    
    stop)
        if fn_session_check
        then
            echo "Server stopping..."
            fn_change_status "${STATUS[off]}"
            fn_to_console "broadcast Stopping the server in 5 seconds."
            sleep 5
            fn_to_console "stop"
        else
            fn_error "Server is already stopped..."
        fi
    ;;
    
    restart)
        if fn_session_check
        then
            echo "Server restarting..."
            fn_change_status "${STATUS[res]}"
            fn_to_console "broadcast Restarting the server in 5 seconds."
            sleep 5
            fn_to_console "stop"
        else
            fn_error "Server is not active..."
        fi
    ;;
    
    console)
        if fn_session_check
        then
            fn_open_session
        else
            fn_error "Server is not active..."
        fi
    ;;
    
    broad)
        if fn_session_check
        then
            fn_to_console "broadcast $ARG"
        else
            fn_error "Server is not active..."
        fi
    ;;
    
    cmd)
        if fn_session_check
        then
            fn_to_console "$ARG"
        else
            fn_error "Server is not active..."
        fi
    ;;
    
    status)
        if fn_is_present "${STATUS_FILE}"
        then
            cat "$STATUS_FILE"
        else
            fn_error "Missing status file..."
        fi
    ;;
    
    *)
        fn_error "Invalid or missing command, Type ./server.sh -help to show useful commands."
    ;;
esac
