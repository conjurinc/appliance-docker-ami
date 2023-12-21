#!/bin/bash
set -exuo pipefail

IMAGE="$1"  # ex: registry.tld/conjur-appliance:4.9-stable
TAG="${IMAGE##*:}"

if [ ! -f conjur-appliance.tar.gz ]; then
  docker pull $IMAGE
  docker save $IMAGE > conjur-appliance.tar
  gzip conjur-appliance.tar
fi

echo "Fetching latest Amazon Linux 2 AMI..."
export AMI=$(summon docker run --rm --env-file @SUMMONENVFILE \
  mesosphere/aws-cli ec2 describe-images --filters '[
    {"Name": "owner-id", "Values": ["137112412989"] },
    {"Name": "name", "Values": ["amzn2-ami-hvm-2.0*"] },
    {"Name": "virtualization-type", "Values": ["hvm"] },
    {"Name": "architecture", "Values": ["x86_64"] },
    {"Name": "hypervisor", "Values": ["xen"] },
    {"Name": "root-device-type", "Values": ["ebs"] },
    {"Name": "state", "Values": ["available"] }
    ]' \
    --query 'reverse(sort_by(Images, &CreationDate))[:1].ImageId | [0]' \
    --region us-east-1 \
    --output text
  )
echo "AMI: $AMI"
echo "Starting build"

export PACKER_LOG=1
summon docker run \
    -v $(pwd):/opt/ \
    --env-file @SUMMONENVFILE -e AMI \
    hashicorp/packer:full build -var "appliance_image_tag=$TAG" /opt/packer.json | tee packer.out

# write the AMI ID to files for smoke tests archiving
ami_id=$(tail -3 packer.out | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }')
echo -n "$ami_id" > AMI
touch $ami_id
