# appliance-docker

Packages the Conjur Docker image into machine images for different platforms.

This project uses [packer](https://www.packer.io/) to create images that run
the Conjur appliance Docker image. Since we are using packer, images for several different
platforms can be built by adding to the `builders` section of [packer.json](packer.json).
[scripts/provision.sh](scripts/provision.sh) contains a series of bash commands that are
run to prepare the image.

Feel free to fork this repository and update the packer scripts
as needed to generate images for your platform.

## Platforms

### Amazon EC2

To build an AMI, run:

```
./build-ami.sh
```

### OpenStack

Modify [packer.json](packer.json) to use the
[OpenStack builder](https://www.packer.io/docs/builders/openstack.html).

---

## Development

You can test these scripts with Vagrant.

Set up your Docker registry proxy according to
[this doc](https://docs.google.com/document/d/1aNVKG_Yq74mdAheW5_v9YqwDtrGZuxPyx0TUY2jXwnw/edit).

```
IMAGE_TAG=${IMAGE_TAG-latest}

docker pull registry.tld/conjur-appliance:${IMAGE_TAG}
docker save registry.tld/conjur-appliance:${IMAGE_TAG} > conjur-appliance.tar

vagrant up
vagrant ssh -c "sudo apt-get update && sudo apt-get dist-upgrade -y" # choose /boot at the GRUB update menu
vagrant reload
vagrant ssh -c "sudo /vagrant/scripts/image-extra.sh"

vagrant ssh
  sudo su -
  cp /vagrant/conjur-appliance.tar /tmp/
  bash /vagrant/scripts/provision.sh

  hostname=conjur.docker
  password=secret
  orgaccount=dev
  docker exec conjur-appliance evoke configure master -h $hostname -p $password $orgaccount

  echo '127.0.0.1 conjur.docker' >> /etc/hosts
```

Logs are in `/var/log/upstart/conjur.log`.
