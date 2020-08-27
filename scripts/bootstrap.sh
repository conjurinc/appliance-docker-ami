#!/bin/bash
set -e

systemctl stop rpcbind
systemctl mask rpcbind
systemctl stop rpcbind.socket
systemctl mask rpcbind.socket

amazon-linux-extras install -y docker
systemctl enable docker
systemctl start docker

if ! docker images | grep conjur; then
  echo "Loading Conjur appliance image into Docker"
  gzip -df /home/ec2-user/conjur-appliance.tar.gz # Unzip the tar.gz into a tar
  docker load -i /home/ec2-user/conjur-appliance.tar
fi

image_id=$(docker images -q)
container_name='conjur-appliance'

docker rm -f ${container_name} > /dev/null 2>&1 || true

mkdir -p /var/log/conjur
mkdir -p /opt/conjur/backup

echo "Creating Conjur container"
cid=$(docker create \
--name ${container_name} \
--privileged --restart always \
--log-driver=journald \
-v /var/log/conjur:/var/log/conjur \
-v /opt/conjur/backup:/opt/conjur/backup \
-p "443:443" \
-p "636:636" \
-p "5432:5432" \
-p "5433:5433" \
-p "1999:1999" \
-p "127.0.0.1:38053:38053" \
$image_id)

cat << CONF > /etc/systemd/system/conjur.service
[Unit]
Description=Conjur
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
ExecStart=/usr/bin/docker start -a ${container_name}
ExecStop=-/usr/bin/docker stop ${container_name}

[Install]
WantedBy=multi-user.target
CONF

systemctl daemon-reload


systemctl enable /etc/systemd/system/conjur.service


echo "Conjur container ready"
