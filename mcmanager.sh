#!/bin/bash
###### ######## ####### #######  ###  #######
###           ##       ##      ## ###
###      #######  ######  ###  ## ###  #######
###      ###  ##  ##  ##  ###  ## ###  ##
######  ###  ##  ##   ## ######  ###  ##

# Function to display help
function display_help() {
    echo "Usage: $0 [command] [server_name] [arguments]"
    echo "Commands:"
    echo "  start                  - Start the specified server"
    echo "  stop                   - Stop the specified server"
    echo "  restart                - Restart the specified server"
    echo "  status                 - Display the status of the specified server"
    echo "  console                - Open the server console"
    echo "  broad [message]        - Broadcast a message to the server"
    echo "  cmd [command]          - Execute a command in the server console"
    echo "  help                   - Display this help message"
}

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    fn_error "Insufficient arguments provided. Use 'help' for usage information."
    exit 1
fi

# Assign server name and command
COMMAND=$1
SERVER=$2
ARG=${3:-}

source "$(dirname "$0")/libs.sh"

# Parse the command
case $COMMAND in
    start)
        echo "Starting server: $SERVER"
        ./server.sh start "$SERVER"
        ;;
    
    stop)
        echo "Stopping server: $SERVER"
        ./server.sh stop "$SERVER"
        ;;
    
    restart)
        echo "Restarting server: $SERVER"
        ./server.sh restart "$SERVER"
        ;;
    
    status)
        echo "Checking status of server: $SERVER"
        ./server.sh status "$SERVER"
        ;;
    
    console)
        echo "Opening console for server: $SERVER"
        ./server.sh console "$SERVER"
        ;;
    
    broad)
        if [ -z "$ARG" ]; then
            fn_error "Please provide a message to broadcast."
            exit 1
        fi
        echo "Broadcasting message to server: $SERVER"
        ./server.sh broad "$SERVER" "$ARG"
        ;;
    
    cmd)
        if [ -z "$ARG" ]; then
            fn_error "Please provide a command to execute."
            exit 1
        fi
        echo "Executing command in server console: $ARG"
        ./server.sh cmd "$SERVER" "$ARG"
        ;;
    
    help)
        display_help
        ;;
    
    *)
        fn_error "Invalid command: $COMMAND"
        display_help
        exit 1
        ;;
esac