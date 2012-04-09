class rubygems::common_dependencies {
	package { ['gcc', 'gcc-c++', 'make', 'ruby-devel']:
		ensure => installed,
	}
}
