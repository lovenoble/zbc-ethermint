#!/bin/bash

set -x

LOCALNET_DIR=$(pwd)/localnet
BUILD_DIR=$LOCALNET_DIR/build
TARGET_NODE_IP_START=10
CHAIN=ethermint
CHAINID="$CHAIN"_9000-1

echo Prepare for validator run

TARGET_NODE_COUNT=$TARGET_NODE_IP_START
for i in $(ls $BUILD_DIR | grep 'node');do
    TARGET_NODE_IP="10.0.0.${TARGET_NODE_COUNT}"
    DIR_TO_UPLOAD=$BUILD_DIR/$i/ethermintd
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        ubuntu@$TARGET_NODE_IP "while ! sudo docker ps; do sleep 1; done; \
        echo $DOCKER_PULL_GITHUB_TOKEN | sudo docker login ghcr.io -u $DOCKER_PULL_GITHUB_USER --password-stdin; \
        sleep 1; \
        cp /home/ubuntu/ethermintd/docker-compose.yml /home/ubuntu; \
        cd /home/ubuntu; \
        mkdir /home/ubuntu/ethermintd/fhevm-keys; \
        stat /home/ubuntu/ethermintd/fhevm-keys/sks || curl 10.0.0.100/sks > /home/ubuntu/ethermintd/fhevm-keys/sks; \
        stat /home/ubuntu/ethermintd/fhevm-keys/pks || curl 10.0.0.100/pks > /home/ubuntu/ethermintd/fhevm-keys/pks; \
        sudo docker compose pull" &
    TARGET_NODE_COUNT=$(( TARGET_NODE_COUNT + 1 ))
done

wait

echo Run all images at once

TARGET_NODE_COUNT=$TARGET_NODE_IP_START
for i in $(ls $BUILD_DIR | grep 'node');do
    TARGET_NODE_IP="10.0.0.${TARGET_NODE_COUNT}"
    DIR_TO_UPLOAD=$BUILD_DIR/$i/ethermintd
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        ubuntu@$TARGET_NODE_IP "cd /home/ubuntu; sudo docker compose up -d" &
    TARGET_NODE_COUNT=$(( TARGET_NODE_COUNT + 1 ))
done

wait

# wait for validators to reach consensus
sleep 10;

echo Load orchestrator private keys into keyring

TARGET_NODE_COUNT=$TARGET_NODE_IP_START
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    ubuntu@10.0.0.10 "echo '$MNEMONIC' | \
    sudo docker exec -i ubuntu-validator-1 ethermintd \
    keys add orchestrator \
    --no-backup --chain-id '$CHAINID' \
    --keyring-backend test --recover &>/dev/null || true"

echo Fund fhevm test accounts

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    ubuntu@10.0.0.10 "
      sleep 2;
      sudo docker exec -i ubuntu-validator-1 python3 /root/.ethermintd/faucet.py 0xa5e1defb98EFe38EBb2D958CEe052410247F4c80;
      sleep 2;
      sudo docker exec -i ubuntu-validator-1 python3 /root/.ethermintd/faucet.py 0xfCefe53c7012a075b8a711df391100d9c431c468;
      sleep 2;
      sudo docker exec -i ubuntu-validator-1 python3 /root/.ethermintd/faucet.py 0xa44366bAA26296c1409AD1e284264212029F02f1;
      sleep 2;
      sudo docker exec -i ubuntu-validator-1 python3 /root/.ethermintd/faucet.py 0xc1d91b49A1B3D1324E93F86778C44a03f1063f1b;
      sleep 2;
      sudo docker exec -i ubuntu-validator-1 python3 /root/.ethermintd/faucet.py 0x305F1F471e9baCFF2b3549F9601f9A4BEafc94e1;
    "
