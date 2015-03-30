require "spec_helper"

module MinitestToRspec
  module Subprocessors
    RSpec.describe Class do
      describe ".process" do

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
            s(:colon2, s(:const, :ActiveSupport), :TestCase),
            s(:iter,
              s(:call, nil, :test, s(:str, "is delicious")),
              s(:args),
              s(:call, nil, :assert,
                s(:call, s(:call, s(:const, :Banana), :new), :delicious?)
              )
            )
          )
          iter = process(input)
          expect(iter.sexp_type).to eq(:iter)
          expect(iter.length).to eq(4) # type, call, args, iter
          call = iter[1]
          expect(call.sexp_type).to eq(:call)
          expect(call.length).to eq(4) # type, receiver, name, argument
          expect(call[1]).to eq(s(:const, :RSpec))
          expect(call[2]).to eq(:describe)
          expect(call[3]).to eq(s(:const, :Banana))
        end
      end
    end
  end
end
