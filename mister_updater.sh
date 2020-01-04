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



# Version 3.5.3 - 2019-12-29 - Optimisation in GAMES_SUBDIR detection.
# Version 3.5.2 - 2019-12-22 - Speed optimisations; optimisations for the new Wiky layout; when GAMES_SUBDIR="" now the updater checks if /media/fat/games subdir exists and actually contains any file.
# Version 3.5.1 - 2019-12-21 - Code clean up by frederic-mahe (thank you very much).
# Version 3.5 - 2019-12-04 - Adapt to Wiki sideboard changes for core listings and separate arcade core listing by rarcos, thank you very much.
# Version 3.4.1 - 2019-12-03 - Added a prompt for PARALLEL_UPDATE.
# Version 3.4 - 2019-11-30 - Added support for the new filters and gamma tables repository structure; FILTERS_URL="" for disabling filters updating; if you use a custom ADDITIONAL_REPOSITORIES, please remove any Filters entry.
# Version 3.3.5 - 2019-11-10 - Added GAMES_SUBDIR option, specifies the Games/Programs subdirectory where core specific directories will be placed; GAMES_SUBDIR="" for letting the script choose between /media/fat and /media/fat/games when it exists, otherwise the subdir you prefer (i.e. GAMES_SUBDIR="/Programs").
# Version 3.3.4 - 2019-10-20 - Fixed an incompatibility with gamehacking.org anti DDOS system.
# Version 3.3.3 - 2019-09-28 - Corrected a bug in MD5 based check in addition to file timestamp for main menu and main MiSTer executable.
# Version 3.3.2 - 2019-09-28 - Implemented MD5 based check in addition to file timestamp for main menu and main MiSTer executable; added https://github.com/MiSTer-devel/Scripts_MiSTer/tree/master/other_authors to ADDITIONAL_REPOSITORIES.
# Version 3.3.1 - 2019-09-07 - Improved core directories creation; added NeoGeo xml download/update to ADDITIONAL_REPOSITORIES.
# Version 3.3 - 2019-08-21 - Implemented CREATE_CORES_DIRECTORIES; when "true" (default value), the updater will create the core directory (i.e. /media/fat/Amiga for Minimig core, /media/fat/SNES for SNES core) the first time the core is downloaded.
# Version 3.2 - 2019-08-21 - Implemented GOOD_CORES_URL for having a list of curated "good" cores.
# Version 3.1.1 - 2019-07-26 - The script is compatible with a possible renaming of "Cores" to "Computer Cores" in MiSTer Wiki Sidebar.
# Version 3.1 - 2019-06-16 - Checking cURL download success and restoring old files when needed.
# Version 3.0.2 - 2019-06-10 - Testing Internet connectivity with github.com instead of google.com; improved a regular expression for Debian repository parsing.
# Version 3.0.1 - 2019-05-25 - Changed UPDATE_LINUX default value from "false" to "true".
# Version 3.0 - 2019-05-18 - Added EXPERIMENTAL parallel processing for the update process when PARALLEL_UPDATE="true" (default value is "false"): use it at your own risk!
# Version 2.3 - 2019-05-13 - Added cheats download/update from gamehacking.org when UPDATE_CHEATS="true" ("once" for just downloading them once); added UPDATE_LINUX option instead of uncommenting SD_INSTALLER_PATH (this method still works for ini compatibility).
# Version 2.2.1 - 2019-05-06 - Removed https://github.com/MiSTer-devel/CIFS_MiSTer from ADDITIONAL_REPOSITORIES, now CIFS scripts are hosted in https://github.com/MiSTer-devel/Scripts_MiSTer.
# Version 2.2 - 2019-05-01 - CURL RETRY OPTIONS by wesclemens, now the script has a timeout and retry logic to prevent spotty connections causing the update to lockup, thank you very much; review time sync test by frederic-mahe, thank you very much; now the scripts default path is /media/fat/Scripts, moving #Scripts directory there when needed.
# Version 2.1.5 - 2019-04-03 - Improved date-time parsing for additional repositories.
# Version 2.1.4 - 2019-04-01 - Implemented a safer Linux system updating strategy: linux.img is moved as the very last step in the process.
# Version 2.1.3 - 2019-03-26 - Cosmetic change in ADDITIONAL_REPOSITORIES declaration; added commented (not active) fonts additional repository for reference.
# Version 2.1.2 - 2019-03-03 - Corrected a bug in date-time parsing for additional repositories.
# Version 2.1.1 - 2019-03-03 - Improved date-time parsing for additional repositories; added MiSTer_MidiLink installation scripts to ADDITIONAL_REPOSITORIES.
# Version 2.1 - 2019-03-02 - Linux updating now supports subdirectories under /media/fat/linux.
# Version 2.0.2 - 2019-02-23 - ALLOW_INSECURE_SSH renamed to ALLOW_INSECURE_SSL.
# Version 2.0.1 - 2019-02-03 - Cosmetic changes.
# Version 2.0 - 2019-02-02 - Added ALLOW_INSECURE_SSH option: "true" will check if SSL certificate verification (see https://curl.haxx.se/docs/sslcerts.html ) is working (CA certificates installed) and when it's working it will use this feature for safe curl HTTPS downloads, otherwise it will use --insecure option for disabling SSL certificate verification. If CA certificates aren't installed it's advised to install them (i.e. using security_fixes.sh). "false" will never use --insecure option and if CA certificates aren't installed any download will fail. The script will download and update the simple one line update.sh with a newer one (same ALLOW_INSECURE_SSH option) when needed.
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
#Directory for MiSTer binaries, should always be "/media/fat" when run on MiSTer.
MISTER_PATH="/media/fat"
#Subdirectories where all core categories will be downloaded.
declare -A CORE_CATEGORY_DIRS
CORE_CATEGORY_DIRS["cores"]="/_Computer"
CORE_CATEGORY_DIRS["console-cores"]="/_Console"
CORE_CATEGORY_DIRS["arcade-cores"]="/_Arcade"
CORE_CATEGORY_DIRS["service-cores"]="/_Utility"

