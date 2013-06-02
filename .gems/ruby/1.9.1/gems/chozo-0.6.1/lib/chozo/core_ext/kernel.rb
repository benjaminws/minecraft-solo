require 'chozo/platform'
require 'chozo/ruby_engine'

module Kernel
  include Chozo::Platform
  include Chozo::RubyEngine
end

class Object
  # Re-include since we updated the Kernel module
  include Kernel
end
