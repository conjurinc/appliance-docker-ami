# CoreOS variables
$update_channel = 'stable'
$image_version = ENV['COREOS_VERSION'] || 'current'  # from secrets.yml

Vagrant.configure(2) do |config|
  config.vm.box = "coreos-%s" % [$update_channel]
  config.vm.box_url = "https://storage.googleapis.com/%s.release.core-os.net/amd64-usr/%s/coreos_production_vagrant.json" % [$update_channel, $image_version]
  config.vm.network 'private_network', ip: '172.17.8.100'

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
    v.check_guest_additions = false
    v.functional_vboxsf = false
  end

  config.vm.synced_folder '.', '/vagrant', nfs: true, mount_options: ['nolock,vers=3,udp']

  config.vm.provision 'shell', inline: 'cp /vagrant/conjur-appliance.tar.gz /home/core/'

  config.vm.provision 'shell', path: 'scripts/coreos/bootstrap.sh'
end
