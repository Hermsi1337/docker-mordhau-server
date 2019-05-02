#!/usr/bin/env bash

set -e

function create_missing_dir {
    for DIRECTORY in ${@}; do
        [[ -n "${DIRECTORY}" ]] || return
        if [[ ! -d "${DIRECTORY}" ]]; then
            mkdir -p "${DIRECTORY}"
            echo "...successfully created ${DIRECTORY}"
        fi
    done
}

function copy_missing_file {
	SOURCE="${1}"
	DESTINATION="${2}"

	if [[ ! -f "${DESTINATION}" ]]; then
		cp -a "${SOURCE}" "${DESTINATION}"
		echo "...successfully copied ${SOURCE} to ${DESTINATION}"
	fi
}

if [[ ! "$(id -u "${STEAM_USER}")" -eq "${STEAM_UID}" ]] || [[ ! "$(id -g "${STEAM_GROUP}")" -eq "${STEAM_GID}" ]] ; then
	sudo usermod -o -u "${STEAM_UID}" "${STEAM_USER}"
	sudo groupmod -o -g "${STEAM_GID}" "${STEAM_GROUP}"
	sudo chown -R "${STEAM_USER}":"${STEAM_GROUP}" "${ARK_SERVER_VOLUME}" "${STEAM_HOME}"
fi

echo "_______________________________________"
echo ""
echo "# Mordhau Server - $(date)"
echo "# UID ${STEAM_UID} - GID ${STEAM_GID}"
echo "_______________________________________"

if [[ ! -f "${SERVER_VOLUME}/Mordhau/Saved/Config/LinuxServer/Game.ini" ]]; then
    export IS_FIRST_RUN="true"
    echo "This is your first run. Installing Mordhau. This may take a while..."
else
    echo "Mordhau is already installed. Checking if there is an update available..."
fi

bash $(command -v install-or-update.sh)

MORDHAU_SERVER="${SERVER_VOLUME}/MordhauServer.sh"
if [[ ! -x "${MORDHAU_SERVER}" ]]; then
    echo "Can not allocate MordhauServer.sh"
    echo "Failure!"
    exit 1
fi

cd "${SERVER_VOLUME}"

if [[ "${IS_FIRST_RUN}" == "true" ]]; then
    rm -f "${SERVER_VOLUME}/Mordhau/Saved/Config/LinuxServer/Game.ini"
    mkdir -p "${SERVER_VOLUME}/Mordhau/Saved/Config/LinuxServer"
    envsubst < "${TEMPLATE_VOLUME}/Game.ini.example" > "${SERVER_VOLUME}/Mordhau/Saved/Config/LinuxServer/Game.ini"
fi

exec ${MORDHAU_SERVER}