require 'spec_helper'

shared_examples_for "Chozo::Config" do |resource_klass|
  subject { resource_klass.new }
end
