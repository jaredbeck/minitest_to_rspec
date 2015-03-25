require "spec_helper"

module MinitestToRspec
  RSpec.describe Processor do
    let(:processor) { described_class.new }
    describe "#process_call" do
      it "replaces test_helper with spec_helper" do
        input = s(:call, nil, :require, s(:str, "test_helper"))
        expect(processor.process(input)).to eq(
          s(:call, nil, :require, s(:str, "spec_helper"))
        )
      end

      it "replaces test with it" do
        input = s(:call, nil, :test, s(:str, "is delicious"))
        expect(processor.process(input)).to eq(
          s(:call, nil, :it, s(:str, "is delicious"))
        )
      end
    end
  end
end
