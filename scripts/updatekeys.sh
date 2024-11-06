#!/bin/bash

for file in $(find docker -name secrets.env); do
    sops updatekeys $file > $(dirname $file)/.env
done