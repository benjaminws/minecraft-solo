# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "chozo"
  s.version = "0.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jamie Winsor"]
  s.date = "2013-02-27"
  s.description = "A collection of supporting libraries and Ruby core extensions"
  s.email = ["jamie@vialstudios.com"]
  s.homepage = "https://github.com/reset/chozo"
  s.licenses = ["Apache 2.0"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.1")
  s.rubygems_version = "1.8.23"
  s.summary = "A collection of supporting libraries and Ruby core extensions"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.2.0"])
      s.add_runtime_dependency(%q<multi_json>, [">= 1.3.0"])
      s.add_runtime_dependency(%q<hashie>, [">= 2.0.2"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.2.0"])
      s.add_dependency(%q<multi_json>, [">= 1.3.0"])
      s.add_dependency(%q<hashie>, [">= 2.0.2"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.2.0"])
    s.add_dependency(%q<multi_json>, [">= 1.3.0"])
    s.add_dependency(%q<hashie>, [">= 2.0.2"])
  end
end
