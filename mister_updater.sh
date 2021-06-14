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

# Copyright 2018-2020 Alessandro "Locutus73" Miele

# You can download the latest version of this script from:
# https://github.com/MiSTer-devel/Updater_script_MiSTer


# Version 4.0.15 - 2021-06-14 - Handle HTML codes for square brackets and ampersand
# Version 4.0.14 - 2021-03-23 - Fixed a bug in checkAdditionalRepository.
# Version 4.0.13 - 2021-03-22 - Added XOW scripts to ADDITIONAL_REPOSITORIES; added main branch detection to checkAdditionalRepository.
# Version 4.0.12 - 2021-03-05 - Updated checkAdditionalRepository in order to reflect a change in GitHub HTML code.
# Version 4.0.11 - 2021-02-21 - Removied curl and folder creation errors (thanks to theypsilon and cdewit).
# Version 4.0.10 - 2020-12-07 - Optimised repositories main branch detection through a single API call.
# Version 4.0.9 - 2020-06-25 - Download timeout increased from 120 seconds to 180.
# Version 4.0.8 - 2020-06-24 - Updated checkAdditionalRepository in order to reflect a change in GitHub HTML code.
# Version 4.0.7 - 2020-05-04 - mame and hbmame directories are created only when they don't exist both in games and _Arcade directories; mame and hbmame directories are deleted from games dir, when they're empty and _Arcade/mame and _Arcade/hbmame aren't empty.
# Version 4.0.6 - 2020-05-03 - Improved GAMES_SUBDIR automatic detection, preferring $BASE_PATH/games; mame and hbmame dirs are created in games dir when used; corrected a bug preventing the correct use of BASE_PATH in the ini file; updated ADDITIONAL_REPOSITORIES default value; added TurboGrafx CD cheats.
# Version 4.0.5 - 2020-04-23 - PARALLEL_UPDATE="false" is default again, after users reporting true randomly triggering GitHub anti abuse system.
# Version 4.0.4 - 2020-02-27 - The script prompts for using PARALLEL_UPDATE="false" each time a download fails; corrected an incompatibility with AY-3-8500 repository.
# Version 4.0.3 - 2020-02-24 - Changed MAME_ARCADE_ROMS and MAME_ALT_ROMS default value to "true"; added _Other core directory and removed Arduboy from SD root; renamed CORE_CATEGORY_PATHS["cores"] to CORE_CATEGORY_PATHS["computer-cores"] for better readibility, "cores" still works for both CORE_CATEGORY_PATHS and filters; code clean up by frederic-mahe (thank you very much).
# Version 4.0.2 - 2020-02-09 - Improved script output; the updater performs a full resync when a newer version has been released; the updater informs the user that MAME_ARCADE_ROMS and MAME_ALT_ROMS default values are going to switch to "true" in the next days; corrected a bug in additional repositories files with a comma "," in the name; added GBA cheats; the updater checks the actual installed MiSTer Linux and not only the last downloaded SD-Installer before updating Linux; the updater backups the whole _Arcade dir before switching to the new MRA structure when MAME_ARCADE_ROMS="true"; speed optimisations.
# Version 4.0.1 - 2020-01-18 - Improved script output.
# Version 4.0 - 2020-01-13 - Added report/log of updated cores and additional files at the end of the script; added exit code 100 when there's an error downloading something; now PARALLEL_UPDATE="true" is the default value; added REPOSITORIES_NEGATIVE_FILTER parameter, like REPOSITORIES_FILTER but repository names and core categories must not match the filter, it is processed after REPOSITORIES_FILTER; now the updater only checks repositories which have been actually updated since the last successful update, edit your ini or delete /media/fat/Scripts/.mister_updater/*.last_successful_run files to reset this mechanism; changed MidiLink additional repository to the official MiSTer-devel one.
# Version 3.6.3 - 2020-01-09 - Speed optimisations.
# Version 3.6.2 - 2020-01-07 - Changed MAME_ARCADE_ROMS and MAME_ALT_ROMS default value to ""; "true" for using the new MRA directory/file structure; "false" for restoring the old directory/file structure; "" for doing nothing.
# Version 3.6.1 - 2020-01-07 - Fixed a bug which corrupted the download of MRA files with a single quote char ' in the name.
# Version 3.6 - 2020-01-06 - Added MAME_ARCADE_ROMS option; when "true" the updater downloads/updates MRA files (MAME Arcade ROMs) for Arcade cores; when using MAME_ARCADE_ROMS="true", please do not add "/cores" to CORE_CATEGORY_PATHS["arcade-cores"]; added MAME_ALT_ROMS option; when "true" the updater downloads/updates alternative MRA files (alternative MAME Arcade ROMs) for Arcade cores.
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

#Directories where all core categories will be downloaded.
declare -A CORE_CATEGORY_PATHS
CORE_CATEGORY_PATHS["computer-cores"]="$BASE_PATH/_Computer"
CORE_CATEGORY_PATHS["console-cores"]="$BASE_PATH/_Console"
CORE_CATEGORY_PATHS["arcade-cores"]="$BASE_PATH/_Arcade"
CORE_CATEGORY_PATHS["other-cores"]="$BASE_PATH/_Other"
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

#Like REPOSITORIES_FILTER but repository names or core categories must not match the filter;
#REPOSITORIES_NEGATIVE_FILTER is processed after REPOSITORIES_FILTER.
REPOSITORIES_NEGATIVE_FILTER=""

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

#Specifies if the updater has to download/update MRA files (MAME Arcade ROMs) for Arcade cores;
#"true" for using the new MRA directory/file structure;
#"false" for restoring the old directory/file structure;
#"" for doing nothing.
#when using MAME_ARCADE_ROMS="true", please do not add "/cores" to CORE_CATEGORY_PATHS["arcade-cores"].
MAME_ARCADE_ROMS="true"

#Specifies if the updater has to download/update alternative MRA files (alternative MAME Arcade ROMs) for Arcade cores;
#"true" for using the new MRA directory/file structure;
#"false" for restoring the old directory/file structure;
#"" for doing nothing.
MAME_ALT_ROMS="true"

#Specifies the Games/Programs subdirectory where core specific directories will be placed.
#GAMES_SUBDIR="" for letting the script choose between /media/fat and /media/fat/games when it exists,
#otherwise the subdir you prefer (i.e. GAMES_SUBDIR="/Programs").
GAMES_SUBDIR=""

#========= ADVANCED OPTIONS =========
#ALLOW_INSECURE_SSL="true" will check if SSL certificate verification (see https://curl.haxx.se/docs/sslcerts.html )
#is working (CA certificates installed) and when it's working it will use this feature for safe curl HTTPS downloads,
#otherwise it will use --insecure option for disabling SSL certificate verification.
#If CA certificates aren't installed it's advised to install them (i.e. using security_fixes.sh).
#ALLOW_INSECURE_SSL="false" will never use --insecure option and if CA certificates aren't installed
#any download will fail.
ALLOW_INSECURE_SSL="true"
CURL_RETRY="--connect-timeout 15 --max-time 180 --retry 3 --retry-delay 5"
MISTER_URL="https://github.com/MiSTer-devel/Main_MiSTer"
SCRIPTS_PATH="Scripts"
OLD_SCRIPTS_PATH="#Scripts"
WORK_PATH="/media/fat/$SCRIPTS_PATH/.mister_updater"
#Comment (or uncomment) next lines if you don't want (or want) to update/download from additional repositories (i.e. Scaler filters and Gameboy palettes) each time
ADDITIONAL_REPOSITORIES=(
#	"https://github.com/MiSTer-devel/Filters_MiSTer/tree/master/Filters|txt|$BASE_PATH/Filters"
	"https://github.com/MiSTer-devel/Gameboy_MiSTer/tree/master/palettes|gbp|@GAMES_SUBDIR@/GameBoy"
	"https://github.com/MiSTer-devel/Scripts_MiSTer|sh inc|$BASE_PATH/$SCRIPTS_PATH"
#	"https://github.com/bbond007/MiSTer_MidiLink/tree/master/INSTALL|sh inc|$BASE_PATH/$SCRIPTS_PATH"
	"https://github.com/MiSTer-devel/MidiLink_MiSTer/tree/master/INSTALL|sh inc|$BASE_PATH/$SCRIPTS_PATH"
#	"https://github.com/MiSTer-devel/Fonts_MiSTer|pf|$BASE_PATH/font"
	"https://github.com/MiSTer-devel/NeoGeo_MiSTer/tree/master/releases|xml|@GAMES_SUBDIR@/NeoGeo"
	"https://github.com/MiSTer-devel/Scripts_MiSTer/tree/master/other_authors|sh inc|$BASE_PATH/$SCRIPTS_PATH"
	"https://github.com/MiSTer-devel/xow_MiSTer|sh|$BASE_PATH/$SCRIPTS_PATH"
)
MISTER_DEVEL_REPOS_URL="https://api.github.com/orgs/mister-devel/repos"
FILTERS_URL="https://github.com/MiSTer-devel/Filters_MiSTer"
MRA_ALT_URL="https://github.com/MiSTer-devel/MRA-Alternatives_MiSTer"
CHEATS_URL="https://gamehacking.org/mister/"
CHEAT_MAPPINGS="fds:NES gb:GameBoy gbc:GameBoy gen:Genesis gg:SMS nes:NES pce:TGFX16 sms:SMS snes:SNES gba:GBA pcd:TGFX16"
UNRAR_DEBS_URL="http://http.us.debian.org/debian/pool/non-free/u/unrar-nonfree"
#Uncomment this if you want the script to sync the system date and time with a NTP server
#NTP_SERVER="0.pool.ntp.org"
AUTOREBOOT="true"
REBOOT_PAUSE=0  # in seconds
TEMP_PATH="/tmp"
TO_BE_DELETED_EXTENSION="to_be_deleted"



