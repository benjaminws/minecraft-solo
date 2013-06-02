require 'chozo/errors'

module Chozo
  module Config
    # @author Jamie Winsor <jamie@vialstudios.com>
    class JSON < Config::Abstract
      class << self
        # @param [String] data
        #
        # @return [~Chozo::Config::JSON]
        def from_json(data)
          new.from_json(data)
        end

        # @param [String] path
        #
        # @raise [Chozo::Errors::ConfigNotFound]
        #
        # @return [~Chozo::Config::JSON]
        def from_file(path)
          path = File.expand_path(path)
          data = File.read(path)
          new(path).from_json(data)
        rescue TypeError, Errno::ENOENT, Errno::EISDIR
          raise Chozo::Errors::ConfigNotFound, "No configuration found at: '#{path}'"
        end
      end

      # @see {VariaModel#from_json}
      #
      # @raise [Chozo::Errors::InvalidConfig]
      #
      # @return [Chozo::Config::JSON]
      def from_json(*args)
        super
      rescue MultiJson::DecodeError => e
        raise Chozo::Errors::InvalidConfig, e
      end

      def save(destination = self.path)
        if destination.nil?
          raise Errors::ConfigSaveError, "Cannot save configuration without a destination. Provide one to save or set one on the object."
        end

        FileUtils.mkdir_p(File.dirname(destination))
        File.open(destination, 'w+') do |f|
          f.write(self.to_json(pretty: true))
        end
      end

      # Reload the current configuration file from disk
      #
      # @return [Chozo::Config::JSON]
      def reload
        mass_assign(self.class.from_file(path).to_hash)
        self
      end
    end
  end
end
