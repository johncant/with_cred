# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'with_cred/version'

Gem::Specification.new do |gem|
  gem.name          = "with_cred"
  gem.version       = WithCred::VERSION
  gem.authors       = ["John Cant"]
  gem.email         = ["a.johncant@gmail.com"]
  gem.description   = %q{Simple credentials storage}
  gem.summary       = %q{Credentials as environment variables or as files}
  gem.homepage      = "https://github.com/johncant/with_cred"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'encryptor'
end
