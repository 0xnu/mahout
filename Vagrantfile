# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"

  config.vm.hostname = "0xnu-ml"

  # config.vm.box_check_update = false

  # config.vm.network "forwarded_port", guest: 80, host: 8080

  config.vm.network :private_network, ip: "192.168.56.18"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false

    # Customize the amount of memory on the VM:
    vb.memory = "4096"
    vb.cpus = 4
  end

  config.vm.provision :shell, :path => "bootstrap-mahout.sh"

  config.vm.synced_folder "~/Documents", "/data", owner: "vagrant", group: "vagrant"

  config.ssh.forward_agent = true
end