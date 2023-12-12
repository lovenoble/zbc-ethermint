#!/bin/bash

set -x

LOCALNET_DIR=$(pwd)/localnet
BUILD_DIR=$LOCALNET_DIR/build

echo "- Distribute final genesis.json to all validators"
TARGET_NODE_COUNT=10
for i in $(ls $BUILD_DIR | grep 'node');do
    TARGET_NODE_IP="10.0.0.${TARGET_NODE_COUNT}"
    DIR_TO_UPLOAD=$BUILD_DIR/$i/ethermintd
    rsync -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
        -avz $DIR_TO_UPLOAD ubuntu@$TARGET_NODE_IP:/home/ubuntu/
    TARGET_NODE_COUNT=$(( TARGET_NODE_COUNT + 1 ))
done
