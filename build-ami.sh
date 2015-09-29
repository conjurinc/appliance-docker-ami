#!/bin/bash
set -e

APPLIANCE_IMAGE=${1-registry.tld/conjur-appliance}
APPLIANCE_IMAGE_TAG=${2-latest}

IMAGE_TAG=${IMAGE_TAG-latest}

docker pull ${APPLIANCE_IMAGE}:${APPLIANCE_IMAGE_TAG}
docker save ${APPLIANCE_IMAGE}:${APPLIANCE_IMAGE_TAG} > conjur-appliance.tar

packer build packer.json
