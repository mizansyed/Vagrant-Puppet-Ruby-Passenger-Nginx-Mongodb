#Puppet manifest to install 


Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }


	exec { 'apt-get update':
		#command => 'sudo apt-get update --fix-missing',
		command => 'sudo apt-get update',
		user => "vagrant",
	}


	exec { 'apt-get upgrade':
		command => 'sudo apt-get -y upgrade',
		user => "vagrant",
		refreshonly => true,
	}


Exec["apt-get update"] -> Package <| |>


class pre-install-packages {

	$pkg_array_1 = ['curl', 'patch', 'bzip2', 'build-essential', 'bison', 'zlib1g-dev', 'git-core', 'openssl', 'libssl-dev', 'libreadline5', 'libreadline-dev',
		'libcurl4-openssl-dev', 'libyaml-dev', 'libsqlite3-dev', 'sqlite3', 
		'libxml2-dev', 'libxslt1-dev', 'libgdbm-dev', 'libncurses5-dev', 
		'libtool', 'libffi-dev']

	$pkg_array_2 = ['python-software-properties', 'software-properties-common']

	$pkg_array_3 = ['nodejs']

	add_package { $pkg_array_1: }
	add_package { $pkg_array_2: }
	add_package { $pkg_array_3: }

	define add_package {
		if ! defined(Package["$name"]) {
		    package { "$name" :
		        ensure => installed,
		    }
		}
	}

}



class user-addition {

	add_user {'deployer':}
	
	define add_user {
		user { "$name":
				uid          => 1500,
				comment    	=> 'Deployer',
				ensure       =>  present,
				home         => "/home/$name",
				shell        => '/bin/bash',
				managehome   => true,
				password     => '$1$22p3RA8D$YazKiVM/H8nNf.aURdH.D0',
		}
	}

	sudofy_user {'deployer':}
	sudofy_user {'vagrant':}

	define sudofy_user
	{
		notify{"The user is : $name": }

		sudo::sudoers { "sudofy_$name" :
			ensure  => 'present',
			comment => 'Allow to sudo',
			users   => ["$name"],
			runas   => ['root'],
			cmnds   => ['ALL'],
			tags    => ['NOPASSWD'],
		}
	}

}


class mongodb-install {
	package { "mongodb":
		ensure => present
	}
}


class module-rvm-install
{

	#class { 'pre-install-packages':} -> class { 'user-addition':}

	rvm::system_user { vagrant: ; deployer: ; }

	if $rvm_installed == "true" {

		class { 'install_ruby': }

	} else {

		exec { 'install-rvm':
			command => 'curl -L https://get.rvm.io | sudo bash -s stable',
			cwd => '/tmp',
			require => [Package["curl"], Class["user-addition"]]	
		}

		#include install_ruby
		class { 'install_ruby': }
	}
}


class install_ruby
{

	rvm_system_ruby {
	  'ruby-1.9.3-p448':
	    ensure => 'present',
	    default_use => true;
	  'ruby-2.0.0-p247':
	    ensure => 'present',
	    default_use => false;
	} ->

	rvm_gem {
	  'bundler':
	    name => 'bundler',
	    ruby_version => 'ruby-1.9.3-p448',
	    ensure => latest,
	    require => Rvm_system_ruby['ruby-1.9.3-p448'];
	}

	#reinstall puppet in the default so that we can run vagrant reload 
	rvm_gem {
	  'puppet':
	    name => 'puppet',
	    ruby_version => 'ruby-1.9.3-p448',
	    ensure => latest,
	    require => Rvm_system_ruby['ruby-1.9.3-p448'] ;
	}

	file { '/etc/gemrc':
  		ensure  => present,
  		content => "---\ninstall: --no-rdoc --no-ri\nupdate: --no-rdoc --no-ri\n",
	}

	#class {'deployer-rvm-access':} -> class { 'passenger_nginx': }
}



class deployer-rvm-access{

	exec { "sudo su deployer":
		command => "sudo su deployer",
		require => Class["install_ruby"]
	} ->

	exec { "/etc/profile.d/rvm.sh":
		command => "sudo su deployer && bash -c 'source \"/etc/profile.d/rvm.sh\"'",
		require => Exec["sudo su deployer"]
	}

	exec { "/home/deployer/.bashrc":
		command => "echo 'PATH=\$PATH:/usr/local/rvm/bin # Add RVM to PATH for scripting' >> /home/deployer/.bashrc",
		require => Exec["/etc/profile.d/rvm.sh"]
	}

	exec { "/home/deployer/.zshrc":
		command => "echo 'PATH=\$PATH:/usr/local/rvm/bin # Add RVM to PATH for scripting' >> /home/deployer/.zshrc",
		require => Exec["/home/deployer/.bashrc"]
	}


	exec { "/home/deployer/.zprofile":
		command => "echo '[[ -s \"/usr/local/rvm/scripts/rvm\" ]] && bash -c \"source \'/usr/local/rvm/scripts/rvm\'\"' >> /home/deployer/.zprofile",
		require => Exec["/home/deployer/.zshrc"]
	}

	exec { "/home/deployer/.bashrc 2":
		command => "echo bash -c 'source \"/etc/profile.d/rvm.sh\"' >> /home/deployer/.bashrc",
		require => Exec["/home/deployer/.zprofile"]
	}


	exec { "/home/vagrant/.bash_profile.OLD":
		command => "sudo su vagrant && mv /home/vagrant/.bash_profile /home/vagrant/.bash_profile.OLD",
		onlyif => "test -f /home/vagrant/.bash_profile",
		require => Exec["/home/deployer/.bashrc 2"]
	} 
	
}



class virtual-host-setup{

	passenger_nginx::vhost { 'localhost2':}
}

Class['user-addition'] -> Class['module-rvm-install'] -> Class['deployer-rvm-access'] -> Class['passenger_nginx'] -> Class['virtual-host-setup']

include rvm 
include sudo
include mongodb-install
include pre-install-packages
include user-addition
include module-rvm-install
include deployer-rvm-access
include passenger_nginx
include virtual-host-setup