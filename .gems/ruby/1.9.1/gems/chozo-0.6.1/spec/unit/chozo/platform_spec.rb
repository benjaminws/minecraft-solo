require 'spec_helper'

describe Chozo::Platform do
  subject { Chozo::Platform }

  before(:each) do
    @original = RbConfig::CONFIG['host_os']
  end

  after(:each) do
    RbConfig::CONFIG['host_os'] = @original
  end

  describe "::windows?" do
    it "returns true when 'host_os' config matches mswin" do
      RbConfig::CONFIG['host_os'] = 'mswin'

      subject.should be_windows
    end

    it "returns true when 'host_os' config matches mingw" do
      RbConfig::CONFIG['host_os'] = 'mingw'

      subject.should be_windows
    end

    it "returns true when 'host_os' config matches cygwin" do
      RbConfig::CONFIG['host_os'] = 'cygwin'

      subject.should be_windows
    end

    it "returns false when 'host_os' config does not match windows" do
      RbConfig::CONFIG['host_os'] = 'darwin11.3.0'

      subject.should_not be_windows
    end
  end

  describe "::osx?" do
    it "returns false when 'host_os' config does not match darwin" do
      RbConfig::CONFIG['host_os'] = 'mingw'

      subject.should_not be_osx
    end

    it "returns true when 'host_os' config matches darwin" do
      RbConfig::CONFIG['host_os'] = 'darwin'

      subject.should be_osx
    end
  end

  describe "::linux?" do
    it "returns false when 'host_os' config does not match linux" do
      RbConfig::CONFIG['host_os'] = 'mingw'

      subject.should_not be_linux
    end

    it "returns true when 'host_os' config matches linux" do
      RbConfig::CONFIG['host_os'] = 'linux'

      subject.should be_linux
    end
  end
end
