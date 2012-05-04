class memcached(
	$user = 'memcached',
	$port = 11211,
	$max_connections = 1024,
	$cache_size = 64,
	$options = '-l 127.0.0.1'
) {
	package { 'memcached':
		ensure => latest,
	}

	file { 'memcached-config':
		path => '/etc/sysconfig/memcached',
		content => template('memcached/memcached.conf.erb'),
		ensure => present,
		owner => root,
		group => root,
		mode => 0644,
		require => Package['memcached'],
	}

	service { 'memcached':
		ensure => running,
		enable => true,
		hasrestart => true,
		hasstatus => true,
		require => File['memcached-config'],
	}
}
