module Chozo
  # @author Jamie Winsor <jamie@vialstudios.com>
  module Errors
    class ChozoError < StandardError; end
    class ConfigNotFound < ChozoError; end
    class InvalidConfig < ChozoError; end
    class ConfigSaveError < ChozoError; end
  end
end
