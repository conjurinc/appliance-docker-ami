#!/bin/bash

export PATH=/opt/conjur/bin:$PATH

APPLIANCE_IMAGE=${1}
APPLIANCE_IMAGE_TAG=${2}

summon ./build-ami.sh ${APPLIANCE_IMAGE} ${APPLIANCE_IMAGE_TAG}
