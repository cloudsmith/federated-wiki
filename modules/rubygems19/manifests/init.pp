class rubygems19 {
	if($::gems19_system_latest != 'true') {
		exec { 'update-gems19-system':
			command => 'gem1.9 update --system',
			path => ['/usr/local/bin', '/bin', '/usr/bin'],
		} -> Package<| provider == gem19 |>
	}

	exec { "create-${::rubysitedir19}":
		unless => "test -d \"${::rubysitedir19}\"",
		command => "mkdir -p \"${::rubysitedir19}\"",
		path => ['/usr/local/bin', '/bin', '/usr/bin'],
	}

	file { "${::rubysitedir19}/fix_ruby_revision.rb":
		source => 'puppet:///modules/rubygems19/fix_ruby_revision.rb',
		owner => root,
		group => root,
		mode => 0644,
		require => Exec["create-${::rubysitedir19}"],
	}
}
