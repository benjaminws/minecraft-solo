# -*- encoding: utf-8 -*-
require File.expand_path('../lib/chozo/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ["Jamie Winsor"]
  s.email         = ["jamie@vialstudios.com"]
  s.description   = %q{A collection of supporting libraries and Ruby core extensions}
  s.summary       = s.description
  s.homepage      = "https://github.com/reset/chozo"
  s.license       = "Apache 2.0"

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(spec)/})
  s.name          = "chozo"
  s.require_paths = ["lib"]
  s.version       = Chozo::VERSION
  s.required_ruby_version = ">= 1.9.1"

  s.add_runtime_dependency 'activesupport', '>= 3.2.0'
  s.add_runtime_dependency 'multi_json', '>= 1.3.0'
  s.add_runtime_dependency 'hashie', '>= 2.0.2'
end
