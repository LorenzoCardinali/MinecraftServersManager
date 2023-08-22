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
STATUS_FILE=$(jq -r ".files.status_file" "$JSON_FILE")

# statuses import
declare -A STATUS=(
	["on"]="$(jq -r ".statuses.on" "$JSON_FILE")"
	["run"]="$(jq -r ".statuses.run" "$JSON_FILE")"
	["res"]="$(jq -r ".statuses.res" "$JSON_FILE")"
	["off"]="$(jq -r ".statuses.off" "$JSON_FILE")"
)

# log file import
LOG_FILE=$(jq -r ".files.logs_file" "$JSON_FILE")

# ram import
MIN_RAM=$(jq -r ".servers.${SERVER}.min_ram" "$JSON_FILE")
MAX_RAM=$(jq -r ".servers.${SERVER}.max_ram" "$JSON_FILE")

# parameters import
PARAMETER_ID=$(jq -r ".servers.${SERVER}.parameter_id" "$JSON_FILE")
PARAMETERS=$(jq -r ".parameters[${PARAMETER_ID}]" "$JSON_FILE")

# Jar import 
JAR_FILE=$(jq -r ".servers.${SERVER}.jar_file" "$JSON_FILE")
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
function fn_to_log() {
	echo "[$(date)] : ${1}" >> "$LOG_FILE"
}

# change the server status
function fn_change_status() {
	echo "$1" > "$STATUS_FILE"
}

# move to server directory if present
cd "$SERVER" || exit 1
#######################
# Server handler loop #
#######################

while true
do
	case $(cat "$STATUS_FILE")
	in
		"${STATUS[on]}")
			fn_to_log "Server started."
			fn_change_status "${STATUS[run]}"
			java -Xmx${MAX_RAM} -Xms${MIN_RAM} ${PARAMETERS} ${JAR_FILE} -nogui
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

		*)
			fn_to_log "ERROR Start script."
			fn_to_log "Status file -> $(cat "$STATUS_FILE")"
			rm "$STATUS_FILE"
			exit 1
		;;
	esac
done
