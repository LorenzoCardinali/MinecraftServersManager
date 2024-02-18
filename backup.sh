#!/bin/bash
  ###### ######## ####### #######  ###  #######
###           ##       ##      ## ###
###      #######  ######  ###  ## ###  #######
###      ###  ##  ##  ##  ###  ## ###  ##
 ######  ###  ##  ##   ## ######  ###  ##

FOLDER="backups"

# error handling
function fn_error() {
    echo "ERROR: $1"
    exit 1
}

# file presents check
function fn_is_present() {
    test -e "$1"
}

# check if backup folder exist
if ! fn_is_present "${FOLDER}"
then
	echo "Missing backups folder, making one..."
	mkdir "${FOLDER}"
fi

zip -FS9ryo ${FOLDER}/crossplay_worlds.zip crossplay/world*
zip -FS9ryo ${FOLDER}/crossplay_plugins.zip crossplay/plugins/* -x "crossplay/plugins/dynmap/web/tiles/faces/*" -x "crossplay/plugins/dynmap/web/tiles/world*" 
zip -FS9ryo ${FOLDER}/crossplay_settings.zip crossplay/* -x "crossplay/plugins/*" -x "crossplay/world*"
