#!/bin/bash

# papermc api url
URL="https://papermc.io/api/v2/projects/paper"

# initial version
initial="latest"

echo "Making server folders..."
mkdir -p "$DATA_FOLDER"

while true; do
    read -e -i "$initial" -p "Insert version (ex. 1.20): " -r respond

    if [ "$respond" == "latest" ]; then
        version="latest"
        break
    fi

    results=$(wget -qO - "$URL" | jq -r ".versions" | grep -c "$respond")

    if [ "$results" -eq 0 ]; then
        fn_error "No matching result, try again." false
    elif [ "$results" -gt 1 ]; then
        fn_error "Too many matching results, try again." false
    else
        version=$respond
        break
    fi

    initial=$respond
done

if [ "$version" == "latest" ]; then
    # Get the latest MC version
    version=$(wget -qO - $URL | jq -r '.versions[-1]')
fi

URL="$URL/versions/$version"
PAPER_BUILD=$(wget -qO - "$URL" | jq '.builds[-1]')
JAR_NAME="paper-$version-$PAPER_BUILD.jar"
URL="$URL/builds/$PAPER_BUILD/downloads/$JAR_NAME"

# Download the jar and check if the download was successful
wget "$URL" -O "$SERVER_PATH/$JAR_NAME" -q --show-progress
if [ $? -ne 0 ]; then
    fn_error "Failed to download the jar file."
fi

# initial ram size
initial=1024

while true; do
    read -e -i "$initial" -p "Insert max server ram MB (ex. 1024): " -r respond

    if ! [[ $respond =~ ^[0-9]+$ ]]; then
        fn_error "Not a number" false
    elif [[ $respond -lt 512 ]]; then
        fn_error "Ram size must be greater than 512 MB" false
    elif [[ $respond -gt 32768 ]]; then
        fn_error "Ram size must be less than 32768 MB" false
    else
        size=$respond
        break
    fi

    initial=$respond
done

# creating config file
jar="${JAR_NAME}" ram="${size}M" min_ram="$((size / 2))M" yq '.jar_file = strenv(jar) | .max_ram = strenv(ram) | .min_ram = strenv(min_ram)' "$CONFIG_PATH/base.yml" >"$CONFIG_FILE"
