module MinitestToRspec
  module Exp

    # Data object.  Represents a `:call` s-expression.
    class Call

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
  end
end
