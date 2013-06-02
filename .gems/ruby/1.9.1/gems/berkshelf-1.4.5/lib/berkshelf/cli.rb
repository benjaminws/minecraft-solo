require 'berkshelf'

module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  class Cli < Thor
    class << self
      def dispatch(meth, given_args, given_opts, config)
        unless (given_args & ['-h', '--help']).empty?
          if given_args.length == 1
            # berks --help
            super
          else
            command = given_args.first
            super(meth, ['help', command].compact, nil, config)
          end
        else
          super
          Berkshelf.formatter.cleanup_hook unless config[:current_command].name == "help"
        end
      end
    end

    def initialize(*args)
      super(*args)

      if @options[:config]
        unless File.exist?(@options[:config])
          raise BerksConfigNotFound, "You specified a path to a configuration file that did not exist: '#{@options[:config]}'"
        end
        Berkshelf::Config.path = @options[:config]
      end

      if @options[:debug]
        Berkshelf.logger.level = ::Logger::DEBUG
      end

      if @options[:quiet]
        Berkshelf.ui.mute!
      end

      Berkshelf.set_format @options[:format]
      @options = options.dup # unfreeze frozen options Hash from Thor
    end

    namespace "berkshelf"

    map 'in'   => :install
    map 'up'   => :upload
    map 'ud'   => :update
    map 'ls'   => :list
    map 'book' => :cookbook
    map ['ver', '-v', '--version'] => :version

    default_task :install

    class_option :config,
      type: :string,
      desc: "Path to Berkshelf configuration to use.",
      aliases: "-c",
      banner: "PATH"
    class_option :format,
      type: :string,
      default: "human",
      desc: "Output format to use.",
      aliases: "-F",
      banner: "FORMAT"
    class_option :quiet,
      type: :boolean,
      desc: "Silence all informational output.",
      aliases: "-q",
      default: false
    class_option :debug,
      type: :boolean,
      desc: "Output debug information",
      aliases: "-d",
      default: false

    method_option :force,
      type: :boolean,
      default: false,
      desc: "create a new configuration file even if one already exists."
    desc "configure", "Create a new configuration file to customize Berkshelf's behavior"
    def configure(path = Berkshelf::Config.path)
      path = File.expand_path(path)

      if File.exist?(path) && !options[:force]
        raise Berkshelf::ConfigExists, "A configuration file already exists. Re-run with the --force flag if you wish to overwrite it."
      end

      @config = Berkshelf::Config.new(path)

      [
        "chef.chef_server_url",
        "chef.node_name",
        "chef.client_key",
        "chef.validation_client_name",
        "chef.validation_key_path",
        "vagrant.vm.box",
        "vagrant.vm.box_url",
      ].each do |attribute|
        default = @config.get_attribute(attribute)

        message = "Enter value for #{attribute}"
        message << " (default: '#{default}')" if default
        message << ": "

        input = Berkshelf.ui.ask(message)

        if input.present?
          @config.set_attribute(attribute, input)
        end
      end

      unless @config.valid?
        raise InvalidConfiguration.new(@config.errors)
      end

      @config.save

      Berkshelf.formatter.msg "Config written to: '#{path}'"
    end

    desc "open NAME", "Opens the source directory of an installed cookbook"
    def open(name)
      editor = [ENV['BERKSHELF_EDITOR'], ENV['VISUAL'], ENV['EDITOR']].find{|e| !e.nil? && !e.empty? }
      raise ArgumentError, "To open a cookbook, set $EDITOR or $BERKSHELF_EDITOR" unless editor

      cookbook = Berkshelf.cookbook_store.cookbooks(name).last
      raise CookbookNotFound, "Cookbook '#{name}' not found in any of the sources!" unless cookbook

      Dir.chdir(cookbook.path) do
        command = "#{editor} #{cookbook.path}"
        success = system(command)
        raise CommandUnsuccessful, "Could not run `#{command}`" unless success
      end
    end

    method_option :except,
      type: :array,
      desc: "Exclude cookbooks that are in these groups.",
      aliases: "-e"
    method_option :only,
      type: :array,
      desc: "Only cookbooks that are in these groups.",
      aliases: "-o"
    method_option :berksfile,
      type: :string,
      default: File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME),
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    method_option :path,
      type: :string,
      desc: "Path to install cookbooks to (i.e. vendor/cookbooks).",
      aliases: "-p",
      banner: "PATH"
    desc "install", "Install the Cookbooks specified by a Berksfile or a Berksfile.lock"
    def install
      berksfile = ::Berkshelf::Berksfile.from_file(options[:berksfile])
      berksfile.install(options)
    end

    method_option :berksfile,
      type: :string,
      default: File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME),
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    method_option :except,
      type: :array,
      desc: "Exclude cookbooks that are in these groups.",
      aliases: "-e"
    method_option :only,
      type: :array,
      desc: "Only cookbooks that are in these groups.",
      aliases: "-o"
    desc "update [COOKBOOKS]", "Update all Cookbooks and their dependencies specified by a Berksfile to their latest versions"
    def update(*cookbook_names)
      berksfile = Berksfile.from_file(options[:berksfile])

      update_options = {
        cookbooks: cookbook_names
      }.merge(options).symbolize_keys

      berksfile.update(update_options)
    end

    method_option :berksfile,
      type: :string,
      default: File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME),
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    method_option :except,
      type: :array,
      desc: "Exclude cookbooks that are in these groups.",
      aliases: "-e"
    method_option :only,
      type: :array,
      desc: "Only cookbooks that are in these groups.",
      aliases: "-o"
    method_option :no_freeze,
      type: :boolean,
      default: false,
      desc: "Do not freeze uploaded cookbook(s)."
    method_option :force,
      type: :boolean,
      default: false,
      desc: "Upload all cookbook(s) even if a frozen one exists on the Chef Server."
    method_option :ssl_verify,
      type: :boolean,
      default: nil,
      desc: "Disable/Enable SSL verification when uploading cookbooks."
    method_option :skip_syntax_check,
      type: :boolean,
      default: false,
      desc: "Skip Ruby syntax check when uploading cookbooks.",
      aliases: "-s"
    method_option :skip_dependencies,
      type: :boolean,
      desc: "Skip uploading dependent cookbook(s).",
      default: false,
      aliases: "-D"
    method_option :halt_on_frozen,
      type: :boolean,
      default: false,
      desc: "Halt uploading and exit if the Chef Server has a frozen version of the cookbook(s)."
    desc "upload [COOKBOOKS]", "Upload cookbook(s) specified by a Berksfile to the configured Chef Server."
    def upload(*cookbook_names)
      berksfile = ::Berkshelf::Berksfile.from_file(options[:berksfile])

      upload_options             = Hash[options.except(:no_freeze, :berksfile)].symbolize_keys
      upload_options[:cookbooks] = cookbook_names
      upload_options[:freeze]    = false if options[:no_freeze]

      berksfile.upload(upload_options)
    end

    method_option :berksfile,
      type: :string,
      default: File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME),
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    method_option :except,
      type: :array,
      desc: "Exclude cookbooks that are in these groups.",
      aliases: "-e"
    method_option :only,
      type: :array,
      desc: "Only cookbooks that are in these groups.",
      aliases: "-o"
    desc "outdated [COOKBOOKS]", "Show all outdated cookbooks (exclusively from the community site)"
    def outdated(*cookbook_names)
      berksfile = ::Berkshelf::Berksfile.from_file(options[:berksfile])
      Berkshelf.formatter.msg "Listing outdated cookbooks with newer versions available..."
      Berkshelf.formatter.msg "BETA: this feature will only pull differences from the community site and will"
      Berkshelf.formatter.msg "BETA: ignore all other sources you may have defined"
      Berkshelf.formatter.msg ""

      outdated_options = {
        cookbooks: cookbook_names
      }.merge(options).symbolize_keys

      outdated = berksfile.outdated(outdated_options)

      if outdated.empty?
        Berkshelf.formatter.msg "All cookbooks up to date"
      else
        outdated.each do |cookbook, latest_version|
          Berkshelf.formatter.msg "Cookbook '#{cookbook.name} (#{cookbook.version_constraint})' is outdated (#{latest_version})"
        end
      end
    end

    method_option :foodcritic,
      type: :boolean,
      desc: "Creates a Thorfile with Foodcritic support to lint test your cookbook"
    method_option :scmversion,
      type: :boolean,
      desc: "Creates a Thorfile with SCMVersion support to manage versions for continuous integration"
    method_option :no_bundler,
      type: :boolean,
      desc: "Skips generation of a Gemfile and other Bundler specific support"
    method_option :vagrant,
      type: :boolean,
      hide: true
    method_option :skip_vagrant,
      type: :boolean,
      desc: "Skips adding a Vagrantfile and adding supporting gems to the Gemfile"
    method_option :git,
      type: :boolean,
      hide: true
    method_option :skip_git,
      type: :boolean,
      desc: "Skips adding a .gitignore and running git init in the cookbook directory"
    desc "init [PATH]", "Prepare a local path to have its Cookbook dependencies managed by Berkshelf"
    def init(path = Dir.pwd)
      Berkshelf.formatter.deprecation "--git is now the default" if options[:git]
      Berkshelf.formatter.deprecation "--vagrant is now the default" if options[:vagrant]

      if File.chef_cookbook?(path)
        options[:chefignore] = true
        options[:metadata_entry] = true
      end

      ::Berkshelf::InitGenerator.new([path], options).invoke_all

      ::Berkshelf.formatter.msg "Successfully initialized"
    end

    method_option :berksfile,
      type: :string,
      default: File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME),
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    desc "list", "Show all of the cookbooks in the current Berkshelf"
    def list
      berksfile = ::Berkshelf::Berksfile.from_file(options[:berksfile])

      Berkshelf.ui.say "Cookbooks installed by your Berksfile:"
      Berkshelf.ui.mute { berksfile.resolve }.sort.each do |cookbook|
        Berkshelf.ui.say "  * #{cookbook.cookbook_name} (#{cookbook.version})"
      end
    end

    method_option :berksfile,
      type: :string,
      default: File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME),
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    desc "show COOKBOOK", "Display the source path on the local file system for the given cookbook"
    def show(name)
      berksfile = ::Berkshelf::Berksfile.from_file(options[:berksfile])
      cookbook = Berkshelf.ui.mute { berksfile.resolve }.find{ |cookbook| cookbook.cookbook_name == name }

      raise CookbookNotFound, "Cookbook '#{name}' was not installed by your Berksfile" unless cookbook
      Berkshelf.ui.say(cookbook.path)
    end

    method_option :version,
      type: :string,
      desc: 'The version of the cookbook to display.',
      aliases: '-v'
    desc "info [COOKBOOK]", "Display name, author, copyright, and dependency information about a cookbook"
    def info(name)
      if options[:version]
        cookbook = Berkshelf.cookbook_store.cookbook(name, options[:version])
      else
        cookbook = Berkshelf.cookbook_store.cookbooks(name).sort_by(&:version).last
      end

      raise CookbookNotFound, "Cookbook '#{name}' was not installed by your Berksfile" if cookbook.nil?
      Berkshelf.ui.say(cookbook.pretty_print)
    end

    method_option :berksfile,
      type: :string,
      default: File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME),
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    desc "contingent COOKBOOK", "Display a list of cookbooks that depend on the given cookbook"
    def contingent(name)
      berksfile = ::Berkshelf::Berksfile.from_file(options[:berksfile])

      Berkshelf.ui.say "Cookbooks contingent upon #{name}:"
      sources = Berkshelf.ui.mute { berksfile.resolve }.sort.each do |cookbook|
        if cookbook.dependencies.include?(name)
          Berkshelf.ui.say "  * #{cookbook.cookbook_name} (#{cookbook.version})"
        end
      end
    end

    desc "version", "Display version and copyright information"
    def version
      Berkshelf.formatter.msg version_header
      Berkshelf.formatter.msg "\n"
      Berkshelf.formatter.msg license
    end

    method_option :foodcritic,
      type: :boolean,
      desc: "Creates a Thorfile with Foodcritic support to lint test your cookbook"
    method_option :chef_minitest,
      type: :boolean,
      desc: "Creates chef-minitest support files and directories, adds minitest-handler cookbook to run_list of Vagrantfile"
    method_option :scmversion,
      type: :boolean,
      desc: "Creates a Thorfile with SCMVersion support to manage versions for continuous integration"
    method_option :license,
      type: :string,
      default: "reserved",
      desc: "License for cookbook (apachev2, gplv2, gplv3, mit, reserved)",
      aliases: "-L"
    method_option :maintainer,
      type: :string,
      desc: "Name of cookbook maintainer",
      aliases: "-m"
    method_option :maintainer_email,
      type: :string,
      desc: "Email address of cookbook maintainer",
      aliases: "-e"
    method_option :no_bundler,
      type: :boolean,
      desc: "Skips generation of a Gemfile and other Bundler specific support"
    method_option :vagrant,
      type: :boolean,
      hide: true
    method_option :skip_vagrant,
      type: :boolean,
      desc: "Skips adding a Vagrantfile and adding supporting gems to the Gemfile"
    method_option :git,
      type: :boolean,
      hide: true
    method_option :skip_git,
      type: :boolean,
      desc: "Skips adding a .gitignore and running git init in the cookbook directory"
    desc "cookbook NAME", "Create a skeleton for a new cookbook"
    def cookbook(name)
      Berkshelf.formatter.deprecation "--git is now the default" if options[:git]
      Berkshelf.formatter.deprecation "--vagrant is now the default" if options[:vagrant]

      unless Config.instance.valid?
        raise InvalidConfiguration.new(Config.instance.errors)
      end

      ::Berkshelf::CookbookGenerator.new([File.join(Dir.pwd, name), name], options).invoke_all
    end

    private

      def version_header
        "Berkshelf (#{Berkshelf::VERSION})"
      end

      def license
        File.read(Berkshelf.root.join('LICENSE'))
      end
  end
end
