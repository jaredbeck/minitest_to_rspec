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

        context "input class is not test case" do
          it "does not convert empty class" do
            input = ->{ s(:class, :Derp, nil) }
            expect(process(input.call)).to eq(input.call)
          end

          it "does not convert trivial class" do
            input = ->{ s(:class, :Derp, nil, s(:call, nil, :puts)) }
            expect(process(input.call)).to eq(input.call)
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