#========= CODE STARTS HERE =========

UPDATER_VERSION="4.0.15"
echo "MiSTer Updater version ${UPDATER_VERSION}"
echo ""

ORIGINAL_SCRIPT_PATH="$0"
if [ "$ORIGINAL_SCRIPT_PATH" == "bash" ]
then
	ORIGINAL_SCRIPT_PATH=$(ps | grep "^ *$PPID " | grep -o "[^ ]*$")
fi
INI_PATH=${ORIGINAL_SCRIPT_PATH%.*}.ini
if [ -f $INI_PATH ]
then
	eval "$(cat $INI_PATH | tr -d '\r')"
	INI_DATETIME_UTC=$(date -d "$(stat -c %y "${INI_PATH}" 2>/dev/null)" -u +"%Y-%m-%dT%H:%M:%SZ")
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

#if [ "$PARALLEL_UPDATE" != "true" ]
#then
#			echo "Do you want a"
#			echo "faster update?"
#			echo "Please try"
#			echo "PARALLEL_UPDATE=\"true\""
#			echo "in your"
#			echo "$(basename $INI_PATH)"
#			echo ""
#fi

#if [ "${MAME_ARCADE_ROMS}" != "true" ] || [ "${MAME_ALT_ROMS}" != "true" ]
#then
#	echo "In the next days"
#	echo "MAME_ARCADE_ROMS"
#	echo "and"
#	echo "MAME_ALT_ROMS"
#	echo "default values will"
#	echo "be switched to \"true\"."
#	echo "If you're still using"
#	echo "the old, outdated and"
#	echo "deprecated rom style,"
#	echo "please add"
#	echo "MAME_ARCADE_ROMS=\"false\""
#	echo "and"
#	echo "MAME_ALT_ROMS=\"false\""
#	echo "to your"
#	echo "$(basename $INI_PATH)"
#	echo ""
#fi

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

UPDATE_START_DATETIME_LOCAL=$(date)
UPDATE_START_DATETIME_UTC=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

for idx in "${!CORE_CATEGORY_PATHS[@]}"; do
	CORE_CATEGORY_PATHS[$idx]="${CORE_CATEGORY_PATHS[$idx]/\/media\/fat/${BASE_PATH}}"
	#echo "CORE_CATEGORY_PATHS[$idx]=${CORE_CATEGORY_PATHS[$idx]}"
done
if [ "${GAMES_SUBDIR}" == "" ]
then
	if [ "$(find ${BASE_PATH}/games -type f -print -quit 2> /dev/null)" == "" ] && { [ "$(find ${BASE_PATH}/GameBoy -type f -print -quit 2> /dev/null)" != "" ] || [ "$(find ${BASE_PATH}/NeoGeo -type f -print -quit 2> /dev/null)" != "" ]; }
	then
		GAMES_SUBDIR="${BASE_PATH}"
	else
		GAMES_SUBDIR="${BASE_PATH}/games"
	fi
fi
for idx in "${!ADDITIONAL_REPOSITORIES[@]}"; do
	ADDITIONAL_REPOSITORIES[$idx]="${ADDITIONAL_REPOSITORIES[$idx]/\/media\/fat/${BASE_PATH}}"
	ADDITIONAL_REPOSITORIES[$idx]="${ADDITIONAL_REPOSITORIES[$idx]/@GAMES_SUBDIR@/${GAMES_SUBDIR}}"
	#echo "ADDITIONAL_REPOSITORIES[$idx]=${ADDITIONAL_REPOSITORIES[$idx]}"
done

