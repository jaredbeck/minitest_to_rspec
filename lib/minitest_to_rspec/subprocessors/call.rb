module MinitestToRspec
  module Subprocessors
    class Call

      ASSERTIONS = %i[
        assert
        assert_equal
        refute
        refute_equal
      ]

      class << self
        def process(exp)
          orig = exp.dup
          raise ArgumentError unless exp.shift == :call
          receiver = exp.shift
          method_name = exp.shift
          result = case method_name
          when :test
            method_test(exp, receiver)
          when :require
            method_require(exp, orig, receiver)
          when *ASSERTIONS
            assertion(exp, method_name)
          else
            orig
          end
          exp.clear
          result
        end

        def assertion(exp, method_name)
          send("method_#{method_name}".to_sym, exp)
        end

        private

        def be_falsey
          matcher(:be_falsey)
        end

        def be_truthy
          matcher(:be_truthy)
        end

        def eq(exp)
          matcher(:eq, exp)
        end

        def expectation_target(exp)
          s(:call, nil, :expect, exp)
        end

        # Takes `exp`, the argument to an `assert` or `refute`.
        # In RSpec `expect(exp)` is called an expectation target.
        # Returns an expression representing an expectation like
        # `expect(exp).to be_falsey`.
        def expect_to(matcher, exp)
          s(:call, expectation_target(exp), :to, matcher)
        end

        def expect_to_not(matcher, exp)
          s(:call, expectation_target(exp), :to_not, matcher)
        end

        def matcher(name, *args)
          exp = s(:call, nil, name)
          exp.concat(args)
        end

        def method_assert(exp)
          expect_to(be_truthy, exp.shift)
        end

        def method_assert_equal(exp)
          expected = exp.shift
          calculated = exp.shift
          expect_to(eq(expected), calculated)
        end

        def method_refute(exp)
          expect_to(be_falsey, exp.shift)
        end

        def method_refute_equal(exp)
          unexpected = exp.shift
          calculated = exp.shift
          expect_to_not(eq(unexpected), calculated)
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
