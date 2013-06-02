# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "little-plugger"
  s.version = "1.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Pease"]
  s.date = "2011-11-17"
  s.description = "LittlePlugger is a module that provides Gem based plugin management.\nBy extending your own class or module with LittlePlugger you can easily\nmanage the loading and initializing of plugins provided by other gems."
  s.email = "tim.pease@gmail.com"
  s.extra_rdoc_files = ["History.txt", "README.rdoc"]
  s.files = ["History.txt", "README.rdoc"]
  s.homepage = "http://gemcutter.org/gems/little-plugger"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "little-plugger"
  s.rubygems_version = "1.8.23"
  s.summary = "LittlePlugger is a module that provides Gem based plugin management."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 2.7.0"])
    else
      s.add_dependency(%q<rspec>, [">= 2.7.0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 2.7.0"])
  end
end
