#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Copyright 2018 Alessandro "Locutus73" Miele

# Version 1.1 - 2018.12.11 - Added support for additional repositories (i.e. Scaler filters and Game Boy palettes), renamed some variables
# Version 1.0 - 2018.12.11 - First commit



#Change these self-explanatory variables in order to adjust destination paths, etc.
MISTER_URL="https://github.com/MiSTer-devel/Main_MiSTer"
BASE_PATH="/media/fat"
CORES_PATH="$BASE_PATH"
ARCADE_CORES_PATH="$BASE_PATH/_Arcade"
DELETE_OLD_FILES=true
#Comment next line if you don't want to download from additional repositories (i.e. Scaler filters and Gameboy palettes) each time
ADDITIONAL_REPOSITORIES=( "https://github.com/MiSTer-devel/Filters_MiSTer/tree/master/Filters txt $BASE_PATH/Filters" "https://github.com/MiSTer-devel/Gameboy_MiSTer/tree/master/palettes gbp $BASE_PATH/GameBoy/" )

if [ ! -d $CORES_PATH ]
then
	mkdir -p $CORES_PATH
fi
if [ ! -d $ARCADE_CORES_PATH ]
then
	mkdir -p $ARCADE_CORES_PATH
fi

CORE_URLS=$MISTER_URL$'\n'$(curl -ksLf "$MISTER_URL/wiki"| awk '/user-content-cores/,/user-content-service-cores/' | grep -io 'https://github.com/[a-zA-Z0-9./_-]*_MiSTer')

for CORE_URL in $CORE_URLS; do
	echo "Checking $CORE_URL"
	RELEASES_URL=https://github.com$(curl -ksLf "$CORE_URL" | grep -o '/MiSTer-devel/[a-zA-Z0-9./_-]*/tree/[a-zA-Z0-9./_-]*/releases' | head -n1)
	RELEASE_URLS=$(curl -ksLf "$RELEASES_URL" | grep -o '/MiSTer-devel/[a-zA-Z0-9./_-]*_[0-9]\{8\}\w\?\(\.rbf\)\?')
	
	MAX_VERSION=""
	MAX_RELEASE_URL=""
	for RELEASE_URL in $RELEASE_URLS; do
		CURRENT_VERSION=$(echo "$RELEASE_URL" | grep -o '[0-9]\{8\}[a-zA-Z]\?')
		if [[ "$CURRENT_VERSION" > "$MAX_VERSION" ]]
		then
			MAX_VERSION=$CURRENT_VERSION
			MAX_RELEASE_URL=$RELEASE_URL
		fi
	done
	
	FILE_NAME=$(echo "$MAX_RELEASE_URL" | sed 's/.*\///g')
	BASE_FILE_NAME=$(echo "$MAX_RELEASE_URL" | sed 's/.*\///g' | sed 's/_[0-9]\{8\}.*//g')
	if (echo "$MAX_RELEASE_URL" | grep -q '/Arcade-')
	then
		CURRENT_DIR=$ARCADE_CORES_PATH
	else
		CURRENT_DIR=$CORES_PATH
	fi
	if [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ]
	then
		CURRENT_DIR="$BASE_PATH"
	fi
	
	CURRENT_LOCAL_VERSION=""
	MAX_LOCAL_VERSION=""
	for CURRENT_FILE in "$CURRENT_DIR/$BASE_FILE_NAME"*
	do
		if [ -f "$CURRENT_FILE" ]
		then
			if echo "$CURRENT_FILE" | grep -q "$BASE_FILE_NAME\_[0-9]\{8\}[a-zA-Z]\?"
			then
				CURRENT_LOCAL_VERSION=$(echo "$CURRENT_FILE" | grep -o '[0-9]\{8\}[a-zA-Z]\?')
				if [[ "$CURRENT_LOCAL_VERSION" > "$MAX_LOCAL_VERSION" ]]
				then
					MAX_LOCAL_VERSION=$CURRENT_LOCAL_VERSION
				fi
				if [[ "$MAX_VERSION" > "$CURRENT_LOCAL_VERSION" ]] && [ $DELETE_OLD_FILES == true ]
				then
					echo "Deleting $CURRENT_FILE"
					rm "$CURRENT_FILE"
				fi
			fi
		fi
	done
	
	if [[ "$MAX_VERSION" > "$MAX_LOCAL_VERSION" ]]
	then
		echo "Downloading https://github.com$MAX_RELEASE_URL?raw=true"
		curl -kL "https://github.com$MAX_RELEASE_URL?raw=true" -o "$CURRENT_DIR/$FILE_NAME"
		if [ $BASE_FILE_NAME == "MiSTer" ] || [ $BASE_FILE_NAME == "menu" ]
		then
			DESTINATION_FILE=$(echo "$MAX_RELEASE_URL" | sed 's/.*\///g' | sed 's/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
			echo "Copying $DESTINATION_FILE"
			rm "$CURRENT_DIR/$DESTINATION_FILE"
			cp "$CURRENT_DIR/$FILE_NAME" "$CURRENT_DIR/$DESTINATION_FILE"
		fi
		sync
	else
		echo "Nothing to update"
	fi

	echo ""
done

for ADDITIONAL_REPOSITORY in "${ADDITIONAL_REPOSITORIES[@]}"; do
	PARAMS=($ADDITIONAL_REPOSITORY)
	CURRENT_DIR="${PARAMS[2]}"
	if [ ! -d "$CURRENT_DIR" ]
	then
		mkdir -p "$CURRENT_DIR"
	fi
	ADDITIONAL_FILES_URL="${PARAMS[0]}"
	echo "Checking $ADDITIONAL_FILES_URL"
	echo ""
	ADDITIONAL_FILE_URLS=$(curl -ksLf "$ADDITIONAL_FILES_URL" | grep -o "/MiSTer-devel/[a-zA-Z0-9./_-]*\.${PARAMS[1]}")
	for ADDITIONAL_FILE_URL in $ADDITIONAL_FILE_URLS; do
		ADDITIONAL_FILE_NAME=$(echo "$ADDITIONAL_FILE_URL" | sed 's/.*\///g')
		echo "Downloading https://github.com$ADDITIONAL_FILE_URL?raw=true"
		curl -kL "https://github.com$ADDITIONAL_FILE_URL?raw=true" -o "$CURRENT_DIR/$ADDITIONAL_FILE_NAME"
		sync
		echo ""
	done
done

echo "Done!"