require_relative "base"

module MinitestToRspec
  module Exp

    # Data object.  Represents a `:call` s-expression.
    class Call < Base
      attr_reader :original

      def initialize(exp)
        assert_sexp_type(:call, exp)
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

        def assert_nothing_raised?(exp)
          exp.sexp_type == :call && new(exp).assert_nothing_raised?
        end

        def assert_raise?(exp)
          exp.sexp_type == :call && new(exp).assert_raise?
        end

        def assert_raises?(exp)
          exp.sexp_type == :call && new(exp).assert_raises?
        end

        def method_name?(exp, name)
          exp.sexp_type == :call && new(exp).method_name == name
        end
      end

      def arguments
        @exp[3..-1] || []
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

      def assert_nothing_raised?
        method_name == :assert_nothing_raised && arguments.empty?
      end

      def assert_raise?
        method_name == :assert_raise && raise_error_args?
      end

      def assert_raises?
        method_name == :assert_raises && raise_error_args?
      end

      def method_name
        @exp[2]
      end

      def num_arguments
        arguments.length
      end

      def one_string_argument?
        arguments.length == 1 && string?(arguments[0])
      end

      # Returns true if arguments can be processed into RSpec's `raise_error`
      # matcher.  When the last argument is a string, it represents the
      # assertion failure message, which will be discarded later.
      def raise_error_args?
        arg_types = arguments.map(&:sexp_type)
        [[], [:str], [:const], [:const, :str]].include?(arg_types)
      end

      def receiver
        @exp[1]
      end

      # While `#receiver` returns a `Sexp`, `#receiver_call`
      # returns a `Exp::Call`.
      def receiver_call
        if sexp_type?(:call, receiver)
          rvc = Exp::Call.new(receiver)

          # TODO: Seems like a factory pattern
          if rvc.method_name == :returns
            Exp::Calls::Returns.new(receiver)
          else
            rvc
          end
        else
          raise TypeError
        end
      end

      def require_test_helper?
        method_name == :require &&
          one_string_argument? &&
          arguments[0][1] == "test_helper"
      end

      def question_mark_method?
        method_name.to_s.end_with?("?")
      end

      private

      def string?(exp)
        exp.sexp_type == :str
      end
    end
  end
end
