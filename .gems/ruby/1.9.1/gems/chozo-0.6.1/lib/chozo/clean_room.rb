module Chozo
  # @author Jamie Winsor <jamie@vialstudios.com>
  module CleanRoom
    module ClassMethods
      @noisy_clean_room = false

      # @return [CleanRoomBase]
      def clean_room
        @clean_room ||= CleanRoom.fabricate(self)
      end

      # @param [#to_s] filepath
      #
      # @return [Cookbook::Metadata]
      def from_file(filepath)
        filepath = filepath.to_s

        if File.extname(filepath) =~ /\.json/
          from_json_file(filepath)
        else
          from_ruby_file(filepath)
        end
      end

      def from_json_file(filepath)
        json_metadata = JSON.parse(File.read(filepath))
        
        obj = new
        obj.clean_eval do
          json_metadata.each { |key, val| send(key.to_sym, val) }
        end
        obj
      end

      def from_ruby_file(filepath)
        obj = new
        obj.clean_eval(File.read(filepath), filepath, 1)
        obj
      end

      def set_clean_room(klass)
        @clean_room = klass
      end

      def noisy_clean_room(value = nil)
        if value.nil?
          @noisy_clean_room
        else
          @noisy_clean_room = value
        end
      end
    end

    class << self
      def included(base)
        base.extend(ClassMethods)
        base.send(:include, Chozo::VariaModel)
      end

      def fabricate(klass)
        Class.new(CleanRoomBase) do
          klass.attributes.each do |name, _|
            dsl_attr_writer name.to_sym
          end
        end
      end
    end

    # @param [String, Proc] data
    def clean_eval(*args, &block)
      data = args.shift
      unless data.nil?
        block = data.is_a?(Proc) ? data : proc { eval(data, binding, *args) }
      end

      self.class.clean_room.new(self).instance_eval(&block)
    end
  end
end
