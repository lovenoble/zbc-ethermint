#!/bin/bash

cp .env.example .env
# TEST_CONTAINER_NAME=ethermintnodelocal0 npm run test:inband
TEST_CONTAINER_NAME=ethermintnodelocal0 npx hardhat test --grep "should mint the contract" 
