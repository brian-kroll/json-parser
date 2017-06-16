#!/usr/bin/env bash

EXTENSION_ID=""

## locations
#chrome:
CHROME_USR_LOCATION="/usr/share/google-chrome/extensions/"
CHROME_ETC_LOCATION="/opt/google/chrome/extensions/"

#chromium:
CHROMIUM_USR_LOCATION="/usr/share/chromium-browser/extensions/"
CHROMIUM_ETC_LOCATION="/etc/chromium-browser/extensions/"

####### install the preferences file for chrome to find #######################

passw=""
sudo_active=$(sudo -S -v >/dev/null 2>&1 <<<"${passw}"; echo $?)
if [[ $EUID -ne 0 ]] && [[ $sudo_active -ne 0 ]]; then
    echo "The install-script needs root privileges."
    read -rsp "Please enter your password (will not be shown): " passw
    echo ""
    success=$(sudo -S -v >/dev/null 2>&1 <<<"${passw}"; echo $?)
    if [[ $success -ne 0 ]]; then
        echo "Command 'sudo' was not successful - exiting."
        exit 1
    fi
fi

function test_if_installed () {
	$(which $1 > /dev/null 2>&1)
	local status=$?
	if [ ${status} -ne 0 ]; then
		echo 0
    else
    	echo 1
	fi
}

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#preferences file
PREFERENCES_FILE_NAME="${EXTENSION_ID}.json"
PREFERENCES_FILE_PATH="${SCRIPT_DIR}/${PREFERENCES_FILE_NAME}"
## check if chrome is installed
CHROME_INSTALLED=$(test_if_installed "google-chrome")

if  [ ${CHROME_INSTALLED} -eq 1 ]; then
	echo ""
	echo "Chrome was found - installing extension's preference file to"
	echo "   ${CHROME_USR_LOCATION}"
	echo "   ${CHROME_ETC_LOCATION}"
	(
		cd ${SCRIPT_DIR}
		## Attention: only tabs are allowed to indent HEREDOC
		sudo bash <<-"EOS"
	mkdir -p ${CHROME_USR_LOCATION}
	mkdir -p ${CHROME_ETC_LOCATION}
	cp ${PREFERENCES_FILE_PATH} ${CHROME_USR_LOCATION}
	cp ${PREFERENCES_FILE_PATH} ${CHROME_ETC_LOCATION}
	chmod +rx ${CHROME_USR_LOCATION}/${PREFERENCES_FILE_NAME}
	chmod +rx ${CHROME_ETC_LOCATION}/${PREFERENCES_FILE_NAME}
EOS
	)
	echo "If your chrome browser is currently running, restart it to enable the the extension."
	echo ""
fi

## check if chromium is installed
CHROMIUM_INSTALLED=$(test_if_installed "chromium-browser")
if  [ ${CHROMIUM_INSTALLED} -eq 1 ]; then
	echo ""
	echo "Chromium was found - installing extension's preference file to"
	echo "   ${CHROMIUM_USR_LOCATION}"
	echo "   ${CHROMIUM_ETC_LOCATION}"
	(
		cd ${SCRIPT_DIR}
		## Attention: only tabs are allowed to indent HEREDOC
		sudo bash <<-"EOS"
	mkdir -p ${CHROMIUM_USR_LOCATION}
	mkdir -p ${CHROMIUM_ETC_LOCATION}
	cp ${PREFERENCES_FILE_PATH} ${CHROMIUM_USR_LOCATION}
	cp ${PREFERENCES_FILE_PATH} ${CHROMIUM_ETC_LOCATION}
	chmod +rx ${CHROME_USR_LOCATION}/${PREFERENCES_FILE_NAME}
	chmod +rx ${CHROME_ETC_LOCATION}/${PREFERENCES_FILE_NAME}
EOS
	)
	echo "If your chromuim browser is currently running, restart it to enable the the extension."
	echo ""
fi

# close sudo-session if it was not active before
if [[ $sudo_active -ne 0 ]]; then
	sudo -k
fi
