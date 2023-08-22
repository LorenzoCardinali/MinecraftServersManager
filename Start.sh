#!/bin/bash
  ###### ######## ####### #######  ###  #######
###           ##       ##      ## ###         
###      #######  ######  ###  ## ###  #######
###      ###  ##  ##  ##  ###  ## ###  ##     
 ######  ###  ##  ##   ## ######  ###  ##       

# arguments
SERVER=$1
JSON_FILE=$2

###########
# Imports #
###########

# status file import
STATUS_FILE=$(jq -r ".Files.status_file" "$JSON_FILE")

# statuses import
declare -A STATUSES=(
	["on"]="$(jq -r ".Statuses.on" "$JSON_FILE")"
	["run"]="$(jq -r ".Statuses.run" "$JSON_FILE")"
	["res"]="$(jq -r ".Statuses.res" "$JSON_FILE")"
	["off"]="$(jq -r ".Statuses.off" "$JSON_FILE")"
)

# log file import
LOG_FILE=$(jq -r ".Files.logs_file" "$JSON_FILE")

# ram import
MIN_RAM=$(jq -r ".Servers.${SERVER}.min_ram" "$JSON_FILE")
MAX_RAM=$(jq -r ".Servers.${SERVER}.max_ram" "$JSON_FILE")

# parameters import
PARAMETER_ID=$(jq -r ".Servers.${SERVER}.parameter_id" "$JSON_FILE")
PARAMETERS=$(jq -r ".Parameters[${PARAMETER_ID}]" "$JSON_FILE")

# Jar import 
JAR_FILE=$(jq -r ".Servers.${SERVER}.jar_file" "$JSON_FILE")
if [ "$JAR_FILE" == null ]
then
	JAR_FILE=""
else
	JAR_FILE="-jar ${JAR_FILE}"
fi

#############
# Functions #
#############

# logging handling
function to_log() {
	echo "[$(date)] : ${1}" >> "$LOG_FILE"
}

# change the server status
function change_status() {
	echo "$1" > "$STATUS_FILE"
}

# move to server directory if present
cd "$SERVER" || exit 1

while true
do
	case $(cat "$STATUS_FILE")
	in
		"${STATUSES[on]}")
			to_log "Server started."
			change_status "${STATUSES[run]}"
			java -Xmx${MAX_RAM} -Xms${MIN_RAM} ${PARAMETERS} ${JAR_FILE} -nogui
		;;

		"${STATUSES[run]}")
			to_log "Server closed or crashed, restarting it..."
			change_status "${STATUSES[on]}"
		;;

		"${STATUSES[res]}")
			to_log "Server restarted."
			change_status "${STATUSES[on]}"
		;;

		"${STATUSES[off]}")
			to_log "Server stopped."
			exit 0
		;;

		*)
			to_log "ERROR Start script."
			to_log "Status file -> $(cat "$STATUS_FILE")"
			rm "$STATUS_FILE"
			exit 1
		;;
	esac
done