#Optional pipe "|" separated list of directories containing alternative arcade cores to be updated,
#each alternative (hack/revision/whatever) arcade is a subdirectory with the name starting like the rbf core with an underscore prefix,
#i.e. "/media/fat/_Arcade/_Arcade Hacks/_BurgerTime - hack/".
ARCADE_ALT_PATHS="${CORE_CATEGORY_DIRS["arcade-cores"]}/_Arcade Hacks|${CORE_CATEGORY_DIRS["arcade-cores"]}/_Arcade Revisions"

#Specifies if old files (cores, main MiSTer executable, menu, SD-Installer, etc.) will be deleted as part of an update.
DELETE_OLD_FILES="true"

#Specifies what to do with new cores not installed locally:
#true for downloading new cores in the standard directories (see CORE_CATEGORY_DIRS),
#false for not downloading new cores at all,
#a string value, i.e. "NewCores", for downloading new cores in the "NewCores" subdirectory.
DOWNLOAD_NEW_CORES="true"

#Specifies if the "Arcade-" prefix will be removed in local arcade cores.
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

#Specifies if the cheats will be downloaded/updated from https://gamehacking.org/
#"true" for checking for updates each time, "false" for disabling the function,
#"once" for downloading cheats just once if not on the SD card (no further updating).
UPDATE_CHEATS="once"

#EXPERIMENTAL: specifies if the Kernel, the Linux filesystem and the bootloader will be updated; use it at your own risk!
UPDATE_LINUX="true"

#EXPERIMENTAL: specifies if the update process must be done with parallel processing; use it at your own risk!
PARALLEL_UPDATE="false"

#Specifies an optional URL with a text file containing a curated list of "good" cores.
#If a core is specified there, it will be preferred over the latest "bleeding edge" core in its repository.
#The text file can be something simple as "Genesis_20190712.rbf SNES_20190703.rbf".
GOOD_CORES_URL=""

#Specifies if the core directory (i.e. /media/fat/Amiga for Minimig core, /media/fat/SNES for SNES core) has to be created
#the first time the core is downloaded.
CREATE_CORES_DIRECTORIES="true"

#Specifies the Games/Programs subdirectory where core specific directories will be placed.
#GAMES_SUBDIR="" for letting the script choose between /media/fat and /media/fat/games when it exists,
#otherwise the subdir you prefer (i.e. GAMES_SUBDIR="/Programs").
GAMES_SUBDIR=""
if [ "${GAMES_SUBDIR}" == "" ] && [ "$(find ${BASE_PATH}/games -type f -print -quit 2> /dev/null)" != "" ]
then
	GAMES_SUBDIR="/games"
fi

#========= ADVANCED OPTIONS =========
#ALLOW_INSECURE_SSL="true" will check if SSL certificate verification (see https://curl.haxx.se/docs/sslcerts.html )
#is working (CA certificates installed) and when it's working it will use this feature for safe curl HTTPS downloads,
#otherwise it will use --insecure option for disabling SSL certificate verification.
#If CA certificates aren't installed it's advised to install them (i.e. using security_fixes.sh).
#ALLOW_INSECURE_SSL="false" will never use --insecure option and if CA certificates aren't installed
#any download will fail.
ALLOW_INSECURE_SSL="true"
CURL_RETRY="--connect-timeout 15 --max-time 120 --retry 3 --retry-delay 5"
MISTER_URL="https://github.com/MiSTer-devel/Main_MiSTer"
SCRIPTS_PATH="Scripts"
OLD_SCRIPTS_PATH="#Scripts"
WORK_DIR="/Scripts/.mister_updater"
#Comment (or uncomment) next lines if you don't want (or want) to update/download from additional repositories (i.e. Scaler filters and Gameboy palettes) each time
ADDITIONAL_REPOSITORIES=(
#	"https://github.com/MiSTer-devel/Filters_MiSTer/tree/master/Filters|txt|$BASE_PATH/Filters"
	"https://github.com/MiSTer-devel/Gameboy_MiSTer/tree/master/palettes|gbp|${BASE_PATH}${GAMES_SUBDIR}/GameBoy"
	"https://github.com/MiSTer-devel/Scripts_MiSTer|sh inc|$BASE_PATH/$SCRIPTS_PATH"
	"https://github.com/bbond007/MiSTer_MidiLink/tree/master/INSTALL|sh inc|$BASE_PATH/$SCRIPTS_PATH"
#	"https://github.com/MiSTer-devel/Fonts_MiSTer|pf|$BASE_PATH/font"
	"https://github.com/MiSTer-devel/NeoGeo_MiSTer/tree/master/releases|xml|${BASE_PATH}${GAMES_SUBDIR}/NeoGeo"
	"https://github.com/MiSTer-devel/Scripts_MiSTer/tree/master/other_authors|sh inc|$BASE_PATH/$SCRIPTS_PATH"
)
FILTERS_URL="https://github.com/MiSTer-devel/Filters_MiSTer"
CHEATS_URL="https://gamehacking.org/mister/"
CHEAT_MAPPINGS="fds:NES gb:GameBoy gbc:GameBoy gen:Genesis gg:SMS nes:NES pce:TGFX16 sms:SMS snes:SNES"
UNRAR_DEBS_URL="http://http.us.debian.org/debian/pool/non-free/u/unrar-nonfree"
#Uncomment this if you want the script to sync the system date and time with a NTP server
#NTP_SERVER="0.pool.ntp.org"
AUTOREBOOT="true"
REBOOT_PAUSE=0  # in seconds
TEMP_PATH="/tmp"
TO_BE_DELETED_EXTENSION="to_be_deleted"

