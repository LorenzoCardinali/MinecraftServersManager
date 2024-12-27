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

# file definition
YAML_FILE="config.yml"
export YAML_FILE

LOG_FILE="activity.log"
export LOG_FILE

STATUS_FILE=".status"
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
