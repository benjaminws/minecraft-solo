require 'spec_helper'

describe Hash do
  describe "ClassMethods" do
    subject { Hash }

    describe "::from_dotted_path" do
      it "returns a new Hash" do
        subject.from_dotted_path("deep.nested.item").should be_a(Hash)
      end

      it "returns a hash containing the nested keys" do
        obj = subject.from_dotted_path("deep.nested.item")

        obj.should have_key("deep")
        obj["deep"].should have_key("nested")
        obj["deep"]["nested"].should have_key("item")
      end

      it "sets a nil value for the deepest nested item" do
        obj = subject.from_dotted_path("deep.nested.item")

        obj["deep"]["nested"]["item"].should be_nil
      end

      it "handles a symbol as the dotted path" do
        obj = subject.from_dotted_path(:"a.b.c", "value")
        
        obj["a"]["b"]["c"].should == "value"
      end

      context "when given a seed value" do
        it "sets the value of the deepest nested item to the seed" do
          obj = subject.from_dotted_path("deep.nested.item", "seeded_value")

          obj["deep"]["nested"]["item"].should eql("seeded_value")
        end
      end
    end
  end

  subject { Hash.new }

  describe "#dig" do
    context "when the Hash contains the nested path" do
      subject do
        {
          "we" => {
            "found" => {
              "something" => true
            }
          }
        }
      end

      it "returns the value at the dotted path" do
        subject.dig("we.found.something").should eql(true)
      end
    end

    context "when the Hash does not contain the nested path" do
      it "returns a nil value" do
        subject.dig("nothing.is.here").should be_nil
      end
    end

    context "when the Hash contains symbols for keys" do
      subject do
        {
          we: {
            found: {
              something: :symbol_value
            }
          }
        }
      end

      it "returns the value at the dotted path" do
        subject.dig("we.found.something").should eql(:symbol_value)
      end
    end

    it "returns nil if given a blank string" do
      subject.dig("").should be_nil
    end

    it "returns 'false' nested values as 'false' and not 'nil'" do
      hash = {
        "ssl" => {
          "verify" => false
        }
      }
      
      hash.dig('ssl.verify').should eql(false)
    end
  end

  describe "#dotted_paths" do
    it "returns an array" do
      subject.dotted_paths.should be_a(Array)
    end

    context "given a hash with only top level keys" do
      subject do
        {
          "one" => "val",
          "two" => "val"
        }
      end

      it "returns an array of the top level keys as strings" do
        subject.dotted_paths.should eql(["one", "two"])
      end
    end

    context "given a hash with empty hashes as values" do
      subject do
        {
          "one" => Hash.new,
          "two" => Hash.new
        }
      end

      it "returns an array of the top level keys as strings" do
        subject.dotted_paths.should eql(["one", "two"])
      end
    end

    context "given a hash with nested keys" do
      subject do
        {
          "one" => {
            "nested" => {
              "attribute" => "hello"
            }
          },
          "two" => {
            "nested" => {
              "attribute" => "other_hello",
              "other_attr" => "world"
            }
          }
        }
      end

      it "returns an array of dotted paths including the nested Hash keys" do
        subject.dotted_paths.should eql(["one.nested.attribute", "two.nested.attribute", "two.nested.other_attr"])
      end
    end
  end
end
