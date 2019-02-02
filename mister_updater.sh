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

# Copyright 2018-2019 Alessandro "Locutus73" Miele

# You can download the latest version of this script from:
# https://github.com/MiSTer-devel/Updater_script_MiSTer

# Version 2.0 - 2019-02-02 - Added ALLOW_INSECURE_SSH option: "true" will check if SSL certificate verification (see https://curl.haxx.se/docs/sslcerts.html ) is working (CA certificates installed) and when it's working it will use this feature for safe curl HTTPS downloads, otherwise it will use --insecure option for disabling SSL certificate verification. If CA certificates aren't installed it's advised to install them (i.e. using security_fixes.sh). "false" will never use --insecure option and if CA certificates aren't installed any download will fail.
# Version 1.8.2 - 2019-01-21 - Changed ARCADE_HACKS_PATH to ARCADE_ALT_PATHS: not it supports a pipe "|" separated list of directories containing alternative arcade cores.
# Version 1.8.1 - 2019-01-16 - Changed ADDITIONAL_REPOSITORIES in order to download inc files from scripts repositories; improved ADDITIONAL_REPOSITORIES extensions handling.
# Version 1.8 - 2019-01-15 - Using /media/fat/#Scripts/.mister_updater as work directory, you can safely delete MiSTer_yyyymmdd, menu_yyyymmdd.rbf and release_yyyymmdd.rar from SD root now; using empty files as semaphores and corrected a minor bug about their target directories; improved user option comments.
# Version 1.7.2 - 2019-01-09 - Cosmetic changes.
# Version 1.7.1 - 2019-01-07 - unrar-nonfree is always downloaded in /media/fat/linux.
# Version 1.7 - 2019-01-07 - Added support for an ini configuration file with the same name as the original script, i.e. mister_updater.ini or update.ini; added CIFS_MiSTer and Scripts_MiSTer additional repositories; improved additional repositories handling; added optional advanced NTP_SERVER option for syncing system date and time with a NTP server.
# Version 1.6.2 - 2019-01-02 - Solved a bug that prevented updating MiSTer main executable, menu.rbf and Linux system when DOWNLOAD_NEW_CORES="false" and timestamped files were missing; improved REPOSITORIES_FILTER comments; code clean up by frederic-mahe (thank you very much).
# Version 1.6.1 - 2018-12-30 - Improved date-time parsing for additional repositories; main MiSTer executable, menu.rbf and Linux system are always updated in /media/fat even if BASE_PATH is configured for another directory.
# Version 1.6 - 2018-12-29 - Added REPOSITORIES_FILTER option (i.e. "C64 Minimig NES SNES"); additional repositories files (Filters and GameBoy palettes) online dates and times are checked against local files before downloading; added Internet connection test at the beginning of the script; improved ARCADE_HACKS_PATH file purging; solved a bug with DOWNLOAD_NEW_CORES and paths with spaces; added comments to user options.
# Version 1.5 - 2018-12-27 - Reorganized user options; improved DOWNLOAD_NEW_CORES option handling for paths with spaces; added ARCADE_HACKS_PATH parameter for defining a directory containing arcade hacks to be updated, each arcade hack is a subdirectory with the name starting like the rbf core with an underscore prefix (i.e. /media/fat/_Arcade/_Arcade Hacks/_BurgerTime - hack/).
# Version 1.4 - 2018-12-26 - Added DOWNLOAD_NEW_CORES option: true for downloading new cores in the standard directories as previous script releases, false for not downloading new cores at all, a string value, i.e. "NewCores", for downloading new cores in the "NewCores" subdirectory.
# Version 1.3.6 - 2018-12-24 - Improved local file name parsing so that the script deletes and updates NES_20181113.rbf, but not NES_20181113_NN.rbf.
# Version 1.3.5 - 2018-12-22 - Solved Atari 800XL/5200 and SharpMZ issues; replaced "reboot" with "reboot now"; shortened some of the script outputs.
# Version 1.3.4 - 2018-12-22 - Shortened most of the script outputs in order to make them more friendly to the new MiSTer Script menu OSD; simplified missing directories creation (thanks frederic-mahe).
# Version 1.3.3 - 2018-12-16 - Updating the bootloader before deleting linux.img, moved the Linux system update at the end of the script with an "atomic" approach (first extracting in a linux.update directory and then moving files).
# Version 1.3.2 - 2018-12-16 - Deleting linux.img before updating the linux directory so that the extracted new file won't be overwritten.
# Version 1.3.1 - 2018-12-16 - Disabled Linux updating as default behaviour.
# Version 1.3 - 2018-12-16 - Added Kernel, Linux filesystem and bootloader updating functionality; added autoreboot option.
# Version 1.2 - 2018-12-14 - Added support for distinct directories for computer cores, console cores, arcade cores and service cores; added an option for removing "Arcade-" prefix from arcade core names.
# Version 1.1 - 2018-12-11 - Added support for additional repositories (i.e. Scaler filters and Game Boy palettes), renamed some variables.
# Version 1.0 - 2018-12-11 - First commit.



