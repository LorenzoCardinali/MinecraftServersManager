#!/bin/bash
  ###### ######## ####### #######  ###  #######
###           ##       ##      ## ###
###      #######  ######  ###  ## ###  #######
###      ###  ##  ##  ##  ###  ## ###  ##
 ######  ###  ##  ##   ## ######  ###  ##

# arguments
SERVER=${1}

JSON_FILE="config.json"
JSON_BASE="base.json"

VERSION=""

# error handling
function fn_error() {
	echo "ERROR: $1"
	exit 1
}	

# file presents check
function fn_is_present() {
	test -e "$1"
}

if [ "${SERVER}" == "" ]
then
	fn_error "Missing server name"
fi

# y/n request
function fn_prompt_yn() {
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

URL=https://papermc.io/api/v2/projects/paper

# custom requests for papermc api
initial="latest"

while true
do
	read -e -i "${initial}" -p " Insert version (ex. 1.20): " -r respond

	if [ "${respond}" == "latest" ]
	then
		VERSION="latest"
		break
	fi
	
	results=$(wget -qO - $URL | jq -r ".versions" | grep -c "$respond")

	if [ $results -eq 0 ]
	then
		echo -e "No matching result, try again."
	elif [ $results -gt 1 ]
	then
		echo -e "Too many matching results, try again."
	else
		VERSION="${respond}"
		break
	fi

	initial=$respond
done

if [ ${VERSION} = latest ]
then
  # Get the latest MC version
  VERSION=$(wget -qO - $URL | jq -r '.versions[-1]') # "-r" is needed because the output has quotes otherwise
fi
URL=${URL}/versions/${VERSION}
PAPER_BUILD=$(wget -qO - $URL | jq '.builds[-1]')
JAR_NAME="paper-${VERSION}-${PAPER_BUILD}.jar"
URL=${URL}/builds/${PAPER_BUILD}/downloads/${JAR_NAME}

if ! fn_is_present "${SERVER}"
then
	echo "Server folder missing, making one..."
	mkdir ${SERVER}
fi

wget ${URL} -O ${SERVER}/${JAR_NAME}

