#!/bin/bash
set -e

IMAGE_TAG=${IMAGE_TAG-latest}

docker pull registry.tld/conjur-appliance:${IMAGE_TAG}
docker save registry.tld/conjur-appliance:${IMAGE_TAG} > conjur-appliance.tar

packer build packer.json
