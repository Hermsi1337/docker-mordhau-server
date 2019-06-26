[![Build Status](https://travis-ci.com/Hermsi1337/docker-mordhau-server.svg?branch=master)](https://travis-ci.com/Hermsi1337/docker-mordhau-server)

# Mordhau-Server dockerized

## Usage
### Configuration
You can configure the initial configuration for your mordhau-server by using environment variables:   


| Variable | Default value | Explanation |
|:-----------------:|:----------------------------------------------:|:------------------------------------------------------------------------------------------------------------------------------------:|
| SESSION_NAME | Dockerized Mordhau Server by github.com/Hermsi1337 | The name of your Mordhau-session which is visible in game when searching for servers |
| SERVER_PASSWORD | YouSh4llNotP4SS | Server password which is required to join your session. (overwrite with empty string if you want to disable password authentication) |
| ADMIN_PASSWORD | Th1sShouldB3ch4ng3d | Admin-password in order to access the admin console |
| MAX_PLAYERS | 20 | Maximum number of players to join your session |
| SERVER_VOLUME | /app | Path where the server-files are stored |
| GAME_CLIENT_PORT | 7777 | Exposed game-client port |
| SERVER_LIST_PORT | 27015 | Exposed server-list port |

### Get things running
#### `docker-run`
I personally preffer `docker-compose` but for those of you, who want to run their own Mordhau-server without any "zip and zap", here you go:
```bash
$ docker run -d --name="mordhau_server" --restart=always -v "${HOME}/mordhau-server:/app" -p 7777:7777 -p 27015:27015 -e SESSION_NAME="Awesome Mordhau is awesome" -e ADMIN_PASSWORD="FooB4r"
```

#### `docker-compose`
In order to startup your own Mordhau-server with `docker-compose` - which I personally preffer over a simple `docker run` - you may adapt the following `docker-compose.yml`:
```yaml
version: '3'

volumes:
  server-data:

services:
  server:
    restart: always
    container_name: ${COMPOSE_PROJECT_NAME}_server
    image: hermsi/mordhau-server:latest
    # If you want to build from fresh source every "docker-compose up" ...
    # ... remove the "image:"-key and uncomment the following two lines:
    #build:
    #  context: ../.
    volumes:
      - server-data:/app
    environment:
      - SESSION_NAME=${SESSION_NAME}
      - SERVER_PASSWORD=${SERVER_PASSWORD}
      - ADMIN_PASSWORD=${ADMIN_PASSWORD}
      - MAX_PLAYERS=${MAX_PLAYERS}
    ports:
      # Game client port:
      - "7777:7777/udp"
      # Peer port:
      - "7778:7778/udp"
      # Beacon port:
      - "15000:15000/udp"
      # Steam server-list port:
      - "27015:27015/udp"
    networks:
      - default
```

### Tweaking
After your container is up and Mordhau is installed you can start tweaking your configuration.   
The main configuration-file is located inside your `$SERVER_VOLUME`: `Mordhau/Saved/Config/LinuxServer/Game.ini`.   
A very good explanation on what you can configure can be found [here](https://mordhau.com/forum/topic/10348/dedicated-server-hosting-guide-linux/#configuring-and-running-the-server)   
After you've made your changes, restart the container in order to load the new configuration.

