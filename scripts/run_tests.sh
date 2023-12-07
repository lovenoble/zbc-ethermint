#!/bin/bash

cp .env.example .env
TEST_CONTAINER_NAME=ethermintnodelocal0 npm run test:inband