mkdir -p "${CORE_CATEGORY_PATHS[@]}"
if [ "${MAME_ARCADE_ROMS}" == "true" ]
then
	if ls ${CORE_CATEGORY_PATHS["arcade-cores"]}/*.rbf > /dev/null 2>&1 && ! ls ${CORE_CATEGORY_PATHS["arcade-cores"]}/*.mra > /dev/null 2>&1
	then
		echo "Backupping ${CORE_CATEGORY_PATHS["arcade-cores"]}"
		echo "into ${CORE_CATEGORY_PATHS["arcade-cores"]}_backup_$(date -u +%Y%m%d)"
		echo "please wait..."
		cp -r "${CORE_CATEGORY_PATHS["arcade-cores"]}" "${CORE_CATEGORY_PATHS["arcade-cores"]}_backup_$(date -u +%Y%m%d)"
		echo "...done."
		echo ""
	fi
	mkdir -p "${CORE_CATEGORY_PATHS["arcade-cores"]}/cores"
	if [ ! -d "${CORE_CATEGORY_PATHS["arcade-cores"]}/mame" ] && [ ! -d "${GAMES_SUBDIR}/mame" ]
	then
		if [ "${GAMES_SUBDIR}" == "${BASE_PATH}" ]
		then
			mkdir -p "${CORE_CATEGORY_PATHS["arcade-cores"]}/mame"
		else
			mkdir -p "${GAMES_SUBDIR}/mame"
		fi
	fi
	if [ -d "${BASE_PATH}/games/mame" ] && [ "$(find ${BASE_PATH}/games/mame -type f -print -quit 2> /dev/null)" == "" ] && [ "$(find ${CORE_CATEGORY_PATHS["arcade-cores"]}/mame -type f -print -quit 2> /dev/null)" != "" ]
	then
		echo "Deleting empty ${BASE_PATH}/games/mame since ${CORE_CATEGORY_PATHS["arcade-cores"]}/mame is not empty"
		echo ""
		rm -R "${BASE_PATH}/games/mame" > /dev/null 2>&1
	fi
	if [ ! -d "${CORE_CATEGORY_PATHS["arcade-cores"]}/hbmame" ] && [ ! -d "${GAMES_SUBDIR}/hbmame" ]
	then
		if [ "${GAMES_SUBDIR}" == "${BASE_PATH}" ]
		then
			mkdir -p "${CORE_CATEGORY_PATHS["arcade-cores"]}/hbmame"
		else
			mkdir -p "${GAMES_SUBDIR}/hbmame"
		fi
	fi
	if [ -d "${BASE_PATH}/games/hbmame" ] && [ "$(find ${BASE_PATH}/games/hbmame -type f -print -quit 2> /dev/null)" == "" ] && [ "$(find ${CORE_CATEGORY_PATHS["arcade-cores"]}/hbmame -type f -print -quit 2> /dev/null)" != "" ]
	then
		echo "Deleting empty ${BASE_PATH}/games/hbmame since ${CORE_CATEGORY_PATHS["arcade-cores"]}/hbmame is not empty"
		echo ""
		rm -R "${BASE_PATH}/games/hbmame" > /dev/null 2>&1
	fi
	mv "${CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup/"*.mra "${CORE_CATEGORY_PATHS["arcade-cores"]}/" > /dev/null 2>&1
	find "${CORE_CATEGORY_PATHS["arcade-cores"]}" -maxdepth 1 -type f -name '*.mra' -size +165000c -size -166000c -delete
	rm "${CORE_CATEGORY_PATHS["arcade-cores"]}/Arkanoid (unl.lives%2C slower).mra" > /dev/null 2>&1
elif [ "${MAME_ARCADE_ROMS}" == "false" ]
then
	mv "${CORE_CATEGORY_PATHS["arcade-cores"]}/cores/"*.rbf "${CORE_CATEGORY_PATHS["arcade-cores"]}/" > /dev/null 2>&1
	mkdir -p "${CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup"
	mv "${CORE_CATEGORY_PATHS["arcade-cores"]}/"*.mra "${CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup/" > /dev/null 2>&1
fi
if [ "${MAME_ALT_ROMS}" == "true" ]
then
	mv "${CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup/_alternatives/" "${CORE_CATEGORY_PATHS["arcade-cores"]}/_alternatives/" > /dev/null 2>&1
elif [ "${MAME_ALT_ROMS}" == "false" ]
then
	mkdir -p "${CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup"
	mv "${CORE_CATEGORY_PATHS["arcade-cores"]}/_alternatives/" "${CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup/_alternatives/" > /dev/null 2>&1
fi

rm "${BASE_PATH}/"Arduboy_*.rbf > /dev/null 2>&1

declare -A NEW_CORE_CATEGORY_PATHS
if [ "$DOWNLOAD_NEW_CORES" != "true" ] && [ "$DOWNLOAD_NEW_CORES" != "false" ] && [ "$DOWNLOAD_NEW_CORES" != "" ]
then
	for idx in "${!CORE_CATEGORY_PATHS[@]}"; do
		NEW_CORE_CATEGORY_PATHS[$idx]=$(echo ${CORE_CATEGORY_PATHS[$idx]} | sed "s/$(echo $BASE_PATH | sed 's/\//\\\//g')/$(echo $BASE_PATH | sed 's/\//\\\//g')\/$DOWNLOAD_NEW_CORES/g")
	done
	mkdir -p "${NEW_CORE_CATEGORY_PATHS[@]}"
	if [ "${MAME_ARCADE_ROMS}" == "true" ]
	then
		mkdir -p "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/cores"
		mv "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup/"*.mra "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/" > /dev/null 2>&1
	elif [ "${MAME_ARCADE_ROMS}" == "false" ]
	then
		mv "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/cores/"*.rbf "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/" > /dev/null 2>&1
		mkdir -p "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup"
		mv "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/"*.mra "${NEW_CORE_CATEGORY_PATHS["arcade-cores"]}/mra_backup/" > /dev/null 2>&1
	fi
fi

UPDATED_CORES_FILE=$(mktemp)
ERROR_CORES_FILE=$(mktemp)
UPDATED_ADDITIONAL_REPOSITORIES_FILE=$(mktemp)
ERROR_ADDITIONAL_REPOSITORIES_FILE=$(mktemp)

[ "${UPDATE_LINUX}" == "true" ] && SD_INSTALLER_URL="https://github.com/MiSTer-devel/SD-Installer-Win64_MiSTer"

echo "Downloading MiSTer Wiki structure"
echo ""
#CORE_URLS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$MISTER_URL/wiki"| awk '/user-content-fpga-cores/,/user-content-development/' | grep -io '\(https://github.com/[a-zA-Z0-9./_-]*_MiSTer\)\|\(user-content-[a-zA-Z0-9-]*\)')
CORE_URLS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$MISTER_URL/wiki"| awk '/user-content-fpga-cores/,/user-content-development/' | grep -ioE '(https://github.com/[a-zA-Z0-9./_-]*[_-]MiSTer)|(user-content-[a-zA-Z0-9-]*)')
MENU_URL=$(echo "${CORE_URLS}" | grep -io 'https://github.com/[a-zA-Z0-9./_-]*Menu_MiSTer')
CORE_URLS=$(echo "${CORE_URLS}" |  sed 's/https:\/\/github.com\/[a-zA-Z0-9.\/_-]*Menu_MiSTer//')
CORE_URLS=${SD_INSTALLER_URL}$'\n'${MISTER_URL}$'\n'${MENU_URL}$'\n'${CORE_URLS}$'\n'"user-content-arcade-cores"$'\n'$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$MISTER_URL/wiki/Arcade-Cores-List"| awk '/wiki-content/,/wiki-rightbar/' | grep -io '\(https://github.com/[a-zA-Z0-9./_-]*_MiSTer\)' | awk '!a[$0]++')
CORE_CATEGORY="-"
SD_INSTALLER_PATH=""
REBOOT_NEEDED="false"
CORE_CATEGORIES_FILTER=""
if [ "$REPOSITORIES_FILTER" != "" ]
then
	#CORE_CATEGORIES_FILTER="^\($( echo "$REPOSITORIES_FILTER" | sed 's/[ 	]\{1,\}/\\)\\|\\(/g' )\)$"
	#REPOSITORIES_FILTER="\(Main_MiSTer\)\|\(Menu_MiSTer\)\|\(SD-Installer-Win64_MiSTer\)\|\($( echo "$REPOSITORIES_FILTER" | sed 's/[ 	]\{1,\}/\\)\\|\\([\/_-]/g' )\)"
	CORE_CATEGORIES_FILTER_REGEX="^($( echo "$REPOSITORIES_FILTER" | sed 's/[ 	]\{1,\}/)|(/g' ))$"
	REPOSITORIES_FILTER_REGEX="(Main_MiSTer)|(Menu_MiSTer)|(SD-Installer-Win64_MiSTer)|([\/_-]$( echo "$REPOSITORIES_FILTER" | sed 's/[ 	]\{1,\}/)|([\/_-]/g' ))"
fi
if [ "$REPOSITORIES_NEGATIVE_FILTER" != "" ]
then
	CORE_CATEGORIES_NEGATIVE_FILTER_REGEX="^($( echo "$REPOSITORIES_NEGATIVE_FILTER" | sed 's/[ 	]\{1,\}/)|(/g' ))$"
	REPOSITORIES_NEGATIVE_FILTER_REGEX="([\/_-]$( echo "$REPOSITORIES_NEGATIVE_FILTER" | sed 's/[ 	]\{1,\}/)|([\/_-]/g' ))"
fi
CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER=""
LAST_SUCCESSFUL_RUN_PATH="${WORK_PATH}/$(basename ${ORIGINAL_SCRIPT_PATH%.*}.last_successful_run)"
if [ -f ${LAST_SUCCESSFUL_RUN_PATH} ]
then
	LAST_SUCCESSFUL_RUN_DATETIME_UTC=$(cat "${LAST_SUCCESSFUL_RUN_PATH}" | sed '1q;d')
	LAST_SUCCESSFUL_RUN_INI_DATETIME_UTC=$(cat "${LAST_SUCCESSFUL_RUN_PATH}" | sed '2q;d')
	LAST_SUCCESSFUL_RUN_UPDATER_VERSION=$(cat "${LAST_SUCCESSFUL_RUN_PATH}" | sed '3q;d')
	
	if [ "${MISTER_DEVEL_REPOS_URL}" != "" ] && [ "${INI_DATETIME_UTC}" == "${LAST_SUCCESSFUL_RUN_INI_DATETIME_UTC}" ] && [ "${UPDATER_VERSION}" == "${LAST_SUCCESSFUL_RUN_UPDATER_VERSION}" ]
	then
		echo "Performing an optimized update checking only repositories"
		echo "updated after $(date -d ${LAST_SUCCESSFUL_RUN_DATETIME_UTC})"
		echo "If you want a full updater resync please delete"
		echo "${LAST_SUCCESSFUL_RUN_PATH}"
		echo ""
	else
		echo "Performing a full updater resync because"
		if [ "${UPDATER_VERSION}" != "${LAST_SUCCESSFUL_RUN_UPDATER_VERSION}" ]
		then
			echo "a new updater has been released"
		fi
		if [ "${INI_DATETIME_UTC}" != "${LAST_SUCCESSFUL_RUN_INI_DATETIME_UTC}" ]
		then
			echo "${INI_PATH} was modified"
		fi
		echo ""
	fi
else
	echo "Performing a full updater resync"
	echo ""
fi

echo "Downloading MiSTer-devel updates and main branches"
echo ""
declare -A CORE_DEFAULT_BRANCHES
API_PAGE=1
#API_RESPONSE=$(curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} -sSLf "${MISTER_DEVEL_REPOS_URL}?per_page=100&page=${API_PAGE}" | grep -oE '("svn_url": "[^"]*)|("updated_at": "[^"]*)' | sed 's/"svn_url": "//; s/"updated_at": "//')
API_RESPONSE=$(curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} -sSLf "${MISTER_DEVEL_REPOS_URL}?per_page=100&page=${API_PAGE}" | grep -oE '("svn_url": "[^"]*)|("updated_at": "[^"]*)|("default_branch": "[^"]*)' | sed 's/"svn_url": "//; s/"updated_at": "//; s/"default_branch": "//')

until [ "${API_RESPONSE}" == "" ]; do
	for API_RESPONSE_LINE in $API_RESPONSE; do
		if [[ "${API_RESPONSE_LINE}" =~ [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2} ]]
		then
			REPO_UPDATE_DATETIME_UTC="${API_RESPONSE_LINE}"
		elif [[ "${API_RESPONSE_LINE}" =~ https: ]]
		then
			REPO_NAME="${API_RESPONSE_LINE##*/}"
			if [ "${MISTER_DEVEL_REPOS_URL}" != "" ] && [ "${INI_DATETIME_UTC}" == "${LAST_SUCCESSFUL_RUN_INI_DATETIME_UTC}" ] && [ "${UPDATER_VERSION}" == "${LAST_SUCCESSFUL_RUN_UPDATER_VERSION}" ]
			then
				if [[ "${LAST_SUCCESSFUL_RUN_DATETIME_UTC}" < "${REPO_UPDATE_DATETIME_UTC}" ]]
				then
					CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER="${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER} ${REPO_NAME}"
				fi
			fi
		else
			REPO_DEFAULT_BRANCH="${API_RESPONSE_LINE}"
			CORE_DEFAULT_BRANCHES["${REPO_NAME}"]="${REPO_DEFAULT_BRANCH}"
		fi
	done
	API_PAGE=$((API_PAGE+1))
	#API_RESPONSE=$(curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} -sSLf "${MISTER_DEVEL_REPOS_URL}?per_page=100&page=${API_PAGE}" | grep -oE '("svn_url": "[^"]*)|("updated_at": "[^"]*)' | sed 's/"svn_url": "//; s/"updated_at": "//')
	API_RESPONSE=$(curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} -sSLf "${MISTER_DEVEL_REPOS_URL}?per_page=100&page=${API_PAGE}" | grep -oE '("svn_url": "[^"]*)|("updated_at": "[^"]*)|("default_branch": "[^"]*)' | sed 's/"svn_url": "//; s/"updated_at": "//; s/"default_branch": "//')
