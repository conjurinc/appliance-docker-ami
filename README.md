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

Our AMIs are now based on [Amazon Linux 2](https://aws.amazon.com/amazon-linux-2/).
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

### Amazon Linux 2

Amazon Linux 2 is our preferred OS. We use the latest version at time of build. The name of the service that runs the Conjur container is `conjur.service`.

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

## Contributing

We welcome contributions of all kinds to this repository. For instructions on
how to get started and descriptions of our development workflows, please see our
[contributing guide](CONTRIBUTING.md).

## License

This repository is licensed under the MIT license - see [`LICENSE`](LICENSE) for more details.
