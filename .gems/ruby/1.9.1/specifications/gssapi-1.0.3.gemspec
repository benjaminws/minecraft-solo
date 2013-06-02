# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "gssapi"
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dan Wanek"]
  s.date = "2011-11-07"
  s.description = "    A FFI wrapper around the system GSSAPI library. Please make sure and read the\n    Yard docs or standard GSSAPI documentation if you have any questions.\n    \n    There is also a class called GSSAPI::Simple that wraps many of the common features\n    used for GSSAPI.\n"
  s.email = "dan.wanek@gmail.com"
  s.extra_rdoc_files = ["README.textile", "COPYING"]
  s.files = ["README.textile", "COPYING"]
  s.homepage = "http://github.com/zenchild/gssapi"
  s.rdoc_options = ["-x", "test/", "-x", "examples/"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.1")
  s.rubygems_version = "1.8.23"
  s.summary = "A FFI wrapper around the system GSSAPI library."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ffi>, [">= 1.0.1"])
    else
      s.add_dependency(%q<ffi>, [">= 1.0.1"])
    end
  else
    s.add_dependency(%q<ffi>, [">= 1.0.1"])
  end
end
