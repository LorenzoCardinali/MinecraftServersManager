#!/bin/bash

source "$(dirname "$0")/libs/var-lib.sh"
source "$(dirname "$0")/libs/fun-lib.sh"

# Function to display help
function display_help() {
    echo "Usage: $0 [command] [server_name] [arguments]"
    echo "Commands:"
    echo "  add                     - Add new server"                  
    echo "  start                   - Start the specified server"
    echo "  stop                    - Stop the specified server"
    echo "  restart                 - Restart the specified server"
    echo "  status                  - Display the status of the specified server"
    echo "  console                 - Open the server console"
    echo "  broad [message]         - Broadcast a message to the server"
    echo "  cmd [command]           - Execute a command in the server console"
    echo "  help                    - Display this help message"
}

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    fn_error "Insufficient arguments provided. Use 'help' for usage information."
fi

# Check if server name is provided
if [ $# -eq 1 ]; then
    fn_error "Server name is required."
fi

# Assign server name and command
COMMAND=$1
SERVER_NAME=$2
export SERVER_NAME
ARG=${3:-}

# Parse the command
case $COMMAND in
    add)
        if $(var="$SERVER_NAME" yq '.servers | has(strenv(var))' conf/"$YAML_FILE") ; then
            fn_error "Server '$SERVER_NAME' already exists."
        fi
        echo "Adding server: $SERVER_NAME"
        bash modules/"$ADDSERVER_MODULE"
        ;;

    start)
        echo "Starting server: $SERVER_NAME"
        bash modules/"$SERVER_MODULE" start "$SERVER_NAME"
        ;;
    
    stop)
        echo "Stopping server: $SERVER_NAME"
        bash modules/"$SERVER_MODULE" stop "$SERVER_NAME"
        ;;
    
    restart)
        echo "Restarting server: $SERVER_NAME"
        bash modules/"$SERVER_MODULE" restart "$SERVER_NAME"
        ;;
    
    status)
        echo "Checking status of server: $SERVER_NAME"
        bash modules/"$SERVER_MODULE" status "$SERVER_NAME"
        ;;
    
    console)
        echo "Opening console for server: $SERVER_NAME"
        bash modules/"$SERVER_MODULE" console "$SERVER_NAME"
        ;;
    
    broad)
        if [ -z "$ARG" ]; then
            fn_error "Please provide a message to broadcast."
            exit 1
        fi
        echo "Broadcasting message to server: $SERVER_NAME"
        bash modules/"$SERVER_MODULE" broad "$SERVER_NAME" "$ARG"
        ;;
    
    cmd)
        if [ -z "$ARG" ]; then
            fn_error "Please provide a command to execute."
            exit 1
        fi
        echo "Executing command in server console: $ARG"
        bash modules/"$SERVER_MODULE" cmd "$SERVER_NAME" "$ARG"
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