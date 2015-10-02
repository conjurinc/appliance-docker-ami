#!/bin/bash -eu
# Usage: ./test.sh ami-b13170d4

ami_id=${1}

function finish {
  code=$?
  conjur env run -c secrets.yml -- env AMI_ID=${ami_id} kitchen destroy
  return ${code}
}
trap finish EXIT

echo "Launching test instance from ${ami_id}"

conjur env run -c secrets.yml -- env AMI_ID=${ami_id} kitchen converge

echo "Testing health endpoint"

public_hostname=$(cat .kitchen/default-ubuntu-1404.yml | grep hostname | awk -F ' ' '{print $2}')

resp=$(curl -sSk https://${public_hostname}/health)
good_resp='{"services":{"host-factory":"ok","core":"ok","pubkeys":"ok","audit":"ok","authz":"ok","authn":"ok","ldap":"ok","ok":true},"database":{"ok":true,"connect":{"main":"ok"}},"ok":true}'

if [ "${resp}" != "${good_resp}" ]; then
  echo -e "Expected \n ${good_resp}"
  echo -e "Got \n ${resp}"
  exit 1
fi

echo "PASSED!"
