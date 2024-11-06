#!/bin/bash

for file in $(find docker -name docker-compose.yaml); do
    (
        cd $(dirname $file)
        docker compose up -d
    )
done