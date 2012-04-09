class rubygems {
	if($::gems_system_latest != 'true') {
		exec { 'update-gems-system':
			command => 'gem update --system',
			path => ['/usr/local/bin', '/bin', '/usr/bin'],
		} -> Package<| provider == gem |>
	}
}
