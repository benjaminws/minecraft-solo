# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mixlib-authentication"
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Opscode, Inc."]
  s.date = "2012-08-06"
  s.description = "Mixes in simple per-request authentication"
  s.email = "info@opscode.com"
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", "NOTICE"]
  s.files = ["README.rdoc", "LICENSE", "NOTICE"]
  s.homepage = "http://www.opscode.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Mixes in simple per-request authentication"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mixlib-log>, [">= 0"])
    else
      s.add_dependency(%q<mixlib-log>, [">= 0"])
    end
  else
    s.add_dependency(%q<mixlib-log>, [">= 0"])
  end
end
