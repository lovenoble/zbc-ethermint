#!/bin/bash

set -x

echo Prepare for validator run

DOCKER_IMAGE=ghcr.io/zama-ai/kms:v0.1.2
TARGET_NODE_IP="10.0.0.50"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    ubuntu@$TARGET_NODE_IP "while ! sudo docker ps; do sleep 1; done; \
    echo $DOCKER_PULL_GITHUB_TOKEN | sudo docker login ghcr.io -u $DOCKER_PULL_GITHUB_USER --password-stdin; \
    sleep 1; \
    mkdir /home/ubuntu/fhevm-keys; \
    stat /home/ubuntu/fhevm-keys/cks.bin || curl http://10.0.0.100/cks > /home/ubuntu/fhevm-keys/cks.bin; \
    ( sudo docker ps | grep testnet_kms ) || \
      sudo docker run -d --network=host --name=testnet_kms \
        -v /home/ubuntu/fhevm-keys:/usr/src/kms-server/temp \
        $DOCKER_IMAGE"
