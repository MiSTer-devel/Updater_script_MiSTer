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

# Copyright 2019 Alessandro "Locutus73" Miele

# You can download the latest version of this script from:
# https://github.com/MiSTer-devel/Updater_script_MiSTer

# Version 2.0 - 2019-02-02 - Added ALLOW_INSECURE_SSH option: "true" will check if SSL certificate verification (see https://curl.haxx.se/docs/sslcerts.html ) is working (CA certificates installed) and when it's working it will use this feature for safe curl HTTPS downloads, otherwise it will use --insecure option for disabling SSL certificate verification. If CA certificates aren't installed it's advised to install them (i.e. using security_fixes.sh). "false" will never use --insecure option and if CA certificates aren't installed any download will fail.
# Version 1.0 - 2019-01-07 - First commit


#========= OPTIONS ==================
SCRIPT_URL="https://github.com/MiSTer-devel/Updater_script_MiSTer/blob/master/mister_updater.sh"

#========= ADVANCED OPTIONS =========
# ALLOW_INSECURE_SSH="true" will check if SSL certificate verification (see https://curl.haxx.se/docs/sslcerts.html )
# is working (CA certificates installed) and when it's working it will use this feature for safe curl HTTPS downloads,
# otherwise it will use --insecure option for disabling SSL certificate verification.
# If CA certificates aren't installed it's advised to install them (i.e. using security_fixes.sh).
# ALLOW_INSECURE_SSH="false" will never use --insecure option and if CA certificates aren't installed
# any download will fail.
ALLOW_INSECURE_SSH="true"

#========= CODE STARTS HERE =========
# get the name of the script, or of the parent script if called through a 'curl ... | bash -'
ORIGINAL_SCRIPT_PATH="${0}"
[[ "${ORIGINAL_SCRIPT_PATH}" == "bash" ]] && \
	ORIGINAL_SCRIPT_PATH="$(ps --no-headers --format comm= --pid ${PPID})"
INI_PATH=${ORIGINAL_SCRIPT_PATH%.*}.ini
if [[ -f ${INI_PATH} ]]
then
	eval "$(cat ${INI_PATH} | tr -d '\r')"
fi

SSL_SECURITY_OPTION=""
curl -q https://google.com > /dev/null 2>&1
case $? in
	0)
		;;
	60)
		if [[ "${ALLOW_INSECURE_SSH}" == "true" ]]
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

echo "Downloading and executing"
echo "${SCRIPT_URL/*\//}"
echo ""
curl \
	${SSL_SECURITY_OPTION} \
	--fail \
	--location \
	--silent \
	"${SCRIPT_URL}?raw=true" | \
	bash -

exit 0
