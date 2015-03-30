require "spec_helper"

module MinitestToRspec
  module Subrenderers
    RSpec.describe Const do
      let(:out) { StringIO.new }

      describe ".process" do
        it "renders the constant" do
          described_class.process(s(:const, :BananaTest), out)
          expect(out.string).to eq("BananaTest")
        end
      end
    end
  end
end
