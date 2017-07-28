#!/bin/bash
set -ex

APPLIANCE_IMAGE=${1-registry.tld/conjur-appliance}
APPLIANCE_IMAGE_TAG=${2-latest}

if [ ! -f conjur-appliance.tar.gz ]; then
  docker pull ${APPLIANCE_IMAGE}:${APPLIANCE_IMAGE_TAG}
  docker save ${APPLIANCE_IMAGE}:${APPLIANCE_IMAGE_TAG} > conjur-appliance.tar
  gzip conjur-appliance.tar
fi

PACKER_LOG=1 summon packer build \
  -var "appliance_image_tag=${APPLIANCE_IMAGE_TAG}" \
  packer.json | tee packer.out

ami_id=$(tail -2 packer.out | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }')
echo -n "$ami_id" > AMI
touch $ami_id
