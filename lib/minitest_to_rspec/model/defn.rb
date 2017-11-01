require_relative "base"

module MinitestToRspec
  module Model
    # Data object.  Represents a `:defn` s-expression.
    class Defn < Base
      def initialize(exp)
        assert_sexp_type(:defn, exp)
        @exp = exp.dup
        @original = exp.dup
      end

      def body
        @exp[3..-1]
      end

      def method_name
        @exp[1].to_s
      end
    end
  end
end
