require 'spec_helper'

describe Chozo::RubyEngine do
  subject { Chozo::RubyEngine }

  describe "::jruby?" do
    it "returns true if RUBY_ENGINE equals 'jruby'" do
      stub_const("RUBY_ENGINE", "jruby")

      subject.should be_jruby
    end

    it "returns false if RUBY_ENGINE does not equal 'jruby'" do
      stub_const("RUBY_ENGINE", "ruby")

      subject.should_not be_jruby
    end
  end

  describe "::mri?" do
    it "returns true if RUBY_ENGINE equals 'ruby'" do
      stub_const("RUBY_ENGINE", "ruby")

      subject.should be_mri
    end

    it "returns false if RUBY_ENGINE does not equal 'ruby'" do
      stub_const("RUBY_ENGINE", "jruby")

      subject.should_not be_mri
    end
  end

  describe "::rubinius?" do
    it "returns true if RUBY_ENGINE equals 'rbx'" do
      stub_const("RUBY_ENGINE", "rbx")

      subject.should be_rubinius
    end

    it "returns false if RUBY_ENGINE does not equal 'rbx'" do
      stub_const("RUBY_ENGINE", "jruby")

      subject.should_not be_rubinius
    end
  end
end
