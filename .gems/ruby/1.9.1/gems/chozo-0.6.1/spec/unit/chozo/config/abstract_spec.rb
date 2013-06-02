require 'spec_helper'

describe Chozo::Config::Abstract do
  subject { Class.new(described_class).new }

  describe "#to_hash" do
    it "returns a Hash" do
      subject.to_hash.should be_a(Hash)
    end

    it "contains all of the attributes" do
      subject.set_attribute(:something, "value")
      
      subject.to_hash.should have_key(:something)
      subject.to_hash[:something].should eql("value")
    end
  end

  describe "#slice" do
    before(:each) do
      subject.set_attribute(:one, nested: "value")
      subject.set_attribute(:two, nested: "other")
      @sliced = subject.slice(:one)
    end

    it "returns a Hash" do
      @sliced.should be_a(Hash)
    end

    it "contains just the sliced elements" do
      @sliced.should have(1).item
    end
  end
end
