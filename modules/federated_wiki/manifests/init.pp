class federated_wiki(
	$source_git_repository = 'git://github.com/WardCunningham/Smallest-Federated-Wiki.git',
	$install_dir = '/var/www/federated-wiki',
	$persistent_device = undef
) {
	include rubygems19
	include rubygems19::common_dependencies
	include memcached

	$build_dependencies = [
		'libxml2-devel', 'libxslt-devel'
	]

	$patch_dir = "${install_dir}/patch"
	$memcached_patch = "${patch_dir}/memcached.patch"

	$need_pull_util = '/usr/local/lib/git_need_pull.rb'

	package { [$build_dependencies]:
		ensure => installed,
	}

	package { ['bundler', 'memcache-client']:
		ensure => installed,
		provider => gem19,
	}

	package { ['git', 'patch']:
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

	file { $patch_dir:
		ensure => directory,
		owner => root,
		group => root,
		mode => 0755,
		require => Exec['git-clone'],
	}

	file { $memcached_patch:
		source => 'puppet:///modules/federated_wiki/memcached.patch',
		owner => root,
		group => root,
		mode => 0644,
		require => File[$patch_dir],
	}

	exec { 'memcached-patch':
		unless => "patch --dry-run --reverse --strip=1 --force --quiet --input=\"${memcached_patch}\"",
		command => "patch --strip=1 --force --quiet --input=\"${memcached_patch}\"",
		cwd => $install_dir,
		path => ['/usr/local/bin', '/bin', '/usr/bin'],
		require => [Exec['git-clone', 'git-pull'], Package['patch'], File[$memcached_patch]],
	}

	federated_wiki::apache { 'federated_wiki':
		install_dir => $install_dir,
		require => [Class['memcached'], Package['memcache-client'], Exec['bundle-install', 'memcached-patch']],
	}
}
