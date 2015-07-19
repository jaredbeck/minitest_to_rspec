require "spec_helper"

module MinitestToRspec
  module Subprocessors
    RSpec.describe Base do
      let(:subprocessor) { described_class.new(false, false) }

      describe "#allow_to" do
        let(:msg_recipient) { double }
        let(:matcher) { double }

        it "returns a call expression" do
          exp = subprocessor.allow_to(msg_recipient, matcher)
          expect(exp).to eq(
            s(:call,
              s(:call, nil, :allow, msg_recipient),
              :to,
              matcher
            )
          )
        end
      end
    end
  end
end
