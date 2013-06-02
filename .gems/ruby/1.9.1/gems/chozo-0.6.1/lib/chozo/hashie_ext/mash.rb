module Hashie
  # @author Jamie Winsor <jamie@vialstudios.com>
  class Mash < Hashie::Hash
    alias_method :old_setter, :[]=
    alias_method :old_dup, :dup

    attr_writer :coercions

    # @return [Hash]
    def coercions
      @coercions ||= HashWithIndifferentAccess.new
    end

    def coercion(key)
      self.coercions[key]
    end

    def set_coercion(key, fun)
      self.coercions[key] = fun
    end

    # Override setter to coerce the given value if a coercion is defined
    def []=(key, value)
      coerced_value = coercion(key).present? ? coercion(key).call(value) : value
      old_setter(key, coerced_value)
    end

    # Return the containing Hashie::Mash of the given dotted path
    #
    # @param [String] path
    #
    # @return [Hashie::Mash, nil]
    def container(path)
      parts = path.split('.', 2)
      match = (self[parts[0].to_s] || self[parts[0].to_sym])
      if !parts[1] or match.nil?
        self
      else
        match.container(parts[1])
      end
    end

    def dup
      mash = old_dup
      mash.coercions = self.coercions
      mash
    end
  end
end
