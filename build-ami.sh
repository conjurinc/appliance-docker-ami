#!/usr/bin/env bash -e

conjur proxy -p9909 https://docker-registry.itci.conjur.net > /dev/null 2>&1 &
proxy_pid=$!

sleep 5
docker -H localhost:9909 pull conjurinc-appliance:latest
# conjur env run -c secrets.yml -- packer build packer.json

sudo kill $proxy_pid