#!/bin/bash

# Default settings
USER_ID="$(id -u)"
XAUTH=$HOME/.Xauthority

#DOCKER_VERSION=$(docker version --format '{{.Client.Version}}' | cut --delimiter=. --fields=1,2)
#    if [[ $DOCKER_VERSION < "19.03" ]]; then
#        if command -v nvidia-docker &> /dev/null; then
#            RUNTIME="--runtime=nvidia"
#        else
#            echo "Warning: nvidia-docker is not installed. Running without GPU support."
#            RUNTIME=""
#        fi
#    else
#        RUNTIME="--gpus all"
#    fi

docker run \
    -it --rm \
    --volume=$(pwd)/autoware-contents:/home/autoware/autoware-contents:rw \
    --env="DISPLAY=${DISPLAY}" \
    --privileged \
    --network="host" \
    $RUNTIME \
    carla-autoware:latest
