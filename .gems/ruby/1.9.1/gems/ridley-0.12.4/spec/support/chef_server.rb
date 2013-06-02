require 'chef_zero/server'
require_relative 'spec_helpers'

module Ridley::RSpec
  module ChefServer
    PORT = 8889

    class << self
      include Ridley::SpecHelpers

      def clear_request_log
        @request_log = Array.new
      end

      def request_log
        @request_log ||= Array.new
      end

      def server
        @server ||= ChefZero::Server.new(port: PORT)
      end

      def server_url
        (@server && @server.url) || "http://localhost/#{PORT}"
      end

      def start
        server.start_background
        server.on_response do |request, response|
          request_log << [ request, response ]
        end
        clear_request_log

        server
      end

      def stop
        @server.stop if @server
      end

      def running?
        @server && @server.running?
      end
    end

    def chef_client(name, hash = Hash.new)
      load_data(:clients, name, hash)
    end

    def chef_cookbook(name, version, cookbook = Hash.new)
      ChefServer.server.load_data("cookbooks" => { "#{name}-#{version}" => cookbook })
    end

    def chef_data_bag(name, hash = Hash.new)
      ChefServer.server.load_data({ 'data' => { name => hash }})
    end

    def chef_environment(name, hash = Hash.new)
      load_data(:environments, name, hash)
    end

    def chef_node(name, hash = Hash.new)
      load_data(:nodes, name, hash)
    end

    def chef_role(name, hash = Hash.new)
      load_data(:roles, name, hash)
    end

    private

      def load_data(key, name, hash)
        ChefServer.server.load_data(key.to_s => { name => JSON.fast_generate(hash) })
      end
  end
end
