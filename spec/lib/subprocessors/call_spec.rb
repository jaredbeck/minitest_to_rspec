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

        def parse(ruby)
          RubyParser.new.parse(ruby)
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
          expect(
            process(parse("assert Banana.new.delicious?"))
          ).to eq(
            parse("expect(Banana.new.delicious?).to be_truthy")
          )
        end

        it "replaces `refute` with `expect` to be falsey" do
          expect(
            process(parse("refute Kiwi.new.delicious?"))
          ).to eq(
            parse("expect(Kiwi.new.delicious?).to be_falsey")
          )
        end

        it "replaces assert_equal with expect to eq" do
          expect(
            process(parse("assert_equal false, Kiwi.new.delicious?"))
          ).to eq(
            parse("expect(Kiwi.new.delicious?).to eq(false)")
          )
        end

        it "replaces refute_equal with expect to_not eq" do
          expect(
            process(parse("refute_equal(true, Kiwi.new.delicious?)"))
          ).to eq(
            parse("expect(Kiwi.new.delicious?).to_not eq(true)")
          )
        end
      end
    end
  end
end
