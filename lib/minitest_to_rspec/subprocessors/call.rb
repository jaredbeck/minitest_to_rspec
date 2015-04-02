module MinitestToRspec
  module Subprocessors

    # Processes `:call` s-expressions
    class Call

      # Represents a `:call` s-expression
      class Exp

        ASSERTIONS = %i[
          assert
          assert_equal
          refute
          refute_equal
        ]

        attr_reader :original

        def initialize(exp)
          raise ArgumentError unless exp.sexp_type == :call
          @exp = exp.dup
          @original = exp.dup
        end

        def arguments
          @exp[3..-1]
        end

        def assertion?
          ASSERTIONS.include?(method_name)
        end

        def method_name
          @exp[2]
        end

        def one_string_argument?
          arguments.length == 1 && string?(arguments[0])
        end

        def require_test_helper?
          method_name == :require &&
            one_string_argument? &&
            arguments[0][1] == "test_helper"
        end

        def receiver
          @exp[1]
        end

        private

        def string?(exp)
          exp.sexp_type == :str
        end
      end

      class << self
        def process(sexp)
          exp = Exp.new(sexp)
          sexp.clear
          if exp.require_test_helper?
            require_spec_helper
          elsif exp.method_name == :test
            method_test(exp)
          elsif exp.assertion?
            assertion(exp)
          else
            exp.original
          end
        end

        private

        def assertion(exp)
          send("method_#{exp.method_name}".to_sym, exp.arguments.dup)
        end

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

        # Takes `exp`, the argument to an `assert` or `refute`. In RSpec
        # `expect(exp)` is called an "expectation target". The combination of
        # target and matcher returned by this method is called an "expectation".
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

        def method_test(exp)
          s(:call, nil, :it, *exp.arguments)
        end

        def require_spec_helper
          s(:call, nil, :require, s(:str, "spec_helper"))
        end
      end
    end
  end
end
