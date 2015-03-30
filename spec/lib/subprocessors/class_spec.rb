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
          expect(process(input)).to eq(
            s(:iter,
              s(:call, s(:const, :RSpec), :describe, s(:const, :BananaTest)),
              s(:args),
              s(:iter,
                s(:call, nil, :it, s(:str, "is delicious")),
                s(:args),
                s(:call, nil, :assert,
                  s(:call, s(:call, s(:const, :Banana), :new), :delicious?)
                )
              )
            )
          )
        end
      end
    end
  end
end
