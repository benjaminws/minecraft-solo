require_relative 'bootstrapper/context'
require_relative 'logging'

module Ridley
  # @author Jamie Winsor <reset@riotgames.com>
  class Bootstrapper
    include Celluloid
    include Ridley::Logging

    # @return  [Array<String>]
    attr_reader :hosts

    # @return [Hash]
    attr_reader :options

    # @param [Array<#to_s>] hosts
    # @option options [Hash] :ssh
    #   * :user (String) a shell user that will login to each node and perform the bootstrap command on (required)
    #   * :password (String) the password for the shell user that will perform the bootstrap
    #   * :keys (Array, String) an array of keys (or a single key) to authenticate the ssh user with instead of a password
    #   * :timeout (Float) [5.0] timeout value for SSH bootstrap
    # @option options [Hash] :winrm
    #   * :user (String) a user that will login to each node and perform the bootstrap command on (required)
    #   * :password (String) the password for the user that will perform the bootstrap
    #   * :port (Fixnum) the winrm port to connect on the node the bootstrap will be performed on (5985)
    # @option options [String] :validator_client
    # @option options [String] :validator_path
    #   filepath to the validator used to bootstrap the node (required)
    # @option options [String] :bootstrap_proxy (nil)
    #   URL to a proxy server to bootstrap through
    # @option options [String] :encrypted_data_bag_secret
    #   your organizations encrypted data bag secret
    # @option options [Hash] :hints (Hash.new)
    #   a hash of Ohai hints to place on the bootstrapped node
    # @option options [Hash] :attributes (Hash.new)
    #   a hash of attributes to use in the first Chef run
    # @option options [Array] :run_list (Array.new)
    #   an initial run list to bootstrap with
    # @option options [String] :chef_version (nil)
    #   version of Chef to install on the node
    # @option options [String] :environment ('_default')
    #   environment to join the node to
    # @option options [Boolean] :sudo (true)
    #   bootstrap with sudo (default: true)
    # @option options [String] :template
    #   bootstrap template to use
    def initialize(hosts, options = {})
      @hosts         = Array(hosts).flatten.collect(&:to_s).uniq
      @options       = options.dup
      @options[:ssh] ||= Hash.new
      @options[:ssh] = {
        timeout: 5.0,
        sudo: true
      }.merge(@options[:ssh])

      @options[:sudo] = @options[:ssh][:sudo]
    end

    # @raise [Errors::HostConnectionError] if a node is unreachable
    #
    # @return [Array<Bootstrapper::Context>]
    def contexts
      @contexts ||= @hosts.collect { |host| Context.create(host, options) }
    end

    # @raise [Errors::HostConnectionError] if a node is unreachable
    #
    # @return [HostConnector::ResponseSet]
    def run
      workers = Array.new
      futures = contexts.collect do |context|
        log.info { "Running bootstrap command on #{context.host}" }

        workers << worker = context.host_connector::Worker.new(context.host, self.options.freeze)

        worker.future.run(context.template_binding.boot_command)
      end

      HostConnector::ResponseSet.new.tap do |response_set|
        futures.each do |future|
          status, response = future.value
          response_set.add_response(response)
        end
      end
    ensure
      workers.map(&:terminate)
    end
  end
end
