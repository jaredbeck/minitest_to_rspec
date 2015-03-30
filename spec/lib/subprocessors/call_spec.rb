require "spec_helper"
require "ruby_parser"

module MinitestToRspec
  module Subprocessors
    RSpec.describe Call do
      describe ".process" do

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

        it "replaces `assert` with `expect` to be truthy" do
          input = s(:call, nil, :assert,
            s(:call, s(:call, s(:const, :Banana), :new), :delicious?)
          )
          expected_ruby = "expect(Banana.new.delicious?).to be_truthy"
          exp = RubyParser.new.parse(expected_ruby)
          expect(process(input)).to eq(exp)
        end
      end
    end
  end
end
