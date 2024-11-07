#!/bin/bash

# Default settings
USER_ID="$(id -u)"
XAUTH=$HOME/.Xauthority

#RUNTIME=""
#DOCKER_VERSION=$(docker version --format '{{.Client.Version}}' | cut --delimiter=. --fields=1,2)
#if [[ $DOCKER_VERSION < "19.03" ]] && ! type nvidia-docker; then
#    RUNTIME="--gpus all"
#else
#    RUNTIME="--runtime=nvidia"
#fi

docker run \
    -it --rm \
    --volume=$(pwd)/autoware-contents:/home/autoware/autoware-contents:rw \
    --env="DISPLAY=${DISPLAY}" \
    --privileged \
    --network="host" \
    $RUNTIME \
    carla-autoware:latest
