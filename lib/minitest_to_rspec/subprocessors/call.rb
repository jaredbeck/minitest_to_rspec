module MinitestToRspec
  module Subprocessors

    # Examples of s(:call)
    # --------------------
    #
    # The following input examples
    #
    #     [:call, nil, :require, [:str, "test_helper"]]
    #     [:call, nil, :test, [:str, "is delicious"]]
    #
    # are processed into
    #
    #     [:call, nil, :require, [:str, "spec_helper"]]
    #     [:call, nil, :it, [:str, "is delicious"]]
    #
    class Call
      class << self
        def process(exp)
          orig = exp.dup
          raise ArgumentError unless exp.shift == :call
          receiver = exp.shift
          method_name = exp.shift
          result = process_by_method_name(exp, method_name, orig, receiver)
          exp.clear
          result
        end

        private

        def expectation_target(exp)
          s(:call, nil, :expect, exp)
        end

        # Takes `exp`, the argument to an `assert` or `refute`.
        # In RSpec `expect(exp)` is called an expectation target.
        # Returns an expression representing an expectation like
        # `expect(exp).to be_falsey`.
        def expect_to(matcher_name, exp)
          matcher = s(:call, nil, matcher_name)
          s(:call, expectation_target(exp), :to, matcher)
        end

        def method_assert(exp)
          expect_to(:be_truthy, exp.shift)
        end

        def method_refute(exp)
          expect_to(:be_falsey, exp.shift)
        end

        def method_require(exp, orig, receiver)
          if test_helper?(exp)
            s(:call, receiver, :require, s(:str, "spec_helper"))
          else
            orig
          end
        end

        def method_test(exp, receiver)
          if exp.length == 1 && string?(exp[0])
            s(:call, receiver, :it, *exp)
          end
        end

        def process_by_method_name(exp, method_name, orig, receiver)
          case method_name
          when :assert
            method_assert(exp)
          when :test
            method_test(exp, receiver)
          when :refute
            method_refute(exp)
          when :require
            method_require(exp, orig, receiver)
          else
            orig
          end
        end

        def string?(exp)
          exp.sexp_type == :str
        end

        def test_helper?(exp)
          exp.length == 1 &&
            string?(exp[0]) &&
            exp[0][1] == "test_helper"
        end
      end
    end
  end
end
