module Chozo
  # @author Jamie Winsor <jamie@vialstudios.com>
  module RubyEngine
    module ClassMethods
      # @return [Boolean]
      def jruby?
        RUBY_ENGINE == 'jruby'
      end

      # @return [Boolean]
      def mri?
        RUBY_ENGINE == 'ruby'
      end

      # @return [Boolean]
      def rubinius?
        RUBY_ENGINE == 'rbx'
      end
      alias_method :rbx?, :rubinius?
    end

    class << self
      def included(base)
        base.send(:include, RubyEngine::ClassMethods)
      end
    end

    extend RubyEngine::ClassMethods
  end
end
