# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + "/lib/sig/version"

Gem::Specification.new do |gem|
  gem.name          = "sig"
  gem.version       = Sig::VERSION
  gem.summary       = "Optional Type Assertions for Ruby."
  gem.description   = "Optional Type Assertions for Ruby methods."
  gem.authors       = ["Jan Lelis"]
  gem.email         = "mail@janlelis.de"
  gem.homepage      = "https://github.com/janlelis/sig"
  gem.license       = "MIT"

  gem.files         = Dir["{**/}{.*,*}"].select{ |path| File.file?(path) && path !~ /^pkg/ }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.1", "< 4.0"
end
