module Chozo
  # @author Jamie Winsor <jamie@vialstudios.com>
  #
  # A collection of helpful mixins 
  module Mixin; end
end

Dir["#{File.dirname(__FILE__)}/mixin/*.rb"].sort.each do |path|
  require "chozo/mixin/#{File.basename(path, '.rb')}"
end
