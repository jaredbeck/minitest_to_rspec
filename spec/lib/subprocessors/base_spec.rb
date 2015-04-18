require "spec_helper"

module MinitestToRspec
  module Subprocessors
    RSpec.describe Base do
      describe "#assert_sexp_type" do
        def assert_sexp_type(type, exp)
          described_class.assert_sexp_type(type, exp)
        end

        def expect_type_error(message)
          expect { yield }.to raise_error(TypeError, message)
        end

        context "nil" do
          it "raises TypeError" do
            expect_type_error("Expected derp s-expression, got nil") {
              assert_sexp_type(:derp, nil)
            }
          end
        end

        context "wrong sexp_type" do
          it "raises TypeError, inspects sexp" do
            expect_type_error("Expected foo s-expression, got s(:bar)") {
              assert_sexp_type(:foo, s(:bar))
            }
          end
        end
      end
    end
  end
end