done
if [ "${MISTER_DEVEL_REPOS_URL}" != "" ] && [ "${INI_DATETIME_UTC}" == "${LAST_SUCCESSFUL_RUN_INI_DATETIME_UTC}" ] && [ "${UPDATER_VERSION}" == "${LAST_SUCCESSFUL_RUN_UPDATER_VERSION}" ]
then
	if [ "${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER}" != "" ]
	then
		CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER=$(echo "${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER}" | cut -c2- )
	else
		CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER="ZZZZZZZZZ"
	fi
fi

if [ "$CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER" != "" ]
then
	CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER_REGEX="([\/_-]$( echo "$CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER" | sed 's/[ 	]\{1,\}/)|([\/_-]/g' ))"
fi

GOOD_CORES=""
if [ "$GOOD_CORES_URL" != "" ]
then
	GOOD_CORES=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$GOOD_CORES_URL")
fi

function checkCoreURL {
	echo "Checking $(sed 's/.*\/// ; s/_MiSTer//' <<< "${CORE_URL}")"
	[ "${SSH_CLIENT}" != "" ] && echo "URL: $CORE_URL"
	# if echo "$CORE_URL" | grep -qE "SD-Installer"
	# then
	# 	RELEASES_URL="$CORE_URL"
	# else
	# 	RELEASES_URL=https://github.com$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$CORE_URL" | grep -oi '/MiSTer-devel/[a-zA-Z0-9./_-]*/tree/[a-zA-Z0-9./_-]*/releases' | head -n1)
	# fi
	#BRANCH_NAME=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "${CORE_URL}/branches" | grep "branch-name" | head -n1 | sed 's/.*>\(.*\)<.*/\1/')
	BRANCH_NAME=${CORE_DEFAULT_BRANCHES["${CORE_URL##*/}"]}
	case "$CORE_URL" in
		*SD-Installer*)
			RELEASES_URL="$CORE_URL"
			;;
		*)
			RELEASES_URL="${CORE_URL}/file-list/${BRANCH_NAME}/releases"
			;;
	esac
	
	RELEASES_HTML=""
	RELEASES_HTML=$(curl ${CURL_RETRY} ${SSL_SECURITY_OPTION} -sSLf "${RELEASES_URL}")
	RELEASE_URLS=$(echo ${RELEASES_HTML} | grep -oE '/MiSTer-devel/[a-zA-Z0-9./_-]*_[0-9]{8}[a-zA-Z]?(\.rbf|\.rar|\.zip)?')
	
	CORE_HAS_MRA="false"
	#if  [ "${CORE_CATEGORY}" == "arcade-cores" ] && [ "${MAME_ARCADE_ROMS}" == "true" ] && { echo "${RELEASES_HTML}" | grep -qE '/MiSTer-devel/[a-zA-Z0-9./_%&#;!()-]*\.mra'; }
	if  [ "${CORE_CATEGORY}" == "arcade-cores" ] && [ "${MAME_ARCADE_ROMS}" == "true" ] && [[ "${RELEASES_HTML}" =~ /MiSTer-devel/[a-zA-Z0-9./_%\&#\;!()-]*\.mra ]]
	then
		CORE_HAS_MRA="true"
	fi
	
	MAX_VERSION=""
	MAX_RELEASE_URL=""
	GOOD_CORE_VERSION=""
	for RELEASE_URL in $RELEASE_URLS; do
		#if echo "$RELEASE_URL" | grep -q "SharpMZ"
		if [[ "${RELEASE_URL}" =~ SharpMZ ]]
		then
			RELEASE_URL=$(echo "$RELEASE_URL"  | grep '\.rbf$')
		fi			
		#if echo "$RELEASE_URL" | grep -q "Atari800"
		if [[ "${RELEASE_URL}" =~ Atari800 ]]
		then
			if [ "$CORE_CATEGORY" == "cores" ] || [ "$CORE_CATEGORY" == "computer-cores" ]
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
	
	CURRENT_DIRS="${CORE_CATEGORY_PATHS[$CORE_CATEGORY]}"
	if [ "${NEW_CORE_CATEGORY_PATHS[$CORE_CATEGORY]}" != "" ]
	then
		CURRENT_DIRS=("$CURRENT_DIRS" "${NEW_CORE_CATEGORY_PATHS[$CORE_CATEGORY]}")
	fi 
	if [ "$CURRENT_DIRS" == "" ]
	then
		CURRENT_DIRS=("$BASE_PATH")
	fi
	#if [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || { echo "$CORE_URL" | grep -qE "SD-Installer|Filters_MiSTer"; }
	if [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || [[ "${CORE_URL}" =~ SD-Installer|Filters_MiSTer|MRA-Alternatives_MiSTer ]]
	then
		mkdir -p "$WORK_PATH"
		CURRENT_DIRS=("$WORK_PATH")
	fi
	
	CURRENT_LOCAL_VERSION=""
	MAX_LOCAL_VERSION=""
	for CURRENT_DIR in "${CURRENT_DIRS[@]}"
	do
		if [ "${CORE_CATEGORY}" == "arcade-cores" ] && [ "${MAME_ARCADE_ROMS}" == "true" ] && [ "${CORE_HAS_MRA}" == "false" ]
		then
			case "${BASE_FILE_NAME}" in
				"CrushRoller")
					[ -f "${CURRENT_DIR}/Crush Roller.mra" ] && { CORE_HAS_MRA="true"; }
					;;
				"MrTNT")
					[ -f "${CURRENT_DIR}/mr. tnt.mra" ] && { CORE_HAS_MRA="true"; }
					;;
				"MsPacman")
					[ -f "${CURRENT_DIR}/Ms. Pacman.mra" ] && { CORE_HAS_MRA="true"; }
					;;
				"PacmanClub")
					[ -f "${CURRENT_DIR}/Pacman Club.mra" ] && { CORE_HAS_MRA="true"; }
					;;
				"PacmanPlus")
					[ -f "${CURRENT_DIR}/Pacman Plus.mra" ] && { CORE_HAS_MRA="true"; }
					;;
				*)
					[ -f "${CURRENT_DIR}/${BASE_FILE_NAME}.mra" ] && { CORE_HAS_MRA="true"; }
					;;
			esac
		fi
		if [ "${CORE_HAS_MRA}" == "true" ]
		then
			mv "${CURRENT_DIR}/${BASE_FILE_NAME}"_*.rbf "${CURRENT_DIR}/cores/" > /dev/null 2>&1
			CURRENT_DIR="${CURRENT_DIR}/cores"
		fi
		for CURRENT_FILE in "$CURRENT_DIR/$BASE_FILE_NAME"*
		do
			if [ -f "$CURRENT_FILE" ]
			then
				#if echo "$CURRENT_FILE" | grep -q "$BASE_FILE_NAME\_[0-9]\{8\}[a-zA-Z]\?\(\.rbf\|\.rar\|\.zip\)\?$"
				if [[ "${CURRENT_FILE}" =~ ${BASE_FILE_NAME}_[0-9]{8}[a-zA-Z]?(\.rbf|\.rar|\.zip)?$ ]]
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
	
	[[ "${CORE_URL}" =~ SD-Installer ]] && [ -f /MiSTer.version ] && MAX_LOCAL_VERSION="20$(cat /MiSTer.version)"
	
	if [ "${BASE_FILE_NAME}" == "MiSTer" ] || [ "${BASE_FILE_NAME}" == "menu" ]
	then
		if [[ "${MAX_VERSION}" == "${MAX_LOCAL_VERSION}" ]]
		then
			#DESTINATION_FILE=$(echo "${MAX_RELEASE_URL}" | sed 's/.*\///g' | sed 's/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
			DESTINATION_FILE=$(echo "${MAX_RELEASE_URL}" | sed 's/.*\///g; s/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
			ACTUAL_CRC=$(md5sum "/media/fat/${DESTINATION_FILE}" | grep -o "^[^ ]*")
			SAVED_CRC=$(cat "${WORK_PATH}/${FILE_NAME}")
			if [ "$ACTUAL_CRC" != "$SAVED_CRC" ]
			then
				mv "${CURRENT_FILE}" "${CURRENT_FILE}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
				MAX_LOCAL_VERSION=""
			fi
		fi
	fi
	
	if [[ "$MAX_VERSION" > "$MAX_LOCAL_VERSION" ]]
	then
		#if [ "$DOWNLOAD_NEW_CORES" != "false" ] || [ "$MAX_LOCAL_VERSION" != "" ] || [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || { echo "$CORE_URL" | grep -qE "SD-Installer|Filters_MiSTer"; }
		if [ "$DOWNLOAD_NEW_CORES" != "false" ] || [ "$MAX_LOCAL_VERSION" != "" ] || [ "$BASE_FILE_NAME" == "MiSTer" ] || [ "$BASE_FILE_NAME" == "menu" ] || [[ "${CORE_URL}" =~ SD-Installer|Filters_MiSTer|MRA-Alternatives_MiSTer ]]
		then
			echo "Downloading $FILE_NAME to $CURRENT_DIR/$FILE_NAME"
			[ "${SSH_CLIENT}" != "" ] && echo "URL: https://github.com$MAX_RELEASE_URL?raw=true"
			if curl $CURL_RETRY $SSL_SECURITY_OPTION $([ "${PARALLEL_UPDATE}" == "true" ] && echo "-sS") -L "https://github.com$MAX_RELEASE_URL?raw=true" -o "$CURRENT_DIR/$FILE_NAME"
			then
				if [ ${DELETE_OLD_FILES} == "true" ]
				then
					echo "Deleting old ${BASE_FILE_NAME} files"
					rm "${CURRENT_DIR}/${BASE_FILE_NAME}"*.${TO_BE_DELETED_EXTENSION} > /dev/null 2>&1
				fi
				if [ $BASE_FILE_NAME == "MiSTer" ] || [ $BASE_FILE_NAME == "menu" ]
				then
					#DESTINATION_FILE=$(echo "$MAX_RELEASE_URL" | sed 's/.*\///g' | sed 's/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
					DESTINATION_FILE=$(echo "$MAX_RELEASE_URL" | sed 's/.*\///g; s/_[0-9]\{8\}[a-zA-Z]\{0,1\}//g')
					echo "Moving $DESTINATION_FILE"
					rm "/media/fat/$DESTINATION_FILE" > /dev/null 2>&1
					mv "$CURRENT_DIR/$FILE_NAME" "/media/fat/$DESTINATION_FILE"
					echo "$(md5sum "/media/fat/${DESTINATION_FILE}" | grep -o "^[^ ]*")" > "${CURRENT_DIR}/${FILE_NAME}"
					REBOOT_NEEDED="true"
				fi
				#if echo "$CORE_URL" | grep -q "SD-Installer"
				if [[ "${CORE_URL}" =~ SD-Installer ]]
				then
					SD_INSTALLER_PATH="$CURRENT_DIR/$FILE_NAME"
				fi
				#if echo "$CORE_URL" | grep -q "Filters_MiSTer"
				if [[ "${CORE_URL}" =~ Filters_MiSTer|MRA-Alternatives_MiSTer ]]
				then
					echo "Extracting ${FILE_NAME}"
					if [[ "${CORE_URL}" =~ MRA-Alternatives_MiSTer ]]
					then
						unzip -o "${WORK_PATH}/${FILE_NAME}" -d "${CORE_CATEGORY_PATHS["arcade-cores"]}" 1>&2
					else
						unzip -o "${WORK_PATH}/${FILE_NAME}" -d "${BASE_PATH}" 1>&2
					fi
					rm "${WORK_PATH}/${FILE_NAME}" > /dev/null 2>&1
					touch "${WORK_PATH}/${FILE_NAME}" > /dev/null 2>&1
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
										#if [ -f "$ARCADE_HACK_CORE" ] && { echo "$ARCADE_HACK_CORE" | grep -q "$BASE_FILE_NAME\_[0-9]\{8\}[a-zA-Z]\?\.rbf$"; }
										if [ -f "${ARCADE_HACK_CORE}" ] && [[ "${ARCADE_HACK_CORE}" =~ ${BASE_FILE_NAME}_[0-9]{8}[a-zA-Z]?\.rbf$ ]]
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
							"Apple-I"|"C64"|"PDP1"|"NeoGeo"|"AY-3-8500"|"EDSAC"|"Galaksija")
								CORE_INTERNAL_NAME="${BASE_FILE_NAME}"
								;;
							"SharpMZ")
								CORE_INTERNAL_NAME="SHARP MZ SERIES"
								;;
							"Amstrad-PCW")
								CORE_INTERNAL_NAME="Amstrad PCW"
								;;
							*)
								CORE_SOURCE_URL="$(echo "https://github.com$MAX_RELEASE_URL" | sed 's/releases.*//g')${BASE_FILE_NAME}.sv"
								CORE_INTERNAL_NAME="$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "${CORE_SOURCE_URL}?raw=true" 2> /tmp/core_internal_name_error | awk '/CONF_STR[^=]*=/,/;/' | grep -oE -m1 '"[^;]*?;' | sed 's/[";]//g')"
								if [ "$CORE_INTERNAL_NAME" == "" ]
								then
									cat /tmp/core_internal_name_error
									echo "Couldn't create directory for ${BASE_FILE_NAME}"
								fi
								;;
						esac
						if [ "$CORE_INTERNAL_NAME" != "" ]
						then
							echo "Creating ${GAMES_SUBDIR}/${CORE_INTERNAL_NAME} directory"
							mkdir -p "${GAMES_SUBDIR}/${CORE_INTERNAL_NAME}"
						fi
					fi
				fi
				if [[ "${CORE_URL}" =~ Filters_MiSTer|MRA-Alternatives_MiSTer ]]
				then
					echo -n ", ${FILE_NAME}" >> "${UPDATED_ADDITIONAL_REPOSITORIES_FILE}"
				else
					echo -n ", ${FILE_NAME}" >> "${UPDATED_CORES_FILE}"
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
				if [[ "${CORE_URL}" =~ Filters_MiSTer|MRA-Alternatives_MiSTer ]]
				then
					echo -n ", ${FILE_NAME}" >> "${ERROR_ADDITIONAL_REPOSITORIES_FILE}"
				else
					echo -n ", ${FILE_NAME}" >> "${ERROR_CORES_FILE}"
				fi
				echo "If you experience frequent download errors"
				echo "maybe the parallel update is hitting your network too hard"
				echo "please try PARALLEL_UPDATE=\"false\" in"
				echo "${INI_PATH}"
			fi
			sync
		else
			echo "New core: $FILE_NAME"
		fi
	else
		echo "Nothing to update"
	fi
	
	if [ "${CORE_HAS_MRA}" == "true" ] && [ "${RELEASES_HTML}" != "" ]
	then
		ADDITIONAL_REPOSITORY="MRA files|mra|${CURRENT_DIR%%\/cores}"
		checkAdditionalRepository
		ADDITIONAL_REPOSITORY=""
	else
		echo ""
	fi
	RELEASES_HTML=""
}

