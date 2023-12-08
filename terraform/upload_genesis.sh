#!/bin/bash

set -x

CHAIN=evmos
DENOM=aevmos

CHAINID="$CHAIN"_9000-1
CHAIND=/Users/deividas/projects/evmos-orig/build/evmosd
MONIKER="orchestrator"

# Orchestrator account
KEY="orchestrator"
MNEMONIC="stumble tilt business detect father ticket major inner awake jeans name vibrant tribe pause crunch sad wine muscle hidden pumpkin inject segment rocket silver"

LOCALNET_DIR=$(pwd)/localnet
BUILD_DIR=$LOCALNET_DIR/build
STARTING_IP=10.0.0.10

# TODO uncomment this when issue https://github.com/evmos/ethermint/issues/1579 is solved
# DATA_DIR=$BUILD_DIR/node4/$CHAIND
DATA_DIR=$BUILD_DIR/node4/evmosd

CONF_DIR=$DATA_DIR/config
GENESIS=$CONF_DIR/genesis.json
TEMP_GENESIS=$CONF_DIR/tmp_genesis.json
CONFIG=$CONF_DIR/config.toml
# TODO: workout gas supply for genesis
NODE_COUNT=4

echo "- Distribute final genesis.json to all validators"
TARGET_NODE_COUNT=10
for i in $(ls $BUILD_DIR | grep 'node');do
    TARGET_NODE_IP="10.0.0.${TARGET_NODE_COUNT}"
    DIR_TO_UPLOAD=$BUILD_DIR/$i/evmosd
    rsync -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
        -avz --delete $DIR_TO_UPLOAD ubuntu@$TARGET_NODE_IP:/home/ubuntu/
    TARGET_NODE_COUNT=$(( TARGET_NODE_COUNT + 1 ))
done
