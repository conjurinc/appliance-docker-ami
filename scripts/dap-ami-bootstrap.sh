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

mkdir -p /var/log/dap
mkdir -p /opt/cyberark/dap/{security,configuration,backup,seeds}

echo "Creating DAP container"
cid=$(docker create \
--name ${container_name} \
--restart unless-stopped \
--detach \
--log-driver=journald \
--security-opt seccomp:/opt/cyberark/dap/security/seccomp.json \
--volume /opt/cyberark/dap/configuration:/opt/cyberark/dap/configuration:Z \
--volume /opt/cyberark/dap/security:/opt/cyberark/dap/security:Z \
--volume /opt/cyberark/dap/backups:/opt/conjur/backup:Z \
--volume /opt/cyberark/dap/seeds:/opt/cyberark/dap/seeds:Z \
--volume /var/log/dap:/var/log/conjur:Z \
--publish "443:443" \
--publish "444:444" \
--publish "1999:1999" \
--publish "5432:5432" \
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
