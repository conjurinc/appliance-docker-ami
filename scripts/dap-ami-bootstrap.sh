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
container_name='dap'

docker rm -f ${container_name} > /dev/null 2>&1 || true

mkdir -p /var/log/conjur
mkdir -p /opt/conjur/backup

echo "Creating DAP container"
cid=$(docker create \
--name ${container_name} \
--privileged --restart unless-stopped \
--log-driver=journald \
--volume /var/log/conjur:/var/log/conjur:Z \
--volume /opt/conjur/backup:/opt/conjur/backup:Z \
--volume /opt/cyberark/dap/security:/opt/cyberark/dap/security:Z \
--security-opt seccomp:/opt/cyberark/dap/security/seccomp.json \
--publish "443:443" \
--publish "444:444" \
--publish "5432:5432" \
--publish "5433:5433" \
--publish "1999:1999" \
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

systemctl daemon-reload

systemctl enable /etc/systemd/system/dap.service

echo "DAP container ready (reboot, or use 'systemctl start dap' to start)"
