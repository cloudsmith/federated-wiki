require 'puppet/util/package'

Puppet::Type.type(:package).provide :gem19, :parent => :gem do
  desc "Ruby Gem support for secondary installation of ruby 1.9"

  commands :gemcmd => "gem1.9"
end
