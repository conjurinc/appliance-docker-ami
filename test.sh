#!/bin/bash
# Usage: ./test.sh ami-b13170d4

set -exo pipefail

ami_id=${1}

finish() {
  code=$?
  # Bring down the AWS instance
  summon env AMI_ID=${ami_id} bash -c 'docker run \
      --rm \
      -v "$(pwd)":/opt/ \
      -w /opt/ \
      -e AMI_ID \
      -e AWS_ACCESS_KEY_ID \
      -e AWS_SECRET_ACCESS_KEY \
      -v "$SSH_KEY:/root/.ssh/id_rsa" \
      test-kitchen kitchen destroy'

  return ${code}
}
#trap finish EXIT

# Create a Test Kitchen container
docker build -t test-kitchen -f Dockerfile.testkitchen .

echo "Launching test instance from ${ami_id}"

# Converge Test Kitchen to bring up the CoreOS instance in AWS
summon env AMI_ID=${ami_id} bash -c 'docker run \
    --rm \
    -v "$(pwd)":/opt/ \
    -w /opt/ \
    -e AMI_ID \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -v "$SSH_KEY:/root/.ssh/id_rsa" \
    test-kitchen kitchen converge'

echo "Testing health endpoint"

public_hostname=$(cat .kitchen/default-coreos-stable.yml | grep hostname | awk -F ' ' '{print $2}')

sleep 5

response_code=$(curl -k -s -o health.response -w "%{http_code}" https://${public_hostname}/health)

if [ "${response_code}" != "200" ]; then
  echo "Expected 200"
  echo "Got ${response_code}"
  echo "-----"
  echo "$(cat health.response)"
  exit 1
fi

echo "PASSED!"
