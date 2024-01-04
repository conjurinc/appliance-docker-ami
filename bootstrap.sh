#!/bin/bash -e

# Used by test-kitchen, converge looks for 'bootstrap.sh' by default
# Runs via sudo by default

echo "Running bootstrap.sh as ${USER}..."

echo "Waiting for container to be ready (TODO switch to polling)"
sleep 60

echo "Fetching instance hostname..."
hostname=$(curl -s http://169.254.169.254/latest/meta-data/hostname)
password=TestingAMI-12!
orgaccount=kitchen

echo "Configuring for master..."
docker exec conjur-appliance evoke configure master --accept-eula -h $hostname -p $password $orgaccount
