#!/bin/bash

git fetch
git pull

./scripts/decrypt.sh
./scripts/dockerup.sh