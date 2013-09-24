Vagrant Puppet Ruby Passenger Nginx MongoDb
===========================================


Vagrant to control and provision machines, mainly for Ruby development purpose.

NOTE: This plugin requires Vagrant 1.3+ (rather it was built with Vagrant 1.3).

It installs

	* Ruby 1.9.3-p448 (default)
	* Ruby 2.0.0-p247
	* Nginx
	* Passenger
	* MongoDb


It configures vhost files for a given site and adds 'service' script for nginx.

### Basic usage

		vagrant up


Let me know if you have improvements/advice. This is a first attempt with Vagrant/Puppet.
