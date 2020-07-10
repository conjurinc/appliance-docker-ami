#!/bin/bash
set -e

amazon-linux-extras install -y docker
systemctl enable docker
systemctl start docker

if ! docker images | grep appliance; then
  echo "Loading DAP appliance image into Docker"
  docker load -i /opt/dap-appliance.tar.gz
fi

image_id=$(docker images -q)
container_name='dap-appliance'

docker rm -f ${container_name} > /dev/null 2>&1 || true

mkdir -p /var/log/conjur
mkdir -p /opt/conjur/backup

echo "Creating DAP container"
cid=$(docker create \
--name ${container_name} \
--privileged --restart always \
--log-driver=journald \
-v /var/log/conjur:/var/log/conjur \
-v /opt/conjur/backup:/opt/conjur/backup \
-p "443:443" \
-p "444:444" \
-p "636:636" \
-p "5432:5432" \
-p "5433:5433" \
-p "1999:1999" \
-p "127.0.0.1:38053:38053" \
$image_id)

cat << CONF > /etc/systemd/system/dap.service
[Unit]
Description=DAP
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
ExecStart=/usr/bin/docker start -a ${container_name}
ExecStop=-/usr/bin/docker stop ${container_name}

[Install]
WantedBy=multi-user.target
CONF

systemctl enable /etc/systemd/system/dap.service

systemctl daemon-reload

echo "DAP container ready (reboot, or use 'systemctl start dap' to start)"
