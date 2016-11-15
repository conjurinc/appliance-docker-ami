#!/bin/bash
set -ex

APPLIANCE_IMAGE=${1-registry.tld/conjur-appliance}
APPLIANCE_IMAGE_TAG=${2-latest}

if [ ! -f conjur-appliance.tar.gz ]; then
  docker pull ${APPLIANCE_IMAGE}:${APPLIANCE_IMAGE_TAG}
  docker save ${APPLIANCE_IMAGE}:${APPLIANCE_IMAGE_TAG} > conjur-appliance.tar
  gzip conjur-appliance.tar
fi

PACKER_LOG=1 packer build \
  -var "appliance_image_tag=${APPLIANCE_IMAGE_TAG}" \
  packer.json | tee packer.out
