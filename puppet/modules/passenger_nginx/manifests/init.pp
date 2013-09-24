# Module: passenger_nginx
# Adapted from adaptation of Sergio Galvan's nginx puppet module 
# Mizan Syed

class passenger_nginx (
  $ruby_version = 'ruby-1.9.3-p448',
  $passenger_version = '4.0.18',
  $logdir = '/var/log/nginx',
  $installdir = '/opt/nginx',
  $www    = '/var/www' ) {

    $options = "--auto --auto-download  --prefix=$installdir"
    $dependencies_passenger = [ 'libcurl4-openssl-dev' ]

    include rvm

    package { $dependencies_passenger : ensure => present }


    class ruby_system_install {
      if !defined(Rvm_system_ruby[$ruby_version]) {
        rvm_system_ruby {
          $ruby_version:
            ensure      => 'present',
            default_use => true;
        }
      }
    }


    include ruby_system_install


    rvm_gem {
    'passenger':
      name => 'passenger',
      ruby_version => $ruby_version,
      ensure => $passenger_version,
      require => Rvm_system_ruby[$ruby_version];
    }


    exec { 'create container':
      command => "/bin/mkdir $www && /bin/chown www-data:www-data $www",
      unless  => "/usr/bin/test -d $www",
      before  => Exec['nginx-install']
    }
    

    exec { 'nginx-install':
      command => "/bin/bash -l -i -c \"/usr/local/rvm/gems/$ruby_version/bin/passenger-install-nginx-module $options\"",
      group   => 'root',
      unless  => "/usr/bin/test -d $installdir",
      require => [ Package[$dependencies_passenger], Class['ruby_system_install'], Rvm_gem["passenger"]],
      logoutput => true,
      tries => 3,
    }


    file { 'nginx-config':
      path    => "${installdir}/conf/nginx.conf",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('passenger_nginx/nginx.conf.erb'),
      require => Exec['nginx-install'],
    }


    exec { 'create sites-conf':
      path    => ['/usr/bin','/bin'],
      unless  => "/usr/bin/test -d  $installdir/conf/sites-available && /usr/bin/test -d $installdir/conf/sites-enabled",
      command => "/bin/mkdir  $installdir/conf/sites-available && /bin/mkdir $installdir/conf/sites-enabled",
      require => Exec['nginx-install'],
    }


    file { 'nginx-service':
      path      => '/etc/init.d/nginx',
      owner     => 'root',
      group     => 'root',
      mode      => '0755',
      content   => template('passenger_nginx/nginx.init.erb'),
      require   => File['nginx-config'],
      subscribe => File['nginx-config'],
    }


    file { $logdir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0644'
    }


    service { 'nginx':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      subscribe  => File['nginx-config'],
      require    => [ File[$logdir], File['nginx-service']],
    }

}