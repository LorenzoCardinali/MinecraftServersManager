#!/bin/bash
###### ######## ####### #######  ###  #######
###           ##       ##      ## ###
###      #######  ######  ###  ## ###  #######
###      ###  ##  ##  ##  ###  ## ###  ##
######  ###  ##  ##   ## ######  ###  ##

source "$(dirname "$0")/libs.sh"

# arguments
SERVER=${1:-default}

# Json files
JSON_FILE="config.json"

if [ -z "${SERVER}" ]
then
    fn_error "Missing server name"
fi

URL=https://papermc.io/api/v2/projects/paper

# custom requests for papermc api
initial="latest"

while true
do
    read -e -i "${initial}" -p "Insert version (ex. 1.20): " -r respond
    
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
    VERSION=$(wget -qO - $URL | jq -r '.versions[-1]')
fi

URL=${URL}/versions/${VERSION}
PAPER_BUILD=$(wget -qO - $URL | jq '.builds[-1]')
JAR_NAME="paper-${VERSION}-${PAPER_BUILD}.jar"
URL=${URL}/builds/${PAPER_BUILD}/downloads/${JAR_NAME}

# Makes the server folder if missing
if ! fn_is_present "${SERVER}"
then
    echo "Server folder missing, making one..."
    mkdir -p ${SERVER}
fi

# Download the jar
wget ${URL} -O ${SERVER}/${JAR_NAME} -q --show-progress

# Check if the download was successful
if [ $? -ne 0 ]
then
    echo "Failed to download the jar file."
    exit 1
fi

if ! fn_is_present "${JSON_FILE}"
then
	echo "Json file not present, making one..."
	wget https://raw.githubusercontent.com/LorenzoCardinali/MinecraftServersManager/refs/heads/main/config.json -q -O ${JSON_FILE}
fi