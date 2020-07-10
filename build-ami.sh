#!/bin/bash
set -exuo pipefail

IMAGE="$1"  # ex: registry.tld/conjur-appliance:5.0-stable
TAG="${IMAGE##*:}"

if [ ! -f dap-appliance.tar.gz ]; then
  docker pull $IMAGE
  docker save $IMAGE | gzip > dap-appliance.tar.gz
fi

echo "Fetching latest Amazon Linux 2 AMI..."
export AMI=$(summon docker run --rm -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY \
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
    -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e SSH_KEY -e AMI \
    hashicorp/packer:light build -var "appliance_image_tag=$TAG" /opt/packer.json | tee packer.out

# write the AMI ID to files for smoke tests archiving
ami_id=$(tail -2 packer.out | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }')
echo -n "$ami_id" > AMI
touch $ami_id
