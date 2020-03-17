# Contributing
  
For general contribution and community guidelines, please see the [community repo](https://github.com/cyberark/community).

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

## Contributing Workflow

1. [Fork the project](https://help.github.com/en/github/getting-started-with-github/fork-a-repo)
2. [Clone your fork](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository)
3. Make local changes to your fork by editing files
3. [Commit your changes](https://help.github.com/en/github/managing-files-in-a-repository/adding-a-file-to-a-repository-using-the-command-line)
4. [Push your local changes to the remote server](https://help.github.com/en/github/using-git/pushing-commits-to-a-remote-repository)
5. [Create new Pull Request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork)

From here your pull request will be reviewed and once you've responded to all
feedback it will be merged into the project. Congratulations, you're a
contributor!
