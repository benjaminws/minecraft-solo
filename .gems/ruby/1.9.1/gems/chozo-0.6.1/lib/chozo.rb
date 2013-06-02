# @author Jamie Winsor <jamie@vialstudios.com>
module Chozo
  autoload :CleanRoom, 'chozo/clean_room'
  autoload :CleanRoomBase, 'chozo/clean_room_base'
  autoload :Config, 'chozo/config'
  autoload :Errors, 'chozo/errors'
  autoload :Mixin, 'chozo/mixin'
  autoload :Platform, 'chozo/platform'
  autoload :RubyEngine, 'chozo/ruby_engine'
  autoload :VariaModel, 'chozo/varia_model'

  class << self
    # Path to the root directory of the Chozo application
    #
    # @return [Pathname]
    def app_root
      @app_root ||= Pathname.new(File.expand_path('../', File.dirname(__FILE__)))
    end
  end
end

require 'chozo/core_ext'
require 'chozo/hashie_ext'
require 'active_support/core_ext'
