require 'spec_helper'

describe Chozo::Mixin::FromFile do
  describe "ClassMethods" do
    let(:file) { double('file') }
    let(:args) { double('args') }

    subject do
      Class.new do
        include Chozo::Mixin::FromFile
      end
    end

    describe "::from_file" do
      it "initializes a new class and delegates to #from_file" do
        instance = double('instance')
        subject.should_receive(:new).with(args).and_return(instance)
        instance.should_receive(:from_file).with(file)

        subject.from_file(file, args)
      end
    end

    describe "::class_from_file" do
      it "initializes a new class and delegates to #class_from_file" do
        instance = double('instance')
        subject.should_receive(:new).with(args).and_return(instance)
        instance.should_receive(:class_from_file).with(file)

        subject.class_from_file(file, args)
      end
    end
  end

  subject do
    Class.new do
      include Chozo::Mixin::FromFile
    end.new
  end

  describe "#from_file" do
    let(:file) { tmp_path.join('rspec-test').to_s }

    before(:each) do
      File.open(file, 'w+') do |f|
        f.write <<-CODE
          def hello
            1+1
          end
        CODE
      end
    end

    it "evaluates the contents of the file in a new instance of the including class" do
      subject.from_file(file).should respond_to(:hello)
    end

    it "returns a new instance of the including class" do
      subject.from_file(file).should be_a(subject.class)
    end

    it "it raises IOError if the file cannot be read" do
      expect {
        subject.from_file("/doesnot/exist")
      }.to raise_error(IOError)
    end
  end

  describe "#class_from_file" do
    it "it raises IOError if the file cannot be read" do
      expect {
        subject.class_from_file("/doesnot/exist")
      }.to raise_error(IOError)
    end
  end
end
