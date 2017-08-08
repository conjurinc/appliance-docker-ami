#!/bin/bash
set -exu

IMAGE="$1"  # ex: registry.tld/conjur-appliance:4.9-stable
TAG="${IMAGE##*:}"

if [ ! -f conjur-appliance.tar.gz ]; then
  docker pull $IMAGE
  docker save $IMAGE > conjur-appliance.tar
  gzip conjur-appliance.tar
fi

export PACKER_LOG=1
# summon packer build -var "appliance_image_tag=$TAG" packer.json | tee packer.out
summon docker run \
    -it \
    -v $(pwd):/opt/ \
    --env-file @SUMMONENVFILE \
    hashicorp/packer:light build -var "appliance_image_tag=$TAG" /opt/packer.json | tee packer.out

# write the AMI ID to files for smoke tests archiving
ami_id=$(tail -2 packer.out | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }')
echo -n "$ami_id" > AMI
touch $ami_id