#=========   USER OPTIONS   =========
#Base directory for all script’s tasks, "/media/fat" for SD root, "/media/usb0" for USB drive root.
BASE_PATH="/media/fat"

#Directories where all core categories will be downloaded.
declare -A CORE_CATEGORY_PATHS
CORE_CATEGORY_PATHS["cores"]="$BASE_PATH/_Computer"
CORE_CATEGORY_PATHS["console-cores"]="$BASE_PATH/_Console"
CORE_CATEGORY_PATHS["arcade-cores"]="$BASE_PATH/_Arcade"
CORE_CATEGORY_PATHS["service-cores"]="$BASE_PATH/_Utility"

#Optional pipe "|" separated list of directories containing alternative arcade cores to be updated,
#each alternative (hack/revision/whatever) arcade is a subdirectory with the name starting like the rbf core with an underscore prefix,
#i.e. "/media/fat/_Arcade/_Arcade Hacks/_BurgerTime - hack/".
ARCADE_ALT_PATHS="${CORE_CATEGORY_PATHS["arcade-cores"]}/_Arcade Hacks|${CORE_CATEGORY_PATHS["arcade-cores"]}/_Arcade Revisions"

#Specifies if old files (cores, main MiSTer executable, menu, SD-Installer, etc.) will be deleted as part of an update.
DELETE_OLD_FILES="true"

#Specifies what to do with new cores not installed locally:
#true for downloading new cores in the standard directories (see CORE_CATEGORY_PATHS),
#false for not downloading new cores at all,
#a string value, i.e. "NewCores", for downloading new cores in the "NewCores" subdirectory.
DOWNLOAD_NEW_CORES="true"

#Specifies if the “Arcade-“ prefix will be removed in local arcade cores.
REMOVE_ARCADE_PREFIX="true"

#A space separated list of filters for the online repositories;
#each filter can be part of the repository name or a whole core category,
#i.e. “C64 Minimig NES SNES arcade-cores” if you want the script to check only
#for C64, Minimig, NES, SNES, and all arcade cores repositories making the whole
#update process quicker;
#if you use this option probably you want DOWNLOAD_NEW_CORES="true" so that you
#can use this filter in order to setup a brand new empty SD with only the cores
#you need, otherwise cores in the filter, but not on the SD won't be downloaded.
REPOSITORIES_FILTER=""



