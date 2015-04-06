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

        def process(input, rails_helper = false)
          described_class.process(input, rails_helper)
        end

        context "rails_helper is false" do
          it "replaces test_helper with spec_helper" do
            input = exp(:require, "test_helper")
            expect(process(input, false)).to eq(exp(:require, "spec_helper"))
          end
        end

        context "rails_helper is true" do
          it "replaces test_helper with rails_helper" do
            input = exp(:require, "test_helper")
            expect(process(input, true)).to eq(exp(:require, "rails_helper"))
          end
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

        it "replaces assert_match with expect to match" do
          expect(
            process(parse('assert_match(/nana\Z/, "banana")'))
          ).to eq(
            parse('expect("banana").to match(/nana\Z/)')
          )
        end

        it "replaces assert_nil with expect to be_nil" do
          expect(
            process(parse('assert_nil(kiwi)'))
          ).to eq(
            parse('expect(kiwi).to(be_nil)')
          )
        end

        it "does not change factory call" do
          input = -> {
            s(:call,
              nil,
              :create,
              s(:lit, :banana),
              s(:hash,
                s(:lit, :peel),
                s(:call, nil, :peel),
                s(:lit, :color),
                s(:str, "yellow"),
                s(:lit, :delicious),
                s(:true)
              )
            )
          }
          expect(process(input.call)).to eq(input.call)
        end

        it "replaces stubs/returns with expect to receive" do
          expect(
            process(parse("Banana.stubs(:delicious?).returns(true)"))
          ).to eq(
            parse("allow(Banana).to receive(:delicious?).and_return(true)")
          )
        end

        it "does not replace every method named 'returns'" do
          # In this example, `returns` does not represent a mocha stub.
          input = -> { parse("Banana.returns(peel)") }
          expect(process(input.call)).to eq(input.call)
        end

        it "replaces stub with double" do
          skip "Not yet implemented"
          expect(
            process(parse("stub(:delicious? => true)"))
          ).to eq(
            parse('double("Untitled", :delicious? => true)')
          )
        end

        context "stub_everything" do
          it "replaces with double as_null_object" do
            skip "Not yet implemented"
            expect(
              process(parse("stub_everything"))
            ).to eq(
              parse('double("Untitled").as_null_object')
            )
          end

          context "with specific allowed methods" do
            it "replaces with double as_null_object" do
              skip "Not yet implemented"
              expect(
                process(parse("stub_everything(:delicious? => false)"))
              ).to eq(
                parse('double("Untitled", :delicious? => false).as_null_object')
              )
            end
          end
        end
      end
    end
  end
end
