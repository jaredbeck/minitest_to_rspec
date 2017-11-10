# frozen_string_literal: true

require_relative 'base'

module MinitestToRspec
  module Model
    # Data object.  Represents a `:defn` s-expression.
    class Defn < Base
      def initialize(exp)
        assert_sexp_type(:defn, exp)
        @exp = exp.dup
      end

      def body
        @exp[3..-1]
      end

      def method_name
        @exp[1].to_s
      end

      def test_method?
        method_name.start_with?('test_')
      end
    end
  end
end
