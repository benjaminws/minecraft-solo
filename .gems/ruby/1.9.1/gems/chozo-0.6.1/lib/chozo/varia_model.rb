require 'multi_json'
require 'chozo/core_ext'
require 'chozo/hashie_ext'

module Chozo
  # @author Jamie Winsor <jamie@vialstudios.com>
  module VariaModel
    module ClassMethods
      ASSIGNMENT_MODES = [
        :whitelist,
        :carefree
      ]

      # @return [Hashie::Mash]
      def attributes
        @attributes ||= Hashie::Mash.new
      end

      # @return [Hashie::Mash]
      def validations
        @validations ||= Hashie::Mash.new
      end

      # @return [Symbol]
      def assignment_mode
        @assignment_mode ||= :whitelist
      end

      # Set the attribute mass assignment mode
      #   * :whitelist - only attributes defined on the class will have values set
      #   * :carefree  - values will be set for attributes that are not explicitly defined
      #                  in the class definition 
      #
      # @param [Symbol] mode
      #   an assignment mode to use @see {ASSIGNMENT_MODES}
      def set_assignment_mode(mode)
        unless ASSIGNMENT_MODES.include?(mode)
          raise ArgumentError, "unknown assignment mode: #{mode}"
        end

        @assignment_mode = mode
      end

      # @param [#to_s] name
      # @option options [Symbol, Array<Symbol>] :type
      # @option options [Boolean] :required
      # @option options [Object] :default
      # @option options [Proc] :coerce
      def attribute(name, options = {})
        name = name.to_s
        options[:type] = Array(options[:type])
        options[:required] ||= false

        register_attribute(name, options)
        define_mimic_methods(name, options)
      end

      # @param [String] name
      #
      # @return [Array]
      def validations_for(name)
        self.validations[name] ||= Array.new
      end

      # @param [Constant, Array<Constant>] types
      # @param [VariaModel] model
      # @param [String] key
      #
      # @return [Array]
      def validate_kind_of(types, model, key)
        errors  = Array.new
        types   = types.uniq
        matches = false

        types.each do |type|
          if model.get_attribute(key).is_a?(type)
            matches = true
            break
          end
        end

        if matches
          [ :ok, "" ]
        else
          types_msg = types.collect { |type| "'#{type}'" }
          [ :error, "Expected attribute: '#{key}' to be a type of: #{types_msg.join(', ')}" ]
        end
      end

      # Validate that the attribute on the given model has a non-nil value assigned
      #
      # @param [VariaModel] model
      # @param [String] key
      #
      # @return [Array]
      def validate_required(model, key)
        if model.get_attribute(key).nil?
          [ :error, "A value is required for attribute: '#{key}'" ]
        else
          [ :ok, "" ]
        end
      end

      private

        def register_attribute(name, options = {})
          if options[:type] && options[:type].any?
            unless options[:required]
              options[:type] << NilClass
            end
            register_validation(name, lambda { |object, key| validate_kind_of(options[:type], object, key) })
          end

          if options[:required]
            register_validation(name, lambda { |object, key| validate_required(object, key) })
          end

          class_eval do
            new_attributes = Hashie::Mash.from_dotted_path(name, options[:default])
            self.attributes.merge!(new_attributes)
            
            if options[:coerce].is_a?(Proc)
              register_coercion(name, options[:coerce])
            end
          end
        end

        def register_validation(name, fun)
          self.validations[name] = (self.validations_for(name) << fun)
        end

        def register_coercion(name, fun)
          self.attributes.container(name).set_coercion(name.split('.').last, fun)
        end

        def define_mimic_methods(name, options = {})
          fun_name = name.split('.').first
          
          class_eval do
            define_method fun_name do
              _attributes_[fun_name]
            end

            define_method "#{fun_name}=" do |value|
              value = if options[:coerce].is_a?(Proc)
                options[:coerce].call(value)
              else
                value
              end

              _attributes_[fun_name] = value
            end
          end
        end
    end

    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end

    # @return [HashWithIndifferentAccess]
    def validate
      self.class.validations.each do |attr_path, validations|
        validations.each do |validation|
          status, messages = validation.call(self, attr_path)

          if status == :error
            if messages.is_a?(Array)
              messages.each do |message|
                self.add_error(attr_path, message)
              end
            else
              self.add_error(attr_path, messages)
            end
          end
        end
      end

      self.errors
    end

    # @return [Boolean]
    def valid?
      validate.empty?
    end

    # @return [HashWithIndifferentAccess]
    def errors
      @errors ||= HashWithIndifferentAccess.new
    end

    # Assigns the attributes of a model from a given hash of attributes.
    #
    # If the assignment mode is set to `:whitelist`, then only the values of keys which have a
    # corresponding attribute definition on the model will be set. All other keys will have their
    # values ignored.
    #
    # If the assignment mode is set to `:carefree`, then the attributes hash will be populated
    # with any key/values that are provided.
    #
    # @param [Hash] new_attrs
    def mass_assign(new_attrs = {})
      case self.class.assignment_mode
      when :whitelist
        whitelist_assign(new_attrs)
      when :carefree
        carefree_assign(new_attrs)
      end
    end

    # @param [#to_s] key
    #
    # @return [Object]
    def get_attribute(key)
      _attributes_.dig(key.to_s)
    end
    alias_method :[], :get_attribute

    # @param [#to_s] key
    # @param [Object] value
    def set_attribute(key, value)
      _attributes_.deep_merge!(Hashie::Mash.from_dotted_path(key.to_s, value))
    end
    alias_method :[]=, :set_attribute

    # @param [#to_hash] hash
    #
    # @return [self]
    def from_hash(hash)
      mass_assign(hash.to_hash)
      self
    end

    # @param [String] data
    #
    # @return [self]
    def from_json(data)
      mass_assign(MultiJson.decode(data))
      self
    end

    # The storage hash containing all of the key/values for this object's attributes
    #
    # @return [Hashie::Mash]
    def _attributes_
      @_attributes_ ||= self.class.attributes.dup
    end
    alias_method :to_hash, :_attributes_

    # @option options [Boolean] :symbolize_keys
    # @option options [Class, Symbol, String] :adapter
    #
    # @return [String]
    def to_json(options = {})
      MultiJson.encode(_attributes_, options)
    end
    alias_method :as_json, :to_json

    protected

      # @param [String] attribute
      # @param [String] message
      def add_error(attribute, message)
        self.errors[attribute] ||= Array.new
        self.errors[attribute] << message
      end

    private

      def carefree_assign(new_attrs = {})
        _attributes_.deep_merge!(new_attrs)
      end

      def whitelist_assign(new_attrs = {})
        self.class.attributes.dotted_paths.each do |dotted_path|
          value = new_attrs.dig(dotted_path)
          next if value.nil?

          set_attribute(dotted_path, value)
        end
      end
  end
end
