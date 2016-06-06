#!/bin/bash
set -ex

CONJUR_CLI_VERSION=${CONJUR_CLI_VERSION-'5.2.0'}
APPLIANCE_IMAGE_TAG=${APPLIANCE_IMAGE_TAG-latest}
DOCKER_VERSION='1.9.1-0~trusty'

# Install Docker
apt-key adv \
--keyserver hkp://p80.pool.sks-keyservers.net:80 \
--recv-keys 58118E89F3A912897C070ADBF76221572C52609D
bash -c 'echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list'
apt-get update
apt-get install -y linux-image-extra-$(uname -r)
apt-get install -y docker-engine=$DOCKER_VERSION
docker run --rm hello-world

# Enable the 'ubuntu' user to manage docker without sudo
usermod -a -G docker ubuntu

# Install fail2ban to stop malicious attackers
apt-get install -y fail2ban ntp

cli_dlpath='/tmp/conjur.deb'
wget -q \
"https://s3.amazonaws.com/conjur-releases/omnibus/conjur_${CONJUR_CLI_VERSION}-1_amd64.deb" -O ${cli_dlpath} && \
dpkg -i ${cli_dlpath} && \
rm -f ${cli_dlpath}

echo "Loading Conjur appliance image into Docker"
gzip -d /tmp/conjur-appliance.tar.gz # Unzip the tar.gz into a tar
docker load < '/tmp/conjur-appliance.tar'

container_name='conjur-appliance'

docker rm -f ${container_name} || true  # Try to remove the container, even if it doesn't exist

# Pull the Conjur UI, for caching
docker pull conjurinc/conjur-ui

# Start the appliance
cid=$(docker create \
--name ${container_name} \
--restart always \
--log-driver=syslog --log-opt tag="${container_name}" \
-v /var/log/conjur:/var/log/conjur \
-v /opt/conjur/backup:/opt/conjur/backup \
-p "443:443" -p "636:636" -p "5432:5432" -p "5433:5433" -p "127.0.0.1:38053:38053" \
registry.tld/conjur-appliance:${APPLIANCE_IMAGE_TAG})

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
