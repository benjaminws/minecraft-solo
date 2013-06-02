# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ridley/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ["Jamie Winsor"]
  s.email         = ["reset@riotgames.com"]
  s.description   = %q{A reliable Chef API client with a clean syntax}
  s.summary       = s.description
  s.homepage      = "https://github.com/RiotGames/ridley"
  s.license       = "Apache 2.0"

  s.files         = `git ls-files`.split($\)
  s.executables   = Array.new
  s.test_files    = s.files.grep(%r{^(spec)/})
  s.name          = "ridley"
  s.require_paths = ["lib"]
  s.version       = Ridley::VERSION
  s.required_ruby_version = ">= 1.9.1"

  s.add_runtime_dependency 'addressable'
  s.add_runtime_dependency 'chozo',                   '>= 0.6.0'
  s.add_runtime_dependency 'celluloid',               '~> 0.14.0'
  s.add_runtime_dependency 'erubis'
  s.add_runtime_dependency 'faraday',                 '>= 0.8.4'
  s.add_runtime_dependency 'hashie',                  '>= 2.0.2'
  s.add_runtime_dependency 'mixlib-log',              '>= 1.3.0'
  s.add_runtime_dependency 'mixlib-shellout',         '>= 1.1.0'
  s.add_runtime_dependency 'mixlib-config',           '>= 1.1.0'
  s.add_runtime_dependency 'mixlib-authentication',   '>= 1.3.0'
  s.add_runtime_dependency 'net-http-persistent',     '>= 2.8'
  s.add_runtime_dependency 'net-ssh'
  s.add_runtime_dependency 'retryable'
  s.add_runtime_dependency 'solve',                   '>= 0.4.4'
  s.add_runtime_dependency 'winrm',                   '~> 1.1.0'
end
