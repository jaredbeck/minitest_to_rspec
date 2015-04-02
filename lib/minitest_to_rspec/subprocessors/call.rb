require_relative "../exp/call"
require_relative "base"

module MinitestToRspec
  module Subprocessors
    class Call < Base

      ASSERTIONS = %i[
        assert
        assert_equal
        assert_match
        assert_nil
        refute
        refute_equal
      ]

      class << self
        def process(sexp)
          exp = Exp::Call.new(sexp)
          sexp.clear
          process_exp(exp)
        end

        private

        def assertion?(exp)
          ASSERTIONS.include?(exp.method_name)
        end

        def be_falsey
          matcher(:be_falsey)
        end

        def be_nil
          matcher(:be_nil)
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

        # Takes `exp`, the argument to an `assert` or `refute`. In RSpec
        # `expect(exp)` is called an "expectation target". The combination of
        # target and matcher returned by this method is called an "expectation".
        def expect_to(matcher, exp)
          s(:call, expectation_target(exp), :to, matcher)
        end

        def expect_to_not(matcher, exp)
          s(:call, expectation_target(exp), :to_not, matcher)
        end

        def match(pattern)
          matcher(:match, pattern)
        end

        def matcher(name, *args)
          exp = s(:call, nil, name)
          exp.concat(args)
        end

        def method_assert(exp)
          expect_to(be_truthy, exp.arguments[0])
        end

        def method_assert_equal(exp)
          expected = exp.arguments[0]
          calculated = exp.arguments[1]
          expect_to(eq(expected), calculated)
        end

        def method_assert_match(exp)
          pattern = exp.arguments[0]
          string = exp.arguments[1]
          expect_to(match(pattern), string)
        end

        def method_assert_nil(exp)
          expect_to(be_nil, exp.arguments[0])
        end

        def method_refute(exp)
          expect_to(be_falsey, exp.arguments[0])
        end

        def method_refute_equal(exp)
          unexpected = exp.arguments[0]
          calculated = exp.arguments[1]
          expect_to_not(eq(unexpected), calculated)
        end

        def method_test(exp)
          s(:call, nil, :it, *exp.arguments)
        end

        def processable?(exp)
          exp.method_name == :test || assertion?(exp)
        end

        # Given a `Exp::Call`, returns a `Sexp`
        def process_exp(exp)
          if exp.require_test_helper?
            require_spec_helper
          elsif processable?(exp)
            process_method(exp)
          else
            exp.original
          end
        end

        def process_method(exp)
          send("method_#{exp.method_name}".to_sym, exp)
        end

        def require_spec_helper
          s(:call, nil, :require, s(:str, "spec_helper"))
        end
      end
    end
  end
end
