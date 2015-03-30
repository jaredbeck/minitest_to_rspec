require "spec_helper"

module MinitestToRspec
  module Subrenderers
    RSpec.describe Call do
      let(:out) { StringIO.new }

      # Returns an S-expression representing a method call.
      def exp(method_name, argument)
        s(:call, nil, method_name.to_sym, s(:str, argument.to_s))
      end

      def process(input)
        described_class.process(input, out)
      end

      describe ".process" do
        it "renders call with zero arguments" do
          input = s(:call, nil, :banana?)
          process(input)
          expect(out.string).to eq("banana?")
        end

        it "can render trivial call with one string argument" do
          input = exp(:require, "spec_helper")
          process(input)
          expect(out.string).to eq('require("spec_helper")')
        end

        it "can render nested trivial calls" do
          input = s(:call, nil, :banana,
            s(:call, nil, :kiwi,
              s(:str, "grapefruit")
            )
          )
          process(input)
          expect(out.string).to eq('banana(kiwi("grapefruit"))')
        end
      end
    end
  end
end
