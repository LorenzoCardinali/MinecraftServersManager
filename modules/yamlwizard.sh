#!/bin/bash

# Assign command and arguments
COMMAND=$1
KEY=$2
YAML_FILE=$3
VALUE=$4

# Function to view the entire YAML file
function view_yaml() {
    if [ -f "$YAML_FILE" ]; then
        cat "$YAML_FILE"
    else
        echo "YAML file not found."
    fi
}

# Function to get the value of a specific key
function get_yaml() {
    echo $(yq eval ".$KEY" "$YAML_FILE")
}

# Function to set the value of a specific key
function set_yaml() {
    if [ -f "$YAML_FILE" ]; then
        yq eval -i ".$KEY = \"$VALUE\"" "$YAML_FILE"
        echo "Set '$KEY' to '$VALUE'."
    else
        echo "YAML file not found."
    fi
}

# Function to delete a specific key
function delete_yaml() {
    if [ -f "$YAML_FILE" ]; then
        yq eval -i "del(.\"$KEY\")" "$YAML_FILE"
        echo "Deleted key '$KEY'."
    else
        echo "YAML file not found."
    fi
}

function add_server() {
    yq -i '.servers *= load("base.yaml")' "$YAML_FILE"
}

# Parse the command
case $COMMAND in
    view)
        view_yaml
    ;;
    
    get)
        if [ -z "$KEY" ]; then
            echo "Please provide a key to get."
            exit 1
        fi
        get_yaml
    ;;
    
    set)
        if [ -z "$KEY" ] || [ -z "$VALUE" ]; then
            echo "Please provide a key and a value to set."
            exit 1
        fi
        set_yaml
    ;;
    
    delete)
        if [ -z "$KEY" ]; then
            echo "Please provide a key to delete."
            exit 1
        fi
        delete_yaml
    ;;
    
    help)
        display_help
    ;;
    
    *)
        echo "Invalid command: $COMMAND"
        display_help
        exit 1
    ;;
esac