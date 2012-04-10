define federated_wiki::apache($install_dir) {
	include passenger
	include apache2::variables

	Exec['bundle-install'] -> Class['passenger']

	file { ["${install_dir}/.ruby_inline", "${install_dir}/data"]:
		ensure => directory,
		owner => nobody,
		group => nobody,
		mode => 0755,
	}

	file { "${apache2::variables::config_include_dir}/${name}.conf":
		ensure => present,
		content => template('federated_wiki/federated_wiki.conf.erb'),
		owner => root,
		group => root,
		mode => 0644,
		require => [Class['passenger'], File["${install_dir}/.ruby_inline", "${install_dir}/data"]],
		notify => Service['apache2'],
	}
}
