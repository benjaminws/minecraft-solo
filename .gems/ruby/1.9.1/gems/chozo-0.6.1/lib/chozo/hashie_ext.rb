require 'hashie'

Dir["#{File.dirname(__FILE__)}/hashie_ext/*.rb"].sort.each do |path|
  require "chozo/hashie_ext/#{File.basename(path, '.rb')}"
end
