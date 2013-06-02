# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "minitar"
  s.version = "0.5.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Austin Ziegler, Mauricio Fernandez, Antoine Toulme"]
  s.autorequire = "archive/tar/minitar"
  s.date = "2012-11-14"
  s.description = "Archive::Tar::Minitar is a pure-Ruby library and command-line utility that provides the ability to deal with POSIX tar(1) archive files. The implementation is based heavily on Mauricio Ferna'ndez's implementation in rpa-base, but has been reorganised to promote reuse in other projects. Antoine Toulme forked the original project on rubyforge to place it on github, under http://www.github.com/atoulme/minitar"
  s.email = "antoine@lunar-ocean.com"
  s.executables = ["minitar"]
  s.extra_rdoc_files = ["README", "ChangeLog", "Install"]
  s.files = ["bin/minitar", "README", "ChangeLog", "Install"]
  s.homepage = "http://www.github.com/atoulme/minitar"
  s.rdoc_options = ["--title", "Archive::Tar::MiniTar -- A POSIX tarchive library", "--main", "README", "--line-numbers"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.2")
  s.rubygems_version = "1.8.23"
  s.summary = "Provides POSIX tarchive management from Ruby programs."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
