# appliance-docker

Packages the Conjur Docker image into machine images for different platforms.

**Current platforms:**

* AWS AMI

This project uses [packer](https://www.packer.io/) to create images that run
the Conjur appliance Docker image. Since we are using packer, images for several different
platforms can be built by adding to the `builders` section of [packer.json](packer.json).
Bootstrap scripts are located at `scripts/*os*/bootstrap.sh`.

Feel free to fork this repository and update the packer scripts
as needed to generate images for your platform.

You can run this on Jenkins using the [appliance-docker-ami job](https://jenkins.conjur.net/job/appliance-docker-ami/).

## Prerequisites

1. Access to pull Conjur appliance containers. Use [conjur-registry-proxy](https://github.com/conjurinc/conjur-registry-proxy).
2. Install [packer](https://www.packer.io/).
3. If you are modifying this project's scripts, install [Vagrant](https://www.vagrantup.com/) to test your changes locally.

## Usage

### Amazon EC2

To build an AMI, run:

```
./build-ami.sh registry.tld/conjur-appliance latest
```

The positional arguments (image, tag) are optional; defaults are shown above.

Our AMIs are now based on [CoreOS](https://coreos.com/os/docs/latest/).
[Read more below]().

### OpenStack

Modify [packer.json](packer.json) to use the
[OpenStack builder](https://www.packer.io/docs/builders/openstack.html).

---

## How it works

Given a Conjur Docker image, `conjur-appliance.tar.gz`, packer runs
`scripts/*os*/bootstrap.sh`, which:

1. Creates a container from the Conjur Docker image
2. Creates and enables a service that will start this container on system boot

### CoreOS

CoreOS is our preferred OS. The CoreOS version and AMI we use are in [secrets.yml](secrets.yml). These are not secrets, but putting them here makes it easy to pass them into packer and test-kitchen.

CoreOS uses [systemd](https://coreos.com/docs/launching-containers/launching/getting-started-with-systemd/) as its init system. The name of the service that runs the Conjur container is `conjur.service`.

#### Service Management

The systemd unit file is placed at `/etc/systemd/system/conjur.service`. The bootstrap script enables; next time the AMI boots the service will start the Conjur container.

```
# View service status
systemctl status conjur

# Start/stop/restart service
sudo systemctl start conjur
sudo systemctl stop conjur
sudo systemctl restart conjur
```

#### Logs

Container are sent to the [systemd journal](https://www.freedesktop.org/software/systemd/man/systemd-journald.service.html), using Docker [journald logging driver](https://docker.github.io/engine/admin/logging/journald/).

To view the container's logs use `journalctl`:

```
journalctl CONTAINER_NAME=conjur-appliance
```

## Development

You can test these scripts locally against a VM with Vagrant. Ensure you have
`conjur-appliance.tar.gz` in your project directory and run `vagrant up`.

Vagrant will:

1. Copy `conjur-appliance.tar.gz` into the VM.
2. Run bootstrap scripts.

## Testing

Tests are run using [test-kitchen](http://kitchen.ci/). Install the [ChefDK](https://downloads.chef.io/chef-dk/) (bundles test-kitchen) to run tests locally.

Run a test against a created AMI like so:

```
./test.sh <AMI_ID>
```

This will:

1. Spin up an EC2 instance of the AMI.
2. Run [bootstrap.sh](bootstrap.sh) to configure the Conjur container.
3. curl the health endpoint to make sure all is okay.
4. Terminate the EC2 instance.
