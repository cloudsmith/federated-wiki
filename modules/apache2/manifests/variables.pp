class apache2::variables {
	# TODO verify the locataion of config includes accross distros
	$config_include_dir = $::operatingsystem ? {
		'Ubuntu' => '/etc/httpd/conf.d',
		'CentOS' => '/etc/httpd/conf.d',
		'Debian' => '/etc/httpd/conf.d',
		default => '/etc/httpd/conf.d',
	}
}
