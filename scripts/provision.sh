#!/bin/bash

set -e

CONJUR_CLI_VERSION='4.27.0'

# Install Docker
apt-key adv \
--keyserver hkp://p80.pool.sks-keyservers.net:80 \
--recv-keys 58118E89F3A912897C070ADBF76221572C52609D

bash -c 'echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list'

apt-get update

apt-get install -y docker-engine

cli_dlpath='/tmp/conjur.deb'
wget -q \
"https://s3.amazonaws.com/conjur-releases/omnibus/conjur_${CONJUR_CLI_VERSION}-1_amd64.deb" -O ${cli_dlpath} && \
dpkg -i ${cli_dlpath} && \
rm -f ${cli_dlpath}

echo "Loading Conjur appliance image into Docker"
docker load < '/tmp/conjur-appliance.tar'

container_name='conjur-appliance'

docker rm -f ${container_name} || true  # Try to remove the container, even if it doesn't exist
docker create \
--name ${container_name} \
--restart always \
registry.tld/conjur-appliance

cat << CONF > /etc/init/conjur.conf
description "Conjur server"
author "ConjurInc"
start on filesystem and started docker
stop on runlevel [!2345]
respawn
script
  /usr/bin/docker start -a ${container_name}
end script
CONF

service conjur restart
