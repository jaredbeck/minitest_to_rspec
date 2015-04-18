module MinitestToRspec
  module Exp
    RSpec.describe Call do
      describe ".new" do
        context "sexp_type is not :call" do
          it "raises TypeError" do
            expect {
              described_class.new(s(:str, "derp"))
            }.to raise_error(TypeError)
          end
        end
      end
    end
  end
end