function checkAdditionalRepository {
	OLD_IFS="$IFS"
	IFS="|"
	PARAMS=($ADDITIONAL_REPOSITORY)
	ADDITIONAL_FILES_URL="${PARAMS[0]}"
	ADDITIONAL_FILES_EXTENSIONS="\($(echo ${PARAMS[1]} | sed 's/ \{1,\}/\\|/g')\)"
	CURRENT_DIR="${PARAMS[2]}"
	IFS="$OLD_IFS"
	
	echo "Checking $(echo $ADDITIONAL_FILES_URL | sed 's/.*\///g' | awk '{ print toupper( substr( $0, 1, 1 ) ) substr( $0, 2 ); }')"
	if ! [[ "${ADDITIONAL_FILES_URL}" == https://github.com/MiSTer-devel/* ]] || [ "$CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER" == "" ] || [[ "${ADDITIONAL_FILES_URL^^}" =~ ${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER_REGEX^^} ]]
	then
		if [ ! -d "$CURRENT_DIR" ]
		then
			mkdir -p "$CURRENT_DIR"
		fi
		[ "${SSH_CLIENT}" != "" ] && [[ $ADDITIONAL_FILES_URL == http* ]] && echo "URL: $ADDITIONAL_FILES_URL"
		if [ "${RELEASES_HTML}" == "" ]
		then
			if ! [[ "${ADDITIONAL_FILES_URL}" =~ /file-list/ ]]
			then
				if [[ "${ADDITIONAL_FILES_URL}" =~ /tree/master/ ]]
				then
					ADDITIONAL_FILES_URL=$(echo "$ADDITIONAL_FILES_URL" | sed 's/\/tree\/master\//\/file-list\/master\//g')
				elif [[ "${ADDITIONAL_FILES_URL}" =~ /tree/main/ ]]
				then
					ADDITIONAL_FILES_URL=$(echo "$ADDITIONAL_FILES_URL" | sed 's/\/tree\/main\//\/file-list\/main\//g')
				else
					if [[ "${ADDITIONAL_FILES_URL}" == https://github.com/MiSTer-devel/* ]]
					then
						BRANCH_NAME=${CORE_DEFAULT_BRANCHES["${ADDITIONAL_FILES_URL##*/}"]}
					else
						BRANCH_NAME=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "${ADDITIONAL_FILES_URL}/branches" | grep "branch-name" | head -n1 | sed 's/.*>\(.*\)<.*/\1/')
					fi
					ADDITIONAL_FILES_URL="${ADDITIONAL_FILES_URL}/file-list/${BRANCH_NAME}"
				fi
			fi
			CONTENT_HTML=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$ADDITIONAL_FILES_URL")
		else
			CONTENT_HTML="${RELEASES_HTML}"
		fi
		#ADDITIONAL_FILE_DATETIMES=$(echo "$CONTENT_TDS" | awk '/class="age">/,/<\/td>/' | tr -d '\n' | sed 's/ \{1,\}/+/g' | sed 's/<\/td>/\n/g')
		#ADDITIONAL_FILE_DATETIMES=$(echo "$CONTENT_TDS" | awk '/class="age">/,/<\/td>/' | tr -d '\n' | sed 's/ \{1,\}/+/g; s/<\/td>/\n/g')
		#ADDITIONAL_FILE_DATETIMES=$(echo "$CONTENT_TDS" | grep -oE 'datetime="[^"]*"' | sed 's/datetime="//; s/"/ /' | tr -d '\n')
		ADDITIONAL_FILE_DATETIMES=$(echo "$CONTENT_HTML" | grep -oE 'datetime="[^"]*' | sed 's/datetime="//')
		ADDITIONAL_FILE_DATETIMES=( $ADDITIONAL_FILE_DATETIMES )
		#for DATETIME_INDEX in "${!ADDITIONAL_FILE_DATETIMES[@]}"; do 
		#	ADDITIONAL_FILE_DATETIMES[$DATETIME_INDEX]=$(echo "${ADDITIONAL_FILE_DATETIMES[$DATETIME_INDEX]}" | grep -o "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}Z" )
		#	if [ "${ADDITIONAL_FILE_DATETIMES[$DATETIME_INDEX]}" == "" ]
		#	then
		#		ADDITIONAL_FILE_DATETIMES[$DATETIME_INDEX]="${ADDITIONAL_FILE_DATETIMES[$((DATETIME_INDEX-1))]}"
		#	fi
		#done
		#CONTENT_TDS=$(echo "$CONTENT_TDS" | awk '/class="content">/,/<\/td>/' | tr -d '\n' | sed 's/ \{1,\}/+/g' | sed 's/<\/td>/\n/g')
		#CONTENT_TDS=$(echo "$CONTENT_TDS" | awk '/class="content">/,/<\/td>/' | tr -d '\n' | sed 's/ \{1,\}/+/g; s/<\/td>/\n/g')
		#ADDITIONAL_FILE_URLS=$(echo "$CONTENT_HTML" | grep -oE 'js-navigation-open link-gray-dark[^>]*' | sed 's/.*href="//; s/"//')
		ADDITIONAL_FILE_URLS=$(echo "$CONTENT_HTML" | grep -oE 'js-navigation-open Link--primary[^>]*' | sed 's/.*href="//; s/"//')
		#ADDITIONAL_FILE_URLS=$(echo "$CONTENT_TDS" | grep -oE 'js-navigation-open link-gray-dark[^>]*')
		CONTENT_INDEX=0
		#for CONTENT_TD in $CONTENT_TDS; do
		for ADDITIONAL_FILE_URL in $ADDITIONAL_FILE_URLS; do
			#ADDITIONAL_FILE_URL=$(echo "$CONTENT_TD" | grep -o "href=\(\"\|\'\)[a-zA-Z0-9%&#;!()./_-]*\.$ADDITIONAL_FILES_EXTENSIONS\(\"\|\'\)" | sed "s/href=//g" | sed "s/\(\"\|\'\)//g")
			#ADDITIONAL_FILE_URL=$(echo "$CONTENT_TD" | grep -o "href=\(\"\|\'\)[a-zA-Z0-9%&#;!()./_-]*\.$ADDITIONAL_FILES_EXTENSIONS\(\"\|\'\)" | sed "s/href=//g; s/\(\"\|\'\)//g; s/&#39;/'/g")
			#ADDITIONAL_FILE_URL=$(echo "${ADDITIONAL_FILE_URL}" | grep -o "href=\(\"\|\'\)[a-zA-Z0-9%&#;!()./_-]*\.$ADDITIONAL_FILES_EXTENSIONS\(\"\|\'\)" | sed "s/href=//g; s/\(\"\|\'\)//g; s/&#39;/'/g")
			ADDITIONAL_FILE_URL=$(echo "${ADDITIONAL_FILE_URL}" | grep "\.$ADDITIONAL_FILES_EXTENSIONS$" | sed "s/&#39;/'/g")
			if [ "$ADDITIONAL_FILE_URL" != "" ]
			then
				#ADDITIONAL_FILE_NAME=$(echo "$ADDITIONAL_FILE_URL" | sed 's/.*\///g' | sed 's/%20/ /g; s/&#39;/'\''/g')
				#ADDITIONAL_FILE_NAME=$(echo "$ADDITIONAL_FILE_URL" | sed 's/.*\///g' | sed 's/%20/ /g')
				ADDITIONAL_FILE_NAME=$(echo "$ADDITIONAL_FILE_URL" | sed 's/.*\///g; s/%20/ /g; s/%2C/,/g; s/%5B/[/g; s/%5D/]/g; s/%26/\&/g'; s/   */ /g)
				ADDITIONAL_ONLINE_FILE_DATETIME=${ADDITIONAL_FILE_DATETIMES[$CONTENT_INDEX]}
				if [ -f "$CURRENT_DIR/$ADDITIONAL_FILE_NAME" ]
				then
					ADDITIONAL_LOCAL_FILE_DATETIME=$(date -d "$(stat -c %y "$CURRENT_DIR/$ADDITIONAL_FILE_NAME" 2>/dev/null)" -u +"%Y-%m-%dT%H:%M:%SZ")
				else
					ADDITIONAL_LOCAL_FILE_DATETIME=""
				fi
				
				#echo "---------"
				#echo "CONTENT_INDEX=${CONTENT_INDEX}"
				#echo "ADDITIONAL_FILE_URL=${ADDITIONAL_FILE_URL}"
				#echo "ADDITIONAL_ONLINE_FILE_DATETIME=${ADDITIONAL_ONLINE_FILE_DATETIME}"
				#echo "ADDITIONAL_FILE_NAME=${ADDITIONAL_FILE_NAME}"
				#echo "ADDITIONAL_LOCAL_FILE_DATETIME=${ADDITIONAL_LOCAL_FILE_DATETIME}"
				
				if [ "$ADDITIONAL_LOCAL_FILE_DATETIME" == "" ] || [[ "$ADDITIONAL_ONLINE_FILE_DATETIME" > "$ADDITIONAL_LOCAL_FILE_DATETIME" ]]
				then
					echo "Downloading $ADDITIONAL_FILE_NAME"
					[ "${SSH_CLIENT}" != "" ] && echo "URL: https://github.com$ADDITIONAL_FILE_URL?raw=true"
					mv "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}" "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
					if curl $CURL_RETRY $SSL_SECURITY_OPTION $([ "${PARALLEL_UPDATE}" == "true" ] && echo "-sS") -L "https://github.com$ADDITIONAL_FILE_URL?raw=true" -o "$CURRENT_DIR/$ADDITIONAL_FILE_NAME"
					then
						rm "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}.${TO_BE_DELETED_EXTENSION}" > /dev/null 2>&1
						if [[ "${ADDITIONAL_FILE_NAME}" =~ \.mra ]]
						then
							echo -n ", ${ADDITIONAL_FILE_NAME}" >> "${UPDATED_CORES_FILE}"
						else
							echo -n ", ${ADDITIONAL_FILE_NAME}" >> "${UPDATED_ADDITIONAL_REPOSITORIES_FILE}"
						fi
					else
						echo "${ADDITIONAL_FILE_NAME} download failed"
						echo "Restoring old ${ADDITIONAL_FILE_NAME} file"
						rm "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}" > /dev/null 2>&1
						mv "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}.${TO_BE_DELETED_EXTENSION}" "${CURRENT_DIR}/${ADDITIONAL_FILE_NAME}" > /dev/null 2>&1
						if [[ "${ADDITIONAL_FILE_NAME}" =~ \.mra ]]
						then
							echo -n ", ${ADDITIONAL_FILE_NAME}" >> "${ERROR_CORES_FILE}"
						else
							echo -n ", ${ADDITIONAL_FILE_NAME}" >> "${ERROR_ADDITIONAL_REPOSITORIES_FILE}"
						fi
						echo "If you experience frequent download errors"
						echo "maybe the parallel update is hitting your network too hard"
						echo "please try PARALLEL_UPDATE=\"false\" in"
						echo "${INI_PATH}"
					fi
					sync
					echo ""
				fi
			fi
			CONTENT_INDEX=$((CONTENT_INDEX+1))
		done
		echo ""
	fi
	
}

if [ "${CORE_CATEGORY_PATHS["cores"]}" != "" ]
then
	CORE_CATEGORY_PATHS["computer-cores"]="${CORE_CATEGORY_PATHS["cores"]}"
fi
REPOSITORIES_FILTER_REGEX="${REPOSITORIES_FILTER_REGEX/]cores)/]computer-cores)}"
CORE_CATEGORIES_FILTER_REGEX="${CORE_CATEGORIES_FILTER_REGEX/(cores)/(computer-cores)}"
REPOSITORIES_NEGATIVE_FILTER_REGEX="${REPOSITORIES_NEGATIVE_FILTER_REGEX/]cores)/]computer-cores)}"
CORE_CATEGORIES_NEGATIVE_FILTER_REGEX="${CORE_CATEGORIES_NEGATIVE_FILTER_REGEX/(cores)/(computer-cores)}"

for CORE_URL in $CORE_URLS; do
	if [[ $CORE_URL == https://* ]]
	then
		#if [ "$REPOSITORIES_FILTER" == "" ] || { echo "$CORE_URL" | grep -qi "$REPOSITORIES_FILTER";  } || { echo "$CORE_CATEGORY" | grep -qi "$CORE_CATEGORIES_FILTER";  }
		if [ "$REPOSITORIES_FILTER" == "" ] || [[ "${CORE_URL^^}" =~ ${REPOSITORIES_FILTER_REGEX^^} ]] || [[ "${CORE_CATEGORY^^}" =~ ${CORE_CATEGORIES_FILTER_REGEX^^} ]]
		then
			if [ "$REPOSITORIES_NEGATIVE_FILTER" == "" ] || { ! [[ "${CORE_URL^^}" =~ ${REPOSITORIES_NEGATIVE_FILTER_REGEX^^} ]] && ! [[ "${CORE_CATEGORY^^}" =~ ${CORE_CATEGORIES_NEGATIVE_FILTER_REGEX^^} ]]; }
			then
				if [ "$CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER" == "" ] || [[ "${CORE_URL^^}" =~ ${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER_REGEX^^} ]]
				then
					#if echo "$CORE_URL" | grep -qE "(SD-Installer)|(/Main_MiSTer$)|(/Menu_MiSTer$)"
					if [[ "${CORE_URL}"  =~ (SD-Installer)|(/Main_MiSTer$)|(/Menu_MiSTer$) ]]
					then
						checkCoreURL
					else
						[ "$PARALLEL_UPDATE" == "true" ] && { echo "$(checkCoreURL)"$'\n' & } || checkCoreURL
					fi
				fi
			fi
		fi
	else
		CORE_CATEGORY=$(echo "$CORE_URL" | sed 's/user-content-//g')
		#if [ "$CORE_CATEGORY" == "" ]
		#then
		#	CORE_CATEGORY="-"
		#fi
		#if [ "$CORE_CATEGORY" == "computer-cores" ] || [[ "$CORE_CATEGORY" =~ [a-z]+-comput[a-z]+ ]]
		#then
		#	CORE_CATEGORY="cores"
		#fi
		#if [[ "$CORE_CATEGORY" =~ console.* ]]
		#then
		#	CORE_CATEGORY="console-cores"
		#fi
		case "${CORE_URL}" in
			*comput*) CORE_CATEGORY="computer-cores" ;;
			*console*) CORE_CATEGORY="console-cores" ;;
			*other-systems*) CORE_CATEGORY="other-cores" ;;
			"") CORE_CATEGORY="-" ;;
			*) ;;
		esac
	fi
