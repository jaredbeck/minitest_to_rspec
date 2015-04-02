module MinitestToRspec
  module Exp
    RSpec.describe Call do
      describe ".new" do
        context "sexp_type is not :call" do
          it "raises ArgumentError" do
            expect {
              described_class.new(s(:str, "derp"))
            }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
