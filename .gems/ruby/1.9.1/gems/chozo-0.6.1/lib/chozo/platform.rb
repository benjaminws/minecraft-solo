require 'rbconfig'

module Chozo
  # @author Jamie Winsor <jamie@vialstudios.com>
  module Platform
    module ClassMethods
      # @return [Boolean]
      def windows?
        (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/) ? true : false
      end

      def osx?
        (RbConfig::CONFIG['host_os'] =~ /darwin/) ? true : false
      end

      def linux?
        (RbConfig::CONFIG['host_os'] =~ /linux/) ? true : false
      end
    end

    class << self
      def included(base)
        base.send(:include, Platform::ClassMethods)
      end
    end

    extend Platform::ClassMethods
  end
end
