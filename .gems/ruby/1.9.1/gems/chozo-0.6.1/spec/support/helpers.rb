require 'pathname'

module Chozo
  module Spec
    module Helpers
      def app_root_path
        Pathname.new(File.expand_path('../../../', __FILE__))
      end

      def tmp_path
        app_root_path.join('spec/tmp')
      end

      def clean_tmp_path
        FileUtils.rm_rf(tmp_path)
        FileUtils.mkdir_p(tmp_path)
      end
    end
  end
end
