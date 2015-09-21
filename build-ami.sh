#!/usr/bin/env bash -e
IMAGE_TAG=${IMAGE_TAG-latest}

docker pull registry.tld/conjur-appliance:${IMAGE_TAG}
imageid=$(docker images | grep -E "^registry.tld/conjur-appliance.*${IMAGE_TAG}" | awk '{print $3}')
docker save ${imageid} > conjur-appliance.tar

packer build packer.json
