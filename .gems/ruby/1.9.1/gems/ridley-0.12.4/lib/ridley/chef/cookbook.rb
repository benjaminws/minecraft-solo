module Ridley::Chef
  # @author Jamie Winsor <reset@riotgames.com>
  class Cookbook
    require_relative 'cookbook/metadata'
    require_relative 'cookbook/syntax_check'

    class << self
      # @param [String] filepath
      #   a path on disk to the location of a file to checksum
      #
      # @return [String]
      #   a checksum that can be used to uniquely identify the file understood
      #   by a Chef Server.
      def checksum(filepath)
        Ridley::Chef::Digester.md5_checksum_for_file(filepath)
      end

      # Creates a new instance of Ridley::Chef::Cookbook from a path on disk containing
      # a Cookbook.
      #
      # The name of the Cookbook is determined by the value of the name attribute set in
      # the cookbooks' metadata. If the name attribute is not present the name of the loaded
      # cookbook is determined by directory containing the cookbook.
      #
      # @param [#to_s] path
      #   a path on disk to the location of a Cookbook
      #
      # @option options [String] :name
      #   explicitly supply the name of the cookbook we are loading. This is useful if
      #   you are dealing with a cookbook that does not have well-formed metadata
      #
      # @raise [IOError] if the path does not contain a metadata.rb or metadata.json file
      #
      # @return [Ridley::Chef::Cookbook]
      def from_path(path, options = {})
        path     = Pathname.new(path)
        metadata = if path.join('metadata.rb').exist?
          Cookbook::Metadata.from_file(path.join('metadata.rb'))
        elsif path.join('metadata.json').exist?
          Cookbook::Metadata.from_json(File.read(path.join('metadata.json')))
        else
          raise IOError, "no metadata.rb or metadata.json found at #{path}"
        end

        metadata.name(options[:name].presence || metadata.name.presence || File.basename(path))
        new(metadata.name, path, metadata)
      end
    end

    CHEF_TYPE       = "cookbook_version".freeze
    CHEF_JSON_CLASS = "Chef::CookbookVersion".freeze

    extend Forwardable

    attr_reader :cookbook_name
    attr_reader :path
    attr_reader :metadata
    # @return [Hashie::Mash]
    #   a Hashie::Mash containing Cookbook file category names as keys and an Array of Hashes
    #   containing metadata about the files belonging to that category. This is used
    #   to communicate what a Cookbook looks like when uploading to a Chef Server.
    #
    #   example:
    #     {
    #       :recipes => [
    #         {
    #           name: "default.rb",
    #           path: "recipes/default.rb",
    #           checksum: "fb1f925dcd5fc4ebf682c4442a21c619",
    #           specificity: "default"
    #         }
    #       ]
    #       ...
    #       ...
    #     }
    attr_reader :manifest

    # @return [Boolean]
    attr_accessor :frozen

    def_delegator :@metadata, :version

    def initialize(name, path, metadata)
      @cookbook_name = name
      @path          = Pathname.new(path)
      @metadata      = metadata
      @files         = Array.new
      @manifest      = Hashie::Mash.new(
        recipes: Array.new,
        definitions: Array.new,
        libraries: Array.new,
        attributes: Array.new,
        files: Array.new,
        templates: Array.new,
        resources: Array.new,
        providers: Array.new,
        root_files: Array.new
      )
      @frozen        = false
      @chefignore    = Ridley::Chef::Chefignore.new(@path)

      load_files
    end

    # @return [Hash]
    #   an hash containing the checksums and expanded file paths of all of the
    #   files found in the instance of CachedCookbook
    #
    #   example:
    #     {
    #       "da97c94bb6acb2b7900cbf951654fea3" => "/Users/reset/.ridley/nginx-0.101.2/README.md"
    #     }
    def checksums
      {}.tap do |checksums|
        files.each do |file|
          checksums[self.class.checksum(file)] = file
        end
      end
    end

    # @param [Symbol] category
    #   the category of file to generate metadata about
    # @param [String] target
    #   the filepath to the file to get metadata information about
    #
    # @return [Hash]
    #   a Hash containing a name, path, checksum, and specificity key representing the
    #   metadata about a file contained in a Cookbook. This metadata is used when
    #   uploading a Cookbook's files to a Chef Server.
    #
    # @example
    #   file_metadata(:root_files, "somefile.h") => {
    #     name: "default.rb",
    #     path: "recipes/default.rb",
    #     checksum: "fb1f925dcd5fc4ebf682c4442a21c619",
    #     specificity: "default"
    #   }
    def file_metadata(category, target)
      target = Pathname.new(target)

      {
        name: target.basename.to_s,
        path: target.relative_path_from(path).to_s,
        checksum: self.class.checksum(target),
        specificity: file_specificity(category, target)
      }
    end

    # @param [Symbol] category
    # @param [Pathname] target
    #
    # @return [String]
    def file_specificity(category, target)
      case category
      when :files, :templates
        relpath = target.relative_path_from(path).to_s
        relpath.slice(/(.+)\/(.+)\/.+/, 2)
      else
        'default'
      end
    end

    # @return [String]
    #   the name of the cookbook and the version number separated by a dash (-).
    #
    #   example:
    #     "nginx-0.101.2"
    def name
      "#{cookbook_name}-#{version}"
    end

    def validate
      raise IOError, "No Cookbook found at: #{path}" unless path.exist?

      unless syntax_checker.validate_ruby_files
        raise Ridley::Errors::CookbookSyntaxError, "Invalid ruby files in cookbook: #{cookbook_name} (#{version})."
      end
      unless syntax_checker.validate_templates
        raise Ridley::Errors::CookbookSyntaxError, "Invalid template files in cookbook: #{cookbook_name} (#{version})."
      end

      true
    end

    def to_hash
      result                 = manifest.dup
      result[:chef_type]     = CHEF_TYPE
      result[:name]          = name
      result[:cookbook_name] = cookbook_name
      result[:version]       = version
      result[:metadata]      = metadata
      result[:frozen?]       = frozen
      result.to_hash
    end

    def to_json(*args)
      result               = self.to_hash
      result['json_class'] = CHEF_JSON_CLASS
      result.to_json(*args)
    end

    def to_s
      "#{cookbook_name} (#{version}) '#{path}'"
    end

    def <=>(other)
      [self.cookbook_name, self.version] <=> [other.cookbook_name, other.version]
    end

    private

      # @return [Array]
      attr_reader :files
      # @return [Ridley::Chef::Chefignore]
      attr_reader :chefignore

      def_delegator :chefignore, :ignored?

      def load_files
        load_shallow(:recipes, 'recipes', '*.rb')
        load_shallow(:definitions, 'definitions', '*.rb')
        load_shallow(:libraries, 'libraries', '*.rb')
        load_shallow(:attributes, 'attributes', '*.rb')
        load_recursively(:files, "files", "*")
        load_recursively(:templates, "templates", "*")
        load_recursively(:resources, "resources", "*.rb")
        load_recursively(:providers, "providers", "*.rb")
        load_root
      end

      def load_root
        [].tap do |files|
          Dir.glob(path.join('*'), File::FNM_DOTMATCH).each do |file|
            next if File.directory?(file)
            next if ignored?(file)
            @files << file
            @manifest[:root_files] << file_metadata(:root_files, file)
          end
        end
      end

      def load_recursively(category, category_dir, glob)
        [].tap do |files|
          file_spec = path.join(category_dir, '**', glob)
          Dir.glob(file_spec, File::FNM_DOTMATCH).each do |file|
            next if File.directory?(file)
            next if ignored?(file)
            @files << file
            @manifest[category] << file_metadata(category, file)
          end
        end
      end

      def load_shallow(category, *path_glob)
        [].tap do |files|
          Dir[path.join(*path_glob)].each do |file|
            next if ignored?(file)
            @files << file
            @manifest[category] << file_metadata(category, file)
          end
        end
      end

      def syntax_checker
        @syntax_checker ||= Cookbook::SyntaxCheck.new(path.to_s)
      end
  end
end
