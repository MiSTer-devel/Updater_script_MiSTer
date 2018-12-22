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

# Version 1.3.4 - 2018.12.22 - Shortened most of the script outputs in order to make them more friendly to the new MiSTer Script menu OSD; simplified missing directories creation (thanks frederic-mahe).
# Version 1.3.3 - 2018.12.16 - Updating the bootloader before deleting linux.img, moved the Linux system update at the end of the script with an "atomic" approach (first extracting in a linux.update directory and then moving files).
# Version 1.3.2 - 2018.12.16 - Deleting linux.img before updating the linux directory so that the extracted new file won't be overwritten.
# Version 1.3.1 - 2018.12.16 - Disabled Linux updating as default behaviour.
# Version 1.3 - 2018.12.16 - Added Kernel, Linux filesystem and bootloader updating functionality; added autoreboot option.
# Version 1.2 - 2018.12.14 - Added support for distinct directories for computer cores, console cores, arcade cores and service cores; added an option for removing "Arcade-" prefix from arcade core names
# Version 1.1 - 2018.12.11 - Added support for additional repositories (i.e. Scaler filters and Game Boy palettes), renamed some variables
# Version 1.0 - 2018.12.11 - First commit



#Change these self-explanatory variables in order to adjust destination paths, etc.
MISTER_URL="https://github.com/MiSTer-devel/Main_MiSTer"
#EXPERIMENTAL: Uncomment/Comment next line if you want or don't want the Kernel, the Linux filesystem and the bootloader to be updated; do it at your own risk!
#SD_INSTALLER_URL="https://github.com/MiSTer-devel/SD-Installer-Win64_MiSTer"
UNRAR_DEBS_URL="http://http.us.debian.org/debian/pool/non-free/u/unrar-nonfree"
TEMP_PATH="/tmp"
BASE_PATH="/media/fat"
declare -A CORE_CATEGORY_PATHS=(
						["cores"]="$BASE_PATH/_Computer"
						["console-cores"]="$BASE_PATH/_Console"
						["arcade-cores"]="$BASE_PATH/_Arcade"
						["service-cores"]="$BASE_PATH/_Utility"
					 )	
DELETE_OLD_FILES=true
REMOVE_ARCADE_PREFIX=true
SD_INSTALLER_PATH=""
AUTOREBOOT=true
REBOOT_PAUSE=0
#Comment next line if you don't want to download from additional repositories (i.e. Scaler filters and Gameboy palettes) each time
ADDITIONAL_REPOSITORIES=( "https://github.com/MiSTer-devel/Filters_MiSTer/tree/master/Filters txt $BASE_PATH/Filters" "https://github.com/MiSTer-devel/Gameboy_MiSTer/tree/master/palettes gbp $BASE_PATH/GameBoy" )



mkdir -p "${CORE_CATEGORY_PATHS[@]}"

CORE_URLS=$SD_INSTALLER_URL$'\n'$MISTER_URL$'\n'$(curl -ksLf "$MISTER_URL/wiki"| awk '/user-content-cores/,/user-content-development/' | grep -io '\(https://github.com/[a-zA-Z0-9./_-]*_MiSTer\)\|\(user-content-[a-z-]*\)')
CORE_CATEGORY="-"
REBOOT_NEEDED=false

