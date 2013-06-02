# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ipaddress"
  s.version = "0.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marco Ceresa"]
  s.date = "2011-05-16"
  s.description = "      IPAddress is a Ruby library designed to make manipulation \n      of IPv4 and IPv6 addresses both powerful and simple. It mantains\n      a layer of compatibility with Ruby's own IPAddr, while \n      addressing many of its issues.\n"
  s.email = "ceresa@gmail.com"
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = ["LICENSE", "README.rdoc"]
  s.homepage = "http://github.com/bluemonk/ipaddress"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "IPv4/IPv6 addresses manipulation library"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
