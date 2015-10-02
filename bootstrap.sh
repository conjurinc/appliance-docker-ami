#!/bin/bash -e

hostname=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
password=testing
orgaccount=kitchen

docker exec conjur-appliance evoke configure master -h $hostname -p $password $orgaccount
