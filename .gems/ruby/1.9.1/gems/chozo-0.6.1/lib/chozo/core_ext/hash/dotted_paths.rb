class Hash
  class << self
    # Create a new Hash containing other nested Hashes from a string containing
    # a dotted path. A Hash will be created and assigned to a key of another Hash
    # for each entry in the dotted path.
    #
    # If a value is provided for the optional seed argument then the value of the
    # deepest nested key will be set to the given value. If no value is provided
    # the value of the key will be nil.
    #
    # @example creating a nested hash from a dotted path
    #
    #   Hash.from_dotted_path("deep.nested.hash") =>
    #   {
    #     "deep" => {
    #       "nested" => {
    #         "hash" => nil
    #       }
    #     }
    #   }
    #
    #
    # @example specifying a seed value
    #
    #   Hash.from_dotted_path("deep.nested.hash", :seed_value) =>
    #   {
    #     "deep" => {
    #       "nested" => {
    #         "hash" => :seed_value
    #       }
    #     }
    #   }
    #
    # @param [String, Symbol, Array] dotpath
    # @param [Object] seed (nil)
    # @param [Hash] target (self.new)
    #
    # @return [Hash]
    def from_dotted_path(dotpath, seed = nil, target = self.new)
      case dotpath
      when String, Symbol
        from_dotted_path(dotpath.to_s.split("."), seed)
      when Array
        if dotpath.empty?
          return target
        end

        key = dotpath.pop

        if target.empty?
          target[key] = seed
          from_dotted_path(dotpath, seed, target)
        else
          new_target = self.new
          new_target[key] = target
          from_dotted_path(dotpath, seed, new_target)
        end
      end
    end
  end

  # Return the value of the nested hash key from the given dotted path
  #
  # @example
  #
  #   nested_hash = {
  #     "deep" => {
  #       "nested" => {
  #         "hash" => :seed_value
  #       }
  #     }
  #   }
  #
  #   nested_hash.dig('deep.nested.hash') => :seed_value
  #
  # @param [String] path
  #
  # @return [Object, nil]
  def dig(path)
    return nil unless path.present?

    parts = path.split('.', 2)
    match = self[parts[0].to_s].nil? ? self[parts[0].to_sym] : self[parts[0].to_s]
    if !parts[1] or match.nil?
      match
    else
      match.dig(parts[1])
    end
  end

  # Returns an array of dotted paths from the keys, values of this Hash. Values which are
  # nested Hashes will also recurred into and their paths will be added properly.
  #
  # @param [Hash] source
  # @param [Array] acc
  # @param [Array] namespace
  #
  # @return [Array<String>]
  def dotted_paths(source = self, acc = Array.new, namespace = Array.new)
    if source.is_a?(Hash) && !source.empty?
      source.each do |key, value|
        branch = namespace.dup
        branch << key
        dotted_paths(value, acc, branch)
      end
    else
      acc << namespace.join('.')
    end

    acc
  end
end
