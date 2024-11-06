#!/bin/bash

for file in $(find docker -name secrets.env); do
    sops decrypt $file > $(dirname $file)/.env
done