#========= PARSE OPTIONS =========

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

if [ ! -d "$BASE_PATH" ]
then
	echo "BASE_PATH:"
	echo "$BASE_PATH"
	echo "is not a directory"
	exit 4
fi
if [ ! -d "$MISTER_PATH" ]
then
	echo "MISTER_PATH:"
	echo "$MISTER_PATH"
	echo "is not a directory"
	exit 4
fi
if [ "$MISTER_PATH" != "/media/fat" ] && [ "$UPDATE_LINUX" == "true" ]
then
	echo "UPDATE_LINUX is not"
	echo "supported with custom"
	echo "MISTER_PATH"
	exit 4
fi
#Try to interpret old-style absolute paths
if [ "${#CORE_CATEGORY_PATHS[@]}" -gt 0 ]
then
	echo "WARNING: old option"
	echo "CORE_CATEGORY_PATHS"
	echo "detected."
	echo "This overrides new option"
	echo "CORE_CATEGORY_DIRS"
	echo "for backwards"
	echo "compatibility."
	unset $CORE_CATEGORY_DIRS
	for idx in "${!CORE_CATEGORY_PATHS[@]}"
	do
		P=$CORE_CATEGORY_PATHS[idx]
		if [ "${P##${BASE_PATH}}" == "$P" ]
		then
			echo "Error interpreting"
			echo "CORE_CATEGORY_PATHS."
			echo "Please use new option"
			echo "CORE_CATEGORY_DIRS"
			exit 4
		fi
		CORE_CATEGORY_DIRS[idx]=${P##${BASE_PATH}}
	done
fi
if [ ! -z "$WORK_PATH" ]
then
	echo "WARNING: old option"
	echo "WORK_PATH"
	echo "detected."
	echo "This overrides new option"
	echo "WORK_DIR"
	echo "for backwards"
	echo "compatibility."
	if [ "${WORK_PATH##${BASE_PATH}}" == "$WORK_PATH" ]
	then
		echo "Error interpreting"
		echo "WORK_PATH."
		echo "Please use new option"
		echo "WORK_DIR"
		exit 4
	fi
	WORK_DIR=${WORK_PATH##${BASE_PATH}}
fi

if [ -d "${BASE_PATH}/${OLD_SCRIPTS_PATH}" ] && [ ! -d "${BASE_PATH}/${SCRIPTS_PATH}" ]
then
	mv "${BASE_PATH}/${OLD_SCRIPTS_PATH}" "${BASE_PATH}/${SCRIPTS_PATH}"
	echo "Moved"
	echo "${BASE_PATH}/${OLD_SCRIPTS_PATH}"
	echo "to"
	echo "${BASE_PATH}/${SCRIPTS_PATH}"
	echo "please relaunch the script."
	exit 3
fi

if [ "$PARALLEL_UPDATE" != "true" ]
then
			echo "Do you want a"
			echo "faster update?"
			echo "Please try"
			echo "PARALLEL_UPDATE=\"true\""
			echo "in your"
			echo "$(basename $INI_PATH)"
			echo ""
fi

#========= CODE STARTS HERE =========

SSL_SECURITY_OPTION=""
curl $CURL_RETRY -q https://github.com &>/dev/null
case $? in
	0)
		;;
	60)
		if [ "$ALLOW_INSECURE_SSL" == "true" ]
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
if [ "$SSL_SECURITY_OPTION" == "" ]
then
	if [ "$(grep -v "^#" "${ORIGINAL_SCRIPT_PATH}")" == "curl $CURL_RETRY -ksLf https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/mister_updater.sh?raw=true | bash -" ]
	then
		echo "Downloading $(sed 's/.*\///' <<< "${ORIGINAL_SCRIPT_PATH}")"
		echo ""
		curl $CURL_RETRY $SSL_SECURITY_OPTION -L "https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/update.sh?raw=true" -o "$ORIGINAL_SCRIPT_PATH"
	fi
fi

## sync with a public time server
if [[ -n "${NTP_SERVER}" ]] ; then
	echo "Syncing date and time with"
	echo "${NTP_SERVER}"
	# (-b) force time reset, (-s) write output to syslog, (-u) use
	# unprivileged port for outgoing packets to workaround firewalls
	ntpdate -b -s -u "${NTP_SERVER}"
    echo
fi


for P in "${CORE_CATEGORY_DIRS[@]}"; do
  mkdir -p "${BASE_PATH}/${P}"
done

declare -A NEW_CORE_CATEGORY_DIRS
if [ "$DOWNLOAD_NEW_CORES" != "true" ] && [ "$DOWNLOAD_NEW_CORES" != "false" ] && [ "$DOWNLOAD_NEW_CORES" != "" ]
then
	for idx in "${!CORE_CATEGORY_DIRS[@]}"; do
		NEW_CORE_CATEGORY_DIRS[$idx]="/${DOWNLOAD_NEW_CORES}/${CORE_CATEGORY_DIRS[$idx]}"
	done
	for P in "${NEW_CORE_CATEGORY_DIRS[@]}"; do
		mkdir -p "${BASE_PATH}/${P}"
	done
fi

[ "${UPDATE_LINUX}" == "true" ] && SD_INSTALLER_URL="https://github.com/MiSTer-devel/SD-Installer-Win64_MiSTer"

CORE_URLS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sLf "$MISTER_URL/wiki"| awk '/user-content-fpga-cores/,/user-content-development/' | grep -io '\(https://github.com/[a-zA-Z0-9./_-]*_MiSTer\)\|\(user-content-[a-zA-Z0-9-]*\)')
MENU_URL=$(echo "${CORE_URLS}" | grep -io 'https://github.com/[a-zA-Z0-9./_-]*Menu_MiSTer')
CORE_URLS=$(echo "${CORE_URLS}" |  sed 's/https:\/\/github.com\/[a-zA-Z0-9.\/_-]*Menu_MiSTer//')
CORE_URLS=${SD_INSTALLER_URL}$'\n'${MISTER_URL}$'\n'${MENU_URL}$'\n'${CORE_URLS}$'\n'"user-content-arcade-cores"$'\n'$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sLf "$MISTER_URL/wiki/Arcade-Cores-List"| awk '/wiki-content/,/wiki-rightbar/' | grep -io '\(https://github.com/[a-zA-Z0-9./_-]*_MiSTer\)')
CORE_CATEGORY="-"
SD_INSTALLER_PATH=""
REBOOT_NEEDED="false"
CORE_CATEGORIES_FILTER=""
if [ "$REPOSITORIES_FILTER" != "" ]
then
	CORE_CATEGORIES_FILTER="^\($( echo "$REPOSITORIES_FILTER" | sed 's/[ 	]\{1,\}/\\)\\|\\(/g' )\)$"
	REPOSITORIES_FILTER="\(Main_MiSTer\)\|\(Menu_MiSTer\)\|\(SD-Installer-Win64_MiSTer\)\|\($( echo "$REPOSITORIES_FILTER" | sed 's/[ 	]\{1,\}/\\)\\|\\([\/_-]/g' )\)"
