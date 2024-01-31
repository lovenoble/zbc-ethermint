#!/bin/bash

set -x

if [ -z "$REGION" ];
then
    echo "\$REGION environment variable is undefined"
    exit 1
fi

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
      sudo docker run -d \
        --network=host --name=testnet_kms \
        -v /home/ubuntu/fhevm-keys:/usr/src/kms-server/temp \
        --log-driver=awslogs \
        --log-opt awslogs-region=$REGION \
        --log-opt awslogs-group=zbc-prod-logs \
        --log-opt awslogs-stream=zbc-prod-kms-50 \
        --log-opt awslogs-create-group=true \
        $DOCKER_IMAGE"
