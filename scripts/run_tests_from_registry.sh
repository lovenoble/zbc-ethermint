#!/bin/bash

cp .env.example .env
TEST_CONTAINER_NAME=ethermintnode0 npm run test:inband
