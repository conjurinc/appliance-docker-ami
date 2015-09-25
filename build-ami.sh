#!/bin/bash
set -e

APPLIANCE_IMAGE=${APPLIANCE_IMAGE-registry.tld:80/conjur-appliance}
APPLIANCE_IMAGE_TAG=${APPLIANCE_IMAGE_TAG-latest}

IMAGE_TAG=${IMAGE_TAG-latest}

docker pull ${APPLIANCE_IMAGE}:${APPLIANCE_IMAGE_TAG}
docker save ${APPLIANCE_IMAGE}:${APPLIANCE_IMAGE_TAG} > conjur-appliance.tar

packer build packer.json
