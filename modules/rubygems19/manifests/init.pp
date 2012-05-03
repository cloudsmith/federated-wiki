class rubygems19 {
	if($::gems19_system_latest != 'true') {
		exec { 'update-gems19-system':
			command => 'gem1.9 update --system',
			path => ['/usr/local/bin', '/bin', '/usr/bin'],
		} -> Package<| provider == gem19 |>
	}
}
