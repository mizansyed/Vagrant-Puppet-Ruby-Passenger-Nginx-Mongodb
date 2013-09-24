# encoding: utf-8

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

	config.vm.box = "precise64"
	config.vm.box_url = "http://files.vagrantup.com/precise64.box"
	config.ssh.forward_agent = true
	
	config.vm.network :forwarded_port, guest: 80, host: 8085
	config.vm.network :forwarded_port, guest: 4567, host: 4567   # sinatra
	config.vm.network :forwarded_port, guest: 9292, host: 9292   # rack
	config.vm.network :forwarded_port, guest: 9393, host: 9393   # shotgun
	config.vm.network :forwarded_port, guest: 27017, host: 27017 # mongo
  
	config.vm.network :private_network, ip: "192.168.10.2"

	config.vm.provider "virtualbox" do |v|
		v.gui = true
		v.customize ["modifyvm", :id, "--memory", "1024"]
	end

	
	config.vm.synced_folder "src/", "/var/www"
	config.vm.synced_folder "mongodata/", "/data/db/"


	config.vm.provision :puppet do |puppet|
		puppet.facter = { 
			"fqdn" => "appserver00.local", 
		}
		puppet.manifest_file = "default.pp"
		puppet.manifests_path = "puppet/manifests"
		puppet.module_path = "puppet/modules"
		puppet.options = ['--verbose']
	end
	
end
