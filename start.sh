#!/bin/bash

TRACE="--trace"
HOME_ETHERMINTD="$HOME/.incod"
ETHERMINTD="incod"
export FHEVM_GO_KEYS_DIR="$HOME_ETHERMINTD/keys/network-fhe-keys"

LOGLEVEL="info"
# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
$ETHERMINTD start --pruning=nothing $TRACE --log_level $LOGLEVEL \
        --minimum-gas-prices=0.0001ainco \
        --json-rpc.gas-cap=50000000 \
        --json-rpc.api eth,txpool,net,web3