fi

GOOD_CORES=""
if [ "$GOOD_CORES_URL" != "" ]
then
	GOOD_CORES=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sLf "$GOOD_CORES_URL")
fi

function checkCoreURL {
	echo "Checking $(sed 's/.*\/// ; s/_MiSTer//' <<< "${CORE_URL}")"
	[ "${SSH_CLIENT}" != "" ] && echo "URL: $CORE_URL"
	# if echo "$CORE_URL" | grep -qE "SD-Installer"
	# then
	# 	RELEASES_URL="$CORE_URL"
	# else
	# 	RELEASES_URL=https://github.com$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sLf "$CORE_URL" | grep -oi '/MiSTer-devel/[a-zA-Z0-9./_-]*/tree/[a-zA-Z0-9./_-]*/releases' | head -n1)
	# fi
	case "$CORE_URL" in
		*SD-Installer*)
			RELEASES_URL="$CORE_URL"
			;;
		*Minimig*)
			RELEASES_URL="${CORE_URL}/file-list/MiSTer/releases"
			;;
		*)
			RELEASES_URL="${CORE_URL}/file-list/master/releases"
			;;
	esac
	RELEASE_URLS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sLf "$RELEASES_URL" | grep -o '/MiSTer-devel/[a-zA-Z0-9./_-]*_[0-9]\{8\}[a-zA-Z]\?\(\.rbf\|\.rar\|\.zip\)\?')
	
	MAX_VERSION=""
	MAX_RELEASE_URL=""
	GOOD_CORE_VERSION=""
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
		
		if [ "$GOOD_CORES" != "" ]
		then
			GOOD_CORE_VERSION=$(echo "$GOOD_CORES" | grep -wo "$(echo "$RELEASE_URL" | sed 's/.*\///g')" | grep -o '[0-9]\{8\}[a-zA-Z]\?')
			if [ "$GOOD_CORE_VERSION" != "" ]
			then
				MAX_VERSION=$CURRENT_VERSION
				MAX_RELEASE_URL=$RELEASE_URL
				break
			fi
		fi
		
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
	
	CURRENT_DIRS="${BASE_PATH}/${CORE_CATEGORY_DIRS[$CORE_CATEGORY]}"
	if [ "${NEW_CORE_CATEGORY_DIRS[$CORE_CATEGORY]}" != "" ]
	then
		CURRENT_DIRS=("$CURRENT_DIRS" "${BASE_PATH}/${NEW_CORE_CATEGORY_DIRS[$CORE_CATEGORY]}")
	fi 
	if [ "$CURRENT_DIRS" == "" ]
	then
		CURRENT_DIRS=("$BASE_PATH")
	fi
	if [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || { echo "$CORE_URL" | grep -qE "SD-Installer|Filters_MiSTer"; }
	then
		mkdir -p "${BASE_PATH}/${WORK_DIR}"
		CURRENT_DIRS=("${BASE_PATH}/${WORK_DIR}")
	fi
	
	CURRENT_LOCAL_VERSION=""
	MAX_LOCAL_VERSION=""
	for CURRENT_DIR in "${CURRENT_DIRS[@]}"
	do
		for CURRENT_FILE in "$CURRENT_DIR/$BASE_FILE_NAME"*
		do
			if [ -f "$CURRENT_FILE" ]
			then
				if echo "$CURRENT_FILE" | grep -q "$BASE_FILE_NAME\_[0-9]\{8\}[a-zA-Z]\?\(\.rbf\|\.rar\|\.zip\)\?$"
				then
					CURRENT_LOCAL_VERSION=$(echo "$CURRENT_FILE" | grep -o '[0-9]\{8\}[a-zA-Z]\?')
					if [ "$GOOD_CORE_VERSION" != "" ]
					then
						if [ "$CURRENT_LOCAL_VERSION" == "$GOOD_CORE_VERSION" ]
						then
							MAX_LOCAL_VERSION=$CURRENT_LOCAL_VERSION
						else
							if [ "$MAX_LOCAL_VERSION" == "" ]
							then
								MAX_LOCAL_VERSION="00000000"
							fi
							if [ $DELETE_OLD_FILES == "true" ]
							then
								mv "${CURRENT_FILE}" "${CURRENT_FILE}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
							fi
						fi
					else
						if [[ "$CURRENT_LOCAL_VERSION" > "$MAX_LOCAL_VERSION" ]]
						then
							MAX_LOCAL_VERSION=$CURRENT_LOCAL_VERSION
						fi
						if [[ "$MAX_VERSION" > "$CURRENT_LOCAL_VERSION" ]] && [ $DELETE_OLD_FILES == "true" ]
						then
							# echo "Moving $(echo ${CURRENT_FILE} | sed 's/.*\///g')"
							mv "${CURRENT_FILE}" "${CURRENT_FILE}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
						fi
					fi
				
				fi
			fi
		done
		if [ "$MAX_LOCAL_VERSION" != "" ]
		then
			break
		fi
	done
	
	if [ "${BASE_FILE_NAME}" == "MiSTer" ] || [ "${BASE_FILE_NAME}" == "menu" ]
	then
		if [[ "${MAX_VERSION}" == "${MAX_LOCAL_VERSION}" ]]
		then
			DESTINATION_FILE=$(echo "${MAX_RELEASE_URL}" | sed 's/.*\///g' | sed 's/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
			ACTUAL_CRC=$(md5sum "${MISTER_PATH}/${DESTINATION_FILE}" | grep -o "^[^ ]*")
			SAVED_CRC=$(cat "${BASE_PATH}/${WORK_DIR}/${FILE_NAME}")
			if [ "$ACTUAL_CRC" != "$SAVED_CRC" ]
			then
				mv "${CURRENT_FILE}" "${CURRENT_FILE}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
				MAX_LOCAL_VERSION=""
			fi
		fi
	fi
	
	if [[ "$MAX_VERSION" > "$MAX_LOCAL_VERSION" ]]
	then
		if [ "$DOWNLOAD_NEW_CORES" != "false" ] || [ "$MAX_LOCAL_VERSION" != "" ] || [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || { echo "$CORE_URL" | grep -qE "SD-Installer|Filters_MiSTer"; }
		then
			echo "Downloading $FILE_NAME"
			[ "${SSH_CLIENT}" != "" ] && echo "URL: https://github.com$MAX_RELEASE_URL?raw=true"
			if curl $CURL_RETRY $SSL_SECURITY_OPTION -L "https://github.com$MAX_RELEASE_URL?raw=true" -o "$CURRENT_DIR/$FILE_NAME"
			then
				if [ ${DELETE_OLD_FILES} == "true" ]
				then
					echo "Deleting old ${BASE_FILE_NAME} files"
					rm "${CURRENT_DIR}/${BASE_FILE_NAME}"*.${TO_BE_DELETED_EXTENSION} > /dev/null 2>&1
				fi
				if [ $BASE_FILE_NAME == "MiSTer" ] || [ $BASE_FILE_NAME == "menu" ]
				then
					DESTINATION_FILE=$(echo "$MAX_RELEASE_URL" | sed 's/.*\///g' | sed 's/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
					echo "Moving $DESTINATION_FILE"
					rm "${MISTER_PATH}/$DESTINATION_FILE" > /dev/null 2>&1
					mv "$CURRENT_DIR/$FILE_NAME" "${MISTER_PATH}/$DESTINATION_FILE"
					echo "$(md5sum "${MISTER_PATH}/${DESTINATION_FILE}" | grep -o "^[^ ]*")" > "${CURRENT_DIR}/${FILE_NAME}"
					REBOOT_NEEDED="true"
				fi
				if echo "$CORE_URL" | grep -q "SD-Installer"
				then
					SD_INSTALLER_PATH="$CURRENT_DIR/$FILE_NAME"
				fi
				if echo "$CORE_URL" | grep -q "Filters_MiSTer"
				then
					echo "Extracting ${FILE_NAME}"
					unzip -o "${BASE_PATH}/${WORK_DIR}/${FILE_NAME}" -d "${BASE_PATH}" 1>&2
					rm "${BASE_PATH}/${WORK_DIR}/${FILE_NAME}" > /dev/null 2>&1
					touch "${BASE_PATH}/${WORK_DIR}/${FILE_NAME}" > /dev/null 2>&1
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
				if [ "$CREATE_CORES_DIRECTORIES" != "false" ] && [ "$MAX_LOCAL_VERSION" == "" ]
				then
					if [ "$BASE_FILE_NAME" != "menu" ] && [ "$CORE_CATEGORY" == "cores" ] || [ "$CORE_CATEGORY" == "computer-cores" ] || [ "$CORE_CATEGORY" == "console-cores" ]
					then
						CORE_SOURCE_URL=""
						CORE_INTERNAL_NAME=""
						case "${BASE_FILE_NAME}" in
							"Minimig")
								CORE_INTERNAL_NAME="Amiga"
								;;
							"Apple-I"|"C64"|"PDP1"|"NeoGeo")
								CORE_INTERNAL_NAME="${BASE_FILE_NAME}"
								;;
							"SharpMZ")
								CORE_INTERNAL_NAME="SHARP MZ SERIES"
								;;
							*)
								CORE_SOURCE_URL="$(echo "https://github.com$MAX_RELEASE_URL" | sed 's/releases.*//g')${BASE_FILE_NAME}.sv"
								CORE_INTERNAL_NAME="$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sLf "${CORE_SOURCE_URL}?raw=true" | awk '/CONF_STR[^=]*=/,/;/' | grep -oE -m1 '".*?;' | sed 's/[";]//g')"
								;;
						esac
						if [ "$CORE_INTERNAL_NAME" != "" ]
						then
							echo "Creating ${BASE_PATH}${GAMES_SUBDIR}/${CORE_INTERNAL_NAME} directory"
							mkdir -p "${BASE_PATH}${GAMES_SUBDIR}/${CORE_INTERNAL_NAME}"
						fi
					fi
				fi
			else
				echo "${FILE_NAME} download failed"
				rm "${CURRENT_DIR}/${FILE_NAME}" > /dev/null 2>&1
				if [ ${DELETE_OLD_FILES} == "true" ]
				then
					echo "Restoring old ${BASE_FILE_NAME} files"
					for FILE_TO_BE_RESTORED in "${CURRENT_DIR}/${BASE_FILE_NAME}"*.${TO_BE_DELETED_EXTENSION}
					do
					  mv "${FILE_TO_BE_RESTORED}" "${FILE_TO_BE_RESTORED%.${TO_BE_DELETED_EXTENSION}}" > /dev/null 2>&1
					done
				fi
			fi
			sync
		else
			echo "New core: $FILE_NAME"
		fi
	else
		echo "Nothing to update"
	fi
	
	echo ""
}

