#!/bin/bash

FILE=$1
REPO_NAME=zbc-go-ethereum

grep -n "zama.ai/$REPO_NAME" "$FILE" | cut -d: -f1 | xargs -I{} sed -i -e "{}s/=>.*/=> .\/work_dir\/$REPO_NAME/" "$FILE"

# fhevm go
sed -i -E "/PLACEHOLDER_FHEVM_GO/s|// PLACEHOLDER_FHEVM_GO.*|$(grep 'fhevm-go' "$FILE" ) => ./work_dir/fhevm-go|" "$FILE" 