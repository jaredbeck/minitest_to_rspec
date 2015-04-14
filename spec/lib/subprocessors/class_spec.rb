require "spec_helper"
require "ruby_parser"

module MinitestToRspec
  module Subprocessors
    RSpec.describe Class do
      describe ".process" do

        def parse(str)
          RubyParser.new.parse(str)
        end

        def process(exp)
          described_class.process(exp)
        end

        context "unexpected class expression" do
          it "raises ProcessingError" do
            expect {
              process(s(:class, "Derp", nil))
            }.to raise_error(ProcessingError)
          end
        end

        context "input class is not test case" do
          it "does not convert empty class" do
            input = -> { s(:class, :Derp, nil) }
            expect(process(input.call)).to eq(input.call)
          end

          it "does not convert trivial class" do
            # Actually, we wrap the one call in a block, but it
            # still prints the same.
            expect(process(
              s(:class, :Derp, nil, s(:call, nil, :puts))
            )).to eq(
              s(:class, :Derp, nil, s(:block, s(:call, nil, :puts)))
            )
          end
        end

        it "converts an ActiveSupport::TestCase" do
          input = s(:class,
            :BananaTest,
            s(:colon2, s(:const, :ActiveSupport), :TestCase)
          )
          iter = process(input)
          expect(iter.sexp_type).to eq(:iter)
          expect(iter.length).to eq(3) # type, call, args
          call = iter[1]
          expect(call).to eq(parse("RSpec.describe(Banana)"))
        end

        it "converts a class with more than just a single test" do
          expect(process(parse(
            <<-EOS
              class BananaTest < ActiveSupport::TestCase
                include Monkeys
                fend_off_the_monkeys
                peel_bananas
                test "is delicious" do
                  assert Banana.new.delicious?
                end
              end
            EOS
          ))).to eq(parse(
            <<-EOS
              RSpec.describe(Banana) do
                include Monkeys
                fend_off_the_monkeys
                peel_bananas
                it "is delicious" do
                  expect(Banana.new.delicious?).to be_truthy
                end
              end
            EOS
          ))
        end

        context "class definition with module shorthand" do
          it "converts a class with module shorthand" do
            expect {
              process(
                s(:class,
                  s(:colon2, s(:const, :Fruit), :BananaTest),
                  nil
                )
              )
            }.to raise_error(ModuleShorthandError,
              /Please convert your class definition to use nested modules/
            )
          end
        end
      end
    end
  end
end
