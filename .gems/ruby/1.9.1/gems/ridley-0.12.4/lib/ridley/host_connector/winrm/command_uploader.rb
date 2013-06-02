module Ridley
  module HostConnector
    class WinRM
      # @author Kyle Allan <kallan@riotgames.com>
      # @author Justin Campbell <justin.campbell@riotgames.com>
      #
      # @example
      #   command_uploader = CommandUploader.new(long_command, winrm)
      #   command_uploader.upload
      #   command_uploader.command
      #
      #   This class is used by WinRM Workers when the worker is told to execute a command that
      #   might be too long for WinRM to handle.
      #
      #   After an instance of this class is created, the upload method will upload the long command
      #   to the node being worked on in chunks. Once on the node, some Powershell code will decode
      #   the long_command into a batch file. The command method will return a String representing the
      #   command the worker will use to execute the uploaded batch script.
      class CommandUploader
        CHUNK_LIMIT = 1024

        # @return [WinRM::WinRMWebService]
        attr_reader :winrm
        # @return [String]
        attr_reader :base64_file_name
        # @return [String]
        attr_reader :command_file_name

        # @param [WinRM::WinRMWebService] winrm
        def initialize(winrm)
          @winrm             = winrm
          @base64_file_name  = get_file_path("winrm-upload-base64-#{unique_string}")
          @command_file_name = get_file_path("winrm-upload-#{unique_string}.bat")
        end

        # Uploads the command encoded as base64 to a file on the host
        # and then uses Powershell to transform the base64 file into the
        # command that was originally passed through.
        #
        # @param [String] command_string
        def upload(command_string)
          upload_command(command_string)
          convert_command
        end

        # @return [String] the command to execute the uploaded file
        def command
          "cmd.exe /C #{command_file_name}"
        end

        # Runs a delete command on the files generated by #base64_file_name
        # and #command_file_name
        def cleanup
          winrm.run_cmd( "del #{base64_file_name} /F /Q" )
          winrm.run_cmd( "del #{command_file_name} /F /Q" )
        end

        private

          def upload_command(command_string)
            command_string_chars(command_string).each_slice(CHUNK_LIMIT) do |chunk|
              winrm.run_cmd( "echo #{chunk.join} >> \"#{base64_file_name}\"" )
            end
          end

          def command_string_chars(command_string)
            Base64.encode64(command_string).gsub("\n", '').chars.to_a
          end

          def convert_command
            winrm.powershell <<-POWERSHELL
              $base64_string = Get-Content \"#{base64_file_name}\"
              $bytes  = [System.Convert]::FromBase64String($base64_string)
              $new_file = [System.IO.Path]::GetFullPath(\"#{command_file_name}\")
              [System.IO.File]::WriteAllBytes($new_file,$bytes)
            POWERSHELL
          end

          def unique_string
            @unique_string ||= "#{Process.pid}-#{Time.now.to_i}"
          end

          # @return [String]
          def get_file_path(file)
            (winrm.run_cmd("echo %TEMP%\\#{file}"))[:data][0][:stdout].chomp
          end
      end
    end
  end
end
