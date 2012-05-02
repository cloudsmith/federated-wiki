class rubygems19::common_dependencies {
	package { ['gcc', 'gcc-c++', 'make', 'ruby19-devel']:
		ensure => installed,
	}

	package { 'rdoc':
		ensure => installed,
		provider => gem19,
	}
}