for CORE_URL in $CORE_URLS; do
	if [[ $CORE_URL == https://* ]]
	then
		if [ "$REPOSITORIES_FILTER" == "" ] || { echo "$CORE_URL" | grep -qi "$REPOSITORIES_FILTER";  } || { echo "$CORE_CATEGORY" | grep -qi "$CORE_CATEGORIES_FILTER";  }
		then
			if echo "$CORE_URL" | grep -qE "(SD-Installer)|(/Main_MiSTer$)|(/Menu_MiSTer$)"
			then
				checkCoreURL
			else
				[ "$PARALLEL_UPDATE" == "true" ] && { echo "$(checkCoreURL)"$'\n' & } || checkCoreURL
			fi
		fi
	else
		CORE_CATEGORY=$(echo "$CORE_URL" | sed 's/user-content-//g')
		if [ "$CORE_CATEGORY" == "" ]
		then
			CORE_CATEGORY="-"
		fi
		if [ "$CORE_CATEGORY" == "computer-cores" ] || [[ "$CORE_CATEGORY" =~ [a-z]+-comput[a-z]+ ]]
		then
			CORE_CATEGORY="cores"
		fi
		if [[ "$CORE_CATEGORY" =~ console.* ]]
		then
			CORE_CATEGORY="console-cores"
		fi
	fi
done
wait

if [ "$FILTERS_URL" != "" ]
then
	if [ -d "$BASE_PATH/Filters" ] && dir $BASE_PATH/Filters/* > /dev/null 2>&1 && ! dir $BASE_PATH/Filters/*/ > /dev/null 2>&1 && [ ! -d "$BASE_PATH/Filters_backup" ]
	then
		echo "Backing up Filters"
		mkdir -p "$BASE_PATH/Filters_backup"
		mv $BASE_PATH/Filters/* $BASE_PATH/Filters_backup/
		echo ""
	fi
	CORE_CATEGORY="-"
	CORE_URL="$FILTERS_URL"
	checkCoreURL
fi

function checkAdditionalRepository {
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
	[ "${SSH_CLIENT}" != "" ] && echo "URL: $ADDITIONAL_FILES_URL"
	if echo "$ADDITIONAL_FILES_URL" | grep -q "\/tree\/master\/"
	then
		ADDITIONAL_FILES_URL=$(echo "$ADDITIONAL_FILES_URL" | sed 's/\/tree\/master\//\/file-list\/master\//g')
	else
		ADDITIONAL_FILES_URL="$ADDITIONAL_FILES_URL/file-list/master"
	fi
	CONTENT_TDS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sLf "$ADDITIONAL_FILES_URL")
	ADDITIONAL_FILE_DATETIMES=$(echo "$CONTENT_TDS" | awk '/class="age">/,/<\/td>/' | tr -d '\n' | sed 's/ \{1,\}/+/g' | sed 's/<\/td>/\n/g')
	ADDITIONAL_FILE_DATETIMES=( $ADDITIONAL_FILE_DATETIMES )
	for DATETIME_INDEX in "${!ADDITIONAL_FILE_DATETIMES[@]}"; do 
		ADDITIONAL_FILE_DATETIMES[$DATETIME_INDEX]=$(echo "${ADDITIONAL_FILE_DATETIMES[$DATETIME_INDEX]}" | grep -o "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}Z" )
		if [ "${ADDITIONAL_FILE_DATETIMES[$DATETIME_INDEX]}" == "" ]
		then
			ADDITIONAL_FILE_DATETIMES[$DATETIME_INDEX]="${ADDITIONAL_FILE_DATETIMES[$((DATETIME_INDEX-1))]}"
		fi
	done
	CONTENT_TDS=$(echo "$CONTENT_TDS" | awk '/class="content">/,/<\/td>/' | tr -d '\n' | sed 's/ \{1,\}/+/g' | sed 's/<\/td>/\n/g')
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
				[ "${SSH_CLIENT}" != "" ] && echo "URL: https://github.com$ADDITIONAL_FILE_URL?raw=true"
				mv "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}" "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
				if curl $CURL_RETRY $SSL_SECURITY_OPTION -L "https://github.com$ADDITIONAL_FILE_URL?raw=true" -o "$CURRENT_DIR/$ADDITIONAL_FILE_NAME"
				then
					rm "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
				else
					echo "${ADDITIONAL_FILE_NAME} download failed"
					echo "Restoring old ${ADDITIONAL_FILE_NAME} file"
					rm "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}" > /dev/null 2>&1
					mv "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}.${TO_BE_DELETED_EXTENSION}" "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}" > /dev/null 2>&1
				fi
				sync
				echo ""
			fi
		fi
		CONTENT_TD_INDEX=$((CONTENT_TD_INDEX+1))
	done
	echo ""
}

for ADDITIONAL_REPOSITORY in "${ADDITIONAL_REPOSITORIES[@]}"; do
	[ "$PARALLEL_UPDATE" == "true" ] && { echo "$(checkAdditionalRepository)"$'\n' & } || checkAdditionalRepository
done
wait

function checkCheat {
	MAPPING_KEY=$(echo "${CHEAT_MAPPING}" | grep -o "^[^:]*")
	MAPPING_VALUE=$(echo "${CHEAT_MAPPING}" | grep -o "[^:]*$")
	MAX_VERSION=""
	FILE_NAME=$(echo "${CHEAT_URLS}" | grep "mister_${MAPPING_KEY}_")
	echo "Checking ${MAPPING_KEY^^}"
	if [ "${FILE_NAME}" != "" ]
	then
		CHEAT_URL="${CHEATS_URL}${FILE_NAME}"
		MAX_VERSION=$(echo "${FILE_NAME}" | grep -oE "[0-9]{8}")
		CURRENT_LOCAL_VERSION=""
		MAX_LOCAL_VERSION=""
		for CURRENT_FILE in "${BASE_PATH}/${WORK_DIR}/mister_${MAPPING_KEY}_"*
		do
			if [ -f "${CURRENT_FILE}" ]
			then
				if echo "${CURRENT_FILE}" | grep -qE "mister_[^_]+_[0-9]{8}.zip"
				then
					CURRENT_LOCAL_VERSION=$(echo "${CURRENT_FILE}" | grep -oE '[0-9]{8}')
					[ "${UPDATE_CHEATS}" == "once" ] && CURRENT_LOCAL_VERSION="99999999"
					if [[ "${CURRENT_LOCAL_VERSION}" > "${MAX_LOCAL_VERSION}" ]]
					then
						MAX_LOCAL_VERSION=${CURRENT_LOCAL_VERSION}
					fi
					if [[ "${MAX_VERSION}" > "${CURRENT_LOCAL_VERSION}" ]] && [ "${DELETE_OLD_FILES}" == "true" ]
					then
						mv "${CURRENT_FILE}" "${CURRENT_FILE}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
					fi
				fi
			fi
		done
		if [[ "${MAX_VERSION}" > "${MAX_LOCAL_VERSION}" ]]
		then
			echo "Downloading ${FILE_NAME}"
			[ "${SSH_CLIENT}" != "" ] && echo "URL: ${CHEAT_URL}"
			if curl $CURL_RETRY $SSL_SECURITY_OPTION -L --cookie "challenge=BitMitigate.com" "${CHEAT_URL}" -o "${BASE_PATH}/${WORK_DIR}/${FILE_NAME}"
			then
				if [ ${DELETE_OLD_FILES} == "true" ]
				then
					echo "Deleting old mister_${MAPPING_KEY} files"
					rm "${BASE_PATH}/${WORK_DIR}/mister_${MAPPING_KEY}_"*.${TO_BE_DELETED_EXTENSION} > /dev/null 2>&1
				fi
				mkdir -p "${BASE_PATH}/cheats/${MAPPING_VALUE}"
				sync
				echo "Extracting ${FILE_NAME}"
				unzip -o "${BASE_PATH}/${WORK_DIR}/${FILE_NAME}" -d "${BASE_PATH}/cheats/${MAPPING_VALUE}" 1>&2
				rm "${BASE_PATH}/${WORK_DIR}/${FILE_NAME}" > /dev/null 2>&1
				touch "${BASE_PATH}/${WORK_DIR}/${FILE_NAME}" > /dev/null 2>&1
			else
				echo "${FILE_NAME} download failed"
				rm "${BASE_PATH}/${WORK_DIR}/${FILE_NAME}" > /dev/null 2>&1
				if [ ${DELETE_OLD_FILES} == "true" ]
				then
					echo "Restoring old mister_${MAPPING_KEY} files"
					for FILE_TO_BE_RESTORED in "${BASE_PATH}/${WORK_DIR}/mister_${MAPPING_KEY}_"*.${TO_BE_DELETED_EXTENSION}
					do
					  mv "${FILE_TO_BE_RESTORED}" "${FILE_TO_BE_RESTORED%.${TO_BE_DELETED_EXTENSION}}" > /dev/null 2>&1
					done
				fi
			fi
			sync
		fi
	fi
	echo ""
}

if [ "${UPDATE_CHEATS}" != "false" ]
then
	echo "Checking Cheats"
	echo ""
	CHEAT_URLS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sLf --cookie "challenge=BitMitigate.com" "${CHEATS_URL}" | grep -oE '"mister_[^_]+_[0-9]{8}.zip"' | sed 's/"//g')
	for CHEAT_MAPPING in ${CHEAT_MAPPINGS}; do
		[ "$PARALLEL_UPDATE" == "true" ] && { echo "$(checkCheat)"$'\n' & } || checkCheat
	done
	wait
fi

if [ "$SD_INSTALLER_PATH" != "" ]
then
	echo "Linux system must be updated"
	if [ ! -f "${MISTER_PATH}/linux/unrar-nonfree" ]
	then
		UNRAR_DEB_URLS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sLf "$UNRAR_DEBS_URL" | grep -o '\"unrar[a-zA-Z0-9%./_+-]*_armhf\.deb\"' | sed 's/\"//g')
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
		tar -xJf "$TEMP_PATH/data.tar.xz" --strip-components=3 -C "${MISTER_PATH}/linux" ./usr/bin/unrar-nonfree
		rm "$TEMP_PATH/data.tar.xz" > /dev/null 2>&1
	fi
	if [ -f "${MISTER_PATH}/linux/unrar-nonfree" ] && [ -f "$SD_INSTALLER_PATH" ]
	then
		sync
		if "${MISTER_PATH}/linux/unrar-nonfree" t "$SD_INSTALLER_PATH"
		then
			if [ -d "${MISTER_PATH}/linux.update" ]
			then
				rm -R "${MISTER_PATH}/linux.update" > /dev/null 2>&1
			fi
			mkdir "${MISTER_PATH}/linux.update"
			if "${MISTER_PATH}/linux/unrar-nonfree" x -y "$SD_INSTALLER_PATH" files/linux/* "${MISTER_PATH}/linux.update"
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
				mv -f "${MISTER_PATH}/linux.update/files/linux/linux.img" "${MISTER_PATH}/linux/linux.img.new"
				mv -f "${MISTER_PATH}/linux.update/files/linux/"* "${MISTER_PATH}/linux/"
				rm -R "${MISTER_PATH}/linux.update" > /dev/null 2>&1
				sync
				"${MISTER_PATH}/linux/updateboot"
				sync
				mv -f "${MISTER_PATH}/linux/linux.img.new" "${MISTER_PATH}/linux/linux.img"
				sync
			else
				rm -R "${MISTER_PATH}/linux.update" > /dev/null 2>&1
				sync
			fi
			REBOOT_NEEDED="true"
		else
			echo "Downloaded installer RAR is broken, deleting $SD_INSTALLER_PATH"
			rm "$SD_INSTALLER_PATH" > /dev/null 2>&1
		fi
	fi
fi

echo "Done!"
if [[ "${REBOOT_NEEDED}" == "true" ]] ; then
    if [[ "${AUTOREBOOT}" == "true" && "${REBOOT_PAUSE}" -ge 0 ]] ; then
	echo "Rebooting in ${REBOOT_PAUSE} seconds"
	sleep "${REBOOT_PAUSE}"
	reboot now
    else
	echo "You should reboot"
    fi
fi

exit 0
