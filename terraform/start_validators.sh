#!/bin/bash

set -x

LOCALNET_DIR=$(pwd)/localnet
BUILD_DIR=$LOCALNET_DIR/build

echo "- Distribute final genesis.json to all validators"
TARGET_NODE_COUNT=10
for i in $(ls $BUILD_DIR | grep 'node');do
    TARGET_NODE_IP="10.0.0.${TARGET_NODE_COUNT}"
    DIR_TO_UPLOAD=$BUILD_DIR/$i/ethermintd
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        ubuntu@$TARGET_NODE_IP "while ! sudo docker ps; do sleep 1; done; \
        echo $DOCKER_PULL_GITHUB_TOKEN | sudo docker login ghcr.io -u $DOCKER_PULL_GITHUB_USER --password-stdin; \
        sleep 1; \
        cp /home/ubuntu/ethermintd/docker-compose.yml /home/ubuntu; \
        cd /home/ubuntu; \
        sudo docker compose up -d" &
    TARGET_NODE_COUNT=$(( TARGET_NODE_COUNT + 1 ))
done

wait
