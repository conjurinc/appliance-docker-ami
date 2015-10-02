#!/bin/bash
set -ex

export PATH=/opt/conjur/bin:$PATH

APPLIANCE_IMAGE=${1}
APPLIANCE_IMAGE_TAG=${2}

summon ./build-ami.sh ${APPLIANCE_IMAGE} ${APPLIANCE_IMAGE_TAG}

ami_id=$(tail -2 packer.out | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }')
touch $ami_id

./test.sh ${ami_id}
