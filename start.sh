#!/bin/bash
###### ######## ####### #######  ###  #######
###           ##       ##      ## ###
###      #######  ######  ###  ## ###  #######
###      ###  ##  ##  ##  ###  ## ###  ##
######  ###  ##  ##   ## ######  ###  ##

# arguments
SERVER=$1
JSON_FILE=$2

source "$(dirname "$0")/libs.sh"

###########
# Imports #
###########

# ram import
MIN_RAM=$(jq -r ".servers.${SERVER}.min_ram" "$JSON_FILE")
MAX_RAM=$(jq -r ".servers.${SERVER}.max_ram" "$JSON_FILE")

# parameters import
PARAMETER_ID=$(jq -r ".servers.${SERVER}.parameter_id" "$JSON_FILE")
PARAMETERS=$(jq -r ".parameters[${PARAMETER_ID}]" "$JSON_FILE")

# Jar check
if [ "$JAR_FILE" == null ]
then
    JAR_FILE=""
else
    JAR_FILE="-jar ${JAR_FILE}"
fi

# move to server directory if present
cd "$SERVER" || exit 1

#################
# Crash handler #
#################

# timestamp and tries variables
TIME_STAMP=0
MAX_TRIES=3
TEST_TIME=500
TRIES=$MAX_TRIES

function fn_timer_update() {
    if [ $(($(date +%s) - "$TIME_STAMP")) -ge $TEST_TIME ]
    then
        TIME_STAMP=$(date +%s)
        TRIES=$MAX_TRIES
    else
        ((TRIES -= 1))
    fi
    
    if [ $TRIES -le 0 ]
    then
        fn_change_status "${STATUS[err]}"
    fi
}

#######################
# Server handler loop #
#######################

while true
do
    case $(fn_get_status)
        in
        "${STATUS[on]}")
            fn_to_log "Server started."
            fn_change_status "${STATUS[run]}"
            fn_timer_update
            java -Xmx${MAX_RAM} -Xms${MIN_RAM} ${PARAMETERS} ${JAR_FILE}
        ;;
        
        "${STATUS[run]}")
            fn_to_log "Server closed or crashed, restarting it..."
            fn_change_status "${STATUS[on]}"
        ;;
        
        "${STATUS[res]}")
            fn_to_log "Server restarted."
            fn_change_status "${STATUS[on]}"
        ;;
        
        "${STATUS[off]}")
            fn_to_log "Server stopped."
            exit 0
        ;;
        
        "${STATUS[err]}")
            fn_to_log "Server crashed multiple times, shutting it down..."
            fn_change_status "${STATUS[off]}"
        ;;
        
        *)
            fn_to_log "ERROR Start script."
            fn_to_log "Status file -> $(fn_get_status)"
            exit 1
        ;;
    esac
done
