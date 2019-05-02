#!/usr/bin/env bash

STEAM_CMD="${STEAM_HOME}/steamcmd/steamcmd.sh"
if [[ ! -x "${STEAM_CMD}" ]]; then
    echo "Can not allocate steamcmd.sh"
    echo "Failure!"
    exit 1
fi

bash ${STEAM_CMD} +login anonymous +force_install_dir ${SERVER_VOLUME} +app_update 629800 validate +quit