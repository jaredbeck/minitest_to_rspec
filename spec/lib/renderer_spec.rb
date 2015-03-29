require "spec_helper"

module MinitestToRspec
  RSpec.describe Renderer do
    describe "#process_call" do
      let(:buffer) { StringIO.new }
      let(:input) { s(:call, nil, :require, s(:str, "spec_helper")) }
      let(:subrenderer) { Subrenderers::Call }

      it "delegates" do
        allow(subrenderer).to receive(:process).and_call_original
        described_class.new(buffer).process(input)
        expect(subrenderer).to have_received(:process).with(input, buffer)
      end
    end
  end
end
