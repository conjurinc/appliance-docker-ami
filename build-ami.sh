#!/bin/bash
set -exuo pipefail

IMAGE="$1"  # ex: registry.tld/conjur-appliance:4.9-stable
TAG="${IMAGE##*:}"

if [ ! -f conjur-appliance.tar.gz ]; then
  docker pull $IMAGE
  docker save $IMAGE > conjur-appliance.tar
  gzip conjur-appliance.tar
else
  # If we didn't pull the docker image because
  # an archive existed locally, load it
  # so we can extract the pas releas file.
  IMAGE="$(docker load < conjur-appliance.tar.gz|sed 's/^Loaded image: //')"
fi

get_file_contents_from_image(){
  local image="${1}"
  local path="${2}"
  docker run \
  --rm \
  --entrypoint bash \
  ${image} \
    -c "cat ${path}"
}

# Extract versions from the docker image
conjur_version="$(get_file_contents_from_image ${IMAGE} /opt/conjur/possum/VERSION)"
appliance_version="$(get_file_contents_from_image ${IMAGE} /opt/conjur/etc/VERSION)"
pas_version="$(get_file_contents_from_image ${IMAGE} /opt/conjur/etc/PAS_RELEASE)"

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
    hashicorp/packer:full build \
      -var "appliance_image_tag=$TAG" \
      -var "conjur_version=${conjur_version}" \
      -var "appliance_version=${appliance_version}" \
      -var "pas_version=${pas_version}" \
      /opt/packer.json \
        | tee packer.out

# write the AMI ID to files for smoke tests archiving
ami_id=$(tail -3 packer.out | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }')
echo -n "$ami_id" > AMI
touch $ami_id