done
wait

if [ "${MAME_ALT_ROMS}" == "true" ]
then
	CORE_CATEGORY="-"
	CORE_URL="${MRA_ALT_URL}"
	if [ "$CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER" == "" ] || [[ "${CORE_URL^^}" =~ ${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER_REGEX^^} ]]
	then
		checkCoreURL
	fi
fi

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
	if [ "$CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER" == "" ] || [[ "${CORE_URL^^}" =~ ${CORE_CATEGORIES_LAST_SUCCESSFUL_RUN_FILTER_REGEX^^} ]]
	then
		checkCoreURL
	fi
fi

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
		for CURRENT_FILE in "${WORK_PATH}/mister_${MAPPING_KEY}_"*
		do
			if [ -f "${CURRENT_FILE}" ]
			then
				#if echo "${CURRENT_FILE}" | grep -qE "mister_[^_]+_[0-9]{8}.zip"
				if [[ "${CURRENT_FILE}" =~ mister_[^_]+_[0-9]{8}\.zip ]]
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
			if curl $CURL_RETRY $SSL_SECURITY_OPTION -L --cookie "challenge=BitMitigate.com" "${CHEAT_URL}" -o "${WORK_PATH}/${FILE_NAME}"
			then
				if [ ${DELETE_OLD_FILES} == "true" ]
				then
					echo "Deleting old mister_${MAPPING_KEY} files"
					rm "${WORK_PATH}/mister_${MAPPING_KEY}_"*.${TO_BE_DELETED_EXTENSION} > /dev/null 2>&1
				fi
				mkdir -p "${BASE_PATH}/cheats/${MAPPING_VALUE}"
				sync
				echo "Extracting ${FILE_NAME}"
				unzip -o "${WORK_PATH}/${FILE_NAME}" -d "${BASE_PATH}/cheats/${MAPPING_VALUE}" 1>&2
				rm "${WORK_PATH}/${FILE_NAME}" > /dev/null 2>&1
				touch "${WORK_PATH}/${FILE_NAME}" > /dev/null 2>&1
				echo -n ", ${FILE_NAME}" >> "${UPDATED_ADDITIONAL_REPOSITORIES_FILE}"
			else
				echo "${FILE_NAME} download failed"
				rm "${WORK_PATH}/${FILE_NAME}" > /dev/null 2>&1
				if [ ${DELETE_OLD_FILES} == "true" ]
				then
					echo "Restoring old mister_${MAPPING_KEY} files"
					for FILE_TO_BE_RESTORED in "${WORK_PATH}/mister_${MAPPING_KEY}_"*.${TO_BE_DELETED_EXTENSION}
					do
					  mv "${FILE_TO_BE_RESTORED}" "${FILE_TO_BE_RESTORED%.${TO_BE_DELETED_EXTENSION}}" > /dev/null 2>&1
					done
				fi
				echo -n ", ${FILE_NAME}" >> "${ERROR_ADDITIONAL_REPOSITORIES_FILE}"
				echo "If you experience frequent download errors"
				echo "maybe the parallel update is hitting your network too hard"
				echo "please try PARALLEL_UPDATE=\"false\" in"
				echo "${INI_PATH}"
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
	CHEAT_URLS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf --cookie "challenge=BitMitigate.com" "${CHEATS_URL}" | grep -oE '"mister_[^_]+_[0-9]{8}.zip"' | sed 's/"//g')
	for CHEAT_MAPPING in ${CHEAT_MAPPINGS}; do
		[ "$PARALLEL_UPDATE" == "true" ] && { echo "$(checkCheat)"$'\n' & } || checkCheat
	done
	wait
