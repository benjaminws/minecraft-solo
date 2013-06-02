# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ridley"
  s.version = "0.12.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jamie Winsor"]
  s.date = "2013-05-28"
  s.description = "A reliable Chef API client with a clean syntax"
  s.email = ["reset@riotgames.com"]
  s.homepage = "https://github.com/RiotGames/ridley"
  s.licenses = ["Apache 2.0"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.1")
  s.rubygems_version = "1.8.23"
  s.summary = "A reliable Chef API client with a clean syntax"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<addressable>, [">= 0"])
      s.add_runtime_dependency(%q<chozo>, [">= 0.6.0"])
      s.add_runtime_dependency(%q<celluloid>, ["~> 0.14.0"])
      s.add_runtime_dependency(%q<erubis>, [">= 0"])
      s.add_runtime_dependency(%q<faraday>, [">= 0.8.4"])
      s.add_runtime_dependency(%q<hashie>, [">= 2.0.2"])
      s.add_runtime_dependency(%q<mixlib-log>, [">= 1.3.0"])
      s.add_runtime_dependency(%q<mixlib-shellout>, [">= 1.1.0"])
      s.add_runtime_dependency(%q<mixlib-config>, [">= 1.1.0"])
      s.add_runtime_dependency(%q<mixlib-authentication>, [">= 1.3.0"])
      s.add_runtime_dependency(%q<net-http-persistent>, [">= 2.8"])
      s.add_runtime_dependency(%q<net-ssh>, [">= 0"])
      s.add_runtime_dependency(%q<retryable>, [">= 0"])
      s.add_runtime_dependency(%q<solve>, [">= 0.4.4"])
      s.add_runtime_dependency(%q<winrm>, ["~> 1.1.0"])
    else
      s.add_dependency(%q<addressable>, [">= 0"])
      s.add_dependency(%q<chozo>, [">= 0.6.0"])
      s.add_dependency(%q<celluloid>, ["~> 0.14.0"])
      s.add_dependency(%q<erubis>, [">= 0"])
      s.add_dependency(%q<faraday>, [">= 0.8.4"])
      s.add_dependency(%q<hashie>, [">= 2.0.2"])
      s.add_dependency(%q<mixlib-log>, [">= 1.3.0"])
      s.add_dependency(%q<mixlib-shellout>, [">= 1.1.0"])
      s.add_dependency(%q<mixlib-config>, [">= 1.1.0"])
      s.add_dependency(%q<mixlib-authentication>, [">= 1.3.0"])
      s.add_dependency(%q<net-http-persistent>, [">= 2.8"])
      s.add_dependency(%q<net-ssh>, [">= 0"])
      s.add_dependency(%q<retryable>, [">= 0"])
      s.add_dependency(%q<solve>, [">= 0.4.4"])
      s.add_dependency(%q<winrm>, ["~> 1.1.0"])
    end
  else
    s.add_dependency(%q<addressable>, [">= 0"])
    s.add_dependency(%q<chozo>, [">= 0.6.0"])
    s.add_dependency(%q<celluloid>, ["~> 0.14.0"])
    s.add_dependency(%q<erubis>, [">= 0"])
    s.add_dependency(%q<faraday>, [">= 0.8.4"])
    s.add_dependency(%q<hashie>, [">= 2.0.2"])
    s.add_dependency(%q<mixlib-log>, [">= 1.3.0"])
    s.add_dependency(%q<mixlib-shellout>, [">= 1.1.0"])
    s.add_dependency(%q<mixlib-config>, [">= 1.1.0"])
    s.add_dependency(%q<mixlib-authentication>, [">= 1.3.0"])
    s.add_dependency(%q<net-http-persistent>, [">= 2.8"])
    s.add_dependency(%q<net-ssh>, [">= 0"])
    s.add_dependency(%q<retryable>, [">= 0"])
    s.add_dependency(%q<solve>, [">= 0.4.4"])
    s.add_dependency(%q<winrm>, ["~> 1.1.0"])
  end
end
