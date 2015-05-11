require "spec_helper"
require "ruby_parser"

module MinitestToRspec
  module Subprocessors
    RSpec.describe Klass do
      describe "#process" do

        def parse(str)
          RubyParser.new.parse(str)
        end

        def process(exp, rails = false)
          described_class.new(exp, rails).process
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

        it "converts a Draper::TestCase" do
          input = parse("class BananaDecoratorTest < Draper::TestCase; end")
          expect(process(input, true)).to eq(parse(
            "RSpec.describe(BananaDecorator, type: :decorator) do; end"
          ))
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
          it "raises ModuleShorthandError" do
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

        context "class that inherits from ActionController::TestCase" do
          it "converts to describe with :type => :controller" do
            inp = <<-EOS
              class BananasControllerTest < ActionController::TestCase
              end
            EOS
            expect(process(parse(inp), true)).to eq(parse(
              <<-EOS
                RSpec.describe(BananasController, :type => :controller) do
                end
              EOS
            ))
          end
        end

        context "class that inherits from ActiveSupport::TestCase" do
          it "converts to describe with :type => :model" do
            inp = <<-EOS
              class BananaTest < ActiveSupport::TestCase
              end
            EOS
            expect(process(parse(inp), true)).to eq(parse(
              <<-EOS
                RSpec.describe(Banana, :type => :model) do
                end
              EOS
            ))
          end
        end
      end
    end
  end
end
