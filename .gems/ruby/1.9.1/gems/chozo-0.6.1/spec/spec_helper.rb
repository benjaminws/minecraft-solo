require 'rubygems'
require 'bundler'
require 'chozo/core_ext'

def setup_rspec
  require 'rspec'
  require 'json_spec'

  Dir[File.join(File.expand_path("../../spec/support/**/*.rb", __FILE__))].each { |f| require f }

  RSpec.configure do |config|
    config.include JsonSpec::Helpers
    config.include Chozo::Spec::Helpers

    config.mock_with :rspec
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run focus: true
    config.run_all_when_everything_filtered = true

    config.before(:each) do
      clean_tmp_path
    end
  end
end

if mri? && ENV['CI'] != 'true'
  require 'spork'

  Spork.prefork do
    setup_rspec
  end

  Spork.each_run do
    require 'chozo'

    Dir["#{Chozo.app_root}/lib/chozo/core_ext/**/*.rb"].each do |ext|
      load(ext)
    end
  end
else
  require 'chozo'
  setup_rspec
end
