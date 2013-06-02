module Ridley
  # @author Jamie Winsor <reset@riotgames.com>
  # @api private
  class SandboxUploader
    class << self
      # Return the checksum of the contents of the file at the given filepath
      #
      # @param [String] path
      #   file to checksum
      #
      # @return [String]
      #   the binary checksum of the contents of the file
      def checksum(path)
        File.open(path, 'rb') { |f| checksum_io(f, Digest::MD5.new) }
      end

      # Return a base64 encoded checksum of the contents of the given file. This is the expected
      # format of sandbox checksums given to the Chef Server.
      #
      # @param [String] path
      #
      # @return [String]
      #   a base64 encoded checksum
      def checksum64(path)
        Base64.encode64([checksum(path)].pack("H*")).strip
      end

      # @param [String] io
      # @param [Object] digest
      #
      # @return [String]
      def checksum_io(io, digest)
        while chunk = io.read(1024 * 8)
          digest.update(chunk)
        end
        digest.hexdigest
      end
    end

    include Celluloid

    attr_reader :client_name
    attr_reader :client_key
    attr_reader :options

    def initialize(client_name, client_key, options = {})
      @client_name = client_name
      @client_key  = client_key
      @options     = options
    end

    # Upload one file into the sandbox for the given checksum id
    #
    # @param [Ridley::SandboxObject] sandbox
    # @param [String] chk_id
    #   checksum of the file being uploaded
    # @param [String] path
    #   path to the file to upload
    #
    # @return [Hash, nil]
    def upload(sandbox, chk_id, path)
      checksum = sandbox.checksum(chk_id)

      unless checksum[:needs_upload]
        return nil
      end

      headers  = {
        'Content-Type' => 'application/x-binary',
        'content-md5' => self.class.checksum64(path)
      }
      contents = File.open(path, 'rb') { |f| f.read }

      url         = URI(checksum[:url])
      upload_path = url.path
      url.path    = ""

      # versions prior to OSS Chef 11 will strip the port to upload the file to in the checksum
      # url returned. This will ensure we are uploading to the proper location.
      if sandbox.send(:resource).connection.foss?
        url.port = URI(sandbox.send(:resource).connection.server_url).port
      end

      begin
        Faraday.new(url, self.options) do |c|
          c.response :chef_response
          c.response :follow_redirects
          c.request :chef_auth, self.client_name, self.client_key
          c.adapter :net_http
        end.put(upload_path, contents, headers)
      rescue Ridley::Errors::HTTPError => ex
        abort(ex)
      end
    end
  end
end
