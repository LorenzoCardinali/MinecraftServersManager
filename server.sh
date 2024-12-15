#!/bin/bash
###### ######## ####### #######  ###  #######
###           ##       ##      ## ###
###      #######  ######  ###  ## ###  #######
###      ###  ##  ##  ##  ###  ## ###  ##
######  ###  ##  ##   ## ######  ###  ##

# move to script directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

# arguments
COMMAND=${1}
SERVER=${2}
ARG=${3}

source "$(dirname "$0")/libs.sh"

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
    fn_error "Server configs not found."
fi

if ! fn_is_present "$SERVER"
then
    fn_error "Server folder not present."
fi

if [ "$JAR_FILE" == "null" ]
then
    fn_error "Jar file incorrect."
fi

if ! fn_is_present "$JAR_FILE"
then
    fn_error "Jar file not found."
fi

# log file check
if ! fn_is_present "$LOG_FILE"
then
    echo "Log file not present, making a new one..."
    touch "$LOG_FILE"
fi

# session parameters
SESSION_NAME="MC_${SERVER}"

#############
# Functions #
#############

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
            #./$START_SCRIPT "$SERVER" "$JSON_FILE"
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
        fn_error "Invalid or missing command."
    ;;
esac
