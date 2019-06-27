ARG         DEBIAN_VERSION="${DEBIAN_VERSION:-stretch}"
FROM        debian:${DEBIAN_VERSION}-slim

LABEL       MAINTAINER="https://github.com/Hermsi1337/"

ENV         LANG="en_US.UTF-8" \
            LANGUAGE="en_US:en" \
            LC_ALL="en_US.UTF-8" \
            TERM="linux" \
            MAX_PLAYERS="20" \
            SESSION_NAME="Dockerized Mordhau Server by github.com/Hermsi1337" \
            SERVER_PASSWORD="YouSh4llNotP4SS" \
            ADMIN_PASSWORD="Th1sShouldB3ch4ng3d" \
            BANNED_PLAYERS="" \
            SERVER_VOLUME="/app" \
            TEMPLATE_VOLUME="/templates" \
            GAME_CLIENT_PORT="7777" \
            PEER_PORT="7778" \
            SERVER_LIST_PORT="27015" \
            BEACON_PORT="15000" \
            STEAM_USER="steam" \
            STEAM_GROUP="steam" \
            STEAM_UID="1000" \
            STEAM_GID="1000" \
            STEAM_HOME="/home/steam"

RUN         set -x && \
            apt-get -qq update && apt-get -qq upgrade && \
            apt-get -qq install curl lib32gcc1 lsof perl-modules libc6-i386 bzip2 bash-completion locales sudo gettext-base && \
            sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen && \
            addgroup --gid ${STEAM_GID} ${STEAM_USER} && \
            adduser --home ${STEAM_HOME} --uid ${STEAM_UID} --gid ${STEAM_GID} --disabled-login --shell /bin/bash --gecos "" ${STEAM_USER} && \
            echo "${STEAM_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
            usermod -a -G sudo ${STEAM_USER} && \
            mkdir -p ${SERVER_VOLUME} ${STEAM_HOME}/steamcmd && \
            curl -L http://media.steampowered.com/installer/steamcmd_linux.tar.gz \
                | tar -xvzf - -C ${STEAM_HOME}/steamcmd/ && \
            bash -x ${STEAM_HOME}/steamcmd/steamcmd.sh +login anonymous +quit && \
            chown -R ${STEAM_USER}:${STEAM_GROUP} ${SERVER_VOLUME} && \
            chmod 755 /root/ && \
            apt-get -qq autoclean && apt-get -qq autoremove && apt-get -qq clean && \
            rm -rf /tmp/* /var/cache/apt/*

COPY        bin/    /usr/local/bin/
COPY        conf.d/ /templates/
EXPOSE      ${GAME_CLIENT_PORT}/udp ${SERVER_LIST_PORT}/udp ${BEACON_PORT}/udp ${PEER_PORT}/udp

VOLUME      ["${SERVER_VOLUME}"]
WORKDIR     ${SERVER_VOLUME}

USER        ${STEAM_USER}
ENTRYPOINT  ["entrypoint.sh"]
