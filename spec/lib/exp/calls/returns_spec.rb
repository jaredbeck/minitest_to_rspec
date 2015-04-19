module MinitestToRspec
  module Exp
    module Calls
      RSpec.describe Returns do
        describe "#rspec_mocks_method" do
          context "unknown variant" do
            let(:exp) { RubyParser.new.parse("tax.returns") }

            it "raises error" do
              expect {
                described_class.new(exp).rspec_mocks_method
              }.to raise_error(ProcessingError)
            end
          end
        end
      end
    end
  end
end
