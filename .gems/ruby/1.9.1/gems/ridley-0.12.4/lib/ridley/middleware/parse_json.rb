module Ridley
  module Middleware
    # @author Jamie Winsor <reset@riotgames.com>
    class ParseJson < Faraday::Response::Middleware
      include Ridley::Logging

      JSON_TYPE  = 'application/json'.freeze

      BRACKETS   = [
        "[",
        "{"
      ].freeze

      WHITESPACE = [
        " ",
        "\n",
        "\r",
        "\t"
      ].freeze

      class << self
        include Ridley::Logging

        # Takes a string containing JSON and converts it to a Ruby hash
        # symbols for keys
        #
        # @param [String] body
        #
        # @return [Hash]
        def parse(body)
          result = JSON.parse(body)
          result.is_a?(Hash) ? Hashie::Mash.new(result) : result
        end

        # Extracts the type of the response from the response headers
        # of a Faraday request env. 'text/html' will be returned if no
        # content-type is specified in the response
        #
        # @example
        #   env = {
        #     :response_headers => {
        #       'content-type' => 'text/html; charset=utf-8'
        #     }
        #     ...
        #   }
        #
        #   ParseJson.response_type(env) => 'application/json'
        #
        # @param [Hash] env
        #   a Faraday request env
        #
        # @return [String]
        def response_type(env)
          if env[:response_headers][CONTENT_TYPE].nil?
            log.debug { "response did not specify a content type" }
            return "text/html"
          end

          env[:response_headers][CONTENT_TYPE].split(';', 2).first
        end

        # Determines if the response of the given Faraday request env
        # contains JSON
        #
        # @param [Hash] env
        #   a Faraday request env
        #
        # @return [Boolean]
        def json_response?(env)
          response_type(env) == JSON_TYPE && looks_like_json?(env)
        end

        # Examines the body of a request env and returns true if it appears
        # to contain JSON or false if it does not
        #
        # @param [Hash] env
        #   a Faraday request env
        # @return [Boolean]
        def looks_like_json?(env)
          return false unless env[:body].present?

          BRACKETS.include?(first_char(env[:body]))
        end

        private

          def first_char(body)
            idx = -1
            begin
              char = body[idx += 1]
              char = char.chr if char
            end while char && WHITESPACE.include?(char)

            char
          end
      end

      def on_complete(env)
        if self.class.json_response?(env)
          log.debug { "==> parsing Chef response body as JSON" }
          env[:body] = self.class.parse(env[:body])
        else
          log.debug { "==> Chef response did not contain a JSON body" }
        end
      end
    end
  end
end

Faraday.register_middleware(:response, parse_json: Ridley::Middleware::ParseJson)
