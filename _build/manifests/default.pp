Exec {
  path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin"]
}

Package {
	require => Exec["apt-get update"]
}

File {
	require => Exec["apt-get update"]
}

exec { "apt-get update":
	 command => '/usr/bin/apt-get update',
     require => Exec['add php54 apt-repo']
}

include stdlib
include apt
include dev
include ntp
include php54
include php
include java
include ruby
include apache2
include mongodb
include mysql
include postgres
include couchdb
include elasticsearch
include beanstalkd
include memcached
include redis

apache::loadmodule{"rewrite": }

file { "/etc/apache2/mods-enabled/rewrite.load":
	ensure => link,
	target => "/etc/apache2/mods-available/rewrite.load",
	require => Package['apache2'],
	notify => Service['apache2']
}

file { "/etc/apache2/sites-available/default":
	ensure => present,
	source => "/vagrant/_build/manifests/apache.default",
	require => Package["apache2"],
	notify => Service['apache2']
}

file { "/etc/php5/apache2/php.ini":
	ensure => present,
	require => [Package['apache2'], Package['php5-dev'], Package['libapache2-mod-php5']],
	source => "/vagrant/_build/manifests/php.ini",
	notify => Service['apache2']
}

exec { "php_cli":
	require => Package['php5-dev'],
	command => "/usr/bin/sudo ln -sf /etc/php5/apache2/php.ini /etc/php5/cli/php.ini"
}

# Start beanstalkd
file { "/etc/default/beanstalkd":
	ensure => present,
	source => "/vagrant/_build/manifests/beanstalkd.default",
	require => Package["beanstalkd"]
}

exec { "resources_permissions"
    command => "chmod -R 0777 /vagrant/app/resources"
}