# frozen_string_literal: true

require "spec_helper"
require "ruby_parser"

module MinitestToRspec
  module Subprocessors
    RSpec.describe Call do
      # Returns an S-expression representing a method call.
      def exp(method_name, argument)
        s(:call, nil, method_name.to_sym, s(:str, argument.to_s))
      end

      def parse(ruby)
        RubyParser.new.parse(ruby)
      end

      def process(input, rails = false, mocha = true)
        described_class.new(input, rails, mocha).process
      end

      context "assert" do
        it "replaces `assert` with `expect` to be_truthy" do
          expect(
            process(parse("assert Banana"))
          ).to eq(
            parse("expect(Banana).to be_truthy")
          )
        end

        it "replaces question-mark `assert` with `expect` to eq(true)" do
          expect(
            process(parse("assert Banana.delicious?"))
          ).to eq(
            parse("expect(Banana.delicious?).to eq(true)")
          )
        end
      end

      context "assert_equal" do
        it "replaces assert_equal (two args) with expect to eq" do
          expect(
            process(parse("assert_equal false, Kiwi.new.delicious?"))
          ).to eq(
            parse("expect(Kiwi.new.delicious?).to eq(false)")
          )
        end

        it "replaces assert_equal (three args) with expect to eq" do
          expect(
            process(parse("assert_equal false, Kiwi.new.delicious?, 'asdf'"))
          ).to eq(
            parse("expect(Kiwi.new.delicious?).to eq(false)")
          )
        end
      end

      context "assert_match" do
        it "replaces assert_match with expect to match" do
          expect(
            process(parse('assert_match(/nana\Z/, "banana")'))
          ).to eq(
            parse('expect("banana").to match(/nana\Z/)')
          )
        end
      end

      context "assert_nil" do
        it "replaces assert_nil with expect to be_nil" do
          expect(
            process(parse('assert_nil(kiwi)'))
          ).to eq(
            parse('expect(kiwi).to(be_nil)')
          )
        end
      end

      context "assert_not_equal" do
        it "replaces assert_not_equal (two args) with expect to_not eq" do
          expect(
            process(parse("assert_not_equal(:banana, :kiwi)"))
          ).to eq(
            parse("expect(:kiwi).to_not eq(:banana)")
          )
        end

        it "replaces assert_not_equal (three args) with expect to_not eq" do
          expect(
            process(parse("assert_not_equal(:banana, :kiwi, 'asdf')"))
          ).to eq(
            parse("expect(:kiwi).to_not eq(:banana)")
          )
        end
      end

      context "create" do
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
      end

      context "expects" do
        it "converts single expects to receive" do
          expect(
            process(parse("Banana.expects(:delicious?).returns(true)"))
          ).to eq(
            parse("expect(Banana).to receive(:delicious?).and_return(true)")
          )
        end

        it "converts single expects with call receiver, to receive" do
          expect(
            process(parse("a_b.expects(:c?).returns(:d)"))
          ).to eq(
            parse("expect(a_b).to receive(:c?).and_return(:d)")
          )
        end

        it "converts hash-expects to many receives" do
          expect(process(parse(
            'Banana.expects(edible: true, color: "yellow")'
          ))).to eq(parse(
            <<-EOS
              lambda {
                "Sorry for the pointless lambda here."
                expect(Banana).to(receive(:edible).and_return(true))
                expect(Banana).to(receive(:color).and_return("yellow"))
              }.call
            EOS
          ))
        end

        it "converts expects without return" do
          expect(
            process(parse("Banana.expects(:delicious?)"))
          ).to eq(
            parse("expect(Banana).to receive(:delicious?).and_call_original")
          )
        end

        context "variants which should not be converted" do
          it "does not replace non-mocha returns" do
            input = -> { parse("tax.returns") }
            expect(process(input.call)).to eq(input.call)
          end

          it "does not replace expects with arity > 1" do
            input = -> { parse("tax.expects(:arm, :leg)") }
            expect(process(input.call)).to eq(input.call)
          end

          it "does not replace expects with unknown argument type" do
            input = -> { parse("foo.expects(a_call_exp)") }
            expect(process(input.call)).to eq(input.call)
          end
        end
      end

      context "once" do
        it "replaces once with expect to receive once" do
          expect(
            process(parse("a.expects(:b).once"))
          ).to eq(
            parse("expect(a).to receive(:b).and_call_original.once")
          )
        end
      end

      context "refute" do
        it "replaces `refute` with `expect` to be_falsey" do
          expect(
            process(parse("refute Kiwi"))
          ).to eq(
            parse("expect(Kiwi).to be_falsey")
          )
        end

        it "replaces question-mark `refute` with `expect` to be falsey" do
          expect(
            process(parse("refute Kiwi.delicious?"))
          ).to eq(
              parse("expect(Kiwi.delicious?).to eq(false)")
          )
        end
      end

      context "refute_equal" do
        it "replaces refute_equal with expect to_not eq" do
          expect(
            process(parse("refute_equal(true, Kiwi.new.delicious?)"))
          ).to eq(
            parse("expect(Kiwi.new.delicious?).to_not eq(true)")
          )
        end
      end

      context "returns" do
        it "replaces stubs/returns with expect to receive" do
          expect(
            process(parse("Banana.stubs(:delicious?).returns(true)"))
          ).to eq(
            parse("allow(Banana).to receive(:delicious?).and_return(true)")
          )
        end

        it "converts any_instance.expects" do
          expect(
            process(parse("Banana.any_instance.stubs(:delicious?).returns(true)"))
          ).to eq(
            parse("allow_any_instance_of(Banana).to receive(:delicious?).and_return(true)")
          )
        end

        it "converts any_instance.stubs" do
          expect(
            process(parse("Banana.any_instance.expects(:delicious?).returns(true)"))
          ).to eq(
            parse("expect_any_instance_of(Banana).to receive(:delicious?).and_return(true)")
          )
        end

        it "does not replace every method named 'returns'" do
          # In this example, `returns` does not represent a mocha stub.
          input = -> { parse("Banana.returns(peel)") }
          expect(process(input.call)).to eq(input.call)
        end
      end

      context "require" do
        it "does not replace unknown requires" do
          input = -> { parse("require 'a_shrubbery'") }
          expect(process(input.call)).to eq(input.call)
        end

        context "rails option is false" do
          it "replaces test_helper with spec_helper" do
            input = exp(:require, "test_helper")
            expect(process(input, false)).to eq(exp(:require, "spec_helper"))
          end
        end

        context "rails option is true" do
          it "replaces test_helper with rails_helper" do
            input = exp(:require, "test_helper")
            expect(process(input, true)).to eq(exp(:require, "rails_helper"))
          end
        end
      end

      context "stub" do
        it "replaces stub with double" do
          expect(process(parse("stub"))).to eq(parse('double'))
        end

        it "replaces stub(hash) with double" do
          expect(
            process(parse("stub(:delicious? => true)"))
          ).to eq(
            parse('double(:delicious? => true)')
          )
        end

        it "does not replace explicit receiver stub" do
          input = -> { parse("pencil.stub") }
          expect(process(input.call)).to eq(input.call)
        end
      end

      context "stub_everything" do
        it "replaces with double as_null_object" do
          expect(
            process(parse("stub_everything"))
          ).to eq(
            parse('double.as_null_object')
          )
        end

        context "with explicit receiver" do
          it "does not replace" do
            input = -> { parse("pencil.stub_everything") }
            expect(process(input.call)).to eq(input.call)
          end
        end

        context "with specific allowed methods" do
          it "replaces with double as_null_object" do
            expect(
              process(parse("stub_everything(:delicious? => false)"))
            ).to eq(
              parse('double(:delicious? => false).as_null_object')
            )
          end
        end
      end

      context "test" do
        it "replaces `test` with `it`" do
          argument = "is delicious"
          input = exp(:test, argument)
          expect(process(input)).to eq(exp(:it, argument))
        end
      end

      context "twice" do
        it "replaces twice with expect to receive twice" do
          expect(
            process(parse("a.expects(:b).twice"))
          ).to eq(
            parse("expect(a).to receive(:b).and_call_original.twice")
          )
        end
      end
    end
  end
end
