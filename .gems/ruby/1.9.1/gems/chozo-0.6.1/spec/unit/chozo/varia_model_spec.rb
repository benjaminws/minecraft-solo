require 'spec_helper'

describe Chozo::VariaModel do
  describe "ClassMethods" do
    subject do
      Class.new do
        include Chozo::VariaModel
      end
    end

    describe "::attributes" do
      it "returns a Hashie::Mash" do
        subject.attributes.should be_a(Hashie::Mash)
      end

      it "is empty by default" do
        subject.attributes.should be_empty
      end
    end

    describe "::attribute" do
      it "adds an attribute to the attributes hash for each attribute function call" do
        subject.attribute 'jamie.winsor'
        subject.attribute 'brooke.winsor'

        subject.attributes.should have(2).items
      end

      it "adds a validation if :required option is true" do
        subject.attribute 'brooke.winsor', required: true

        subject.validations.should have(1).item
      end

      it "adds a validation if the :type option is provided" do
        subject.attribute 'brooke.winsor', type: :string

        subject.validations.should have(1).item
      end

      it "sets a default value if :default option is provided" do
        subject.attribute 'brooke.winsor', default: 'rhode island'

        subject.attributes.dig('brooke.winsor').should eql('rhode island')
      end

      it "allows an attribute called 'attributes'" do
        subject.attribute 'attributes', default: 'bag of junk'

        subject.attributes.dig('attributes').should eql('bag of junk')
      end

      it "allows an attribute called 'attribute'" do
        subject.attribute 'attribute', default: 'some value'

        subject.attributes.dig('attribute').should eql('some value')
      end
    end

    describe "::validations" do
      it "returns a Hashie::Mash" do
        subject.validations.should be_a(Hashie::Mash)
      end

      it "is empty by default" do
        subject.validations.should be_empty
      end
    end

    describe "::validations_for" do
      context "when an attribute is registered and has validations" do
        before(:each) do
          subject.attribute("nested.attribute", required: true, type: String)
        end

        it "returns an array of procs" do
          validations = subject.validations_for("nested.attribute")

          validations.should be_a(Array)
          validations.should each be_a(Proc)
        end
      end

      context "when an attribute is registered but has no validations" do
        before(:each) do
          subject.attribute("nested.attribute")
        end

        it "returns an empty array" do
          validations = subject.validations_for("nested.attribute")

          validations.should be_a(Array)
          validations.should be_empty
        end
      end

      context "when an attribute is not registered" do
        it "returns an empty array" do
          validations = subject.validations_for("not_existing.attribute")

          validations.should be_a(Array)
          validations.should be_empty
        end
      end

      describe "#assignment_mode" do
        it "returns the default assignment mode :whitelist" do
          subject.assignment_mode.should eql(:whitelist)
        end
      end

      describe "#set_assignment_mode" do
        it "sets the assignment_mode to whitelist" do
          subject.set_assignment_mode(:whitelist)

          subject.assignment_mode.should eql(:whitelist)
        end

        it "sets the assignment_mode to carefree" do
          subject.set_assignment_mode(:carefree)

          subject.assignment_mode.should eql(:carefree)
        end

        it "raises if given an invalid assignment mode" do
          expect {
            subject.set_assignment_mode(:not_a_real_mode)
          }.to raise_error(ArgumentError)
        end
      end
    end

    describe "::validate_kind_of" do
      let(:types) do
        [
          String,
          Boolean
        ]
      end

      let(:key) do
        'nested.one'
      end

      subject do
        Class.new do
          include Chozo::VariaModel

          attribute 'nested.one', types: [String, Boolean]
        end
      end

      let(:model) do
        subject.new
      end

      it "returns an array" do
        subject.validate_kind_of(types, model, key).should be_a(Array)
      end

      context "failure" do
        before(:each) do
          model.nested.one = nil
        end

        it "returns an array where the first element is ':error'" do
          subject.validate_kind_of(types, model, key).first.should eql(:error)
        end

        it "returns an array where the second element is an error message containing the attribute and types" do
          types.each do |type|
            subject.validate_kind_of(types, model, key)[1].should =~ /#{type}/
          end
          subject.validate_kind_of(types, model, key)[1].should =~ /#{key}/
        end
      end

      context "success" do
        before(:each) do
          model.nested.one = true
        end

        it "returns an array where the first element is ':ok'" do
          subject.validate_kind_of(types, model, key).first.should eql(:ok)
        end

        it "returns an array where the second element is a blank string" do
          subject.validate_kind_of(types, model, key)[1].should be_blank
        end
      end

      context "when given two types of the same kind" do
        let(:types) do
          [
            String,
            String
          ]
        end

        let(:key) do
          'nested.one'
        end

        subject do
          Class.new do
            include Chozo::VariaModel

            attribute 'nested.one', types: [String, Boolean]
          end
        end

        let(:model) do
          subject.new
        end

        before(:each) do
          model.nested.one = nil
        end

        it "returns a error message that contains the type error only once" do
          subject.validate_kind_of(types, model, key)[1].should eql("Expected attribute: 'nested.one' to be a type of: 'String'")
        end
      end
    end

    describe "::validate_required" do
      let(:key) do
        'nested.one'
      end

      subject do
        Class.new do
          include Chozo::VariaModel

          attribute 'nested.one', required: true
        end
      end

      let(:model) do
        subject.new
      end

      it "returns an array" do
        subject.validate_required(model, key).should be_a(Array)
      end

      it "fails validation if the value of the attribute is nil" do
        model.set_attribute(key, nil)
        
        subject.validate_required(model, key).first.should eql(:error)
      end

      it "passes validation if the value of the attribute is false" do
        model.set_attribute(key, false)

        subject.validate_required(model, key).first.should eql(:ok)
      end

      it "passes validation if the value of the attribute is not nil" do
        model.set_attribute(key, 'some_value')

        subject.validate_required(model, key).first.should eql(:ok)
      end

      context "failure" do
        before(:each) do
          model.nested.one = nil
        end

        it "returns an array where the first element is ':error'" do
          subject.validate_required(model, key).first.should eql(:error)
        end

        it "returns an array where the second element is an error message containing the attribute name" do
          subject.validate_required(model, key)[1].should =~ /#{key}/
        end
      end

      context "success" do
        before(:each) do
          model.nested.one = "hello"
        end

        it "returns an array where the first element is ':ok'" do
          subject.validate_required(model, key).first.should eql(:ok)
        end

        it "returns an array where the second element is a blank string" do
          subject.validate_required(model, key)[1].should be_blank
        end
      end
    end
  end

  subject do
    Class.new do
      include Chozo::VariaModel

      attribute 'nested.not_coerced', default: 'hello'
      attribute 'nested.no_default'
      attribute 'nested.coerced', coerce: lambda { |m| m.to_s }
      attribute 'toplevel', default: 'hello'
      attribute 'no_default'
      attribute 'coerced', coerce: lambda { |m| m.to_s }
    end.new
  end

  describe "GeneratedAccessors" do
    describe "nested getter" do
      it "returns the default value" do
        subject.nested.not_coerced.should eql('hello')
      end

      it "returns nil if there is no default value" do
        subject.nested.no_default.should be_nil
      end
    end

    describe "toplevel getter" do
      it "returns the default value" do
        subject.toplevel.should eql('hello')
      end

      it "returns nil if there is no default value" do
        subject.no_default.should be_nil
      end
    end

    describe "nested setter" do
      it "sets the value of the nested attribute" do
        subject.nested.not_coerced = 'world'

        subject.nested.not_coerced.should eql('world')
      end
    end

    describe "toplevel setter" do
      it "sets the value of the top level attribute" do
        subject.toplevel = 'world'

        subject.toplevel.should eql('world')
      end
    end

    describe "nested coerced setter" do
      it "sets the value of the nested coerced attribute" do
        subject.nested.coerced = 1

        subject.nested.coerced.should eql("1")
      end
    end

    describe "toplevel coerced setter" do
      it "sets the value of the top level coerced attribute" do
        subject.coerced = 1

        subject.coerced.should eql('1')
      end
    end

    context "given two nested attributes with a common parent and default values" do
      subject do
        Class.new do
          include Chozo::VariaModel

          attribute 'nested.one', default: 'val_one'
          attribute 'nested.two', default: 'val_two'
        end.new
      end

      it "sets a default value for each nested attribute" do
        subject.nested.one.should eql('val_one')
        subject.nested.two.should eql('val_two')
      end
    end

    context "given two nested attributes with a common parent and coercions" do
      subject do
        Class.new do
          include Chozo::VariaModel

          attribute 'nested.one', coerce: lambda { |m| m.to_s }
          attribute 'nested.two', coerce: lambda { |m| m.to_s }
        end.new
      end

      it "coerces each value if both have a coercion" do
        subject.nested.one = 1
        subject.nested.two = 2

        subject.nested.one.should eql("1")
        subject.nested.two.should eql("2")
      end
    end

    context "given an attribute called 'attributes'" do
      subject do
        Class.new do
          include Chozo::VariaModel

          attribute 'attributes', default: Hash.new
        end.new
      end

      it "allows the setting and getting of the 'attributes' mimic methods" do
        subject.attributes.should be_a(Hash)
        subject.attributes.should be_empty

        new_hash = { something: "here" }
        subject.attributes = new_hash
        subject.attributes[:something].should eql("here")
      end
    end
  end

  describe "Validations" do
    describe "validate required" do
      subject do
        Class.new do
          include Chozo::VariaModel

          attribute 'brooke.winsor', required: true
        end.new
      end

      it "is not valid if it fails validation" do
        subject.should_not be_valid
      end

      it "adds an error for each attribute that fails validations" do
        subject.validate

        subject.errors.should have(1).item
      end

      it "adds a message for each failed validation" do
        subject.validate

        subject.errors['brooke.winsor'].should have(1).item
        subject.errors['brooke.winsor'][0].should eql("A value is required for attribute: 'brooke.winsor'")
      end
    end

    describe "validate type" do
      subject do
        Class.new do
          include Chozo::VariaModel

          attribute 'brooke.winsor', type: String
        end.new
      end

      before(:each) do
        subject.brooke.winsor = false
      end

      it "returns false if it fails validation" do
        subject.should_not be_valid
      end

      it "adds an error if it fails validation" do
        subject.validate

        subject.errors.should have(1).item
        subject.errors['brooke.winsor'].should have(1).item
        subject.errors['brooke.winsor'][0].should eql("Expected attribute: 'brooke.winsor' to be a type of: 'String', 'NilClass'")
      end
    end
  end

  describe "#set_attribute" do
    subject do
      Class.new do
        include Chozo::VariaModel

        attribute 'brooke.winsor', type: String, default: 'sister'
        attribute 'brooke.costantini', type: String, default: 'sister'
      end.new
    end

    it "sets the value of the given attribute" do
      subject.set_attribute('brooke.winsor', 'rhode island')

      subject.brooke.winsor.should eql('rhode island')
    end

    it "does not disturb the other attributes" do
      subject.set_attribute('brooke.winsor', 'rhode island')

      subject.brooke.costantini.should eql('sister')
    end
  end

  describe "#get_attribute" do
    subject do
      Class.new do
        include Chozo::VariaModel

        attribute 'brooke.winsor', type: String, default: 'sister'
      end.new
    end

    it "returns the value of the given dotted path" do
      subject.get_attribute('brooke.winsor').should eql('sister')
    end

    it "returns nil if the dotted path matches no attributes" do
      subject.get_attribute('brooke.costantini').should be_nil
    end
  end

  describe "#mass_assign" do
    subject do
      Class.new do
        include Chozo::VariaModel

        attribute 'brooke.winsor', type: String, default: 'sister'
        attribute 'jamie.winsor', type: String, default: 'brother'
        attribute 'gizmo', type: String, default: 'dog'
      end.new
    end

    it "sets the values of all matching defined attributes" do
      new_attrs = {
        brooke: {
          winsor: "other"
        },
        jamie: {
          winsor: "other_two"
        }
      }

      subject.mass_assign(new_attrs)
      subject.brooke.winsor.should eql("other")
      subject.jamie.winsor.should eql("other_two")
    end

    it "leaves the values of untouched attributes" do
      new_attrs = {
        brooke: {
          winsor: "other"
        },
        jamie: {
          winsor: "other_two"
        }
      }

      subject.mass_assign(new_attrs)
      subject.gizmo.should eql("dog")
    end

    it "ignores values which are not defined attributes" do
      new_attrs = {
        undefined_attribute: "value"
      }

      subject.mass_assign(new_attrs)
      subject.get_attribute(:undefined_attribute).should be_nil
      subject.should_not respond_to(:undefined_attribute)
    end

    context "when in carefree assignment mode" do
      subject do
        Class.new do
          include Chozo::VariaModel

          set_assignment_mode :carefree
        end.new
      end

      it "does not ignore values which are not defined" do
        new_attrs = {
          undefined_attribute: "value"
        }

        subject.mass_assign(new_attrs)
        subject.get_attribute(:undefined_attribute).should eql("value")
      end
    end
  end

  describe "#from_json" do
    subject do
      Class.new do
        include Chozo::VariaModel

        attribute 'first_name', type: String
        attribute 'nick', type: String
      end.new
    end

    it "returns self" do
      subject.from_json(MultiJson.encode(first_name: "jamie", nick: "reset")).should be_a(described_class)
    end

    it "updates self from JSON data" do
      subject.from_json(MultiJson.encode(first_name: "jamie", nick: "reset"))

      subject.first_name.should eql("jamie")
      subject.nick.should eql("reset")
    end
  end

  describe "#from_hash" do
    subject do
      Class.new do
        include Chozo::VariaModel

        attribute 'first_name', type: String
        attribute 'nick', type: String
      end.new
    end

    it "returns self" do
      subject.from_hash(first_name: "jamie", nick: "reset").should be_a(described_class)
    end

    it "updates and returns self from a Hash" do
      subject.from_hash(first_name: "jamie", nick: "reset")

      subject.first_name.should eql("jamie")
      subject.nick.should eql("reset")
    end
  end

  describe "#to_json" do
    subject do
      Class.new do
        include Chozo::VariaModel

        attribute 'first_name', type: String
        attribute 'nick', type: String
      end.new
    end

    it "returns a JSON string containin the serialized attributes" do
      subject.first_name = "brooke"
      subject.nick = "leblanc"

      subject.to_json.should eql(MultiJson.encode(first_name: "brooke", nick: "leblanc"))
    end
  end

  describe "#to_hash" do
    it "returns all of the varia dattributes" do
      subject.to_hash.should eql(subject.send(:_attributes_))
    end
  end
end
