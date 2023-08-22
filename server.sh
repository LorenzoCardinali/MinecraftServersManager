#!/bin/bash
  ###### ######## ####### #######  ###  #######
###           ##       ##      ## ###
###      #######  ######  ###  ## ###  #######
###      ###  ##  ##  ##  ###  ## ###  ##
 ######  ###  ##  ##   ## ######  ###  ##

# move to script directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

# arguments
SERVER=${1}
COMMAND=${2}
ARG=${3}

# Json and script
START_SCRIPT="Start.sh"
JSON_FILE="Config.json"

# error handling
function error() {
	echo "ERROR: $1"
	exit 1
}	

# file presents check
function is_present() {
	test -f "$1"
}

# help
function help() {
	echo "Script usage: ${0} [Server name] [Command]"
	echo "Commands list:"
	echo -e "start \011\011- Start server"
	echo -e "stop \011\011- Stop server"
	echo -e "restart \011- Restart server"
	echo -e "status \011\011- Display the server status"
	echo -e "console \011- Open the server console"
	echo -e "broad [string] \011- Broadcast a string"
	echo -e "cmd [string] \011- Execute a command"
	exit
}

if [ "${SERVER}" == "" ] || [ "${SERVER}" == "-help" ]
then
	help
fi

######################
# Imports and checks #
######################

# start script check
if ! is_present $START_SCRIPT 
then 
	error "Start script not present."
fi

# Json and Server check
if is_present $JSON_FILE
then
	if [ "$SERVER" == "" ]
	then
		help "invalid Server name"
	elif ! jq -r ".Servers | keys" $JSON_FILE | grep -q "$SERVER"
	then
		error "Server not present."
	fi
else
	error "Json file not present."
fi

# Jar import and check
JAR_FILE=$(jq -r ".Servers.${SERVER}.jar_file" "$JSON_FILE")
if [ ! $JAR_FILE == null ]
then
 	if ! is_present "$SERVER/$JAR_FILE"
	then
		error "Jar file not present or incorrect."
	fi
fi

# log file import and check
LOG_FILE="$SERVER/$(jq -r ".Servers.$SERVER.logs_file" "$JSON_FILE")"
if ! is_present "$LOG_FILE"
then
	echo "Log file not present, making a new one..."
	touch "$LOG_FILE"
fi

# status file import
STATUS_FILE="$SERVER/$(jq -r ".Servers.$SERVER.status_file" "$JSON_FILE")"

# statuses import
declare -A STATUSES=(
	["on"]="$(jq -r ".Statuses.on" "$JSON_FILE")"
	["run"]="$(jq -r ".Statuses.run" "$JSON_FILE")"
	["res"]="$(jq -r ".Statuses.res" "$JSON_FILE")"
	["off"]="$(jq -r ".Statuses.off" "$JSON_FILE")"
)

# session parameters
SESSION_NAME="$(echo "MC_${SERVER}_${PWD##*/}" | tr '.' '_')"

#############
# Functions #
#############

# y/n request
fn_prompt_yn() {
	local prompt="$1"
	local initial="$2"

	if [ "${initial}" == "Y" ]; then
		prompt+=" [Y/n] "
	elif [ "${initial}" == "N" ]; then
		prompt+=" [y/N] "
	else
		prompt+=" [y/n] "
	fi

	while true; do
		read -e -i "${initial}" -p "${prompt}" -r yn
		case "${yn}" in
			[Yy] | [Yy][Ee][Ss]) return 0 ;;
			[Nn] | [Nn][Oo]) return 1 ;;
			*) echo -e "Please answer yes or no." ;;
		esac
	done
}

# server and screen start
function server_start() {
	tmux new -d -s "${SESSION_NAME}" ./$START_SCRIPT "$SERVER" "$JSON_FILE"
}

# check if session exist
function session_check() {
	tmux ls 2>/dev/null | grep -qc "${SESSION_NAME}"
}

# open session
function open_session(){
	echo -e "Press \"CTRL+b\" then \"d\" to exit console."
	echo -e "Do NOT press CTRL+c to exit."

	if fn_prompt_yn "Continue?" Y
	then
		echo "Accessing console"
		tmux attach-session -t "$SESSION_NAME"
		echo "Console closed"
	fi
}

# execute a command in the server console
function to_console() {
	tmux send -t "${SESSION_NAME}" "${1}" Enter
}

# change the server status
function change_status() {
	echo "$1" > "$STATUS_FILE"
}

##################
# Commands cases #
##################

case $COMMAND
in
	start)
		if session_check
		then
			error "Server is already running..."
		else
			echo "Server starting..."
			change_status "${STATUSES[on]}"
			server_start
 		fi
	;;

  	stop)
		if session_check
		then
			echo "Server stopping..."
			change_status "${STATUSES[off]}"
			to_console "say Stopping the server in 5 seconds."
        	sleep 5
			to_console "stop"
		else
			error "Server is already stopped..."
		fi
   	;;

	restart)
		if session_check
		then
			echo "Server restarting..."
			change_status "${STATUSES[res]}"
			to_console "say Restarting the server in 5 seconds."
        	sleep 5
			to_console "stop"
		else
			error "Server is not active..."
		fi
   	;;

	console)
		if session_check 
		then
			open_session
		else
			error "Server is not active..."
		fi
	;;

	broad)
		if session_check
		then
			to_console "say $ARG"
		else
			error "Server is not active..."
		fi
	;;

	cmd)
		if session_check
		then
			to_console "$ARG"
		else
			error "Server is not active..."
		fi
	;;

	status)
		if is_present "${STATUS_FILE}"
		then
			cat "$STATUS_FILE"
		else
			error "Missing status file..."
		fi
	;;

  	*)
		echo "ERROR: $COMMAND"
		help "invalid command"
    ;;
esac