#========= ADVANCED OPTIONS =========
#ALLOW_INSECURE_SSH="true" will check if SSL certificate verification (see https://curl.haxx.se/docs/sslcerts.html )
#is working (CA certificates installed) and when it's working it will use this feature for safe curl HTTPS downloads,
#otherwise it will use --insecure option for disabling SSL certificate verification.
#If CA certificates aren't installed it's advised to install them (i.e. using security_fixes.sh).
#ALLOW_INSECURE_SSH="false" will never use --insecure option and if CA certificates aren't installed
#any download will fail.
ALLOW_INSECURE_SSH="true"
MISTER_URL="https://github.com/MiSTer-devel/Main_MiSTer"
SCRIPTS_PATH="#Scripts"
WORK_PATH="/media/fat/$SCRIPTS_PATH/.mister_updater"
#Comment next line if you don't want to download from additional repositories (i.e. Scaler filters and Gameboy palettes) each time
ADDITIONAL_REPOSITORIES=( "https://github.com/MiSTer-devel/Filters_MiSTer/tree/master/Filters|txt|$BASE_PATH/Filters" "https://github.com/MiSTer-devel/Gameboy_MiSTer/tree/master/palettes|gbp|$BASE_PATH/GameBoy" "https://github.com/MiSTer-devel/CIFS_MiSTer|sh inc|$BASE_PATH/$SCRIPTS_PATH" "https://github.com/MiSTer-devel/Scripts_MiSTer|sh inc|$BASE_PATH/$SCRIPTS_PATH" )
UNRAR_DEBS_URL="http://http.us.debian.org/debian/pool/non-free/u/unrar-nonfree"
#EXPERIMENTAL: Uncomment/Comment next line if you want or don't want the Kernel, the Linux filesystem and the bootloader to be updated; do it at your own risk!
#SD_INSTALLER_URL="https://github.com/MiSTer-devel/SD-Installer-Win64_MiSTer"
#Uncomment this if you want the script to sync the system date and time with a NTP server
#NTP_SERVER="0.pool.ntp.org"
AUTOREBOOT="true"
REBOOT_PAUSE=0
TEMP_PATH="/tmp"



#========= CODE STARTS HERE =========

ORIGINAL_SCRIPT_PATH="$0"
if [ "$ORIGINAL_SCRIPT_PATH" == "bash" ]
then
	ORIGINAL_SCRIPT_PATH=$(ps | grep "^ *$PPID " | grep -o "[^ ]*$")
fi
INI_PATH=${ORIGINAL_SCRIPT_PATH%.*}.ini
if [ -f $INI_PATH ]
then
	eval "$(cat $INI_PATH | tr -d '\r')"
fi

SSL_SECURITY_OPTION=""
curl -q https://google.com &>/dev/null
case $? in
	0)
		;;
	60)
		if [ "$ALLOW_INSECURE_SSH" == "true" ]
		then
			SSL_SECURITY_OPTION="--insecure"
		else
			echo "CA certificates need"
			echo "to be fixed for"
			echo "using SSL certificate"
			echo "verification."
			echo "Please fix them i.e."
			echo "using security_fixes.sh"
			exit 2
		fi
		;;
	*)
		echo "No Internet connection"
		exit 1
		;;
