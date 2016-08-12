Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network 'private_network', :type => 'dhcp'

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.provision 'file',
    source: 'conjur-appliance.tar.gz',
    destination: '/tmp/conjur-appliance.tar.gz'

  config.vm.provision 'shell' do |s|
    s.path = 'scripts/provision.sh'
    s.args = 'vagrant'
  end

  config.vm.provision 'shell', path: 'bootstrap_vagrant.sh'
end
