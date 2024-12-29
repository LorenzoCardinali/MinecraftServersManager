#!/bin/bash

# module definiotion
SERVER_MODULE="server.sh"
export SERVER_MODULE

START_MODULE="start.sh"
export START_MODULE

BACKUP_MODULE="backup.sh"
export BACKUP_MODULE

ADDSERVER_MODULE="addServer.sh"
export ADDSERVER_MODULE

# file / folder definition
SERVER_PATH="$PWD/$SERVER_NAME"
export SERVER_PATH
DATA_FOLDER="$SERVER_PATH/mcmanager"
export DATA_FOLDER

CONFIG_FILE="$DATA_FOLDER/config.yml"
export CONFIG_FILE

LOG_FILE="$DATA_FOLDER/activity.log"
export LOG_FILE

STATUS_FILE="$DATA_FOLDER/.status"
export STATUS_FILE

# statuses
declare -A STATUS=(
    ["on"]="active"
    ["run"]="running"
    ["res"]="restarting"
    ["off"]="inactive"
    ["err"]="error"
)
export STATUS
