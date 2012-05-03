if defined?(RUBY_REVISION) && RUBY_REVISION == 0
  ruby_version = RUBY_VERSION.split('.').map { |part| part.to_i }
  if ruby_version[0] > 1 || ruby_version[0] == 1 && ruby_version[1] > 9 || ruby_version[0] == 1 && ruby_version[1] == 9 && ruby_version[2] > 2
    ::RUBY_REVISION = 26959
  end
end
