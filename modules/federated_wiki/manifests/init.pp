class federated_wiki(
	$source_git_repository = 'git://github.com/WardCunningham/Smallest-Federated-Wiki.git',
	$install_dir = '/var/www/federated-wiki',
	$persistent_device = undef,
	$open_id_identifier = undef
) {
	include rubygems19
	include rubygems19::common_dependencies
	include memcached

	$build_dependencies = [
		'libxml2-devel', 'libxslt-devel'
	]

	$need_pull_util = '/usr/local/lib/git_need_pull.rb'

	package { [$build_dependencies]:
		ensure => installed,
	}

	package { 'bundler':
		ensure => installed,
		provider => gem19,
	}

	package { 'git':
		ensure => installed,
	}

	file { $need_pull_util:
		source => 'puppet:///modules/federated_wiki/git_need_pull.rb',
		owner => root,
		group => root,
		mode => 0644,
	}

	exec { 'git-clone':
		unless => "test -d \"${install_dir}\"",
		command => "git clone \"${source_git_repository}\" \"${install_dir}\"",
		path => ['/usr/local/bin', '/bin', '/usr/bin'],
		require => Package['git'],
	}

	exec { 'git-pull':
		onlyif => "test -d \"${install_dir}\" && ruby \"${need_pull_util}\"",
		command => 'git pull',
		cwd => $install_dir,
		path => ['/usr/local/bin', '/bin', '/usr/bin'],
		require => Package['git'],
	}

	exec { 'bundle-install':
		unless => 'bundle check',
		command => 'bundle install',
		environment => ["RUBYOPT=-rfix_ruby_revision"],
		cwd => $install_dir,
		timeout => 0,
		path => ['/usr/local/bin', '/bin', '/usr/bin'],
		require => [Package['bundler'], Exec['git-clone', 'git-pull'], Class['rubygems19::common_dependencies'], Package[$build_dependencies]],
	}

	if($persistent_device != undef) {
		exec { "mkfs-${persistent_device}":
			unless => "dumpe2fs -h \"${persistent_device}\"",
			command => "mkfs -t ext3 \"${persistent_device}\"",
			path => ['/usr/local/sbin', '/usr/local/bin', '/sbin', '/bin', '/usr/sbin', '/usr/bin'],
		}

		exec { "mountpoint-${install_dir}/data":
			unless => 'test -d data',
			command => 'mkdir data',
			cwd => $install_dir,
			path => ['/usr/local/bin', '/bin', '/usr/bin'],
			require => Exec['git-clone'],
		}

		mount { "mount-${install_dir}/data":
			ensure => mounted,
			name => "${install_dir}/data",
			device => $persistent_device,
			fstype => 'ext3',
			options => 'defaults',
			require => Exec["mkfs-${persistent_device}", "mountpoint-${install_dir}/data"],
			before => File["${install_dir}/data"],
		}
	}

	federated_wiki::apache { 'federated_wiki':
		install_dir => $install_dir,
		require => [Class['memcached'], Exec['bundle-install']],
	}

	if($open_id_identifier != undef) {
		file { "${install_dir}/data/status":
			ensure => directory,
			owner => nobody,
			group => nobody,
			mode => 0755,
			require => File["${install_dir}/data"],
		}

		file { "${install_dir}/data/status/open_id.identifier":
			ensure => present,
			content => template('federated_wiki/open_id.identifier.erb'),
			owner => root,
			group => root,
			mode => 0644,
			require => File["${install_dir}/data/status"],
		}
	}
}
