#!/bin/bash

FILE=$1
REPO_NAME=$2

sed -i 's/\.\.\/zbc-go-ethereum/\.\/work_dir\/zbc-go-ethereum/' $FILE
sed -i 's/\.\.\/fhevm-go/\.\/work_dir\/fhevm-go/' $FILE