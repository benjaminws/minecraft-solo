module Chozo
  # @author Jamie Winsor <jamie@vialstudios.com>
  class CleanRoomBase
    class << self
      # Create a DSL writer function that will assign the a given value
      # to the real object of this clean room.
      #
      # @param [Symbol] attribute
      def dsl_attr_writer(attribute)
        class_eval do
          define_method(attribute) do |value|
            set_attribute(attribute, value)
          end
        end
      end
    end

    def initialize(real_model)
      @real_model = real_model
      @noisy      = real_model.class.noisy_clean_room
    end

    private

      attr_reader :noisy
      attr_reader :real_model

      def set_attribute(name, value)
        real_model.send("#{name}=", value)
      end

      def method_missing(*args)
        noisy ? super : nil
      end
  end
end
