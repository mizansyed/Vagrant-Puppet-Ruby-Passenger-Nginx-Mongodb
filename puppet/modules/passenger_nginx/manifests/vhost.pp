# Define: nginx::vhost
#
# Creates nginx virtual hosts
#
# Parameters:
#   $host
#       The title of the resource  is used as the host.
#   $port
#       Virtual host port
#   $root
#       Virtual host path
#   $create_root
#       True or false, allows to create the path for the virtual host
#   $rails
#       True or false, sets if the application is rails based or not.
# Actions:
#       Creates a virtual host
#
# Requires:
#       nginx
#
# Sample Usage:
#
#  nginx::vhost { 'test':
#    sever_name =>  'blog.test.com'
# }
define passenger_nginx::vhost(
  $host = $name,
  $port = '80',
  $root    = "/var/www/${host}",
  $makeroot = true,
  $rails = false,
){
  include passenger_nginx

  if $makeroot{
    if ! defined(File["$root"]) {
      file { $root:
        ensure  => directory,
        owner   => 'www-data',
        group   => 'www-data',
        mode    => '0755',
        require => Class['passenger_nginx'],
      }
    }
  }

  $template =  $rails ? {
    true    => 'vhost.rails.erb',
    default => 'vhost.erb',
  }

  file { $host:
    ensure  => present,
    path    => "${passenger_nginx::installdir}/conf/sites-available/${host}",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("passenger_nginx/${template}"),
    require => Class['passenger_nginx'],
  }

  file { "${passenger_nginx::installdir}/conf/sites-enabled/${host}":
    ensure  => link,
    target  => "${passenger_nginx::installdir}/conf/sites-available/${host}",
    require => File[$host],
  }

  exec { "nginx ${host}":
    command => '/etc/init.d/nginx restart',
    require => File["${passenger_nginx::installdir}/conf/sites-enabled/${host}"],
  }

}
