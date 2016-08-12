# appliance-docker

Packages the Conjur Docker image into machine images for different platforms.

This project uses [packer](https://www.packer.io/) to create images that run
the Conjur appliance Docker image. Since we are using packer, images for several different
platforms can be built by adding to the `builders` section of [packer.json](packer.json).
[scripts/provision.sh](scripts/provision.sh) contains a series of bash commands that are
run to prepare the image.

Feel free to fork this repository and update the packer scripts
as needed to generate images for your platform.

## Prerequisites

1. Save the Conjur Docker image to this project directory as `conjur-appliance.tar.gz`. If you have the image uploaded to an internal repository, save it like so:

    ```
    docker pull myregistry/conjur-appliance:4.7.3
    docker save myregistry/conjur-appliance:4.7.3 > conjur-appliance.tar
    gzip conjur-appliance.tar
    ```
2. Install [packer](https://www.packer.io/).
3. If you are modifying this project, install [Vagrant](https://www.vagrantup.com/) to test your changes locally.

## Usage

### Amazon EC2

To build an AMI, run:

```
./build-ami.sh
```

### OpenStack

Modify [packer.json](packer.json) to use the
[OpenStack builder](https://www.packer.io/docs/builders/openstack.html).

---

## How it works

Given a Conjur Docker image, `conjur-appliance.tar.gz`, packer runs
[scripts/provision.sh](scripts/provision.sh), which:

1. Installs Docker
2. Installs the [Conjur CLI](https://developer.conjur.net/cli)
3. Installs and starts fail2ban and ntp
4. Creates a container from the Conjur Docker image
5. Creates a service that will start this container on system boot

## Development

You can test these scripts locally against a VM with Vagrant. Ensure you have
`conjur-appliance.tar.gz` in your project directory and run `vagrant up`.

Vagrant will:

1. Copy `conjur-appliance.tar.gz` into the VM.
2. Run [scripts/provision.sh](scripts/provision.sh).
3. Run [bootstrap_vagrant.sh](bootstrap_vagrant.sh), configuring Conjur appliance and CLI.

After the machine is provisioned, SSH in.
You are already connected and authenticated with the Conjur CLI as user 'admin'.

```sh
$ vagrant ssh
Welcome to Ubuntu 14.04.5 LTS (GNU/Linux 3.13.0-93-generic x86_64)...

$ conjur authn whoami
{"account":"vagrant","username":"admin"}
```

`/var/log/syslog` on the Vagrant VM contains all logs from the Conjur container.
