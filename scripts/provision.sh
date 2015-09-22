#!/bin/bash

set -e

# Install Docker
apt-key adv \
--keyserver hkp://p80.pool.sks-keyservers.net:80 \
--recv-keys 58118E89F3A912897C070ADBF76221572C52609D

bash -c 'echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list'

apt-get update

apt-get install -y docker-engine

echo "Loading Conjur appliance image into Docker"
docker load < '/tmp/conjur-appliance.tar'

cat << CONF > /etc/init/conjur.conf
description "Conjur server"
author "ConjurInc"
start on filesystem and started docker
stop on runlevel [!2345]
respawn
script
  /usr/bin/docker run \
  --rm --name=conjur-appliance \
  registry.tld/conjur-appliance
end script
CONF
