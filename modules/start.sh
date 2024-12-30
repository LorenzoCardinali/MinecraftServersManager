#!/bin/bash

###########
# Imports #
###########

# ram import
MIN_RAM=$(yq '.min_ram' "$CONFIG_FILE")
MAX_RAM=$(yq '.max_ram' "$CONFIG_FILE")

# parameters import
PARAMETERS=$(yq '.parameters' "$CONFIG_FILE")

if [ "$JAR_FILE" == null ]; then
    JAR_FILE=""
else
    JAR_FILE="-jar $JAR_FILE"
fi

# move to server directory if present
cd "$SERVER_PATH" || exit 1

#################
# Crash handler #
#################

# timestamp and tries variables
TIMESTAMP=0
MAX_TRIES=3
TEST_TIME=500
TRIES=$MAX_TRIES

function fn_timer_update() {
    if [ $(($(date +%s) - "$TIMESTAMP")) -ge $TEST_TIME ]; then
        TIMESTAMP=$(date +%s)
        TRIES=$MAX_TRIES
    else
        ((TRIES -= 1))
    fi

    if [ $TRIES -le 1 ]; then
        fn_change_status "$STATUS_err" "$STATUS_FILE"
    fi
}

#######################
# Server handler loop #
#######################

while true; do
    case $(fn_get_status "$STATUS_FILE") in
    "$STATUS_on")
        echo "$LOG_FILE"
        fn_to_log "Server started." "$LOG_FILE"
        fn_change_status "$STATUS_run" "$STATUS_FILE"
        fn_timer_update
        java -Xmx${MAX_RAM} -Xms${MIN_RAM} ${JAR_FILE}
        ;;

    "$STATUS_run")
        fn_to_log "Server closed or crashed, restarting it..." "$LOG_FILE"
        fn_change_status "$STATUS_on" "$STATUS_FILE"
        ;;

    "$STATUS_res")
        fn_to_log "Server restarted." "$LOG_FILE"
        fn_change_status "$STATUS_on" "$STATUS_FILE"
        ;;

    "$STATUS_off")
        fn_to_log "Server stopped." "$LOG_FILE"
        exit 0
        ;;

    "$STATUS_err")
        fn_to_log "Server crashed multiple times, shutting it down..." "$LOG_FILE"
        fn_change_status "$STATUS_off" "$STATUS_FILE"
        ;;

    *)
        fn_to_log "ERROR Start script." "$LOG_FILE"
        fn_to_log "Status file -> $(fn_get_status "$STATUS_FILE")" "$LOG_FILE"
        exit 1
        ;;
    esac
done
