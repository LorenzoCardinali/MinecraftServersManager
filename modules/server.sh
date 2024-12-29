#!/bin/bash

# move to script directory
#cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

# arguments
COMMAND=${1}
ARG=${2}

######################
# Imports and checks #
######################

# config file check
fn_is_present "$CONFIG_FILE" "Yaml file not present."

# import jar file
JAR_FILE="$SERVER_PATH/$(yq e '.jar_file' "$CONFIG_FILE")"
fn_is_present "$JAR_FILE" "Jar file not found."
export JAR_FILE

# log file check
if ! fn_is_present "$LOG_FILE"
then
    echo "Log file not present, making a new one..."
    fn_to_log "Made log file" "$LOG_FILE"
fi

# session parameters
SESSION_NAME="MC_${SERVER_NAME}"

EULA_FILE="$SERVER_PATH/eula.txt"

#############
# Functions #
#############

# eula check
function fn_eula_check() {
    if fn_is_present "$EULA_FILE"
    then
        if grep -q "false" "$EULA_FILE"
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
        printf "#%s \neula=true\n" "$(date)" > "$EULA_FILE"
    else
        fn_error "Can't start the server without the agreement of the eula."
    fi
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

case "$COMMAND" in
    start)
        if fn_session_check
        then
            fn_error "Server is already running..."
        else
            fn_eula_check
            echo "Server starting..."
            fn_change_status "$STATUS_on" "$STATUS_FILE"
            tmux new -d -s "${SESSION_NAME}" bash "$MODULE_PATH/$START_MODULE"
        fi
    ;;
    
    stop)
        if fn_session_check
        then
            echo "Server stopping..."
            fn_change_status "$STATUS_off" "$STATUS_FILE"
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
            fn_change_status "$STATUS_res" "$STATUS_FILE"
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
            fn_error "Missing status file..." false
            echo "Making one..."
            fn_change_status "$STATUS_off" "$STATUS_FILE"
        fi
    ;;
    
    *)
        fn_error "Invalid or missing command."
    ;;
esac
