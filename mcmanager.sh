#!/bin/bash

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

# Assign server name and command
COMMAND=$1
SERVER_NAME=$2
ARG=${3:-}

# path definitions
SOURCE_PATH=$(dirname "$0")

SERVER_PATH="$PWD/$SERVER_NAME"
export SERVER_PATH

MODULE_PATH="$SOURCE_PATH/modules"
export MODULE_PATH
LIBS_PATH="$SOURCE_PATH/libs"
CONFIG_PATH="$SOURCE_PATH/config"
export CONFIG_PATH

source "$LIBS_PATH/var-lib.sh"
source "$LIBS_PATH/fun-lib.sh"

echo "$STATUS"

# $(var="$SERVER_NAME" yq '.servers | has(strenv(var))' conf/"$YAML_FILE")

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    fn_error "Insufficient arguments provided. Use 'help' for usage information."
fi

# Check if server name is provided
if [ $# -eq 1 ]; then
    fn_error "Server name is required."
fi

# Parse the command
case $COMMAND in
    add)
        if fn_is_present "$SERVER_PATH"; then
            fn_error "Server $SERVER_NAME already exists."
        fi
        echo "Adding server: $SERVER_NAME"
        bash "$MODULE_PATH/$ADDSERVER_MODULE"
        ;;

    start)
        echo "Starting server: $SERVER_NAME"
        bash "$MODULE_PATH/$SERVER_MODULE" start
        ;;
    
    stop)
        echo "Stopping server: $SERVER_NAME"
        bash "$MODULE_PATH/$SERVER_MODULE" stop
        ;;
    
    restart)
        echo "Restarting server: $SERVER_NAME"
        bash "$MODULE_PATH/$SERVER_MODULE" restart
        ;;
    
    status)
        echo "Checking status of server: $SERVER_NAME"
        bash "$MODULE_PATH/$SERVER_MODULE" status
        ;;
    
    console)
        echo "Opening console for server: $SERVER_NAME"
        bash "$MODULE_PATH/$SERVER_MODULE" console
        ;;
    
    broad)
        if [ -z "$ARG" ]; then
            fn_error "Please provide a message to broadcast."
            exit 1
        fi
        echo "Broadcasting message to server: $SERVER_NAME"
        bash "$MODULE_PATH/$SERVER_MODULE" broad "$ARG"
        ;;
    
    cmd)
        if [ -z "$ARG" ]; then
            fn_error "Please provide a command to execute."
            exit 1
        fi
        echo "Executing command in server console: $ARG"
        bash "$MODULE_PATH/$SERVER_MODULE" cmd "$ARG"
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