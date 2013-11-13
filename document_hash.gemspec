# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'document_hash/version'

Gem::Specification.new do |gem|
  gem.name          = "document_hash"
  gem.version       = DocumentHash::VERSION
  gem.authors       = ["Giancarlo Palavicini"]
  gem.email         = ["kasthor@gmail.com"]
  gem.description   = %q{Implements a multi-level nested document, that notifies about changes, and some other related features}
  gem.summary       = %q{Document Object}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "debugger"
end
