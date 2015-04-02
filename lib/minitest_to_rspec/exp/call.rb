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

      class << self
        def assert_difference?(exp)
          exp.sexp_type == :call && new(exp).assert_difference?
        end

        def assert_no_difference?(exp)
          exp.sexp_type == :call && new(exp).assert_no_difference?
        end
      end

      def arguments
        @exp[3..-1]
      end

      def argument_types
        arguments.map(&:sexp_type)
      end

      def assert_difference?
        return false unless method_name == :assert_difference
        [[:str], [:str, :lit]].include?(argument_types)
      end

      def assert_no_difference?
        method_name == :assert_no_difference &&
          arguments.length == 1 &&
          arguments[0].sexp_type == :str
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

      private

      def string?(exp)
        exp.sexp_type == :str
      end
    end
  end
end
