#!/bin/bash -eu
# Usage: ./test.sh ami-b13170d4

ami_id=${1}

function finish {
  code=$?
  summon env AMI_ID=${ami_id} chef exec kitchen destroy
  return ${code}
}
trap finish EXIT

echo "Launching test instance from ${ami_id}"

summon env AMI_ID=${ami_id} chef exec kitchen converge

echo "Testing health endpoint"

public_hostname=$(cat .kitchen/default-ubuntu-1404.yml | grep hostname | awk -F ' ' '{print $2}')

sleep 5

response_code=$(curl -k -s -o health.response -w "%{http_code}" https://${public_hostname}/health)

if [ "${response_code}" != "200" ]; then
  echo "Expected 200"
  echo "Got ${response_code}"
  echo ""
  echo $(cat health.response)
  exit 1
fi

echo "PASSED!"
