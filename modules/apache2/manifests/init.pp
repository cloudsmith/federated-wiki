class apache2 {
	$package = $::operatingsystem ? {
		'Ubuntu' => 'apache2',
		'CentOS' => 'httpd',
		'Debian' => 'apache2',
		default => 'httpd',
	}

	$service = $package

	package { 'apache2':
		name => "${package}",
		ensure => latest,
	}

	service { 'apache2':
		name => "${service}",
		ensure => running,
		enable => true,
		hasrestart => true,
		hasstatus => true,
		require => Package['apache2'],
	}
}
