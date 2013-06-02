require 'spec_helper'

describe Chozo::CleanRoom do
  describe "ClassMethods" do
    subject do
      Class.new do
        include Chozo::CleanRoom

        attribute 'one'
      end
    end

    describe "::clean_room" do
      it "returns an anonymous class" do
        subject.clean_room.class.should eql(Class)
      end

      it "has a superlcass of CleanRoomBase" do
        subject.clean_room.superclass.should eql(Chozo::CleanRoomBase)
      end
    end

    describe "::from_ruby_file" do
      let(:file) { tmp_path.join('rspec').to_s }

      before(:each) do
        File.open(file, 'w+') do |f|
          f.write <<-TXT
            one 'value'
          TXT
        end
      end

      it "returns self" do
        result = subject.from_ruby_file(file)
        result.should be_a(subject)
      end
    end

    describe "::from_json_file" do
      pending
    end
  end

  subject do
    Class.new do
      include Chozo::CleanRoom

      attribute 'one', type: String
      attribute 'two.three'
    end.new
  end

  describe "#clean_eval" do
    it "evaluates a string" do
      string = <<-RB
        one 'value'
      RB

      subject.clean_eval(string)
      subject.one.should eql("value")
    end

    it "evaluates a block" do
      subject.clean_eval do
        one 'value'
      end

      subject.one.should eql("value")
    end

    it "evaluates a proc" do
      code = proc {
        one "value"
      }

      subject.clean_eval(code)
    end

    it "responds to a message for each class attribute" do
      subject.class.attributes.each do |message, _|
        subject.should respond_to(message.to_sym)
      end
    end

    context "strict clean room: false" do
      subject do
        Class.new do
          include Chozo::CleanRoom
          noisy_clean_room(false)
        end.new
      end

      it "doesn't raise an error if an unknown attribute is accessed" do
        subject.clean_eval do
          one 'hello'
          three 'asdf'
        end
      end
    end

    context "strict clean room: true" do
      subject do
        Class.new do
          include Chozo::CleanRoom
          noisy_clean_room(true)
        end.new
      end

      it "raises NoMethodError if an unknown attribute is accessed" do
        expect {
          subject.clean_eval do
            one 'hello'
          end
        }.to raise_error(NoMethodError)
      end
    end
  end
end
