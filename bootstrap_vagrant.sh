#!/bin/bash -e

hostname='conjur.docker'
password='vagrant'
orgaccount='vagrant'

if ! docker ps | grep conjur; then
  docker start conjur-appliance
  docker exec conjur-appliance evoke configure master -h $hostname -p $password $orgaccount

  echo '127.0.0.1 conjur.docker' >> /etc/hosts
  echo 'yes' | conjur init -h conjur.docker
fi

conjur authn login -u admin -p vagrant
