require "spec_helper"

module MinitestToRspec
  module Subrenderers
    RSpec.describe Call do
      let(:out) { StringIO.new }

      # Returns an S-expression representing a method call.
      def exp(method_name, argument)
        s(:call, nil, method_name.to_sym, s(:str, argument.to_s))
      end

      describe "#process" do
        it "can render trivial call with one string argument" do
          input = exp(:require, "spec_helper")
          described_class.process(input, out)
          expect(out.string).to eq('require("spec_helper")')
        end

        it "can render nested trivial calls" do
          input = s(:call, nil, :banana,
            s(:call, nil, :kiwi,
              s(:str, "grapefruit")
            )
          )
          described_class.process(input, out)
          expect(out.string).to eq('banana(kiwi("grapefruit"))')
        end
      end
    end
  end
end