fi

EXIT_CODE=0
LOG_PATH="${WORK_PATH}/$(basename ${ORIGINAL_SCRIPT_PATH%.*}.log)"
echo "MiSTer Updater version ${UPDATER_VERSION}" > "${LOG_PATH}"
echo "started at ${UPDATE_START_DATETIME_LOCAL}" >> "${LOG_PATH}"
echo "" >> "${LOG_PATH}"
echo "Successfully updated cores:" >> "${LOG_PATH}"
if [ "$(cat "${UPDATED_CORES_FILE}")" != "" ]
then
	cat "${UPDATED_CORES_FILE}" | cut -c3- >> "${LOG_PATH}"
else
	echo "none" >> "${LOG_PATH}"
fi
rm "${UPDATED_CORES_FILE}" > /dev/null 2>&1
echo "" >> "${LOG_PATH}"
echo "Error updating these cores:" >> "${LOG_PATH}"
if [ "$(cat "${ERROR_CORES_FILE}")" != "" ]
then
	cat "${ERROR_CORES_FILE}" | cut -c3- >> "${LOG_PATH}"
	EXIT_CODE=100
else
	 echo "none" >> "${LOG_PATH}"
fi
rm "${ERROR_CORES_FILE}" > /dev/null 2>&1
echo "" >> "${LOG_PATH}"
echo "Successfully updated additional files:" >> "${LOG_PATH}"
if [ "$(cat "${UPDATED_ADDITIONAL_REPOSITORIES_FILE}")" != "" ]
then
	cat "${UPDATED_ADDITIONAL_REPOSITORIES_FILE}" | cut -c3- >> "${LOG_PATH}"
