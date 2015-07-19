require "spec_helper"

module MinitestToRspec
  RSpec.describe Processor do
    let(:processor) { described_class.new(false, true) }

    describe "#process_call" do
      let(:delegate) { Subprocessors::Call }

      it "delegates" do
        input = s(:call)
        allow(delegate).to receive(:new).and_call_original
        processor.process(input)
        expect(delegate).to have_received(:new).with(input, false, true)
      end
    end

    describe "#process_class" do
      let(:delegate) { Subprocessors::Klass }

      it "delegates" do
        input = s(:class, :Banana)
        allow(delegate).to receive(:new).and_call_original
        processor.process(input)
        expect(delegate).to have_received(:new).with(input, false, true)
      end
    end

    describe "#process_iter" do
      let(:delegate) { Subprocessors::Iter }

      it "delegates" do
        input = s(:iter)
        allow(delegate).to receive(:new).and_call_original
        processor.process(input)
        expect(delegate).to have_received(:new).with(input, false, true)
      end
    end
  end
end