for CORE_URL in $CORE_URLS; do
	if [[ $CORE_URL == https://* ]]
	then
		echo "Checking $(echo $CORE_URL | sed 's/.*\///g' | sed 's/_MiSTer//gI')"
		echo "URL: $CORE_URL" >&2
		if echo "$CORE_URL" | grep -q "SD-Installer"
		then
			RELEASES_URL="$CORE_URL"
		else
			RELEASES_URL=https://github.com$(curl -ksLf "$CORE_URL" | grep -o '/MiSTer-devel/[a-zA-Z0-9./_-]*/tree/[a-zA-Z0-9./_-]*/releases' | head -n1)
		fi
		RELEASE_URLS=$(curl -ksLf "$RELEASES_URL" | grep -o '/MiSTer-devel/[a-zA-Z0-9./_-]*_[0-9]\{8\}\w\?\(\.rbf\|\.rar\)\?')
		
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
		if [ "$CORE_CATEGORY" == "arcade-cores" ] && [ $REMOVE_ARCADE_PREFIX == true ]
		then
			FILE_NAME=$(echo "$FILE_NAME" | sed 's/Arcade-//gI')
		fi
		BASE_FILE_NAME=$(echo "$FILE_NAME" | sed 's/_[0-9]\{8\}.*//g')
		
		CURRENT_DIR="${CORE_CATEGORY_PATHS[$CORE_CATEGORY]}"
		if [ "$CURRENT_DIR" == "" ] || [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ]
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
						rm "$CURRENT_FILE" > /dev/null 2>&1
					fi
				fi
			fi
		done
		
		if [[ "$MAX_VERSION" > "$MAX_LOCAL_VERSION" ]]
		then
			echo "Downloading $FILE_NAME"
			echo "URL: https://github.com$MAX_RELEASE_URL?raw=true" >&2
			curl -kL "https://github.com$MAX_RELEASE_URL?raw=true" -o "$CURRENT_DIR/$FILE_NAME"
			if [ $BASE_FILE_NAME == "MiSTer" ] || [ $BASE_FILE_NAME == "menu" ]
			then
				DESTINATION_FILE=$(echo "$MAX_RELEASE_URL" | sed 's/.*\///g' | sed 's/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
				echo "Copying $DESTINATION_FILE"
				rm "$CURRENT_DIR/$DESTINATION_FILE" > /dev/null 2>&1
				cp "$CURRENT_DIR/$FILE_NAME" "$CURRENT_DIR/$DESTINATION_FILE"
				REBOOT_NEEDED=true
			fi
			if echo "$CORE_URL" | grep -q "SD-Installer"
			then
				SD_INSTALLER_PATH="$CURRENT_DIR/$FILE_NAME"
			fi
			sync
		else
			echo "Nothing to update"
		fi
	
		echo ""
	else
		CORE_CATEGORY=$(echo "$CORE_URL" | sed 's/user-content-//g')
		if [ "$CORE_CATEGORY" == "" ]
		then
			CORE_CATEGORY="-"
		fi
	fi
done

for ADDITIONAL_REPOSITORY in "${ADDITIONAL_REPOSITORIES[@]}"; do
	PARAMS=($ADDITIONAL_REPOSITORY)
	CURRENT_DIR="${PARAMS[2]}"
	if [ ! -d "$CURRENT_DIR" ]
	then
		mkdir -p "$CURRENT_DIR"
	fi
	ADDITIONAL_FILES_URL="${PARAMS[0]}"
	echo "Checking $(echo $ADDITIONAL_FILES_URL | sed 's/.*\///g')"
	echo "URL: $ADDITIONAL_FILES_URL" >&2
	echo ""
	ADDITIONAL_FILE_URLS=$(curl -ksLf "$ADDITIONAL_FILES_URL" | grep -o "/MiSTer-devel/[a-zA-Z0-9./_-]*\.${PARAMS[1]}")
	for ADDITIONAL_FILE_URL in $ADDITIONAL_FILE_URLS; do
		ADDITIONAL_FILE_NAME=$(echo "$ADDITIONAL_FILE_URL" | sed 's/.*\///g')
		echo "Downloading $ADDITIONAL_FILE_NAME"
		echo "URL: https://github.com$ADDITIONAL_FILE_URL?raw=true" >&2
		curl -kL "https://github.com$ADDITIONAL_FILE_URL?raw=true" -o "$CURRENT_DIR/$ADDITIONAL_FILE_NAME"
		sync
		echo ""
	done
done

if [ "$SD_INSTALLER_PATH" != "" ]
then
	echo "Linux system must be updated"
	if [ ! -f "$BASE_PATH/unrar-nonfree" ]
	then
		UNRAR_DEB_URLS=$(curl -ksLf "$UNRAR_DEBS_URL" | grep -o '\"unrar[a-zA-Z0-9./_+-]*_armhf\.deb\"' | sed 's/\"//g')
		MAX_VERSION=""
		MAX_RELEASE_URL=""
		for RELEASE_URL in $UNRAR_DEB_URLS; do
			CURRENT_VERSION=$(echo "$RELEASE_URL" | grep -o '_[a-zA-Z0-9.+-]*_' | sed 's/_//g')
			if [[ "$CURRENT_VERSION" > "$MAX_VERSION" ]]
			then
				MAX_VERSION=$CURRENT_VERSION
				MAX_RELEASE_URL=$RELEASE_URL
			fi
		done
		echo "Downloading $UNRAR_DEBS_URL/$MAX_RELEASE_URL"
		curl -kL "$UNRAR_DEBS_URL/$MAX_RELEASE_URL" -o "$TEMP_PATH/$MAX_RELEASE_URL"
		echo "Extracting unrar-nonfree"
		ORIGINAL_DIR=$(pwd)
		cd "$TEMP_PATH"
		rm data.tar.xz > /dev/null 2>&1
		ar -x "$TEMP_PATH/$MAX_RELEASE_URL" data.tar.xz
		cd "$ORIGINAL_DIR"
		rm "$TEMP_PATH/$MAX_RELEASE_URL"
		tar -xJf "$TEMP_PATH/data.tar.xz" --strip-components=3 -C "$BASE_PATH" ./usr/bin/unrar-nonfree
		rm "$TEMP_PATH/data.tar.xz" > /dev/null 2>&1
	fi
	if [ -f "$BASE_PATH/unrar-nonfree" ] && [ -f "$SD_INSTALLER_PATH" ]
	then
		sync
		if $BASE_PATH/unrar-nonfree t "$SD_INSTALLER_PATH"
		then
			if [ -d $BASE_PATH/linux.update ]
			then
				rm -R "$BASE_PATH/linux.update" > /dev/null 2>&1
			fi
			mkdir "$BASE_PATH/linux.update"
			if $BASE_PATH/unrar-nonfree e -y "$SD_INSTALLER_PATH" files/linux/* $BASE_PATH/linux.update
			then
				echo ""
				echo "======================================================================================"
				echo "Hold your breath: updating the Kernel, the Linux filesystem, the bootloader and stuff."
				echo "Stopping this will make your SD unbootable!"
				echo ""
				echo "If something goes wrong, please download the SD Installer from"
				echo "$SD_INSTALLER_URL"
				echo "and copy the content of the files/linux/ directory in the linux directory of the SD."
				echo "Reflash the bootloader with the SD Installer if needed."
				echo "======================================================================================"
				echo ""
				sync
				mv "$BASE_PATH/linux.update/"*boot* "$BASE_PATH/linux/"
				sync
				$BASE_PATH/linux/updateboot
				rm "$BASE_PATH/linux/linux.img" > /dev/null 2>&1
				sync
				mv "$BASE_PATH/linux.update/"* "$BASE_PATH/linux/"
			fi
			rm -R "$BASE_PATH/linux.update" > /dev/null 2>&1
			sync
			REBOOT_NEEDED=true
		else
			echo "Downloaded installer RAR is broken, deleting $SD_INSTALLER_PATH"
			rm "$SD_INSTALLER_PATH" > /dev/null 2>&1
		fi
	fi
fi

echo "Done!"
if [ $REBOOT_NEEDED == true ]
then
	if [ $AUTOREBOOT == true ]
	then
		echo "Rebooting in $REBOOT_PAUSE seconds"
		sleep $REBOOT_PAUSE
		reboot
	else
		echo "You should reboot"
	fi
fi