else
	 echo "none" >> "${LOG_PATH}"
fi
rm "${UPDATED_ADDITIONAL_REPOSITORIES_FILE}" > /dev/null 2>&1
echo "" >> "${LOG_PATH}"
echo "Error updating these additional files:" >> "${LOG_PATH}"
if [ "$(cat "${ERROR_ADDITIONAL_REPOSITORIES_FILE}")" != "" ]
then
	cat "${ERROR_ADDITIONAL_REPOSITORIES_FILE}" | cut -c3- >> "${LOG_PATH}"
	EXIT_CODE=100
else
	 echo "none" >> "${LOG_PATH}"
fi
rm "${ERROR_ADDITIONAL_REPOSITORIES_FILE}" > /dev/null 2>&1
if [ "${EXIT_CODE}" != "0" ] && [ "$PARALLEL_UPDATE" == "true" ]
then
	echo "" >> "${LOG_PATH}"
	echo "If you experience frequent download errors" >> "${LOG_PATH}"
	echo "maybe the parallel update is hitting your network too hard" >> "${LOG_PATH}"
	echo "please try PARALLEL_UPDATE=\"false\" in" >> "${LOG_PATH}"
	echo "${INI_PATH}" >> "${LOG_PATH}"
fi
echo "Updater log, see ${LOG_PATH}"
echo "==========================="
cat "${LOG_PATH}"
echo "==========================="
echo ""
if [ "${EXIT_CODE}" == "0" ]
then
	echo "${UPDATE_START_DATETIME_UTC}" > "${LAST_SUCCESSFUL_RUN_PATH}"
	#[ "${INI_DATETIME_UTC}" != "" ] && echo "${INI_DATETIME_UTC}" >> "${LAST_SUCCESSFUL_RUN_PATH}"
	echo "${INI_DATETIME_UTC}" >> "${LAST_SUCCESSFUL_RUN_PATH}"
	echo "${UPDATER_VERSION}" >> "${LAST_SUCCESSFUL_RUN_PATH}"
fi
sync

if [ "$SD_INSTALLER_PATH" != "" ]
then
	echo "Linux system must be updated"
	if [ ! -f "/media/fat/linux/unrar-nonfree" ]
	then
		UNRAR_DEB_URLS=$(curl $CURL_RETRY $SSL_SECURITY_OPTION -sSLf "$UNRAR_DEBS_URL" | grep -o '\"unrar[a-zA-Z0-9%./_+-]*_armhf\.deb\"' | sed 's/\"//g')
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
			if /media/fat/linux/unrar-nonfree x -y "$SD_INSTALLER_PATH" files/linux/* /media/fat/linux.update
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
				mv -f "/media/fat/linux.update/files/linux/linux.img" "/media/fat/linux/linux.img.new"
				mv -f "/media/fat/linux.update/files/linux/"* "/media/fat/linux/"
				rm -R "/media/fat/linux.update" > /dev/null 2>&1
				sync
				/media/fat/linux/updateboot
				sync
				mv -f "/media/fat/linux/linux.img.new" "/media/fat/linux/linux.img"
				sync
			else
				rm -R "/media/fat/linux.update" > /dev/null 2>&1
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

exit ${EXIT_CODE}
