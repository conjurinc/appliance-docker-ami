# appliance-docker
Docker build of the Conjur appliance

## AMI

To build an AMI, run:

```
./build-ami.sh
```

## Development

You can test these scripts with Vagrant.

Set up your Docker registry proxy according to
[this doc](https://docs.google.com/document/d/1aNVKG_Yq74mdAheW5_v9YqwDtrGZuxPyx0TUY2jXwnw/edit).

```
IMAGE_TAG=${IMAGE_TAG-latest}

docker pull registry.tld/conjur-appliance:${IMAGE_TAG}
docker save registry.tld/conjur-appliance:${IMAGE_TAG} > conjur-appliance.tar

vagrant up
vagrant ssh -c "sudo /vagrant/scripts/dist-upgrade.sh"
vagrant ssh -c "sudo /vagrant/scripts/image-extra.sh"
vagrant reload

vagrant ssh
  sudo su -
  bash /vagrant/scripts/provision.sh

  hostname=conjur.docker
  password=secret
  orgaccount=dev
  docker exec conjur-appliance evoke configure master -h $hostname -p $password $orgaccount

  echo '127.0.0.1 conjur.docker' >> /etc/hosts
```

Logs are in `/var/log/upstart/conjur.log`.
