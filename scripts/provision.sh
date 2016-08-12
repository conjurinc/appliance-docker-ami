#!/bin/bash
set -e

CONJUR_CLI_VERSION=${CONJUR_CLI_VERSION-'5.2.5'}
APPLIANCE_IMAGE_TAG=${APPLIANCE_IMAGE_TAG-latest}
DOCKER_VERSION='1.9.1-0~trusty'

BOXUSER=${1-'ubuntu'}

if ! docker info > /dev/null 2>&1; then
  # Install Docker
  apt-key adv \
  --keyserver hkp://p80.pool.sks-keyservers.net:80 \
  --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  bash -c 'echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list'
  apt-get update
  apt-get install -y linux-image-extra-$(uname -r)
  apt-get install -y docker-engine=$DOCKER_VERSION

  # Enable the 'ubuntu' or 'vagrant' user to manage docker without sudo
  usermod -a -G docker $BOXUSER
fi

# Install fail2ban to stop malicious attackers
apt-get install -y fail2ban ntp

if ! conjur > /dev/null 2>&1; then
  cli_dlpath='/tmp/conjur.deb'
  wget -q \
    "https://github.com/conjurinc/cli-ruby/releases/download/v$CONJUR_CLI_VERSION/conjur_$CONJUR_CLI_VERSION-1_amd64.deb" \
    -O ${cli_dlpath} && \
    dpkg -i ${cli_dlpath} && \
    rm -f ${cli_dlpath}
fi

if ! docker images | grep conjur; then
  echo "Loading Conjur appliance image into Docker"
  gzip -df /tmp/conjur-appliance.tar.gz # Unzip the tar.gz into a tar
  docker load -i /tmp/conjur-appliance.tar
fi

image_id=$(docker images -q)
container_name='conjur-appliance'

docker rm -f ${container_name} || true

# Start the appliance
cid=$(docker create \
--name ${container_name} \
--restart always \
--log-driver=syslog --log-opt tag="${container_name}" \
-v /var/log/conjur:/var/log/conjur \
-v /opt/conjur/backup:/opt/conjur/backup \
-p "443:443" -p "636:636" -p "5432:5432" -p "5433:5433" -p "127.0.0.1:38053:38053" \
$image_id)

# Clean up Docker tars, no longer needed
rm -f /tmp/conjur-appliance.tar*

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
