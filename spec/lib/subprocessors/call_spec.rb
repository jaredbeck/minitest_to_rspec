require "spec_helper"

module MinitestToRspec
  module Subprocessors
    RSpec.describe Call do
      describe "#process_call" do

        # Returns an S-expression representing a method call.
        def exp(method_name, argument)
          s(:call, nil, method_name.to_sym, s(:str, argument.to_s))
        end

        def process(input)
          described_class.process(input)
        end

        it "replaces `test_helper` with `spec_helper`" do
          input = exp(:require, "test_helper")
          expect(process(input)).to eq(exp(:require, "spec_helper"))
        end

        it "replaces `test` with `it`" do
          argument = "is delicious"
          input = exp(:test, argument)
          expect(process(input)).to eq(exp(:it, argument))
        end
      end
    end
  end
end