esac
if [ "$SSL_SECURITY_OPTION" = "" ]
then
	if [ "$(cat "$ORIGINAL_SCRIPT_PATH" | grep "^[^#].*")" == "curl -ksLf https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/mister_updater.sh?raw=true | bash -" ]
	then
		echo "Downloading $(echo $ORIGINAL_SCRIPT_PATH | sed 's/.*\///g')"
		curl $SSL_SECURITY_OPTION -L "https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/update.sh?raw=true" -o "$ORIGINAL_SCRIPT_PATH"
	fi
fi

if [ "$NTP_SERVER" != "" ]
then
	echo "Syncing date and time with"
	echo "$NTP_SERVER"$'\n'
	ntpdate -s -b -u $NTP_SERVER
fi

mkdir -p "${CORE_CATEGORY_PATHS[@]}"

declare -A NEW_CORE_CATEGORY_PATHS
if [ "$DOWNLOAD_NEW_CORES" != "true" ] && [ "$DOWNLOAD_NEW_CORES" != "false" ] && [ "$DOWNLOAD_NEW_CORES" != "" ]
then
	for idx in "${!CORE_CATEGORY_PATHS[@]}"; do
		NEW_CORE_CATEGORY_PATHS[$idx]=$(echo ${CORE_CATEGORY_PATHS[$idx]} | sed "s/$(echo $BASE_PATH | sed 's/\//\\\//g')/$(echo $BASE_PATH | sed 's/\//\\\//g')\/$DOWNLOAD_NEW_CORES/g")
	done
	mkdir -p "${NEW_CORE_CATEGORY_PATHS[@]}"
fi

CORE_URLS=$SD_INSTALLER_URL$'\n'$MISTER_URL$'\n'$(curl $SSL_SECURITY_OPTION -sLf "$MISTER_URL/wiki"| awk '/user-content-cores/,/user-content-development/' | grep -io '\(https://github.com/[a-zA-Z0-9./_-]*_MiSTer\)\|\(user-content-[a-z-]*\)')
CORE_CATEGORY="-"
SD_INSTALLER_PATH=""
REBOOT_NEEDED="false"
CORE_CATEGORIES_FILTER=""
if [ "$REPOSITORIES_FILTER" != "" ]
then
	CORE_CATEGORIES_FILTER="^\($( echo "$REPOSITORIES_FILTER" | sed 's/[ 	]\{1,\}/\\)\\|\\(/g' )\)$"
	REPOSITORIES_FILTER="\(Main_MiSTer\)\|\(Menu_MiSTer\)\|\(SD-Installer-Win64_MiSTer\)\|\($( echo "$REPOSITORIES_FILTER" | sed 's/[ 	]\{1,\}/\\)\\|\\([\/_-]/g' )\)"
fi

for CORE_URL in $CORE_URLS; do
	if [[ $CORE_URL == https://* ]]
	then
		if [ "$REPOSITORIES_FILTER" == "" ] || { echo "$CORE_URL" | grep -qi "$REPOSITORIES_FILTER";  } || { echo "$CORE_CATEGORY" | grep -qi "$CORE_CATEGORIES_FILTER";  }
		then
			echo "Checking $(echo $CORE_URL | sed 's/.*\///g' | sed 's/_MiSTer//gI')"
			echo "URL: $CORE_URL" >&2
			if echo "$CORE_URL" | grep -q "SD-Installer"
			then
				RELEASES_URL="$CORE_URL"
			else
				RELEASES_URL=https://github.com$(curl $SSL_SECURITY_OPTION -sLf "$CORE_URL" | grep -o '/MiSTer-devel/[a-zA-Z0-9./_-]*/tree/[a-zA-Z0-9./_-]*/releases' | head -n1)
			fi
			RELEASE_URLS=$(curl $SSL_SECURITY_OPTION -sLf "$RELEASES_URL" | grep -o '/MiSTer-devel/[a-zA-Z0-9./_-]*_[0-9]\{8\}[a-zA-Z]\?\(\.rbf\|\.rar\)\?')
			
			MAX_VERSION=""
			MAX_RELEASE_URL=""
			for RELEASE_URL in $RELEASE_URLS; do
				if echo "$RELEASE_URL" | grep -q "SharpMZ"
				then
					RELEASE_URL=$(echo "$RELEASE_URL"  | grep '\.rbf$')
				fi			
				if echo "$RELEASE_URL" | grep -q "Atari800"
				then
					if [ "$CORE_CATEGORY" == "cores" ]
					then
						RELEASE_URL=$(echo "$RELEASE_URL"  | grep '800_[0-9]\{8\}[a-zA-Z]\?\.rbf$')
					else
						RELEASE_URL=$(echo "$RELEASE_URL"  | grep '5200_[0-9]\{8\}[a-zA-Z]\?\.rbf$')
					fi
				fi			
				CURRENT_VERSION=$(echo "$RELEASE_URL" | grep -o '[0-9]\{8\}[a-zA-Z]\?')
				if [[ "$CURRENT_VERSION" > "$MAX_VERSION" ]]
				then
					MAX_VERSION=$CURRENT_VERSION
					MAX_RELEASE_URL=$RELEASE_URL
				fi
			done
			
			FILE_NAME=$(echo "$MAX_RELEASE_URL" | sed 's/.*\///g')
			if [ "$CORE_CATEGORY" == "arcade-cores" ] && [ $REMOVE_ARCADE_PREFIX == "true" ]
			then
				FILE_NAME=$(echo "$FILE_NAME" | sed 's/Arcade-//gI')
			fi
			BASE_FILE_NAME=$(echo "$FILE_NAME" | sed 's/_[0-9]\{8\}.*//g')
			
			CURRENT_DIRS="${CORE_CATEGORY_PATHS[$CORE_CATEGORY]}"
			if [ "${NEW_CORE_CATEGORY_PATHS[$CORE_CATEGORY]}" != "" ]
			then
				CURRENT_DIRS=("$CURRENT_DIRS" "${NEW_CORE_CATEGORY_PATHS[$CORE_CATEGORY]}")
			fi 
			if [ "$CURRENT_DIRS" == "" ]
			then
				CURRENT_DIRS=("$BASE_PATH")
			fi
			if [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || { echo "$CORE_URL" | grep -q "SD-Installer"; }
			then
				mkdir -p "$WORK_PATH"
				CURRENT_DIRS=("$WORK_PATH")
			fi
			
			CURRENT_LOCAL_VERSION=""
			MAX_LOCAL_VERSION=""
			for CURRENT_DIR in "${CURRENT_DIRS[@]}"
			do
				for CURRENT_FILE in "$CURRENT_DIR/$BASE_FILE_NAME"*
				do
					if [ -f "$CURRENT_FILE" ]
					then
						if echo "$CURRENT_FILE" | grep -q "$BASE_FILE_NAME\_[0-9]\{8\}[a-zA-Z]\?\(\.rbf\|\.rar\)\?$"
						then
							CURRENT_LOCAL_VERSION=$(echo "$CURRENT_FILE" | grep -o '[0-9]\{8\}[a-zA-Z]\?')
							if [[ "$CURRENT_LOCAL_VERSION" > "$MAX_LOCAL_VERSION" ]]
							then
								MAX_LOCAL_VERSION=$CURRENT_LOCAL_VERSION
							fi
							if [[ "$MAX_VERSION" > "$CURRENT_LOCAL_VERSION" ]] && [ $DELETE_OLD_FILES == "true" ]
							then
								echo "Deleting $(echo $CURRENT_FILE | sed 's/.*\///g')"
								rm "$CURRENT_FILE" > /dev/null 2>&1
							fi
						fi
					fi
				done
				if [ "$MAX_LOCAL_VERSION" != "" ]
				then
					break
				fi
			done
			
			if [[ "$MAX_VERSION" > "$MAX_LOCAL_VERSION" ]]
			then
				if [ "$DOWNLOAD_NEW_CORES" != "false" ] || [ "$MAX_LOCAL_VERSION" != "" ] || [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || { echo "$CORE_URL" | grep -q "SD-Installer"; }
				then
					echo "Downloading $FILE_NAME"
					echo "URL: https://github.com$MAX_RELEASE_URL?raw=true" >&2
					curl $SSL_SECURITY_OPTION -L "https://github.com$MAX_RELEASE_URL?raw=true" -o "$CURRENT_DIR/$FILE_NAME"
					if [ $BASE_FILE_NAME == "MiSTer" ] || [ $BASE_FILE_NAME == "menu" ]
					then
						DESTINATION_FILE=$(echo "$MAX_RELEASE_URL" | sed 's/.*\///g' | sed 's/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
						echo "Moving $DESTINATION_FILE"
						rm "/media/fat/$DESTINATION_FILE" > /dev/null 2>&1
						mv "$CURRENT_DIR/$FILE_NAME" "/media/fat/$DESTINATION_FILE"
						touch "$CURRENT_DIR/$FILE_NAME"
						REBOOT_NEEDED="true"
					fi
					if echo "$CORE_URL" | grep -q "SD-Installer"
					then
						SD_INSTALLER_PATH="$CURRENT_DIR/$FILE_NAME"
					fi
					if [ "$CORE_CATEGORY" == "arcade-cores" ]
					then
						OLD_IFS="$IFS"
						IFS="|"
						for ARCADE_ALT_PATH in $ARCADE_ALT_PATHS
						do
							for ARCADE_ALT_DIR in "$ARCADE_ALT_PATH/_$BASE_FILE_NAME"*
							do
								if [ -d "$ARCADE_ALT_DIR" ]
								then
									echo "Updating $(echo $ARCADE_ALT_DIR | sed 's/.*\///g')"
									if [ $DELETE_OLD_FILES == "true" ]
									then
										for ARCADE_HACK_CORE in "$ARCADE_ALT_DIR/"*.rbf
										do
											if [ -f "$ARCADE_HACK_CORE" ] && { echo "$ARCADE_HACK_CORE" | grep -q "$BASE_FILE_NAME\_[0-9]\{8\}[a-zA-Z]\?\.rbf$"; }
											then
												rm "$ARCADE_HACK_CORE"  > /dev/null 2>&1
											fi
										done
									fi
									cp "$CURRENT_DIR/$FILE_NAME" "$ARCADE_ALT_DIR/"
								fi
							done
						done
						IFS="$OLD_IFS"
					fi
					sync
				else
					echo "New core: $FILE_NAME"
				fi
			else
				echo "Nothing to update"
			fi
			
			echo ""
		fi
	else
		CORE_CATEGORY=$(echo "$CORE_URL" | sed 's/user-content-//g')
		if [ "$CORE_CATEGORY" == "" ]
		then
			CORE_CATEGORY="-"
		fi
	fi
done

for ADDITIONAL_REPOSITORY in "${ADDITIONAL_REPOSITORIES[@]}"; do
	OLD_IFS="$IFS"
	IFS="|"
	PARAMS=($ADDITIONAL_REPOSITORY)
	ADDITIONAL_FILES_URL="${PARAMS[0]}"
	ADDITIONAL_FILES_EXTENSIONS="\($(echo ${PARAMS[1]} | sed 's/ \{1,\}/\\|/g')\)"
	CURRENT_DIR="${PARAMS[2]}"
	IFS="$OLD_IFS"
	if [ ! -d "$CURRENT_DIR" ]
	then
		mkdir -p "$CURRENT_DIR"
	fi
	echo "Checking $(echo $ADDITIONAL_FILES_URL | sed 's/.*\///g' | awk '{ print toupper( substr( $0, 1, 1 ) ) substr( $0, 2 ); }')"
	echo "URL: $ADDITIONAL_FILES_URL" >&2
	echo ""
	CONTENT_TDS=$(curl $SSL_SECURITY_OPTION -sLf "$ADDITIONAL_FILES_URL")
	ADDITIONAL_FILE_DATETIMES=$(echo "$CONTENT_TDS" | grep -o "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}Z" )
	ADDITIONAL_FILE_DATETIMES=( $ADDITIONAL_FILE_DATETIMES )
	CONTENT_TDS=$(echo "$CONTENT_TDS" | awk '/class="content"/,/<\/td>/' | tr -d '\n' | sed 's/ \{1,\}/+/g' | sed 's/<\/td>/\n/g')
	CONTENT_TD_INDEX=0
	for CONTENT_TD in $CONTENT_TDS; do
		ADDITIONAL_FILE_URL=$(echo "$CONTENT_TD" | grep -o "href=\(\"\|\'\)[a-zA-Z0-9%()./_-]*\.$ADDITIONAL_FILES_EXTENSIONS\(\"\|\'\)" | sed "s/href=//g" | sed "s/\(\"\|\'\)//g")
		if [ "$ADDITIONAL_FILE_URL" != "" ]
		then
			ADDITIONAL_FILE_NAME=$(echo "$ADDITIONAL_FILE_URL" | sed 's/.*\///g' | sed 's/%20/ /g')
			ADDITIONAL_ONLINE_FILE_DATETIME=${ADDITIONAL_FILE_DATETIMES[$CONTENT_TD_INDEX]}
			if [ -f "$CURRENT_DIR/$ADDITIONAL_FILE_NAME" ]
			then
				ADDITIONAL_LOCAL_FILE_DATETIME=$(date -d "$(stat -c %y "$CURRENT_DIR/$ADDITIONAL_FILE_NAME" 2>/dev/null)" -u +"%Y-%m-%dT%H:%M:%SZ")
			else
				ADDITIONAL_LOCAL_FILE_DATETIME=""
			fi
			if [ "$ADDITIONAL_LOCAL_FILE_DATETIME" == "" ] || [[ "$ADDITIONAL_ONLINE_FILE_DATETIME" > "$ADDITIONAL_LOCAL_FILE_DATETIME" ]]
			then
				echo "Downloading $ADDITIONAL_FILE_NAME"
				echo "URL: https://github.com$ADDITIONAL_FILE_URL?raw=true" >&2
				curl $SSL_SECURITY_OPTION -L "https://github.com$ADDITIONAL_FILE_URL?raw=true" -o "$CURRENT_DIR/$ADDITIONAL_FILE_NAME"
				sync
				echo ""
			fi
		fi
		CONTENT_TD_INDEX=$((CONTENT_TD_INDEX+1))
	done
done

if [ "$SD_INSTALLER_PATH" != "" ]
then
	echo "Linux system must be updated"
	if [ ! -f "/media/fat/linux/unrar-nonfree" ]
	then
		UNRAR_DEB_URLS=$(curl $SSL_SECURITY_OPTION -sLf "$UNRAR_DEBS_URL" | grep -o '\"unrar[a-zA-Z0-9./_+-]*_armhf\.deb\"' | sed 's/\"//g')
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
		curl $SSL_SECURITY_OPTION -L "$UNRAR_DEBS_URL/$MAX_RELEASE_URL" -o "$TEMP_PATH/$MAX_RELEASE_URL"
		echo "Extracting unrar-nonfree"
		ORIGINAL_DIR=$(pwd)
		cd "$TEMP_PATH"
		rm data.tar.xz > /dev/null 2>&1
		ar -x "$TEMP_PATH/$MAX_RELEASE_URL" data.tar.xz
		cd "$ORIGINAL_DIR"
		rm "$TEMP_PATH/$MAX_RELEASE_URL"
		tar -xJf "$TEMP_PATH/data.tar.xz" --strip-components=3 -C "/media/fat/linux" ./usr/bin/unrar-nonfree
		rm "$TEMP_PATH/data.tar.xz" > /dev/null 2>&1
	fi
	if [ -f "/media/fat/linux/unrar-nonfree" ] && [ -f "$SD_INSTALLER_PATH" ]
	then
		sync
		if /media/fat/linux/unrar-nonfree t "$SD_INSTALLER_PATH"
		then
			if [ -d /media/fat/linux.update ]
			then
				rm -R "/media/fat/linux.update" > /dev/null 2>&1
			fi
			mkdir "/media/fat/linux.update"
			if /media/fat/linux/unrar-nonfree e -y "$SD_INSTALLER_PATH" files/linux/* /media/fat/linux.update
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
				rm "$SD_INSTALLER_PATH" > /dev/null 2>&1
				touch "$SD_INSTALLER_PATH"
				sync
				mv "/media/fat/linux.update/"*boot* "/media/fat/linux/"
				sync
				/media/fat/linux/updateboot
				rm "/media/fat/linux/linux.img" > /dev/null 2>&1
				sync
				mv "/media/fat/linux.update/"* "/media/fat/linux/"
			fi
			rm -R "/media/fat/linux.update" > /dev/null 2>&1
			sync
			REBOOT_NEEDED="true"
		else
			echo "Downloaded installer RAR is broken, deleting $SD_INSTALLER_PATH"
			rm "$SD_INSTALLER_PATH" > /dev/null 2>&1
		fi
	fi
fi

echo "Done!"
if [ $REBOOT_NEEDED == "true" ]
then
	if [ $AUTOREBOOT == "true" ]
	then
		echo "Rebooting in $REBOOT_PAUSE seconds"
		sleep $REBOOT_PAUSE
		reboot now
	else
		echo "You should reboot"
	fi
fi

exit 0