module MinitestToRspec
  module Exp

    # Data object.  Represents a `:call` s-expression.
    class Call
      attr_reader :original

      def initialize(exp)
        unless exp.sexp_type == :call
          raise ArgumentError, "Expected call, got #{exp.sexp_type}"
        end
        @exp = exp.dup
        @original = exp.dup
      end

      def arguments
        @exp[3..-1]
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
